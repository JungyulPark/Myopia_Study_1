# ============================================================================
# M-LIGHT value-add 2 — AXIAL-LENGTH / HIGH-MYOPIA MR   (Roadmap Phase 3)
# ----------------------------------------------------------------------------
# WHY THIS ELEVATES THE PAPER
#   Refractive error (our current outcome) is a composite. AXIAL LENGTH is the
#   STRUCTURAL mediator that actually drives pathological myopia and its
#   blinding complications. Wang Y 2024 (PMC11314700) tested complement targets
#   against refractive error / myopia, NOT against axial length. Asking
#   "do the same cis-anchored instruments move the STRUCTURAL phenotype?" is a
#   genuinely orthogonal, mechanism-level question -> this is the real venue
#   upgrade (TVST / IOVS), not a cosmetic add-on.
#
# HONEST FRAMING (locked):
#   - This is still confirmation/triangulation, NOT discovery. A locus that
#     moves BOTH refractive error AND axial length is a stronger POSITIVE
#     CONTROL; it does not become a "new gene".
#   - A NULL axial-length result is INFORMATIVE (locus acts via a non-axial /
#     refractive route, or is underpowered) and is NEVER converted into a
#     positive. See the pre-registered interpretation grid at the bottom.
#   - TGFB1 stays excluded as a positive (discordant MR direction upstream).
#
# DATA ACCESS IS THE GATING RISK (Roadmap 3.1 — resolve BEFORE running):
#   Pick ONE axial-length outcome and set AL_OUTCOME below. Options, best first:
#     (a) PI-generated UKB axial length  (fields 5201/5202, ~67k eye-exam subset)
#         -> highest power; requires the PI's own GWAS summary stats on disk.
#     (b) CREAM axial-length GWAS         -> public but lower N (power caveat).
#     (c) Pan-UKBB axial-length phenocode -> public.
#   And for the CLINICAL endpoint (degenerative/high myopia), set HM_OUTCOME:
#     (d) FinnGen  H7_MYOPIA  /  degenerative-myopia endpoint (public).
#   The script CHECKS availability and STOPS with a clear message rather than
#   silently producing an underpowered or empty result.
#
# DEPENDENCIES:  TwoSampleMR, ieugwasr, dplyr, data.table
#   OpenGWAS auth: set OPENGWAS_JWT in the environment (do NOT hardcode tokens).
# ============================================================================

suppressMessages({
  library(TwoSampleMR); library(ieugwasr); library(dplyr); library(data.table)
})
if (Sys.getenv("OPENGWAS_JWT") == "")
  stop("Set OPENGWAS_JWT in your environment (Sys.setenv(OPENGWAS_JWT=...)) before running.")

out_dir <- if (dir.exists("c:/Projectbulid")) "c:/Projectbulid/Submit_Manuscript/value_add" else "."
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

# ---------------------------------------------------------------------------
# CONFIG — resolve these per Roadmap 3.1 before running.
# ---------------------------------------------------------------------------
# Axial-length outcome. Replace with the resolved source.
#   - For a local PI UKB-AL file, set AL_LOCAL to its path and AL_OUTCOME=NA.
#   - For an OpenGWAS id (CREAM/Pan-UKBB), set AL_OUTCOME to the id.
AL_OUTCOME <- NA_character_          # e.g. "ebi-a-XXXXXXX" (CREAM axial length), or set AL_LOCAL
AL_LOCAL   <- NA_character_          # e.g. "c:/Projectbulid/data/ukb_axial_length.txt.gz" (PI-generated)
# Clinical high/degenerative-myopia endpoint (FinnGen via OpenGWAS, or local):
HM_OUTCOME <- "finn-b-H7_MYOPIA"     # confirm exact endpoint id in OpenGWAS first

# Exposure: cis-eQTL instruments for the four NON-discordant anchors.
# (TGFB1 excluded as a positive: discordant MR direction upstream.)
# Mirror the existing CP3 pipeline — eqtl-a-<ENSG> OpenGWAS panels.
exposures <- c(
  RDH5   = "eqtl-a-ENSG00000135437",
  CD55   = "eqtl-a-ENSG00000196352",
  CTNNB1 = "eqtl-a-ENSG00000168036",
  FBN1   = "eqtl-a-ENSG00000166147"
)

# ---------------------------------------------------------------------------
# Availability gate (Roadmap 3.1) — fail loud, never silent.
# ---------------------------------------------------------------------------
resolve_al <- function() {
  if (!is.na(AL_LOCAL)) {
    if (!file.exists(AL_LOCAL)) stop("AL_LOCAL set but file not found: ", AL_LOCAL)
    cat("Axial-length outcome: LOCAL file", AL_LOCAL, "\n"); return(list(mode = "local", src = AL_LOCAL))
  }
  if (!is.na(AL_OUTCOME)) {
    ok <- tryCatch({ gwasinfo(AL_OUTCOME); TRUE }, error = function(e) FALSE)
    if (!ok) stop("AL_OUTCOME '", AL_OUTCOME, "' not reachable in OpenGWAS. Resolve a real axial-length dataset (Roadmap 3.1).")
    cat("Axial-length outcome: OpenGWAS", AL_OUTCOME, "\n"); return(list(mode = "opengwas", src = AL_OUTCOME))
  }
  stop("No axial-length outcome configured. Set AL_OUTCOME or AL_LOCAL (Roadmap 3.1) before running. ",
       "Do NOT proceed with an underpowered placeholder.")
}

