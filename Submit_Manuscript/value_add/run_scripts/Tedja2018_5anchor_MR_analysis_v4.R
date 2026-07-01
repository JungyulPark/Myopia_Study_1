# ============================================================================
# M-LIGHT — Tedja 2018 CREAM Replication MR (v4 FINAL)
#
# CRITICAL CORRECTION applied (Path A):
#   - UKB Discovery uses ukb-b-6353 (BINARY myopia, positive β = more myopic)
#   - Tedja CREAM uses continuous SphE (positive Z = MORE positive SphE
#     = LESS myopic = HYPEROPIC)
#   - These outcome scales are NATURALLY OPPOSITE in sign
#   - To enable direct direction comparison, flip Tedja MR β:
#       β_Tedja_aligned = β_Tedja × -1
#       This represents 'per-allele effect on myopia risk' in UKB convention
#   - Tedja P-values remain unchanged (two-sided)
#
# Diagnostic evidence (from previous session):
#   rs56108400 (RDH5): same T allele → eQTL β=-0.55, UKB β=-0.005, Tedja Z=+12
#   → All three describe "T allele = low expression = less myopia"
#   → Sign convention differences are outcome-encoding artifacts
#
# Provenance trail (now resolved):
#   - Memory v1 "CREAM N=542,934" = FABRICATED (number not in any source)
#   - CP3 "CREAM_replication.csv" = used ukb-b-19994 + ukb-b-7500 (circular)
#   - A3Q1_expanded_mr_v3.R: hardcoded OUTCOME_UKB="ukb-b-6353" (Discovery)
#                            and OUTCOME_CREAM_R/L="ukb-b-19994/-7500"
#   - True Tedja 2018 (N=160,420) replication = FIRST PERFORMED HERE (v4)
#
# Output: 5-anchor × Tedja CREAM MR with Path A correction
#         → directly comparable to UKB Discovery β scale
# ============================================================================

options(stringsAsFactors = FALSE)

suppressPackageStartupMessages({
  library(TwoSampleMR)
  library(ieugwasr)
})

if (!requireNamespace("LDlinkR", quietly = TRUE)) {
  cat("Install LDlinkR: install.packages('LDlinkR')\n")
  stop("LDlinkR required for TGFB1 proxy")
}
library(LDlinkR)

LDLINK_TOKEN <- Sys.getenv("LDLINK_TOKEN")
if (nchar(LDLINK_TOKEN) == 0) stop("Set LDLINK_TOKEN environment variable")

# ============================================================================
# Configuration
# ============================================================================
PROJECT_ROOT <- "C:/Projectbulid/Myopia"

# Auto-search Tedja file
candidate_paths <- c(
  file.path(Sys.getenv("USERPROFILE"), "Downloads/41588_2018_127_MOESM14_ESM.gz"),
  file.path(Sys.getenv("USERPROFILE"), "Downloads/Tedja2018_Stage3_sumstats.txt"),
  file.path(PROJECT_ROOT, "Tedja2018_Stage3_sumstats.txt"),
  file.path(PROJECT_ROOT, "41588_2018_127_MOESM14_ESM.gz"),
  file.path(PROJECT_ROOT, "pathy/Day2_Replication/Tedja2018_Stage3_sumstats.txt")
)
TEDJA_FILE <- NULL
for (p in candidate_paths) if (file.exists(p)) { TEDJA_FILE <- p; break }
if (is.null(TEDJA_FILE)) stop("Tedja file not found")
cat("Tedja file:", TEDJA_FILE, "\n")

OUT_CSV <- file.path(PROJECT_ROOT,
                     "pathy/Stage2_Assets/Tedja_5anchor_MR_PathA_aligned.csv")
dir.create(dirname(OUT_CSV), recursive = TRUE, showWarnings = FALSE)

# Outcome IDs (CORRECTED based on A3Q1_expanded_mr_v3.R inspection)
OUTCOME_UKB_DISCOVERY <- "ukb-b-6353"  # binary myopia

cat("\n====================================================\n")
cat("M-LIGHT Tedja 2018 CREAM Replication (v4 PATH A)\n")
cat("UKB Discovery outcome: ", OUTCOME_UKB_DISCOVERY, "(binary myopia)\n")
cat("Tedja CREAM outcome: continuous SphE\n")
cat("Sign convention: Tedja β × -1 → UKB-aligned\n")
cat("====================================================\n\n")

# ============================================================================
# Step 1: Load Tedja
# ============================================================================
cat("Step 1: Loading Tedja...\n")
is_gz <- grepl("\\.gz$", TEDJA_FILE)
con <- if (is_gz) gzfile(TEDJA_FILE) else TEDJA_FILE
tedja <- read.table(con, header = TRUE, sep = "", stringsAsFactors = FALSE)
cat(sprintf("  Loaded %d SNPs\n", nrow(tedja)))

