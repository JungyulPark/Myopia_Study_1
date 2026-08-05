#!/usr/bin/env Rscript
# ============================================================================
# 09_screening_agreement.R
#
# Agreement between the automated keyword screen (08_literature_screen.py) and
# the reader adjudication of the same records, reported as Cohen's kappa with a
# normal-approximation 95% CI.
#
# WHAT THIS IS NOT: this is not the two-independent-reader agreement that
# LITERATURE_SEARCH_PROTOCOL.md sec.5 specifies. Both arms here originate from a
# single reader-plus-filter pass, so kappa measures how well the cheap automated
# filter reproduces the adjudicated decision - useful for showing the filter did
# not silently drop eligible studies, and nothing more. The human second reader
# remains outstanding (protocol sec.10).
#
# Inputs : outputs/literature_screening_log.csv  (automated verdicts)
#          outputs/published_targets_master.csv  (adjudicated includes)
# Output : outputs/SCREENING_AGREEMENT.txt
# ============================================================================

suppressMessages(library(data.table))

ROOT   <- normalizePath(file.path(dirname(sub("--file=", "", grep("--file=", commandArgs(), value = TRUE)[1])), ".."))
OUTDIR <- file.path(ROOT, "outputs")

log    <- fread(file.path(OUTDIR, "literature_screening_log.csv"), colClasses = list(character = "pmid"))
master <- fread(file.path(OUTDIR, "published_targets_master.csv"), colClasses = list(character = "source_pmid"))

included_pmids <- unique(as.character(master$source_pmid))

log[, auto_include  := verdict == "INCLUDE_candidate"]
log[, final_include := pmid %in% included_pmids]

con <- file(file.path(OUTDIR, "SCREENING_AGREEMENT.txt"), open = "wt")
say <- function(...) { cat(sprintf(...), file = con); cat(sprintf(...)) }

say("SCREENING AGREEMENT — automated filter vs reader adjudication\n")
say("Records: %d (round-1 search set)\n", nrow(log))
say("%s\n\n", strrep("=", 70))

tab <- table(factor(log$auto_include,  c(FALSE, TRUE)),
             factor(log$final_include, c(FALSE, TRUE)))
say("Confusion matrix (rows = automated, cols = adjudicated)\n")
say("%14s %10s %10s\n", "", "excl", "incl")
say("%14s %10d %10d\n", "auto-exclude", tab[1, 1], tab[1, 2])
say("%14s %10d %10d\n", "auto-include", tab[2, 1], tab[2, 2])

n   <- sum(tab)
po  <- sum(diag(tab)) / n
pe  <- sum(rowSums(tab) * colSums(tab)) / n^2
k   <- (po - pe) / (1 - pe)
se  <- sqrt(po * (1 - po) / (n * (1 - pe)^2))
lo  <- k - 1.96 * se; hi <- k + 1.96 * se

say("\nObserved agreement  : %.3f\n", po)
say("Expected by chance  : %.3f\n", pe)
say("Cohen's kappa       : %.3f (95%% CI %.3f-%.3f)\n", k, lo, hi)

interp <- if (k < 0.20) "slight" else if (k < 0.40) "fair" else
          if (k < 0.60) "moderate" else if (k < 0.80) "substantial" else "almost perfect"
say("Strength (Landis-Koch): %s\n", interp)

# The operationally important quantity: did the cheap filter lose anything?
fn <- log[auto_include == FALSE & final_include == TRUE]
fp <- log[auto_include == TRUE  & final_include == FALSE]
say("\nSensitivity of the automated filter : %.1f%% (%d/%d eligible retained)\n",
    100 * tab[2, 2] / sum(tab[, 2]), tab[2, 2], sum(tab[, 2]))
say("False-positive burden               : %d records read but excluded\n", nrow(fp))
if (nrow(fn)) {
  say("\n[WARNING] %d eligible study/studies were NOT flagged by the filter:\n", nrow(fn))
  for (i in seq_len(nrow(fn))) say("  PMID %s — %s\n", fn$pmid[i], substr(fn$title[i], 1, 70))
  say("  These were recovered only because every candidate was read manually.\n")
} else {
  say("\nNo eligible study was missed by the automated filter.\n")
}

say("\nCAVEAT: not a two-independent-reader kappa. See the header of this script\n")
say("and LITERATURE_SEARCH_PROTOCOL.md sec.10 — the human second reader is outstanding.\n")

close(con)
cat("\nWritten: outputs/SCREENING_AGREEMENT.txt\n")
