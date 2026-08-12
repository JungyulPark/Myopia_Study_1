#!/usr/bin/env Rscript
# ============================================================================
# 12_hypothesis_profile.R
#
# The headline "PP.H4 > 0.8" count hides the informative part of a coloc result.
# This compares the FULL posterior profile of the published nominations against
# established myopia loci run through the identical pipeline, which separates
# three very different reasons a gene can fail to colocalize:
#
#   H0 dominant : no causal variant detected for either trait  -> no power
#   H1 dominant : eQTL signal present, NO myopia signal in the window
#   H3 dominant : both signals present but at DIFFERENT variants
#
# Only H0 means the test was uninformative. H1 and H3 are positive findings.
#
# Input : outputs/audit_v4_results.csv   (produced by audit_v4.R on real data)
# Output: outputs/HYPOTHESIS_PROFILE.txt
# ============================================================================

suppressMessages(library(data.table))

ROOT   <- normalizePath(file.path(dirname(sub("--file=", "",
            grep("--file=", commandArgs(), value = TRUE)[1])), ".."))
OUTDIR <- file.path(ROOT, "outputs")
r <- fread(file.path(OUTDIR, "audit_v4_results.csv"))[status == "ok"]

r[, grp := ifelse(phase == "positive_control",
                  "established myopia loci", "published nominations")]
r[, top := c("H0","H1","H2","H3","H4")[max.col(as.matrix(.SD))],
  .SDcols = c("PP.H0","PP.H1","PP.H2","PP.H3","PP.H4")]

con <- file(file.path(OUTDIR, "HYPOTHESIS_PROFILE.txt"), open = "wt")
say <- function(...) { cat(sprintf(...), file = con); cat(sprintf(...)) }

say("POSTERIOR PROFILE: nominations vs established myopia loci\n%s\n\n", strrep("=", 72))

for (g in c("established myopia loci", "published nominations")) {
  s <- r[grp == g]
  say("%s (n = %d, median %d shared SNPs)\n", g, nrow(s), as.integer(median(s$n_shared)))
  for (h in c("H0","H1","H2","H3","H4"))
    say("   %s dominant : %2d (%3.0f%%)%s\n", h, sum(s$top == h), 100*mean(s$top == h),
        c(H0 = "   <- uninformative: no power", H1 = "   <- eQTL yes, NO myopia signal",
          H2 = "", H3 = "   <- both signals, DIFFERENT variants",
          H4 = "   <- shared causal variant")[[h]])
  say("   PP.H4 > 0.8   : %2d (%3.0f%%)\n\n", sum(s$PP.H4 > 0.8), 100*mean(s$PP.H4 > 0.8))
}

a <- r[grp == "established myopia loci"]; b <- r[grp == "published nominations"]
say("%s\n", strrep("-", 72))
say("The two groups fail for OPPOSITE reasons:\n")
say("  established loci  -> H3 in %.0f%%: the myopia signal is present and the assay\n",
    100*mean(a$top == "H3"))
say("                       resolves it as a distinct variant from blood expression.\n")
say("  nominations       -> H1 in %.0f%%: blood expression signal is present but the\n",
    100*mean(b$top == "H1"))
say("                       myopia GWAS shows essentially nothing in the window.\n\n")

ft <- fisher.test(matrix(c(sum(a$top == "H3"), nrow(a) - sum(a$top == "H3"),
                           sum(b$top == "H3"), nrow(b) - sum(b$top == "H3")), nrow = 2))
say("H3 dominance, established vs nominated : %.0f%% vs %.0f%%, Fisher P = %.2e\n",
    100*mean(a$top == "H3"), 100*mean(b$top == "H3"), ft$p.value)
say("PP.H4 distribution                     : median %.4f vs %.4f, Wilcoxon P = %.3f\n",
    median(a$PP.H4), median(b$PP.H4),
    suppressWarnings(wilcox.test(a$PP.H4, b$PP.H4))$p.value)
say("H0 dominance (genuine lack of power)   : %d/%d vs %d/%d\n\n",
    sum(a$top == "H0"), nrow(a), sum(b$top == "H0"), nrow(b))

say("WHAT THIS DOES AND DOES NOT SUPPORT\n%s\n", strrep("-", 72))
say("Supported:\n")
say(" - The pipeline is NOT blind to myopia signal. At established loci it detects it\n")
say("   in %.0f%% of cases; H0 dominance is %d of %d. Low PP.H4 is therefore not an\n",
    100*mean(a$top %in% c("H3","H4")), sum(a$top == "H0"), nrow(a))
say("   artefact of missing power, which is what the pooled gate figure suggested.\n")
say(" - Even where myopia signal is certain, blood expression shares the causal variant\n")
say("   in only %.0f%% of loci. Failing colocalization in blood is therefore weak\n",
    100*mean(a$PP.H4 > 0.8))
say("   evidence against a gene, and should not be reported as refutation.\n")
say(" - The nominated loci behave differently from established loci (Fisher P above).\n\n")
say("NOT supported, and must not be claimed:\n")
say(" - That the nominations are false. H1 dominance means no myopia association in\n")
say("   THIS outcome (ukb-b-6353, self-reported myopia). The source studies used other,\n")
say("   sometimes better-powered outcomes, and self-report is a lossy phenotype. Outcome\n")
say("   choice and nomination quality are confounded here and cannot be separated.\n")
say(" - Any sensitivity figure as a property of the assay alone: positive controls map a\n")
say("   GWAS lead SNP to its NEAREST gene, which is often not the causal gene.\n")

close(con)
cat("\nWritten: outputs/HYPOTHESIS_PROFILE.txt\n")
