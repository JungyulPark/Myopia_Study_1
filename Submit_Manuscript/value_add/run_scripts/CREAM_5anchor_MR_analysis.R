# ============================================================================
# M-LIGHT — Path C v2: outcome cache-based MR analysis
#
# Fixes from v1:
#   1. data.frame syntax (cache is data.frame, NOT data.table)
#      → use cache[cache$SNP %in% ...] instead of cache[get(snp_col) %in% ...]
#   2. Honest outcome labeling
#      → Cache content is actually ukb-b-19994 "Spherical power (right)"
#         and ukb-b-19995 (likely) "Spherical power (left)"
#      → NOT Tedja 2018 CREAM consortium
#      → Output labels updated to reflect actual outcome
#
# Cache details (from Step 1 inspection):
#   outcome    : "Spherical power (right) || id:ukb-b-19994"
#   samplesize : 99,380
#   format     : TwoSampleMR 'outcome' object (data.frame)
#   columns    : SNP, chr, pos, beta.outcome, se.outcome, samplesize.outcome,
#                pval.outcome, eaf.outcome, effect_allele.outcome,
#                other_allele.outcome, outcome, id.outcome, ...
#
# Note: Despite the filename 'outcome_t2_cream*', this is UKB Spherical
#       power R/L (not Tedja 2018 CREAM consortium). User should verify
#       this matches Memory v1 "CREAM" lock values, or run separate Tedja
#       CREAM analysis if true CREAM is needed.
# ============================================================================

options(stringsAsFactors = FALSE)

required_pkgs <- c("TwoSampleMR", "ieugwasr", "dplyr", "data.table")
missing_pkgs <- required_pkgs[!sapply(required_pkgs, requireNamespace,
                                       quietly = TRUE)]
if (length(missing_pkgs) > 0) {
  stop("Missing packages: ", paste(missing_pkgs, collapse = ", "))
}

suppressPackageStartupMessages({
  library(TwoSampleMR)
  library(ieugwasr)
  library(dplyr)
  library(data.table)
})

# ============================================================================
# Config
# ============================================================================
PROJECT_ROOT <- "C:/Projectbulid/Myopia"
CACHE_R <- file.path(PROJECT_ROOT,
                    "CP6_assembly/data/tier2_progress/outcome_t2_creamR_chunk_001.rds")
CACHE_L <- file.path(PROJECT_ROOT,
                    "CP6_assembly/data/tier2_progress/outcome_t2_creamL_chunk_001.rds")

OUT_DIR <- file.path(PROJECT_ROOT, "pathy/Stage2_Assets")
dir.create(OUT_DIR, recursive = TRUE, showWarnings = FALSE)
OUT_CSV <- file.path(OUT_DIR, "Replication_5anchor_MR_for_Figure2.csv")

cat("===== M-LIGHT Figure 2 Replication MR Analysis (Path C v2) =====\n\n")

# ============================================================================
# Step 1: Load cache and inspect actual outcome
# ============================================================================
cat("===== Step 1: Loading cache + identifying outcome =====\n")
cream_r_cache <- readRDS(CACHE_R)
cream_l_cache <- readRDS(CACHE_L)

cat("\nR cache outcome ID:", unique(cream_r_cache$id.outcome), "\n")
cat("R cache outcome name:", unique(cream_r_cache$outcome), "\n")
cat("R cache sample size:", unique(cream_r_cache$samplesize.outcome), "\n")
cat("R cache n SNPs:", nrow(cream_r_cache), "\n\n")

cat("L cache outcome ID:", unique(cream_l_cache$id.outcome), "\n")
cat("L cache outcome name:", unique(cream_l_cache$outcome), "\n")
cat("L cache sample size:", unique(cream_l_cache$samplesize.outcome), "\n")
cat("L cache n SNPs:", nrow(cream_l_cache), "\n\n")

# ============================================================================
# Step 2: Fetch 5 anchor instruments
# ============================================================================
cat("===== Step 2: Fetching eQTL instruments =====\n")
anchors <- data.frame(
  gene    = c("RDH5", "CD55", "TGFB1", "CTNNB1", "FBN1"),
  tier    = c("A", "A", "B", "B", "B"),
  eqtl_id = c("eqtl-a-ENSG00000135437",
              "eqtl-a-ENSG00000196352",
              "eqtl-a-ENSG00000105329",
              "eqtl-a-ENSG00000168036",
              "eqtl-a-ENSG00000166147")
)

