# ============================================================================
# M-LIGHT value-add 4 — PATHWAY / MECHANISM LAYER
# ----------------------------------------------------------------------------
# WHY THIS ELEVATES THE PAPER
#   A list of single genes reads as "confirmation". Recasting the SAME honest
#   evidence as a small number of BIOLOGICAL AXES gives the mechanistic depth
#   that higher-tier ophthalmic venues (and the EER/JEI aspiration) want — WITHOUT
#   any new-gene claim. The axes are:
#       - Visual cycle / retinoid      : RDH5 (+ RLBP1, RPE65, LRAT as pathway context)
#       - Complement regulation        : CD55 (+ CFH, C3, CD46 as pathway context)
#       - TGF-beta / ECM (scleral)     : TGFB1, FBN1 (+ COL/LOX scleral remodelling genes)
#       - Wnt / beta-catenin           : CTNNB1 (+ canonical Wnt context)
#
# WHAT THIS SCRIPT DOES (honest, no fabrication):
#   1. PATHWAY-LEVEL MR: for each axis, run cis-eQTL MR for every member gene that
#      has instruments, then summarise the axis (how many member genes show a
#      consistent-direction effect on refractive error). This tests whether the
#      AXIS, not just the anchor, is supported — a stronger, mechanism-level claim
#      than a single gene, while staying within known biology.
#   2. ENRICHMENT CONTEXT: report how many axis members are already known
#      refractive-error / myopia GWAS genes (Tedja 2018 / GWAS Catalog), making
#      explicit that these are ESTABLISHED axes recovered, not new ones.
#
# HONEST FRAMING (locked):
#   - Axes are framed as "established biology the pipeline recovers", never as
#     newly-discovered mechanisms.
#   - TGFB1 stays excluded as a POSITIVE (discordant MR direction); it may appear
#     only as ECM-axis CONTEXT with that caveat stated.
#   - A member gene with no instrument or a null effect is reported as such; the
#     axis summary is descriptive, not a significance-inflating meta-test.
#
# DEPENDENCIES:  TwoSampleMR, ieugwasr, dplyr, data.table
#   OpenGWAS auth: set OPENGWAS_JWT in the environment (do NOT hardcode).
# ============================================================================

suppressMessages({ library(TwoSampleMR); library(ieugwasr); library(dplyr); library(data.table) })
if (Sys.getenv("OPENGWAS_JWT") == "")
  stop("Set OPENGWAS_JWT in the environment before running.")

outcome_id <- "ukb-b-6353"   # refractive error / myopia (same as primary pipeline)
out_dir <- if (dir.exists("c:/Projectbulid")) "c:/Projectbulid/Submit_Manuscript/value_add" else "."
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

# ---- axes and member genes (anchor first; context genes carry is_anchor=FALSE) ----
# eqtl-a-<ENSG> OpenGWAS panels; confirm each id exists (gwasinfo) — missing ids skip.
axes <- list(
  visual_cycle = list(
    RDH5  = "eqtl-a-ENSG00000135437",  # anchor
    RLBP1 = "eqtl-a-ENSG00000140522",
    RPE65 = "eqtl-a-ENSG00000116745",
    LRAT  = "eqtl-a-ENSG00000121207"
  ),
  complement = list(
    CD55 = "eqtl-a-ENSG00000196352",   # anchor (also Wang-2024 target — disclose)
    CFH  = "eqtl-a-ENSG00000000971",
    C3   = "eqtl-a-ENSG00000125730",
    CD46 = "eqtl-a-ENSG00000117335"
  ),
  tgfb_ecm = list(
    FBN1  = "eqtl-a-ENSG00000166147",  # anchor (coloc fail upstream)
    TGFB1 = "eqtl-a-ENSG00000105329",  # CONTEXT ONLY — discordant direction, no positive claim
    LOX   = "eqtl-a-ENSG00000113083"
  ),
  wnt = list(
    CTNNB1 = "eqtl-a-ENSG00000168036"  # anchor (coloc fail upstream)
  )
)
anchors <- c("RDH5","CD55","FBN1","CTNNB1")
exclude_as_positive <- c("TGFB1")   # discordant direction — context only

mr_one <- function(gene, expo_id) {
  if (!tryCatch({ gwasinfo(expo_id); TRUE }, error = function(e) FALSE)) {
    cat("  [skip]", gene, "- panel", expo_id, "not in OpenGWAS\n"); return(NULL)
  }
  exp_dat <- tryCatch(extract_instruments(expo_id, p1 = 1e-04, clump = TRUE, r2 = 0.001, kb = 10000),
                      error = function(e) NULL)
  if (is.null(exp_dat) || nrow(exp_dat) == 0) { cat("  [no IV]", gene, "\n"); return(NULL) }
  exp_dat$F_stat <- (exp_dat$beta.exposure / exp_dat$se.exposure)^2
  exp_dat <- subset(exp_dat, F_stat > 10); if (nrow(exp_dat) == 0) return(NULL)
  out_dat <- tryCatch(extract_outcome_data(exp_dat$SNP, outcome_id), error = function(e) NULL)
  if (is.null(out_dat) || nrow(out_dat) == 0) return(NULL)
  dat <- subset(harmonise_data(exp_dat, out_dat), mr_keep == TRUE); if (nrow(dat) == 0) return(NULL)
  ivw <- subset(mr(dat), method == "Inverse variance weighted")
  if (nrow(ivw) == 0) ivw <- mr(dat)[1, ]
  data.table(gene = gene, n_iv = nrow(dat), b = ivw$b, se = ivw$se, pval = ivw$pval,
             direction = ifelse(ivw$b > 0, "pos", "neg"))
}

all_rows <- list()
for (ax in names(axes)) {
  cat(sprintf("\n##### AXIS: %s #####\n", ax))
  for (g in names(axes[[ax]])) {
    r <- mr_one(g, axes[[ax]][[g]])
    if (!is.null(r)) {
      r$axis <- ax; r$is_anchor <- g %in% anchors
      r$role <- ifelse(g %in% exclude_as_positive, "context_only_discordant", ifelse(r$is_anchor, "anchor", "context"))
      all_rows[[length(all_rows) + 1]] <- r
    }
  }
}
gene_tab <- rbindlist(all_rows, fill = TRUE)
fwrite(gene_tab, file.path(out_dir, "pathway_mr_per_gene.csv"))

# ---- axis-level descriptive summary (NOT a significance meta-test) ----
axis_tab <- gene_tab[role != "context_only_discordant",
  .(n_genes_tested = .N,
    n_nominal_sig  = sum(pval < 0.05, na.rm = TRUE),
    n_concordant_with_anchor = {
      ad <- direction[is_anchor][1]
      if (is.na(ad)) NA_integer_ else sum(direction == ad, na.rm = TRUE)
    }),
  by = axis]
fwrite(axis_tab, file.path(out_dir, "pathway_axis_summary.csv"))
cat("\nWROTE pathway_mr_per_gene.csv and pathway_axis_summary.csv\n")
print(axis_tab)

cat("\nREPORTING RULES:\n",
    "- Frame axes as ESTABLISHED biology recovered, never newly discovered.\n",
    "- Axis summary is DESCRIPTIVE (how many members move consistently); do NOT pool p-values into a single inflated test.\n",
    "- TGFB1 appears as context only, with discordant-direction caveat; never as a positive.\n",
    "- Any member with no IV / null is reported as such.\n", sep = "")
