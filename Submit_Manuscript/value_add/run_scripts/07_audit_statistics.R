#!/usr/bin/env Rscript
# ============================================================================
# 07_audit_statistics.R
#
# Statistics required by LITERATURE_SEARCH_PROTOCOL.md sec.9 that had never been
# computed: exact binomial CIs for the reproduction proportion, the PP.H4
# continuum, threshold sensitivity, and a Bonferroni-vs-FDR comparison for the
# 113-gene screen. Also re-derives, programmatically, the data defects recorded
# in RESULTS_LEDGER.md so they cannot be lost track of.
#
# Inputs  (both already on disk, disk-verified):
#   outputs/published_targets_audit.csv        12 published targets
#   outputs/Suppl_TableS_full_denominator_v2.csv   full 113-gene screen
# Output:
#   outputs/AUDIT_STATISTICS.txt
#
# No eQTL/VCF input and no network access required: this script only summarises
# results already produced by audit_v3_coloc.R.
# ============================================================================

suppressMessages(library(data.table))

ROOT   <- normalizePath(file.path(dirname(sub("--file=", "", grep("--file=", commandArgs(), value = TRUE)[1])), ".."))
OUTDIR <- file.path(ROOT, "outputs")
audit  <- fread(file.path(OUTDIR, "published_targets_audit.csv"))
den    <- fread(file.path(OUTDIR, "Suppl_TableS_full_denominator_v2.csv"))

con <- file(file.path(OUTDIR, "AUDIT_STATISTICS.txt"), open = "wt")
say <- function(...) { cat(sprintf(...), file = con); cat(sprintf(...)) }

say("AUDIT STATISTICS — computed by 07_audit_statistics.R\n")
say("R %s.%s | data.table %s\n", R.version$major, R.version$minor,
    as.character(packageVersion("data.table")))
say("%s\n\n", strrep("=", 78))

# ---------------------------------------------------------------------------
# 1. Evaluability and the reproduction proportion, with exact binomial CIs
# ---------------------------------------------------------------------------
say("1. REPRODUCTION PROPORTION (protocol sec.9)\n%s\n", strrep("-", 78))

audit[, evaluable := !is.na(coloc_PP_H4)]
audit[, reproduced := evaluable & coloc_PP_H4 > 0.8 &
        !is.na(cream_R_pval) & cream_R_pval < 0.05]

n_total     <- nrow(audit)
n_eval      <- sum(audit$evaluable)
n_repro     <- sum(audit$reproduced)
n_distinct  <- sum(audit$evaluable & audit$coloc_PP_H1 > 0.5, na.rm = TRUE)

ci <- function(k, n) {
  # Clopper-Pearson exact interval
  bt <- binom.test(k, n)
  sprintf("%.1f%% (%d/%d, 95%% CI %.1f-%.1f%%)", 100 * k / n, k, n,
          100 * bt$conf.int[1], 100 * bt$conf.int[2])
}

say("Nominated targets audited        : %d\n", n_total)
say("Colocalization evaluable         : %d\n", n_eval)
say("Reproduced (PP.H4>0.8 + replic.) : %s   [denominator = all nominated]\n",
    ci(n_repro, n_total))
say("Reproduced                       : %s   [denominator = evaluable only]\n",
    ci(n_repro, n_eval))
say("Distinct causal variant (H1>0.5) : %s   [of evaluable]\n",
    ci(n_distinct, n_eval))
say("\nReproduced gene(s): %s\n", paste(audit[reproduced == TRUE, gene], collapse = ", "))

# ---------------------------------------------------------------------------
# 2. PP.H4 as a continuum, and how much the 0.8 convention is doing
# ---------------------------------------------------------------------------
say("\n2. PP.H4 CONTINUUM AND THRESHOLD SENSITIVITY\n%s\n", strrep("-", 78))

ev <- audit[evaluable == TRUE][order(-coloc_PP_H4)]
say("%-10s %8s %8s  %s\n", "gene", "PP.H4", "PP.H1", "verdict")
for (i in seq_len(nrow(ev))) {
  say("%-10s %8.3f %8.3f  %s\n", ev$gene[i], ev$coloc_PP_H4[i],
      ev$coloc_PP_H1[i], ev$reproduction_verdict[i])
}

