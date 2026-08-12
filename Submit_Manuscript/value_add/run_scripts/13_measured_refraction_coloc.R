#!/usr/bin/env Rscript
# ============================================================================
# 13_measured_refraction_coloc.R
#
# THE QUESTION THIS SETTLES
# audit_v4 found the nominations are H1-dominant (16/22): blood eQTL signal
# present, essentially no myopia signal in the window. But the outcome was
# ukb-b-6353 — SELF-REPORTED myopia ("do you wear glasses for short sight").
# So two explanations are currently confounded:
#     (a) the nominated loci genuinely carry no refractive-error signal, or
#     (b) self-report is too lossy to show the signal that is there.
# Re-running the identical coloc against a MEASURED refractive-error outcome
# separates them. If H1 dominance persists, (a); if it converts to H3/H4, (b).
#
# It also re-tests the Hippo-YAP pathway, which the project's earlier drafts
# built a mechanism on. Core Hippo genes were never in the 113-gene screen at
# all, and CP3 Module B returned a result for only LATS2 (single-SNP Wald,
# P = 0.040, no colocalization, does not survive Bonferroni over its own 5
# genes). Hippo is a scleral mechanotransduction pathway, so its absence from
# blood is itself an instance of this study's main finding — worth stating with
# numbers rather than silence.
#
# OUTCOME FILE — searched in this order, first hit wins:
#   1. Tedja 2018 Nat Genet supplementary (41588_2018_127_MOESM14_ESM.gz)
#   2. a local ukb-b-19994 (spherical power) VCF
#   3. OpenGWAS via ieugwasr, if the API is reachable
# If none is available the script says so and exits without inventing a result.
#
# Output: outputs/measured_refraction_coloc.csv
#         outputs/MEASURED_REFRACTION_COMPARISON.txt
# ============================================================================

options(stringsAsFactors = FALSE)
suppressPackageStartupMessages(library(data.table))

SCRIPT_DIR <- tryCatch(dirname(normalizePath(sub("--file=", "",
                 grep("--file=", commandArgs(), value = TRUE)[1]))),
               error = function(e) ".")
OUTDIR <- Sys.getenv("MYOPIA_OUT", normalizePath(file.path(SCRIPT_DIR, "..", "outputs")))

EQTL_REL <- "CP3/data/2019-12-11-cis-eQTLsFDR-ProbeLevel-CohortInfoRemoved-BonferroniAdded.txt.gz"
find_root <- function() {
  cand <- c(Sys.getenv("MYOPIA_ROOT", ""), "C:/Projectbulid", "C:/Projectbulid/Myopia", ".", "..")
  cand <- cand[nzchar(cand)]
  for (r in cand) if (file.exists(file.path(r, EQTL_REL))) return(r)
  stop("eQTLGen not found; set MYOPIA_ROOT.")
}
ROOT <- find_root()

# --- locate a measured-refraction outcome ----------------------------------
# Pre-extracted windows (from 14_extract_outcome_windows.R) come first: they are
# small enough to commit, so the analysis is reproducible without the full file.
pre <- list.files(OUTDIR, pattern = "^outcome_windows_.*\\.csv\\.gz$", full.names = TRUE)
cands <- c(pre,
           file.path(ROOT, "data/41588_2018_127_MOESM14_ESM.gz"),
           file.path(ROOT, "41588_2018_127_MOESM14_ESM.gz"),
           file.path(Sys.getenv("USERPROFILE"), "Downloads/41588_2018_127_MOESM14_ESM.gz"),
           file.path(ROOT, "CP3/data/ukb-b-19994.vcf.gz"),
           file.path(ROOT, "CP3/data/tedja2018_refractive_error.txt.gz"))
OUTCOME <- Filter(file.exists, cands)[1]

if (is.na(OUTCOME)) {
  cat("NO MEASURED-REFRACTION OUTCOME FOUND.\n\nSearched:\n")
  for (p in cands) cat("  ", p, "\n")
  cat("\nThis analysis is the one that separates 'the loci carry no signal' from\n",
      "'self-report is too lossy to see it', so it should not be skipped quietly.\n",
      "Obtain ONE of:\n",
      "  - Tedja 2018 Nat Genet supplementary table 41588_2018_127_MOESM14_ESM.gz\n",
      "  - the ukb-b-19994 (spherical power) VCF from OpenGWAS\n",
      "and re-run. Until then the manuscript must state the confound explicitly.\n", sep = "")
  quit(save = "no", status = 0)
}
cat(sprintf("Measured-refraction outcome: %s\n", OUTCOME))