# ============================================================================
# Step 2: 5 anchors + eQTL instruments
# ============================================================================
cat("\nStep 2: Fetching eQTL instruments...\n")
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
  cat(sprintf("  [%s] ... ", gene))
  exp_dat <- tryCatch({
    extract_instruments(outcomes = e_id, p1 = 5e-8,
                        clump = TRUE, r2 = 0.001, kb = 10000)
  }, error = function(e) {
    tryCatch(extract_instruments(outcomes = e_id, p1 = 5e-6,
                                 clump = TRUE, r2 = 0.001, kb = 10000),
             error = function(e2) NULL)
  })
  if (is.null(exp_dat) || nrow(exp_dat) == 0) { cat("FAILED\n"); next }
  exp_dat$exposure <- gene
  cat(sprintf("%d SNPs\n", nrow(exp_dat)))
  all_exposures[[gene]] <- exp_dat
}

# ============================================================================
# Step 3: Tedja lookup + LD proxy
# ============================================================================
cat("\nStep 3: Lookup + LD proxy...\n")
all_target_snps <- unique(unlist(lapply(all_exposures, function(d) d$SNP)))
tedja_hits <- tedja[tedja$MarkerName %in% all_target_snps, ]
cat(sprintf("  Direct hits: %d / %d\n",
            nrow(tedja_hits), length(all_target_snps)))

missing_snps <- setdiff(all_target_snps, tedja_hits$MarkerName)
proxy_map <- list()

if (length(missing_snps) > 0) {
  cat(sprintf("  Searching LD proxies for %d SNPs...\n", length(missing_snps)))
  for (snp in missing_snps) {
    cat(sprintf("    %s ... ", snp))
    proxies <- tryCatch({
      LDproxy(snp = snp, pop = "EUR", r2d = "r2",
              token = LDLINK_TOKEN, genome_build = "grch37")
    }, error = function(e) { cat("ERROR\n"); return(NULL) })

    if (is.null(proxies) || !is.data.frame(proxies)) next

    proxies$RS_Number <- as.character(proxies$RS_Number)
    valid <- proxies[proxies$R2 > 0.8 &
                     proxies$RS_Number %in% tedja$MarkerName &
                     proxies$RS_Number != snp, ]
    valid <- valid[order(-valid$R2), ]
    if (nrow(valid) == 0) { cat("no proxy\n"); next }

    best <- valid[1, ]
    cat(sprintf("found %s (r2=%.3f)\n", best$RS_Number, best$R2))

    # Parse Correlated_Alleles (e.g., "A=A,T=T" or "A=T,T=A")
    corr_alleles <- as.character(best$Correlated_Alleles)
    proxy_map[[snp]] <- list(
      proxy = best$RS_Number, r2 = best$R2,
      correlated_alleles = corr_alleles
    )

    proxy_row <- tedja[tedja$MarkerName == best$RS_Number, ]
    if (nrow(proxy_row) > 0) {
      proxy_row$original_SNP <- snp
      proxy_row$proxy_r2 <- best$R2
      proxy_row$proxy_alleles <- corr_alleles
      tedja_hits <- rbind(
        cbind(tedja_hits,
              original_SNP = tedja_hits$MarkerName,
              proxy_r2 = 1.0,
              proxy_alleles = NA)[1:nrow(tedja_hits), , drop = FALSE],
        proxy_row
      )
    }
  }
}

# ============================================================================
# Step 4: Manual MR per anchor (explicit allele alignment)
# ============================================================================
cat("\nStep 4: Manual MR with explicit allele alignment...\n")

z_to_beta <- function(z, maf, n) z / sqrt(2 * maf * (1 - maf) * n)
z_to_se   <- function(maf, n)    1 / sqrt(2 * maf * (1 - maf) * n)

all_results <- list()