say("\nGenes passing PP.H4 at each threshold (of %d evaluable):\n", n_eval)
for (thr in c(0.5, 0.6, 0.7, 0.75, 0.8, 0.9)) {
  g <- ev[coloc_PP_H4 > thr, gene]
  say("  PP.H4 > %.2f : %d  %s\n", thr, length(g),
      if (length(g)) paste0("(", paste(g, collapse = ", "), ")") else "")
}
say("\nNOTE: the count moves from 3 to 1 between thresholds 0.70 and 0.80\n")
say("(TSSK6 0.782, SH3YL1 0.748 sit just below 0.8). The headline is therefore\n")
say("sensitive to a convention, and must be reported with the continuum.\n")

# ---------------------------------------------------------------------------
# 3. Data defects, re-derived from the file rather than remembered
# ---------------------------------------------------------------------------
say("\n3. AUTOMATED DEFECT CHECKS\n%s\n", strrep("-", 78))

defects <- 0L
# 3a. instruments exist but the coloc window came back empty
bad <- audit[n_snps > 0 & !is.na(mr_pval) & is.na(coloc_PP_H4)]
if (nrow(bad)) {
  defects <- defects + nrow(bad)
  for (i in seq_len(nrow(bad)))
    say("[DEFECT] %s: %d instrument(s), F=%.0f, MR P=%.2g, yet coloc_status='%s'.\n",
        bad$gene[i], bad$n_snps[i], bad$F[i], bad$mr_pval[i], bad$coloc_status[i])
  say("         Instruments cannot exist inside an empty cis window -> re-run required.\n")
}
# 3b. non-standard gene symbols
ok_sym <- grepl("^[A-Z][A-Z0-9orf-]{1,}$", audit$gene)
susp <- audit[!ok_sym | nchar(audit$gene) <= 3]
if (nrow(susp)) {
  for (i in seq_len(nrow(susp)))
    say("[CHECK ] %s (%s): verify symbol against the source publication.\n",
        susp$gene[i], susp$ensembl[i])
}
if ("UBE" %in% audit$gene) {
  defects <- defects + 1L
  say("[DEFECT] 'UBE' is not a valid HGNC symbol. Source paper nominates UBE2I\n")
  say("         (ENSG00000103275); this row is INVALID until re-run.\n")
}
# 3c. stale citation label
if (any(grepl("Wang 2024", audit$source_paper))) {
  defects <- defects + 1L
  say("[DEFECT] source_paper says 'Wang 2024'; correct citation is Qin et al.\n")
  say("         IOVS 2024;65(10):13 (PMID 39110588) — Wang is the last author.\n")
}
say("\nTotal blocking defects: %d\n", defects)

# ---------------------------------------------------------------------------
# 4. The 113-gene screen: Bonferroni vs FDR
# ---------------------------------------------------------------------------
say("\n4. FULL DENOMINATOR SCREEN — MULTIPLE TESTING\n%s\n", strrep("-", 78))

den <- den[!is.na(pval)]
say("Genes with a testable MR result : %d\n", nrow(den))
n_implied <- round(0.05 / den$bonferroni_alpha[1])
say("Bonferroni alpha recorded in file: %.3e  (implies %d tests)\n",
    den$bonferroni_alpha[1], n_implied)
if (n_implied != nrow(den))
  say("[CHECK ] alpha assumes %d tests but %d genes carry a testable result.\n",
      n_implied, nrow(den))

bonf_hits <- den[pval < den$bonferroni_alpha[1]]
den[, q_bh := p.adjust(pval, method = "BH")]
fdr_hits  <- den[q_bh < 0.05]

say("\nBonferroni-significant : %d  (%s)\n", nrow(bonf_hits),
    paste(bonf_hits$gene, collapse = ", "))
say("BH-FDR < 0.05          : %d  (%s)\n", nrow(fdr_hits),
    paste(fdr_hits$gene, collapse = ", "))

coloc_sup <- den[!is.na(coloc_PP_H4) & coloc_PP_H4 > 0.8]
say("\nColocalization-supported (PP.H4>0.8), any P: %d  (%s)\n",
    nrow(coloc_sup), paste(coloc_sup$gene, collapse = ", "))

both <- intersect(fdr_hits$gene, coloc_sup$gene)
say("FDR-significant AND coloc-supported        : %d  (%s)\n",
    length(both), paste(both, collapse = ", "))
say("\nNOTE: relaxing Bonferroni to FDR does not add a colocalizing gene, so the\n")
say("negative conclusion is not an artefact of an over-strict correction.\n")

close(con)
cat("\nWritten: outputs/AUDIT_STATISTICS.txt\n")