all_exposures <- list()
for (i in seq_len(nrow(anchors))) {
  gene <- anchors$gene[i]
  e_id <- anchors$eqtl_id[i]
  cat(sprintf("  [%s] eqtl_id = %s ... ", gene, e_id))

  exp_dat <- tryCatch({
    extract_instruments(outcomes = e_id, p1 = 5e-8,
                        clump = TRUE, r2 = 0.001, kb = 10000)
  }, error = function(e) {
    tryCatch(extract_instruments(outcomes = e_id, p1 = 5e-6,
                                 clump = TRUE, r2 = 0.001, kb = 10000),
             error = function(e2) NULL)
  })

  if (is.null(exp_dat) || nrow(exp_dat) == 0) {
    cat("FAILED\n")
    next
  }
  exp_dat$exposure <- gene
  cat(sprintf("%d SNPs\n", nrow(exp_dat)))
  all_exposures[[gene]] <- exp_dat
}

# ============================================================================
# Step 3: MR per anchor × eye (FIXED data.frame syntax)
# ============================================================================
cat("\n===== Step 3: MR analysis =====\n")

all_results <- list()
missing_snps_report <- list()

for (gene in names(all_exposures)) {
  exp_dat <- all_exposures[[gene]]
  exp_snps <- exp_dat$SNP

  for (eye in c("R", "L")) {
    cache <- if (eye == "R") cream_r_cache else cream_l_cache
    outcome_id <- unique(cache$id.outcome)[1]
    outcome_name <- unique(cache$outcome)[1]

    cat(sprintf("\n--- %s × %s eye (outcome: %s) ---\n",
                gene, eye, outcome_id))

    # FIX: Use data.frame syntax (NOT data.table syntax)
    cache_sub <- cache[cache$SNP %in% exp_snps, ]
    n_found <- nrow(cache_sub)
    cat(sprintf("  SNPs found: %d / %d\n", n_found, length(exp_snps)))

    if (n_found < length(exp_snps)) {
      missing <- setdiff(exp_snps, cache_sub$SNP)
      missing_snps_report[[paste(gene, eye, sep = "_")]] <- missing
      cat("  Missing:", paste(missing, collapse = ", "), "\n")
    }

    if (n_found == 0) {
      cat("  No overlap. Skip.\n")
      next
    }

    # Cache is already TwoSampleMR outcome format
    outcome_dat <- cache_sub
    outcome_dat$outcome <- paste0(outcome_id, "_", eye)
    outcome_dat$id.outcome <- paste0(outcome_id, "_", eye)

    # Harmonise
    dat <- harmonise_data(exp_dat, outcome_dat, action = 2)
    n_keep <- sum(dat$mr_keep)
    cat(sprintf("  After harmonise: %d SNPs\n", n_keep))
    if (n_keep == 0) next

    # MR
    method <- if (n_keep == 1) "mr_wald_ratio" else "mr_ivw"
    res <- mr(dat, method_list = method)
    if (nrow(res) == 0) next

    ci_lo <- res$b - 1.96 * res$se
    ci_hi <- res$b + 1.96 * res$se

    cat(sprintf("  β = %+.5f (%+.5f, %+.5f), SE = %.5f, P = %.2e [%s, %d SNPs]\n",
                res$b, ci_lo, ci_hi, res$se, res$pval, res$method, res$nsnp))

    all_results[[paste(gene, eye, sep = "_")]] <- data.frame(
      gene = gene, outcome_id = outcome_id, eye = eye, n_snp = res$nsnp,
      beta = res$b, se = res$se, ci_lo = ci_lo, ci_hi = ci_hi,
      pval = res$pval, method = res$method,
      stringsAsFactors = FALSE
    )
  }
}

# ============================================================================
# Step 4: Compare with locked P values (sanity check)
# ============================================================================
cat("\n\n========== VALIDATION vs Locked P Values ==========\n")
cat("(Lock values from Memory v1 - if cache outcome != Tedja CREAM,\n")
cat(" mismatches are EXPECTED and indicate labeling issue.)\n\n")

locked_pvals <- list(
  RDH5_R = 1.5e-15,  RDH5_L = 1.5e-12,
  CD55_R = 1.5e-7,   CD55_L = 5.1e-10,
  TGFB1_R = 4.0e-4,  TGFB1_L = 2.3e-4,
  CTNNB1_R = 2.5e-8, CTNNB1_L = 1.1e-8,
  FBN1_R = 3.9e-5,   FBN1_L = 4.2e-6
)

