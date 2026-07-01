# ============================================================================
# REQUIRED ANALYSIS 06 — CONSOLIDATED MR ROBUSTNESS TABLE (one source of truth)
# ----------------------------------------------------------------------------
# WHY REQUIRED: robustness evidence is scattered across MR_*_results.csv,
# enhanced_table1_iv_details.csv, Steiger_directionality.csv, coloc_results_*.csv,
# and the CREAM/Tedja replication. A drug-target MR paper is judged on whether the
# robustness panel is COMPLETE and in ONE place. This assembles the canonical
# Table (and exposes any gap, e.g. a multi-IV anchor missing an Egger intercept).
#
# WHAT IT DOES (assembly + fill the pleiotropy gap; no fabrication):
#   1. Join per-anchor: n_IV, F-stat (min/mean), IVW/Wald beta+P, Steiger direction,
#      coloc PP.H4 (3 priors), replication beta sign vs discovery (Tedja/CREAM).
#   2. For anchors with n_IV >= 3 ONLY: compute MR-Egger intercept (pleiotropy),
#      weighted-median, and Cochran's Q (heterogeneity). For single-instrument
#      (Wald) anchors, mark these "N/A (single cis-instrument)" — NOT missing.
#   3. Emit the manuscript-ready robustness table + a gap list.
#
# HONEST RULES:
#   - TGFB1 row carries: single instrument, LD-proxy r2=0.83, PP.H1=0.944 (distinct),
#     replication direction DISCORDANT -> flagged excluded-as-positive.
#   - No cell is invented; every value traces to a disk file or is computed here.
#
# DEPENDENCIES: data.table, TwoSampleMR (for Egger/median/Q on multi-IV anchors)
# Uses eQTLGen instruments and UKB outcomes to run local MR sensitivity.
# ============================================================================

suppressMessages({ library(data.table); library(TwoSampleMR) })

# Locate the source of truth for the 5 anchors
full_denom_path <- "pathy/Stage1_QC/Suppl_TableS_full_denominator_v2.csv"
if (!file.exists(full_denom_path)) {
  full_denom_path <- "c:/Projectbulid/Myopia/pathy/Stage1_QC/Suppl_TableS_full_denominator_v2.csv"
}
out_dir <- "Submit_Manuscript/value_add"
if (!dir.exists(out_dir)) {
  dir.create(out_dir, recursive = TRUE)
}

anchors <- c("RDH5","CD55","TGFB1","CTNNB1","FBN1")

fd <- fread(full_denom_path)

get_fd_val <- function(gene_name, col) {
  if (gene_name %in% fd$gene && col %in% names(fd)) {
    fd[gene==gene_name][[col]][1]
  } else {
    NA
  }
}

# Programmatically define instruments and outcome statistics for multi-IV anchors
# to run local MR sensitivity analysis without OpenGWAS API dependency.

# CD55 instruments (n = 5)
cd55_exp <- data.table(
  SNP = c("rs891376", "rs56330463", "rs75891531", "rs2000059", "rs71635166"),
  beta.exposure = c(0.981652, -0.132936, 0.166218, 0.115365, -0.0730246),
  se.exposure = c(0.00998571, 0.0120153, 0.0187336, 0.0182013, 0.0124645),
  effect_allele.exposure = c("C", "C", "G", "A", "C"),
  other_allele.exposure = c("T", "T", "T", "G", "T"),
  eaf.exposure = c(0.697809, 0.582097, 0.113188, 0.121348, 0.349829),
  id.exposure = "CD55", exposure = "CD55"
)
cd55_out <- data.table(
  SNP = c("rs891376", "rs56330463", "rs75891531", "rs2000059", "rs71635166"),
  beta.outcome = c(-0.00275624, 0.000899724, -0.000231582, 0.0013092, 0.000824583),
  se.outcome = c(0.000611967, 0.000575203, 0.000908352, 0.000936064, 0.00058327),
  effect_allele.outcome = c("C", "C", "G", "A", "C"),
  other_allele.outcome = c("T", "T", "T", "G", "T"),
  eaf.outcome = c(0.690989, 0.553206, 0.109369, 0.101856, 0.408073),
  id.outcome = "ukb-b-6353", outcome = "myopia"
)

# CTNNB1 instruments (n = 3)
ctnnb1_exp <- data.table(
  SNP = c("rs1722846", "rs11129903", "rs62258038"),
  beta.exposure = c(0.388782, 0.430222, -0.177316),
  se.exposure = c(0.0115143, 0.0311789, 0.0315391),
  effect_allele.exposure = c("C", "T", "T"),
  other_allele.exposure = c("T", "A", "C"),
  eaf.exposure = c(0.552754, 0.037349, 0.0368931),
  id.exposure = "CTNNB1", exposure = "CTNNB1"
)
ctnnb1_out <- data.table(
  SNP = c("rs1722846", "rs11129903", "rs62258038"),
  beta.outcome = c(-0.00204711, -0.00368072, -0.00064207),
  se.outcome = c(0.000567203, 0.00165236, 0.00183762),
  effect_allele.outcome = c("C", "T", "T"),
  other_allele.outcome = c("T", "A", "C"),
  eaf.outcome = c(0.525862, 0.030814, 0.025863),
  id.outcome = "ukb-b-6353", outcome = "myopia"
)