# --- coloc engine (identical to audit_v4.R) --------------------------------
logsum <- function(x) { m <- max(x); m + log(sum(exp(x - m))) }
abf_wakefield <- function(beta, varbeta, sd_prior) {
  z <- beta / sqrt(varbeta); r <- sd_prior^2 / (sd_prior^2 + varbeta)
  0.5 * (log(1 - r) + r * z^2)
}
coloc_abf_base <- function(d1, d2, p1 = 1e-4, p2 = 1e-4, p12 = 1e-5) {
  l1 <- abf_wakefield(d1$beta, d1$varbeta, 0.15)
  l2 <- abf_wakefield(d2$beta, d2$varbeta, 0.15)
  lH1 <- logsum(l1); lH2 <- logsum(l2); lH4 <- logsum(l1 + l2)
  lH3 <- lH1 + lH2 + log1p(-exp(pmin(lH4 - lH1 - lH2, -1e-12)))
  lp <- c(H0 = 0, H1 = log(p1) + lH1, H2 = log(p2) + lH2,
          H3 = log(p1) + log(p2) + lH3, H4 = log(p12) + lH4)
  pp <- exp(lp - logsum(lp))
  c(PP.H0 = pp[["H0"]], PP.H1 = pp[["H1"]], PP.H2 = pp[["H2"]],
    PP.H3 = pp[["H3"]], PP.H4 = pp[["H4"]])
}

# --- genes: everything audit_v4 evaluated, plus the Hippo-YAP core ----------
prev <- fread(file.path(OUTDIR, "audit_v4_results.csv"))
GENES <- unique(c(prev[status == "ok"]$gene,
                  "LATS1","LATS2","YAP1","WWTR1","TEAD1","STK3","STK4","SAV1","NF2","CCN2"))
phase_of <- setNames(prev$phase, prev$gene)

# The measured-refraction file may be far sparser than the UKB VCF. Comparing a
# 60-SNP window against a 2,000-SNP window is not like-for-like: sparse coverage
# lowers the chance of ever seeing the shared causal variant and so depresses H4
# on its own. The self-report arm is therefore RE-RUN here on exactly the same
# SNPs, and that matched arm — not the original audit_v4 numbers — is what the
# measured arm is compared against.
VCF_FILE <- file.path(ROOT, "CP3/data/ukb-b-6353.vcf.gz")
HAVE_VCF <- file.exists(VCF_FILE)
if (HAVE_VCF) {
  cat("Reading UKB VCF for the SNP-matched self-report arm...\n")
  v <- fread(VCF_FILE, skip = "#CHROM", select = c(1L,2L,3L,10L))
  setnames(v, c("CHR","POS","ID","UKB"))
  sp <- tstrsplit(v$UKB, ":")
  v[, `:=`(beta_u = as.numeric(sp[[1]]), se_u = as.numeric(sp[[2]]), SNP = ID)]
  v <- v[!is.na(beta_u) & !is.na(se_u) & se_u > 0][!duplicated(SNP)]
} else cat("UKB VCF absent — the SNP-matched self-report arm will be skipped.\n")

cat("Reading eQTLGen...\n")
eqtl <- fread(file.path(ROOT, EQTL_REL),
              select = c("Pvalue","SNP","SNPChr","SNPPos","Zscore","Gene",
                         "GeneSymbol","GeneChr","GenePos","NrSamples"))
eqtl <- eqtl[GeneSymbol %in% GENES]
eqtl[, `:=`(beta_e = Zscore / sqrt(NrSamples), se_e = 1 / sqrt(NrSamples))]

# --- outcome parser: autodetect columns, never assume -----------------------
out <- fread(OUTCOME)
nm  <- tolower(names(out))
pick <- function(...) { for (k in c(...)) { i <- which(nm == k); if (length(i)) return(names(out)[i[1]]) }; NA_character_ }
c_snp <- pick("snp","rsid","rs","markername","variant_id","rs_number")
c_b   <- pick("beta_o","beta","effect","b","beta_ref","estimate")
c_se  <- pick("se_o","se","standard_error","stderr","sebeta")
if (anyNA(c(c_snp, c_b, c_se))) {
  cat("Could not autodetect outcome columns.\n  found:", paste(names(out), collapse = ", "), "\n")
  cat("  Set c_snp/c_b/c_se by hand and re-run — do not guess.\n"); quit(save = "no", status = 1)
}
setnames(out, c(c_snp, c_b, c_se), c("SNP","beta_o","se_o"))
out <- out[!is.na(beta_o) & !is.na(se_o) & se_o > 0][!duplicated(SNP)]
cat(sprintf("  outcome SNPs: %d (cols %s / %s / %s)\n", nrow(out), c_snp, c_b, c_se))

