# ============================================================================
# M-LIGHT Path D — Step 2A: FinnGen H7_MYOPIA Full MR for 5 anchors
#
# Goal: 5-anchor × FinnGen myopia (true independent replication)
#       Layer 2 evidence: ancestry-independent (Finland vs UK)
#
# Source: OpenGWAS 'finn-b-H7_MYOPIA' (FinnGen R5/R6 myopia diagnosis)
# Phenotype: Binary (myopia diagnosed = 1)
# Effect scale: log OR per SD increase in cis-eQTL exposure
#
# Output:
#   pathy/Stage2_Assets/PathD_FinnGen_5anchor_MR.csv
#   + paste-ready R code for Figure 2 (Panel C or as designated)
# ============================================================================

# --- Setup -------------------------------------------------------------------
options(stringsAsFactors = FALSE)
required_pkgs <- c("TwoSampleMR", "ieugwasr", "dplyr", "data.table")
missing_pkgs <- required_pkgs[!sapply(required_pkgs, requireNamespace,
                                       quietly = TRUE)]
if (length(missing_pkgs) > 0) {
  cat("Missing packages:", paste(missing_pkgs, collapse = ", "), "\n")
  cat("Install via:\n")
  cat("  remotes::install_github('MRCIEU/TwoSampleMR')\n")
  cat("  remotes::install_github('MRCIEU/ieugwasr')\n")
  stop("Please install missing packages first.")
}
suppressPackageStartupMessages({
  library(TwoSampleMR)
  library(ieugwasr)
  library(dplyr)
  library(data.table)
})

# --- Config ------------------------------------------------------------------
PROJECT_ROOT <- "C:/Projectbulid/Myopia"
OUT_DIR <- file.path(PROJECT_ROOT, "pathy/Stage2_Assets")
dir.create(OUT_DIR, recursive = TRUE, showWarnings = FALSE)
OUT_CSV <- file.path(OUT_DIR, "PathD_FinnGen_5anchor_MR.csv")

FINNGEN_ID <- "finn-b-H7_MYOPIA"

cat("====================================================\n")
cat("Path D Step 2A: FinnGen Full MR for 5 anchors\n")
cat("Outcome:", FINNGEN_ID, "\n")
cat("====================================================\n\n")

# --- FinnGen outcome metadata -----------------------------------------------
cat("--- FinnGen outcome metadata ---\n")
finngen_info <- tryCatch(gwasinfo(FINNGEN_ID), error = function(e) NULL)
if (!is.null(finngen_info)) {
  print(t(as.data.frame(finngen_info)))
} else {
  cat("Could not fetch metadata. Proceeding anyway.\n")
}
cat("\n")

# --- 5 anchors --------------------------------------------------------------
anchors <- data.frame(
  gene    = c("RDH5", "CD55", "TGFB1", "CTNNB1", "FBN1"),
  tier    = c("A", "A", "B", "B", "B"),
  eqtl_id = c("eqtl-a-ENSG00000135437",   # RDH5
              "eqtl-a-ENSG00000196352",   # CD55
              "eqtl-a-ENSG00000105329",   # TGFB1
              "eqtl-a-ENSG00000168036",   # CTNNB1
              "eqtl-a-ENSG00000166147"),  # FBN1
  expected_n = c(2, 5, 1, 3, 1)
)

# --- Run MR per anchor ------------------------------------------------------
cat("--- Running MR for each anchor ---\n")
all_results <- list()