for (key in names(locked_pvals)) {
  if (!is.null(all_results[[key]])) {
    new_p  <- all_results[[key]]$pval
    lock_p <- locked_pvals[[key]]
    ratio  <- new_p / lock_p
    flag   <- if (ratio > 0.1 && ratio < 10) "MATCH" else "DIFFERENT"
    cat(sprintf("  %-12s Lock=%.2e  New=%.2e  Ratio=%.2f  [%s]\n",
                key, lock_p, new_p, ratio, flag))
  }
}

# ============================================================================
# Step 5: Save + paste-ready output
# ============================================================================
if (length(all_results) > 0) {
  final <- do.call(rbind, all_results)
  fwrite(final, OUT_CSV)
  cat(sprintf("\nSaved: %s (%d rows)\n", OUT_CSV, nrow(final)))
}

# Get the actual outcome label for figure
actual_outcome_r <- unique(cream_r_cache$outcome)[1]
actual_outcome_l <- unique(cream_l_cache$outcome)[1]
actual_n_r <- unique(cream_r_cache$samplesize.outcome)[1]
actual_n_l <- unique(cream_l_cache$samplesize.outcome)[1]

cat("\n\n========== PASTE INTO figure2_forest_v1.R ==========\n\n")
cat("# ACTUAL outcome (from cache content, NOT Tedja CREAM):\n")
cat(sprintf("#   R: %s (N=%s)\n", actual_outcome_r, actual_n_r))
cat(sprintf("#   L: %s (N=%s)\n", actual_outcome_l, actual_n_l))
cat("# Update Panel B/C titles in figure script accordingly\n\n")

gene_order <- c("RDH5", "CD55", "TGFB1", "CTNNB1", "FBN1")

emit_data_frame <- function(eye_label, eye_suffix) {
  cat(sprintf("# %s eye replication (fresh MR via cache)\n", eye_label))
  cat(sprintf("cream_%s_data <- data.frame(\n", tolower(eye_suffix)))
  cat("  gene  = c('RDH5', 'CD55', 'TGFB1', 'CTNNB1', 'FBN1'),\n")
  cat("  tier  = c('A', 'A', 'B', 'B', 'B'),\n")

  nsnps_actual <- integer(5)
  betas <- lowers <- uppers <- numeric(5)
  pvals <- character(5)
  for (j in seq_along(gene_order)) {
    key <- paste(gene_order[j], eye_suffix, sep = "_")
    if (!is.null(all_results[[key]])) {
      r <- all_results[[key]]
      nsnps_actual[j] <- r$n_snp
      betas[j]  <- r$beta
      lowers[j] <- r$ci_lo
      uppers[j] <- r$ci_hi
      pvals[j]  <- formatC(r$pval, format = "e", digits = 1)
    } else {
      nsnps_actual[j] <- NA
      betas[j]  <- NA; lowers[j] <- NA; uppers[j] <- NA; pvals[j] <- "NA"
    }
  }

  cat("  nSNP  = c(", paste(nsnps_actual, collapse = ", "), "),\n", sep = "")
  cat("  beta  = c(", paste(sprintf("%+.5f", betas), collapse = ", "), "),\n", sep = "")
  cat("  lower = c(", paste(sprintf("%+.5f", lowers), collapse = ", "), "),\n", sep = "")
  cat("  upper = c(", paste(sprintf("%+.5f", uppers), collapse = ", "), "),\n", sep = "")
  cat("  pval  = c(", paste(sprintf("'%s'", pvals), collapse = ", "), "),\n", sep = "")
  cat("  stringsAsFactors = FALSE\n)\n\n")
}

emit_data_frame("Right", "R")
emit_data_frame("Left", "L")

cat("=========================================================\n")
cat("Action required:\n")
cat("  1. Review validation table — if locked P-values DO match cache results,\n")
cat("     then Memory v1 'CREAM' was actually this UKB Spherical R/L.\n")
cat("  2. If MISMATCH, true Tedja CREAM data needed for proper replication.\n")
cat("  3. Update Figure 2 Panel B/C titles to reflect actual outcome:\n")
cat(sprintf("       Panel B: %s (N=%s)\n", actual_outcome_r, actual_n_r))
cat(sprintf("       Panel C: %s (N=%s)\n", actual_outcome_l, actual_n_l))
cat("=========================================================\n")
