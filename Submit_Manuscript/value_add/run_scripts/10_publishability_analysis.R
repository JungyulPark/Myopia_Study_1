#!/usr/bin/env Rscript
# ============================================================================
# 10_publishability_analysis.R
#
# Two questions that decide whether the audit can carry a paper:
#   (1) What tissue do published myopia gene nominations actually come from?
#       If the field itself nominates from blood, a blood-based re-test is
#       method-matched rather than mismatched, and the "blood is not eye"
#       objection weakens considerably.
#   (2) How many genes must be audited before the reproduction proportion has
#       a usable confidence interval? At n=12 the interval was 0.2-38.5%.
#
# Input : outputs/published_targets_master.csv
# Output: outputs/PUBLISHABILITY_ANALYSIS.txt
# ============================================================================

suppressMessages(library(data.table))

ROOT   <- normalizePath(file.path(dirname(sub("--file=", "", grep("--file=", commandArgs(), value = TRUE)[1])), ".."))
OUTDIR <- file.path(ROOT, "outputs")
m      <- fread(file.path(OUTDIR, "published_targets_master.csv"))

con <- file(file.path(OUTDIR, "PUBLISHABILITY_ANALYSIS.txt"), open = "wt")
say <- function(...) { cat(sprintf(...), file = con); cat(sprintf(...)) }

say("PUBLISHABILITY ANALYSIS\n%s\n\n", strrep("=", 74))

# ---------------------------------------------------------------------------
# 1. Which tissue does the field nominate from?
# ---------------------------------------------------------------------------
say("1. TISSUE OF ORIGIN OF PUBLISHED NOMINATIONS (n = %d gene rows, %d studies)\n%s\n",
    nrow(m), uniqueN(m$source_pmid), strrep("-", 74))

m[, blood_based := grepl("blood", original_tissue, ignore.case = TRUE)]
m[, eye_based   := grepl("retina|RPE|sclera|choroid|pigment", original_tissue, ignore.case = TRUE)]

tis <- m[, .(n_genes = .N, studies = uniqueN(source_pmid)), by = original_tissue][order(-n_genes)]
for (i in seq_len(nrow(tis)))
  say("  %-42s %2d genes\n", substr(tis$original_tissue[i], 1, 42), tis$n_genes[i])

say("\n  Involving blood            : %d/%d gene rows (%.0f%%)\n",
    sum(m$blood_based), nrow(m), 100 * mean(m$blood_based))
say("  Involving any eye tissue   : %d/%d gene rows (%.0f%%)\n",
    sum(m$eye_based), nrow(m), 100 * mean(m$eye_based))
say("  Blood ONLY (no eye tissue) : %d/%d gene rows (%.0f%%)\n",
    sum(m$blood_based & !m$eye_based), nrow(m),
    100 * mean(m$blood_based & !m$eye_based))
say("  Eye tissue ONLY            : %d/%d gene rows\n", sum(!m$blood_based & m$eye_based), nrow(m))

say("\n  Studies using ANY eye tissue: %d of %d\n",
    uniqueN(m[eye_based == TRUE]$source_pmid), uniqueN(m$source_pmid))

# ---------------------------------------------------------------------------
# 2. How large must the audit be?
# ---------------------------------------------------------------------------
say("\n\n2. PRECISION OF THE REPRODUCTION PROPORTION vs AUDIT SIZE\n%s\n", strrep("-", 74))
say("Clopper-Pearson exact 95%% CI, assuming the observed rate holds.\n\n")

ci_w <- function(k, n) { b <- binom.test(round(k), n); 100 * diff(b$conf.int) }
say("%6s | %-22s | %-22s\n", "n", "at 1/12 rate (8.3%)", "at 3/12 rate (25%)")
say("%s\n", strrep("-", 60))
for (n in c(12, 23, 30, 40, 60, 80, 100)) {
  b1 <- binom.test(round(n * 1/12), n); b2 <- binom.test(round(n * 0.25), n)
  say("%6d | %5.1f-%5.1f%% (w=%4.1f) | %5.1f-%5.1f%% (w=%4.1f)\n", n,
      100*b1$conf.int[1], 100*b1$conf.int[2], ci_w(n*1/12, n),
      100*b2$conf.int[1], 100*b2$conf.int[2], ci_w(n*0.25, n))
}

say("\nCurrent audit set after the literature expansion: n = %d gene rows.\n", nrow(m))
b <- binom.test(1, nrow(m))
say("If the reproduction count stayed at 1, the CI would be %.1f-%.1f%%\n",
    100*b$conf.int[1], 100*b$conf.int[2])
say("(vs 0.2-38.5%% at n=12) — narrower, but the upper bound is still high enough\n")
say("that 'few reproduce' is supportable while an exact rate is not.\n")

say("\nINTERPRETATION: the expansion materially improves precision but does not\n")
say("license a point estimate. The defensible claim is directional — most\n")
say("nominations do not reproduce under a uniform standard — not a percentage.\n")

close(con)
cat("\nWritten: outputs/PUBLISHABILITY_ANALYSIS.txt\n")