# read a local AL GWAS into TwoSampleMR outcome format (edit col names to match the file)
read_local_outcome <- function(snps, path) {
  d <- fread(path)
  format_data(as.data.frame(d), type = "outcome", snps = snps,
              snp_col = "SNP", beta_col = "beta", se_col = "se",
              effect_allele_col = "effect_allele", other_allele_col = "other_allele",
              eaf_col = "eaf", pval_col = "pval")
}

run_mr_one <- function(gene, expo_id, outcome, label) {
  cat(sprintf("\n--- %s  ->  %s ---\n", gene, label))
  exp_dat <- tryCatch(extract_instruments(outcomes = expo_id, p1 = 1e-04, clump = TRUE, r2 = 0.001, kb = 10000),
                      error = function(e) NULL)
  if (is.null(exp_dat) || nrow(exp_dat) == 0) { cat("  no instruments\n"); return(NULL) }
  exp_dat$F_stat <- (exp_dat$beta.exposure / exp_dat$se.exposure)^2
  exp_dat <- subset(exp_dat, F_stat > 10)
  if (nrow(exp_dat) == 0) { cat("  no IV with F>10\n"); return(NULL) }

  if (outcome$mode == "local") {
    out_dat <- read_local_outcome(exp_dat$SNP, outcome$src)
  } else {
    out_dat <- tryCatch(extract_outcome_data(snps = exp_dat$SNP, outcomes = outcome$src),
                        error = function(e) NULL)
  }
  if (is.null(out_dat) || nrow(out_dat) == 0) { cat("  outcome SNPs unavailable\n"); return(NULL) }

  dat <- harmonise_data(exp_dat, out_dat); dat <- subset(dat, mr_keep == TRUE)
  if (nrow(dat) == 0) { cat("  nothing left after harmonise\n"); return(NULL) }

  res    <- mr(dat)
  steig  <- tryCatch(directionality_test(dat), error = function(e) NULL)
  het    <- tryCatch(mr_heterogeneity(dat),    error = function(e) NULL)
  pleio  <- tryCatch(mr_pleiotropy_test(dat),  error = function(e) NULL)

  res$gene <- gene; res$outcome_label <- label; res$n_iv <- nrow(dat)
  res$min_F <- min(exp_dat$F_stat); res$mean_F <- mean(exp_dat$F_stat)
  if (!is.null(steig)) { res$steiger_dir <- steig$correct_causal_direction; res$steiger_p <- steig$steiger_pval }
  if (!is.null(pleio)) { res$egger_intercept_p <- pleio$pval }
  res
}

# ---------------------------------------------------------------------------
# RUN
# ---------------------------------------------------------------------------
al  <- resolve_al()
hm  <- list(mode = "opengwas", src = HM_OUTCOME)
# sanity-check the clinical endpoint too
if (!tryCatch({ gwasinfo(HM_OUTCOME); TRUE }, error = function(e) FALSE))
  cat("[WARN] HM_OUTCOME '", HM_OUTCOME, "' not reachable; clinical-endpoint arm will be skipped.\n", sep = "")

all_res <- list()
for (g in names(exposures)) {
  all_res[[paste0(g, "_AL")]] <- run_mr_one(g, exposures[[g]], al, "axial_length")
  all_res[[paste0(g, "_HM")]] <- tryCatch(run_mr_one(g, exposures[[g]], hm, "high_myopia"),
                                          error = function(e) NULL)
}
final <- rbindlist(Filter(Negate(is.null), all_res), fill = TRUE)
out_csv <- file.path(out_dir, "axial_length_MR_results.csv")
fwrite(final, out_csv)
cat("\nWROTE", out_csv, "  rows:", nrow(final), "\n")

# ---------------------------------------------------------------------------
# PRE-REGISTERED INTERPRETATION GRID  (lock BEFORE looking at results)
# ---------------------------------------------------------------------------
# For each anchor, classify by (refractive-error MR already established) x (axial-length MR here):
#
#   RE sig  +  AL sig, SAME direction   -> STRONGER positive control (structural concordance).
#                                          Report as triangulation win. NOT a new gene.
#   RE sig  +  AL null                  -> locus acts via a NON-axial / refractive route, OR
#                                          AL arm underpowered. Report BOTH possibilities; do not
#                                          claim axial involvement. Power note mandatory.
#   RE sig  +  AL OPPOSITE direction    -> red flag: pleiotropy / mis-harmonisation. Investigate,
#                                          do NOT report as a finding.
#   RE null +  AL sig                   -> hypothesis only; flag for replication; no clinical claim.
#
# A null is a RESULT, not a failure, and is reported as such (do-not-regress rule #10).
# If NO usable axial-length dataset is resolved in time, this whole arm ships as a
# clearly-labelled "not yet testable — data access pending" limitation, and the paper
# is submitted on the honest + druggability core WITHOUT it (Roadmap gate G3 = "No path").
cat("\nInterpretation grid is in the script header — apply it as pre-registered. Do not convert nulls to positives.\n")
