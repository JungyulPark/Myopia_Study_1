# ============================================================================
# DISCOVERY ENGINE D3 — MUSCARINIC / ATROPINE-TARGET MR vs AXIAL LENGTH
# ----------------------------------------------------------------------------
# THE most on-theme discovery test. Atropine (a muscarinic antagonist) slows
# myopia, yet its DIRECT targets — muscarinic receptors CHRM1-CHRM5 and
# cholinergic context genes — have not been causally tested against the
# STRUCTURAL phenotype (axial length). A causal muscarinic -> axial-length
# effect would be a mechanistically meaningful, atropine-anchored finding that
# finally justifies the atropine framing on evidence, not narrative.
#
# HONESTY (locked):
#   - A POSITIVE here is a genuine mechanistic finding ONLY if it passes the
#     4-part novelty/causality wall in DISCOVERY_PLAN.md (not known locus, coloc,
#     fine-map credible, replicates). Otherwise it is a candidate/hypothesis.
#   - A NULL is fully reportable: "the causal muscarinic->axial link is not
#     supported / not testable at available power" — and is NOT spun positive.
#   - CAVEAT baked in: GPCRs like CHRM* are low-expressed in BLOOD; eQTLGen
#     instruments may be weak or absent. The script flags weak-instrument cases
#     and recommends GTEx (eye/brain) or tissue eQTL panels where available.
#
# DEPENDENCIES: TwoSampleMR, ieugwasr, dplyr, data.table
#   Auth: set OPENGWAS_JWT in the environment (do NOT hardcode a token).
# ============================================================================

suppressMessages({ library(TwoSampleMR); library(ieugwasr); library(dplyr); library(data.table) })
if (Sys.getenv("OPENGWAS_JWT") == "") stop("Set OPENGWAS_JWT in the environment before running.")

out_dir <- if (dir.exists("c:/Projectbulid")) "c:/Projectbulid/Submit_Manuscript/value_add/discovery" else "."
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

# ---- CONFIG: outcomes (resolve per DISCOVERY_PLAN.md step 0) -----------------
AL_OUTCOME <- NA_character_   # axial-length GWAS OpenGWAS id, OR set AL_LOCAL in a reader
RE_OUTCOME <- "ukb-b-6353"    # refractive error (already used) — secondary outcome

# ---- muscarinic + cholinergic context genes (cis-eQTL exposures) ------------
# Primary: the five muscarinic receptors (direct atropine targets).
# Context: choline/acetylcholine machinery + a known cholinergic-adjacent myopia
# gene (GJD2) as a positive-control-style anchor.
genes <- c(
  CHRM1 = "eqtl-a-ENSG00000168539",
  CHRM2 = "eqtl-a-ENSG00000181072",
  CHRM3 = "eqtl-a-ENSG00000133019",   # most implicated in scleral/retinal myopia biology
  CHRM4 = "eqtl-a-ENSG00000180720",
  CHRM5 = "eqtl-a-ENSG00000184984",
  CHAT  = "eqtl-a-ENSG00000070748",   # choline acetyltransferase (context)
  ACHE  = "eqtl-a-ENSG00000087085",   # acetylcholinesterase (context)
  GJD2  = "eqtl-a-ENSG00000159557"    # known myopia GWAS gene, cholinergic-adjacent (control)
)
known_controls <- c("GJD2")

mr_vs <- function(gene, expo_id, outcome_id, outcome_label) {
  if (is.na(outcome_id)) return(NULL)
  if (!tryCatch({ gwasinfo(expo_id); TRUE }, error = function(e) FALSE)) {
    cat(sprintf("  [skip] %s — eQTL panel %s absent (GPCR low-expression in blood?)\n", gene, expo_id)); return(NULL)
  }
  exp_dat <- tryCatch(extract_instruments(expo_id, p1 = 1e-04, clump = TRUE, r2 = 0.001, kb = 10000),
                      error = function(e) NULL)
  if (is.null(exp_dat) || nrow(exp_dat) == 0) { cat(sprintf("  [no IV] %s\n", gene)); return(NULL) }
  exp_dat$F_stat <- (exp_dat$beta.exposure / exp_dat$se.exposure)^2
  weak <- mean(exp_dat$F_stat) < 10
  exp_dat <- subset(exp_dat, F_stat > 10)
  if (nrow(exp_dat) == 0) { cat(sprintf("  [weak IV, all F<10] %s — REPORT as not-testable\n", gene)); return(
    data.table(gene = gene, outcome = outcome_label, n_iv = 0L, method = NA, b = NA, se = NA, pval = NA,
               min_F = NA, weak_instrument = TRUE, note = "no IV with F>10 (GPCR weak in blood eQTL)")) }
  out_dat <- tryCatch(extract_outcome_data(exp_dat$SNP, outcome_id), error = function(e) NULL)
  if (is.null(out_dat) || nrow(out_dat) == 0) return(NULL)
  dat <- subset(harmonise_data(exp_dat, out_dat), mr_keep == TRUE); if (nrow(dat) == 0) return(NULL)
  res <- mr(dat); ivw <- subset(res, method == "Inverse variance weighted"); if (nrow(ivw)==0) ivw <- res[1,]
  steig <- tryCatch(directionality_test(dat), error = function(e) NULL)
  data.table(gene = gene, outcome = outcome_label, n_iv = nrow(dat), method = ivw$method,
             b = ivw$b, se = ivw$se, pval = ivw$pval, min_F = min(exp_dat$F_stat),
             weak_instrument = weak,
             steiger_ok = if (!is.null(steig)) steig$correct_causal_direction else NA,
             is_known_control = gene %in% known_controls,
             note = "")
}

cat("=== D3: muscarinic/atropine-target MR ===\n")
rows <- list()
for (g in names(genes)) {
  cat(sprintf("\n--- %s ---\n", g))
  rows[[paste0(g,"_AL")]] <- mr_vs(g, genes[[g]], AL_OUTCOME, "axial_length")
  rows[[paste0(g,"_RE")]] <- mr_vs(g, genes[[g]], RE_OUTCOME, "refractive_error")
}
final <- rbindlist(Filter(Negate(is.null), rows), fill = TRUE)
out_csv <- file.path(out_dir, "D3_muscarinic_MR_results.csv")
fwrite(final, out_csv); cat("\nWROTE", out_csv, " rows:", nrow(final), "\n"); print(final)

cat("\n--- DECISION GATE G-D3 ---\n",
    "POSITIVE (headline candidate): a CHRM*/cholinergic gene with n_iv>=1, F>10,\n",
    "  axial-length MR P<0.05 AND consistent direction -> run coloc (Track 3) + fine-map (D2);\n",
    "  promote ONLY if it clears the 4-part novelty wall in DISCOVERY_PLAN.md.\n",
    "NULL / weak: report 'causal muscarinic->axial link not supported / not testable at\n",
    "  available power; GPCRs weakly instrumented in blood eQTL — recommend tissue eQTL.'\n",
    "  GJD2 (known) serves as the positive-control check that the pipeline can detect signal.\n", sep="")
if (is.na(AL_OUTCOME)) cat("\n[!] AL_OUTCOME not set — axial-length arm was skipped. Resolve dataset (PLAN step 0) and re-run.\n")