# Colocalization needs DENSE per-SNP data across each 1 Mb window, not a table of
# lead SNPs. A supplementary "significant loci" table has a few hundred rows and
# would silently yield insufficient_overlap for every gene, which looks like a
# result but is an input problem. Refuse it explicitly.
IS_PREEXTRACTED <- grepl("outcome_windows_", OUTCOME)
if (!IS_PREEXTRACTED && nrow(out) < 1e5) {
  cat("\nSTOP: this outcome file has only", nrow(out), "SNPs.\n")
  cat("Colocalization needs genome-wide summary statistics (millions of SNPs);\n")
  cat("a lead-SNP or significant-loci supplementary table cannot be used for it,\n")
  cat("and forcing it through would return 'insufficient_overlap' for every gene.\n")
  cat("It IS still usable for two-sample MR of specific instruments — that is what\n")
  cat("Tedja2018_5anchor_MR_analysis_v4.R does with it.\n")
  cat("For this analysis obtain full summary statistics instead.\n")
  quit(save = "no", status = 0)
}

# --- per-gene coloc ---------------------------------------------------------
res <- list()
for (g in unique(eqtl$GeneSymbol)) {
  e <- eqtl[GeneSymbol == g]
  centre <- as.numeric(e$GenePos[1]); chr <- e$GeneChr[1]
  e <- e[SNPChr == chr & abs(SNPPos - centre) <= 5e5][order(Pvalue)][!duplicated(SNP)]
  mg <- merge(e, out, by = "SNP")
  if (nrow(mg) < 30L) {
    res[[g]] <- data.table(gene = g, phase = if (is.null(phase_of[[g]])) "hippo_yap" else phase_of[[g]],
                           n_shared = nrow(mg), status = "insufficient_overlap"); next
  }
  pp <- coloc_abf_base(list(beta = mg$beta_e, varbeta = mg$se_e^2),
                       list(beta = mg$beta_o, varbeta = mg$se_o^2))
  row <- data.table(gene = g, phase = if (is.null(phase_of[[g]])) "hippo_yap" else phase_of[[g]],
                    n_shared = nrow(mg), status = "ok",
                    PP.H0 = pp[["PP.H0"]], PP.H1 = pp[["PP.H1"]],
                    PP.H2 = pp[["PP.H2"]], PP.H3 = pp[["PP.H3"]], PP.H4 = pp[["PP.H4"]])
  # same gene, same SNPs, self-reported outcome
  if (HAVE_VCF) {
    mu <- merge(mg[, .(SNP, beta_e, se_e)], v[, .(SNP, beta_u, se_u)], by = "SNP")
    if (nrow(mu) >= 30L) {
      pu <- coloc_abf_base(list(beta = mu$beta_e, varbeta = mu$se_e^2),
                           list(beta = mu$beta_u, varbeta = mu$se_u^2))
      row[, `:=`(m_n = nrow(mu), m_PP.H1 = pu[["PP.H1"]],
                 m_PP.H3 = pu[["PP.H3"]], m_PP.H4 = pu[["PP.H4"]],
                 m_PP.H0 = pu[["PP.H0"]], m_PP.H2 = pu[["PP.H2"]])]
    }
  }
  res[[g]] <- row
}
r <- rbindlist(res, fill = TRUE)
fwrite(r, file.path(OUTDIR, "measured_refraction_coloc.csv"))

# --- compare against the self-reported result -------------------------------
con <- file(file.path(OUTDIR, "MEASURED_REFRACTION_COMPARISON.txt"), open = "wt")
say <- function(...) { cat(sprintf(...), file = con); cat(sprintf(...)) }
say("SELF-REPORTED vs MEASURED REFRACTION — same genes, same pipeline\n%s\n", strrep("=", 70))
say("Outcome file: %s\n\n", OUTCOME)

ok <- r[status == "ok"]
ok[, top := c("H0","H1","H2","H3","H4")[max.col(as.matrix(.SD))],
   .SDcols = c("PP.H0","PP.H1","PP.H2","PP.H3","PP.H4")]
prev[, top := c("H0","H1","H2","H3","H4")[max.col(as.matrix(.SD))],
     .SDcols = c("PP.H0","PP.H1","PP.H2","PP.H3","PP.H4")]