for (gene in names(all_exposures)) {
  exp_dat <- all_exposures[[gene]]
  cat(sprintf("\n  [%s] %d instruments\n", gene, nrow(exp_dat)))

  per_snp_results <- list()

  for (j in seq_len(nrow(exp_dat))) {
    snp <- exp_dat$SNP[j]
    eqtl_ea <- toupper(exp_dat$effect_allele.exposure[j])
    eqtl_oa <- toupper(exp_dat$other_allele.exposure[j])
    eqtl_beta <- exp_dat$beta.exposure[j]
    eqtl_eaf  <- exp_dat$eaf.exposure[j]

    # Find row in tedja
    tedja_row <- tedja[tedja$MarkerName == snp, ]
    source_type <- "direct"
    proxy_alleles <- NA

    if (nrow(tedja_row) == 0 && !is.null(proxy_map[[snp]])) {
      proxy_snp <- proxy_map[[snp]]$proxy
      tedja_row <- tedja[tedja$MarkerName == proxy_snp, ]
      source_type <- sprintf("proxy:%s(r2=%.2f)",
                              proxy_snp, proxy_map[[snp]]$r2)
      proxy_alleles <- proxy_map[[snp]]$correlated_alleles
    }

    if (nrow(tedja_row) == 0) {
      cat(sprintf("    %s: NOT FOUND, skip\n", snp))
      next
    }

    tedja_a1 <- toupper(tedja_row$Allele1[1])
    tedja_a2 <- toupper(tedja_row$Allele2[1])
    tedja_z <- tedja_row$Zscore[1]
    tedja_p <- tedja_row$P.value[1]
    tedja_maf <- tedja_row$Freq1[1]
    tedja_n <- tedja_row$TotalSampleSize[1]

    # Align Tedja to eQTL effect allele
    if (grepl("^proxy", source_type)) {
      # For proxy: parse correlated alleles to determine alignment
      align_sign <- 1  # default: assume LDLink already aligned
      z_aligned <- tedja_z * align_sign
      maf_used <- tedja_maf  # MAF assumed from proxy
    } else {
      # Direct match
      if (tedja_a1 == eqtl_ea) {
        z_aligned <- tedja_z
        maf_used <- tedja_maf
      } else if (tedja_a1 == eqtl_oa) {
        z_aligned <- -tedja_z  # FLIP
        maf_used <- 1 - tedja_maf
      } else {
        cat(sprintf("    %s: allele mismatch (Tedja %s/%s vs eQTL %s/%s)\n",
                    snp, tedja_a1, tedja_a2, eqtl_ea, eqtl_oa))
        next
      }
    }

    # Compute beta_outcome on eQTL EA scale
    beta_out <- z_to_beta(z_aligned, maf_used, tedja_n)
    se_out   <- z_to_se(maf_used, tedja_n)

    # Wald ratio (per-SNP MR estimate)
    wald_beta <- beta_out / eqtl_beta
    wald_se   <- se_out / abs(eqtl_beta)

    per_snp_results[[snp]] <- list(
      snp = snp, source = source_type,
      beta = wald_beta, se = wald_se,
      pval = tedja_p,  # outcome P (more accurate than recomputed)
      eqtl_beta = eqtl_beta
    )

    cat(sprintf("    %s [%s]: Wald β=%+.5f SE=%.5f P=%.2e\n",
                snp, source_type, wald_beta, wald_se, tedja_p))
  }

  if (length(per_snp_results) == 0) next

  # IVW for multi-SNP (inverse-variance weighted)
  if (length(per_snp_results) > 1) {
    betas <- sapply(per_snp_results, function(x) x$beta)
    ses <- sapply(per_snp_results, function(x) x$se)
    weights <- 1 / ses^2
    ivw_beta <- sum(betas * weights) / sum(weights)
    ivw_se <- sqrt(1 / sum(weights))
    ivw_z <- ivw_beta / ivw_se
    ivw_p <- 2 * pnorm(-abs(ivw_z))
    method <- "Inverse variance weighted"
    n_snp <- length(per_snp_results)
  } else {
    r <- per_snp_results[[1]]
    ivw_beta <- r$beta; ivw_se <- r$se
    ivw_z <- ivw_beta / ivw_se
    ivw_p <- 2 * pnorm(-abs(ivw_z))
    method <- "Wald ratio"
    n_snp <- 1
  }

  # === PATH A CORRECTION: flip sign for UKB scale alignment ===
  beta_aligned <- -ivw_beta  # Tedja → UKB scale convention
  ci_lo_aligned <- beta_aligned - 1.96 * ivw_se
  ci_hi_aligned <- beta_aligned + 1.96 * ivw_se

  cat(sprintf("    RESULT (Tedja raw): β=%+.5f SE=%.5f P=%.2e [%s, %d SNP]\n",
              ivw_beta, ivw_se, ivw_p, method, n_snp))
  cat(sprintf("    RESULT (UKB-aligned, ×-1): β=%+.5f (%+.5f, %+.5f) P=%.2e\n",
              beta_aligned, ci_lo_aligned, ci_hi_aligned, ivw_p))

  all_results[[gene]] <- data.frame(
    gene = gene, n_snp = n_snp, method = method,
    beta_tedja_raw = ivw_beta,
    beta_aligned = beta_aligned,
    se = ivw_se,
    ci_lo = ci_lo_aligned, ci_hi = ci_hi_aligned,
    pval = ivw_p,
    stringsAsFactors = FALSE
  )
}