for (i in seq_len(nrow(anchors))) {
  gene  <- anchors$gene[i]
  e_id  <- anchors$eqtl_id[i]
  n_exp <- anchors$expected_n[i]

  cat(sprintf("\n[%s] eqtl_id = %s\n", gene, e_id))

  # 1. Fetch instruments
  cat("  Step 1/4: Fetching instruments ... ")
  exp_dat <- tryCatch({
    extract_instruments(outcomes = e_id, p1 = 5e-8,
                        clump = TRUE, r2 = 0.001, kb = 10000)
  }, error = function(e) {
    cat("\n    P<5e-8 failed, trying P<5e-6...\n  Step 1/4: ")
    tryCatch(extract_instruments(outcomes = e_id, p1 = 5e-6,
                                 clump = TRUE, r2 = 0.001, kb = 10000),
             error = function(e2) NULL)
  })

  if (is.null(exp_dat) || nrow(exp_dat) == 0) {
    cat("FAILED\n")
    next
  }
  exp_dat$exposure <- gene
  cat(sprintf("OK (%d SNPs)\n", nrow(exp_dat)))

  # 2. Fetch outcome
  cat("  Step 2/4: Fetching FinnGen outcome ... ")
  outcome_dat <- tryCatch({
    extract_outcome_data(snps = exp_dat$SNP, outcomes = FINNGEN_ID)
  }, error = function(e) NULL)

  if (is.null(outcome_dat) || nrow(outcome_dat) == 0) {
    cat("FAILED (no SNPs in FinnGen)\n")
    next
  }
  cat(sprintf("OK (%d/%d SNPs)\n", nrow(outcome_dat), nrow(exp_dat)))

  missing <- setdiff(exp_dat$SNP, outcome_dat$SNP)
  if (length(missing) > 0) {
    cat("    Missing in FinnGen:", paste(missing, collapse = ", "), "\n")
    cat("    (Consider LD proxies if critical)\n")
  }

  # 3. Harmonise
  cat("  Step 3/4: Harmonising ... ")
  dat <- harmonise_data(exp_dat, outcome_dat, action = 2)
  n_keep <- sum(dat$mr_keep)
  cat(sprintf("OK (%d SNPs kept)\n", n_keep))
  if (n_keep == 0) next

  # 4. MR
  cat("  Step 4/4: MR analysis ... ")
  method <- if (n_keep == 1) "mr_wald_ratio" else "mr_ivw"
  res <- mr(dat, method_list = method)
  if (nrow(res) == 0) {
    cat("FAILED\n")
    next
  }

  ci_lo <- res$b - 1.96 * res$se
  ci_hi <- res$b + 1.96 * res$se
  or_est <- exp(res$b)
  or_lo  <- exp(ci_lo)
  or_hi  <- exp(ci_hi)

  cat("OK\n")
  cat(sprintf("  RESULT: log(OR) = %+.4f (%+.4f, %+.4f)\n",
              res$b, ci_lo, ci_hi))
  cat(sprintf("          OR     = %.3f (%.3f, %.3f)\n",
              or_est, or_lo, or_hi))
  cat(sprintf("          SE = %.4f, P = %.2e, method = %s, n_SNP = %d\n",
              res$se, res$pval, res$method, res$nsnp))

  all_results[[gene]] <- data.frame(
    gene = gene, outcome = "FinnGen_H7_MYOPIA", n_snp = res$nsnp,
    log_OR = res$b, se = res$se,
    log_OR_ci_lo = ci_lo, log_OR_ci_hi = ci_hi,
    OR = or_est, OR_ci_lo = or_lo, OR_ci_hi = or_hi,
    pval = res$pval, method = res$method
  )
}

# --- Save + summary --------------------------------------------------------
cat("\n\n====================================================\n")
cat("FinnGen 5-anchor MR — Summary\n")
cat("====================================================\n\n")

if (length(all_results) > 0) {
  final <- do.call(rbind, all_results)
  print(final[, c("gene", "n_snp", "log_OR", "log_OR_ci_lo", "log_OR_ci_hi",
                  "OR", "OR_ci_lo", "OR_ci_hi", "pval")])
  fwrite(final, OUT_CSV)
  cat("\nSaved:", OUT_CSV, "\n")
} else {
  stop("No MR results computed. Check OpenGWAS connectivity.")
}

