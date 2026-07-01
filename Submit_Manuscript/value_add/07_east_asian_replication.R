# ============================================================================
# HIGH-VALUE ANALYSIS 07 — EAST-ASIAN ANCESTRY REPLICATION
# ----------------------------------------------------------------------------
# WHY THIS MATTERS MOST: atropine's clinical evidence base (ATOM1/2, LAMP) is
# East-Asian, and myopia burden is concentrated in East Asia — yet our replication
# is EUR-only (UKB, Tedja 2018, CREAM). A reviewer will almost certainly ask for
# trans-ancestry evidence. Replicating the anchors' cis-MR in an East-Asian
# refractive-error / myopia GWAS materially strengthens generalizability.
#
# HONEST FRAMING (locked):
#   - This is a REPLICATION / generalizability test of the SAME anchors, not a new
#     discovery. RDH5/CD55 remain positive controls; a null in East Asians is a
#     reportable ancestry-specificity limitation, never spun positive.
#   - CROSS-ANCESTRY CAVEAT (must be stated): if instruments come from EUR eQTLGen
#     but the outcome is East-Asian, LD and allele-frequency differences can weaken
#     or bias the test. Prefer an EAST-ASIAN eQTL panel for instruments where
#     available; otherwise report the EUR-instrument / EAS-outcome design honestly
#     and restrict to non-palindromic SNPs with concordant allele frequencies.
#
# DATA (PI / Antigravity):
#   Outcome (East-Asian), best first:
#     (a) an East-Asian refractive-error / myopia GWAS you can access
#     (b) BBJ myopia / high-myopia endpoint
#     (c) an Asian consortium refractive-error meta-analysis
#   Instruments: East-Asian eQTL (preferred) else EUR eQTLGen with the caveat above.
#
# DEPENDENCIES: TwoSampleMR, ieugwasr, data.table   (OPENGWAS_JWT in env)
# ============================================================================

suppressMessages({ library(TwoSampleMR); library(ieugwasr); library(data.table) })
if (Sys.getenv("OPENGWAS_JWT") == "") stop("Set OPENGWAS_JWT before running.")

out_dir <- if (dir.exists("c:/Projectbulid")) "c:/Projectbulid/Submit_Manuscript/value_add" else "."

# ---- CONFIG (resolve per your access) ---------------------------------------
EAS_OUTCOME <- NA_character_   # OpenGWAS id of the East-Asian myopia/RE GWAS, OR set EAS_LOCAL reader
# Instrument source: prefer EAS eQTL; fall back to EUR eQTLGen (eqtl-a-*) w/ caveat.
USE_EAS_EQTL <- FALSE          # TRUE if you have an East-Asian eQTL panel wired below
anchors <- list(
  RDH5   = "eqtl-a-ENSG00000135437",
  CD55   = "eqtl-a-ENSG00000196352",
  CTNNB1 = "eqtl-a-ENSG00000168036",
  FBN1   = "eqtl-a-ENSG00000166147"
)

rep_one <- function(gene, expo_id) {
  if (is.na(EAS_OUTCOME)) { cat("[!] EAS_OUTCOME not set — resolve dataset first.\n"); return(NULL) }
  exp_dat <- tryCatch(extract_instruments(expo_id, p1 = 5e-06, clump = TRUE, r2 = 0.001, kb = 10000),
                      error = function(e) NULL)
  if (is.null(exp_dat) || nrow(exp_dat) == 0) { cat("[no IV]", gene, "\n"); return(NULL) }
  exp_dat$F <- (exp_dat$beta.exposure/exp_dat$se.exposure)^2; exp_dat <- subset(exp_dat, F > 10)
  # cross-ancestry hygiene: drop palindromic + allele-freq-ambiguous SNPs
  exp_dat <- subset(exp_dat, !(effect_allele.exposure %in% c("A","T") & other_allele.exposure %in% c("A","T")) &
                             !(effect_allele.exposure %in% c("C","G") & other_allele.exposure %in% c("C","G")))
  if (nrow(exp_dat) == 0) { cat("[all IV palindromic — cross-ancestry unsafe]", gene, "\n"); return(NULL) }
  out_dat <- tryCatch(extract_outcome_data(exp_dat$SNP, EAS_OUTCOME), error = function(e) NULL)
  if (is.null(out_dat) || nrow(out_dat) == 0) { cat("[no outcome overlap]", gene, "\n"); return(NULL) }
  dat <- subset(harmonise_data(exp_dat, out_dat, action = 2), mr_keep == TRUE); if (nrow(dat)==0) return(NULL)
  res <- mr(dat); ivw <- subset(res, method %in% c("Inverse variance weighted","Wald ratio"))[1,]
  data.table(gene = gene, ancestry_design = if (USE_EAS_EQTL) "EAS-eQTL/EAS-outcome" else "EUR-eQTL/EAS-outcome(caveat)",
             n_iv = nrow(dat), method = ivw$method, b = ivw$b, se = ivw$se, pval = ivw$pval,
             direction = ifelse(ivw$b > 0, "pos", "neg"))
}

res <- rbindlist(Filter(Negate(is.null), lapply(names(anchors), function(g) rep_one(g, anchors[[g]]))), fill = TRUE)
fwrite(res, file.path(out_dir, "east_asian_replication.csv"))
cat("WROTE east_asian_replication.csv\n"); print(res)
cat("\nINTERPRET: concordant direction + P<0.05 in East Asians -> trans-ancestry generalizability.\n",
    "Null -> ancestry-specificity limitation (honest), NOT a positive. State cross-ancestry caveat.\n", sep="")