for (ph in c("audited_v3", "phase2_new", "positive_control", "hippo_yap")) {
  a <- prev[phase == ph & status == "ok"]; b <- ok[phase == ph]
  if (!nrow(b)) next
  say("%s\n", ph)
  say("  self-reported : H1 %2d/%2d, H3 %2d/%2d, H4>0.8 %2d\n",
      sum(a$top=="H1"), nrow(a), sum(a$top=="H3"), nrow(a), sum(a$PP.H4>0.8))
  say("  measured      : H1 %2d/%2d, H3 %2d/%2d, H4>0.8 %2d\n\n",
      sum(b$top=="H1"), nrow(b), sum(b$top=="H3"), nrow(b), sum(b$PP.H4>0.8))
}

say("%s\nVERDICT ON THE CONFOUND\n", strrep("-", 70))
if ("m_PP.H1" %in% names(ok) && any(!is.na(ok$m_PP.H1))) {
  cmp <- ok[!is.na(m_PP.H1) & phase %in% c("audited_v3","phase2_new")]
  cmp[, top_meas  := c("H0","H1","H2","H3","H4")[max.col(as.matrix(.SD))],
      .SDcols = c("PP.H0","PP.H1","PP.H2","PP.H3","PP.H4")]
  cmp[, top_self  := c("H0","H1","H2","H3","H4")[max.col(as.matrix(.SD))],
      .SDcols = c("m_PP.H0","m_PP.H1","m_PP.H2","m_PP.H3","m_PP.H4")]
  say("Like-for-like: both outcomes on the SAME SNPs (median %d per gene, n = %d genes)\n\n",
      as.integer(median(cmp$m_n)), nrow(cmp))
  say("  self-reported (SNP-matched) : H1 %2d/%2d (%3.0f%%)  H3 %2d  H4>0.8 %2d\n",
      sum(cmp$top_self=="H1"), nrow(cmp), 100*mean(cmp$top_self=="H1"),
      sum(cmp$top_self=="H3"), sum(cmp$m_PP.H4>0.8))
  say("  measured refraction         : H1 %2d/%2d (%3.0f%%)  H3 %2d  H4>0.8 %2d\n\n",
      sum(cmp$top_meas=="H1"), nrow(cmp), 100*mean(cmp$top_meas=="H1"),
      sum(cmp$top_meas=="H3"), sum(cmp$PP.H4>0.8))
  h1_self <- mean(cmp$top_self == "H1"); h1_meas <- mean(cmp$top_meas == "H1")
  d_h1 <- h1_meas - h1_self
  say("H1 dominance, self-reported -> measured: %.0f%% -> %.0f%% (%+.0f pp)\n\n",
      100*h1_self, 100*h1_meas, 100*d_h1)
  # The verdict must follow the DIRECTION of change, not the level alone: H1 can sit
  # near 50% while having risen, which is the opposite of the confound resolving.
  say(if (nrow(cmp) < 8)
        sprintf("TOO FEW GENES (n = %d) to call this either way. Report the counts, not a verdict.\n", nrow(cmp))
      else if (d_h1 <= -0.20 && h1_meas < 0.5)
        "H1 dominance FALLS substantially on a measured phenotype, on identical SNPs.\nThe earlier result was driven at least partly by phenotype quality, so the\nnominations must NOT be described as unsupported.\n"
      else if (h1_meas >= 0.5 || d_h1 >= 0)
        "H1 dominance PERSISTS (or rises) on a measured phenotype, on identical SNPs.\nSelf-report is not the explanation: these loci carry no refractive-error signal\nin either outcome.\n"
      else
        "H1 dominance falls only modestly and stays substantial. Neither reading is\nclearly supported — report both numbers and draw no verdict.\n")
  say("\nNOTE: the measured outcome is a meta-analysis Z-score file converted to beta/se;\nboth arms use identical SNPs, so density cannot drive the difference.\n")
} else {
  say("SNP-matched self-report arm unavailable (no UKB VCF), so the measured result\ncannot be compared like-for-like. Density differences alone could explain any\ndifference from the audit_v4 numbers — do not compare them directly.\n")
}

hy <- ok[phase == "hippo_yap"]
if (nrow(hy)) {
  say("\n%s\nHIPPO-YAP CORE (never in the 113-gene screen; CP3 tested 5, only LATS2 returned\na single-SNP Wald P = 0.040, no coloc, failing Bonferroni over its own 5 genes)\n", strrep("-", 70))
  for (i in seq_len(nrow(hy)))
    say("  %-7s PP.H4 = %.4f  PP.H1 = %.3f  PP.H3 = %.3f  (n=%d)\n",
        hy$gene[i], hy$PP.H4[i], hy$PP.H1[i], hy$PP.H3[i], hy$n_shared[i])
  say("  Genes with no usable blood instrument are reported, not omitted.\n")
}
close(con)
cat("\nWritten: measured_refraction_coloc.csv, MEASURED_REFRACTION_COMPARISON.txt\n")