# --- Direction consistency check vs UKB Discovery --------------------------
cat("\n--- Direction consistency vs UKB Discovery ---\n")
ukb_discovery <- list(
  RDH5   = +0.00888,
  CD55   = -0.00284,
  TGFB1  = -0.02710,
  CTNNB1 = -0.00552,
  FBN1   = +0.00747
)

cat("Note: UKB outcome is continuous Spherical Equivalent (positive = less myopic)\n")
cat("      FinnGen outcome is binary Myopia (positive log OR = more myopic risk)\n")
cat("      \u2192 Expected DIRECTIONAL FLIP: UKB \u2295 \u21D4 FinnGen \u2296 (or vice versa)\n\n")

for (gene in names(ukb_discovery)) {
  if (!is.null(all_results[[gene]])) {
    ukb_b <- ukb_discovery[[gene]]
    fg_b  <- all_results[[gene]]$log_OR
    fg_p  <- all_results[[gene]]$pval

    expected_sign <- -sign(ukb_b)  # flip expected
    actual_sign   <- sign(fg_b)
    consistent <- (expected_sign == actual_sign)

    cat(sprintf("  %-7s UKB \u03b2=%+.4f \u2192 expected FinnGen sign: %s | actual: %+.4f (%s) [%s]\n",
                gene, ukb_b, ifelse(expected_sign > 0, "+", "-"),
                fg_b, ifelse(actual_sign > 0, "+", "-"),
                ifelse(consistent, "CONSISTENT", "DISCORDANT")))
  }
}

# --- Paste-ready for Figure 2 ----------------------------------------------
cat("\n\n========== PASTE INTO Figure 2 R code ==========\n\n")

gene_order <- c("RDH5", "CD55", "TGFB1", "CTNNB1", "FBN1")
nsnp_order <- c(2, 5, 1, 3, 1)

cat("# Panel C: FinnGen Myopia (true independent replication, binary outcome)\n")
cat("# Note: log_OR scale (different unit from UKB \u03b2 in Panel A)\n")
cat("finngen_data <- data.frame(\n")
cat("  gene  = c('RDH5', 'CD55', 'TGFB1', 'CTNNB1', 'FBN1'),\n")
cat("  tier  = c('A', 'A', 'B', 'B', 'B'),\n")

nsnps <- integer(5)
betas <- lowers <- uppers <- numeric(5)
pvals <- character(5)
for (j in seq_along(gene_order)) {
  g <- gene_order[j]
  if (!is.null(all_results[[g]])) {
    nsnps[j] <- all_results[[g]]$n_snp
    betas[j] <- all_results[[g]]$log_OR
    lowers[j] <- all_results[[g]]$log_OR_ci_lo
    uppers[j] <- all_results[[g]]$log_OR_ci_hi
    pvals[j] <- formatC(all_results[[g]]$pval, format = "e", digits = 1)
  } else {
    nsnps[j] <- NA; betas[j] <- NA; lowers[j] <- NA; uppers[j] <- NA
    pvals[j] <- "NA"
  }
}

cat("  nSNP  = c(", paste(nsnps, collapse = ", "), "),\n", sep = "")
cat("  beta  = c(", paste(sprintf("%+.5f", betas), collapse = ", "), "),  # log OR\n", sep = "")
cat("  lower = c(", paste(sprintf("%+.5f", lowers), collapse = ", "), "),\n", sep = "")
cat("  upper = c(", paste(sprintf("%+.5f", uppers), collapse = ", "), "),\n", sep = "")
cat("  pval  = c(", paste(sprintf("'%s'", pvals), collapse = ", "), "),\n", sep = "")
cat("  stringsAsFactors = FALSE\n)\n\n")

cat("=================================================\n")
cat("Done. Next:\n")
cat("  1. Review direction consistency (above)\n")
cat("  2. Track 2: Tedja 2018 supplementary download for Panel B\n")
cat("  3. Once both done \u2192 Figure 1 v19 + Figure 2 v2 final lock\n")
cat("=================================================\n")