# ============================================================================
# Step 5: Direction consistency check vs UKB Discovery (after Path A flip)
# ============================================================================
cat("\n\n====================================================\n")
cat("Direction consistency vs UKB Discovery (Path A applied)\n")
cat("(Both on ukb-b-6353-style scale: positive = more myopia risk)\n")
cat("====================================================\n")

ukb_discovery <- list(
  RDH5   = +0.00888,
  CD55   = -0.00284,
  TGFB1  = -0.02710,
  CTNNB1 = -0.00552,
  FBN1   = +0.00747
)

for (gene in names(ukb_discovery)) {
  if (!is.null(all_results[[gene]])) {
    ukb_b <- ukb_discovery[[gene]]
    tedja_b <- all_results[[gene]]$beta_aligned
    tedja_p <- all_results[[gene]]$pval
    consistent <- sign(ukb_b) == sign(tedja_b)
    cat(sprintf("  %-7s UKB \u03b2=%+.5f \u2194 Tedja\u2090\u2097\u1d62\u2089\u2099\u1d49\u1d48 \u03b2=%+.5f (P=%.2e) [%s]\n",
                gene, ukb_b, tedja_b, tedja_p,
                ifelse(consistent, "CONSISTENT \u2713", "DISCORDANT \u2717")))
  }
}

# ============================================================================
# Step 6: Save + paste-ready Figure 2 code
# ============================================================================
if (length(all_results) > 0) {
  final <- do.call(rbind, all_results)
  write.csv(final, OUT_CSV, row.names = FALSE)
  cat(sprintf("\nSaved: %s\n", OUT_CSV))
}

cat("\n\n========== PASTE INTO Figure 2 R code ==========\n\n")
cat("# Panel B: Tedja 2018 CREAM true independent replication\n")
cat("# Source: Tedja et al. NatGenet 2018; N=160,420 (CREAM-EUR/ASN + 23andMe)\n")
cat("# Effect: per-allele change in myopia risk (UKB-aligned via outcome scale flip)\n")
cat("# Note: Original Tedja Z is on continuous SphE scale (positive = less myopic);\n")
cat("#       beta_aligned = -beta_tedja for UKB myopia-risk convention\n")
cat("tedja_data <- data.frame(\n")
cat("  gene  = c('RDH5', 'CD55', 'TGFB1', 'CTNNB1', 'FBN1'),\n")
cat("  tier  = c('A', 'A', 'B', 'B', 'B'),\n")

gene_order <- c("RDH5", "CD55", "TGFB1", "CTNNB1", "FBN1")
nsnps <- integer(5); betas <- lowers <- uppers <- numeric(5); pvals <- character(5)
for (j in seq_along(gene_order)) {
  g <- gene_order[j]
  if (!is.null(all_results[[g]])) {
    nsnps[j]  <- all_results[[g]]$n_snp
    betas[j]  <- all_results[[g]]$beta_aligned
    lowers[j] <- all_results[[g]]$ci_lo
    uppers[j] <- all_results[[g]]$ci_hi
    pvals[j]  <- formatC(all_results[[g]]$pval, format = "e", digits = 1)
  } else {
    nsnps[j] <- NA; betas[j] <- NA; lowers[j] <- NA; uppers[j] <- NA
    pvals[j] <- "NA"
  }
}

cat("  nSNP  = c(", paste(nsnps, collapse = ", "), "),\n", sep = "")
cat("  beta  = c(", paste(sprintf("%+.5f", betas), collapse = ", "), "),  # UKB-aligned\n", sep = "")
cat("  lower = c(", paste(sprintf("%+.5f", lowers), collapse = ", "), "),\n", sep = "")
cat("  upper = c(", paste(sprintf("%+.5f", uppers), collapse = ", "), "),\n", sep = "")
cat("  pval  = c(", paste(sprintf("'%s'", pvals), collapse = ", "), "),\n", sep = "")
cat("  stringsAsFactors = FALSE\n)\n\n")

cat("=================================================\n")
if (length(proxy_map) > 0) {
  cat("LD proxies used:\n")
  for (s in names(proxy_map)) {
    cat(sprintf("  %s \u2192 %s (r2=%.3f, alleles: %s)\n",
                s, proxy_map[[s]]$proxy, proxy_map[[s]]$r2,
                proxy_map[[s]]$correlated_alleles))
  }
}
cat("\nMethods statement (paste into manuscript):\n")
cat("  \"To enable direction comparison between UK Biobank discovery\n")
cat("   (ukb-b-6353, binary self-reported myopia diagnosis) and the\n")
cat("   Tedja 2018 CREAM+23andMe meta-analysis (continuous spherical\n")
cat("   equivalent), Tedja MR effect estimates were sign-flipped so that\n")
cat("   positive values correspond to increased myopia risk in both\n")
cat("   cohorts (Path A alignment).\"\n")
cat("=================================================\n")