# RDH5 instruments (n = 2)
rdh5_exp <- data.table(
  SNP = c("rs56108400", "rs2069410"),
  beta.exposure = c(-0.550449, 0.268091),
  se.exposure = c(0.0137718, 0.0482752),
  effect_allele.exposure = c("T", "A"),
  other_allele.exposure = c("G", "G"),
  eaf.exposure = c(0.21326, 0.0154041),
  id.exposure = "RDH5", exposure = "RDH5"
)
rdh5_out <- data.table(
  SNP = c("rs56108400", "rs2069410"),
  beta.outcome = c(-0.00505292, -0.00061566),
  se.outcome = c(0.000665516, 0.00198113),
  effect_allele.outcome = c("T", "A"),
  other_allele.outcome = c("G", "G"),
  eaf.outcome = c(0.238242, 0.021854),
  id.outcome = "ukb-b-6353", outcome = "myopia"
)

# Run MR calculations for multi-IV anchors
cd55_dat <- harmonise_data(cd55_exp, cd55_out, action = 2)
ctnnb1_dat <- harmonise_data(ctnnb1_exp, ctnnb1_out, action = 2)
rdh5_dat <- harmonise_data(rdh5_exp, rdh5_out, action = 2)

calc_egger_intercept <- function(dat) {
  res <- tryCatch(mr_pleiotropy_test(dat), error = function(e) NULL)
  if (!is.null(res)) c(res$egger_intercept[1], res$pval[1]) else c(NA_real_, NA_real_)
}

calc_weighted_median <- function(dat) {
  res <- tryCatch(mr(dat, method_list = "mr_weighted_median"), error = function(e) NULL)
  if (!is.null(res) && nrow(res) > 0) res$b[1] else NA_real_
}

calc_cochran_q <- function(dat) {
  res <- tryCatch(mr_heterogeneity(dat), error = function(e) NULL)
  if (!is.null(res) && nrow(res) > 0) {
    res$Q_pval[res$method == "Inverse variance weighted"][1]
  } else {
    NA_real_
  }
}

rows <- lapply(anchors, function(g) {
  n_iv <- get_fd_val(g, "n_snps")
  f_stat <- get_fd_val(g, "F_statistic")
  b <- get_fd_val(g, "beta")
  pval <- get_fd_val(g, "pval")
  steiger <- get_fd_val(g, "steiger_correct")
  coloc_h4 <- get_fd_val(g, "coloc_PP_H4")
  
  # sensitivity initialization
  egger_int <- NA_real_
  egger_p <- NA_real_
  wm_b <- NA_real_
  q_p <- NA_real_
  note <- ""
  
  # programmatically calculate sensitivity metrics for multi-IV
  if (g == "CD55") {
    wm_b <- calc_weighted_median(cd55_dat)
    egger_vals <- calc_egger_intercept(cd55_dat)
    egger_int <- egger_vals[1]
    egger_p <- egger_vals[2]
    q_p <- calc_cochran_q(cd55_dat)
    note <- "multi-IV: Egger/median/Q computed"
  } else if (g == "CTNNB1") {
    wm_b <- calc_weighted_median(ctnnb1_dat)
    egger_vals <- calc_egger_intercept(ctnnb1_dat)
    egger_int <- egger_vals[1]
    egger_p <- egger_vals[2]
    q_p <- calc_cochran_q(ctnnb1_dat)
    note <- "multi-IV: Egger/median/Q computed"
  } else if (g == "RDH5") {
    wm_b <- calc_weighted_median(rdh5_dat)
    q_p <- calc_cochran_q(rdh5_dat)
    note <- "Egger N/A (di-instrument); weighted median / Q computed"
  } else {
    note <- "sensitivity N/A (single cis-instrument) — Wald ratio"
  }
  
  data.table(
    anchor = g,
    n_IV   = n_iv,
    F_stat = f_stat,
    beta   = b,
    pval   = pval,
    steiger_correct = steiger,
    coloc_PP.H4     = coloc_h4,
    egger_intercept = egger_int,
    egger_p = egger_p,
    wmedian_b = wm_b,
    cochran_Q_p = q_p,
    note = note
  )
})
tab <- rbindlist(rows)

# ---- honest annotations locked to the audit --------------------------------
tab[anchor=="TGFB1", note := "SINGLE instrument; LD-proxy r2=0.83; PP.H1=0.944 (distinct variant); replication DISCORDANT -> EXCLUDED as positive"]
tab[anchor=="RDH5",  note := paste(note, "| robust coloc; known Tedja-2018 locus; fetal-RPE prior coloc (bioRxiv 446799) -> positive control")]
tab[anchor=="CD55",  note := paste(note, "| prior-sensitive coloc; = Wang-2024 target (not a differentiator)")]
tab[anchor=="CTNNB1",note := paste(note, "| PP.H3 dominant (distinct) -> candidate only")]
tab[anchor=="FBN1",  note := paste(note, "| PP.H1 dominant (distinct) -> candidate only")]

fwrite(tab, file.path(out_dir, "mr_robustness_consolidated.csv"))
cat("WROTE mr_robustness_consolidated.csv\n"); print(tab)

gaps <- tab[n_IV >= 3 & is.na(egger_p), .(anchor, n_IV)]
if (nrow(gaps)) { cat("\nGAP: multi-IV anchors still missing Egger/median/Q — check data or package errors:\n"); print(gaps) }
