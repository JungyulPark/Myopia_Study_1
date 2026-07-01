# ============================================================================
# HIGH-VALUE ANALYSIS 08 — coloc-SuSiE UPGRADE (multiple causal variants)
# ----------------------------------------------------------------------------
# WHY: our primary colocalization used coloc.abf, which assumes a SINGLE causal
# variant per locus. coloc.susie relaxes this (allows multiple causal signals)
# and is the current standard. Upgrading strengthens BOTH the positive controls
# (RDH5/CD55 hold under a less restrictive model?) and the negatives (do TGFB1/
# CTNNB1/FBN1 still fail once secondary signals are modelled?).
#
# HONEST FRAMING (locked):
#   - This re-tests the SAME anchors more rigorously; it is a robustness upgrade,
#     not a discovery. Results REPLACE-or-corroborate the coloc.abf numbers, and
#     any change is reported transparently (e.g., "RDH5 remains PP.H4>0.9 under
#     coloc.susie"). A negative that stays negative is reported as such.
#   - No number invented; PP.H4 per signal pair comes from this run.
#
# METHOD: susie_rss on the eQTL and on the GWAS in the same LD window, then
#   coloc.susie() over the two sets of credible sets. Reuses the LD infrastructure
#   from discovery/D2_finemap_unverified_loci.R (matched-ancestry reference).
#
# DEPENDENCIES: coloc (>=5), susieR, data.table   (LD reference via D2)
# ============================================================================

suppressMessages({ library(coloc); library(susieR); library(data.table) })
out_dir <- if (dir.exists("c:/Projectbulid")) "c:/Projectbulid/Submit_Manuscript/value_add" else "."

# ---- CONFIG (resolve paths; mirror 09_coloc_full_local.R + D2 LD provider) ---
EQTL_FILE <- "c:/Projectbulid/CP3/data/2019-12-11-cis-eQTLsFDR-ProbeLevel-CohortInfoRemoved-BonferroniAdded.txt.gz"
EQTL_N    <- 31684
VCF_FILE  <- "c:/Projectbulid/CP3/data/ukb-b-6353.vcf.gz"
# get_LD(snps, chr, start, end, tag) from D2 (1000G EUR PLINK --r, or precomputed .ld.rds)
source_D2_LD <- "Submit_Manuscript/value_add/discovery/D2_finemap_unverified_loci.R"  # reuse get_LD

anchors <- list(
  RDH5   = list(ensembl="ENSG00000135437", chr=12, pos=56115278),
  CD55   = list(ensembl="ENSG00000196352", chr=1,  pos=207494853),
  CTNNB1 = list(ensembl="ENSG00000168036", chr=3,  pos=41240936),
  FBN1   = list(ensembl="ENSG00000166147", chr=15, pos=48700503)
)
WINDOW <- 5e5

# NOTE: implement/borrow get_LD() and the eQTL+VCF readers from D2/09 scripts.
# Pseudocode of the core per anchor (kept explicit so the PI wires the readers):
#   1. window <- SNPs within +/-WINDOW of anchor pos in BOTH eQTL(gene) and GWAS
#   2. R <- get_LD(window$SNP, chr, start, end, tag)   # matched-ancestry LD
#   3. S_eqtl <- runsusie(list(beta=..., varbeta=..., N=EQTL_N, LD=R, type="quant"))
#      S_gwas <- runsusie(list(beta=..., varbeta=..., MAF=..., N=..., LD=R, type="cc"))
#   4. res <- coloc.susie(S_eqtl, S_gwas)     # PP.H4 per credible-set pair
#   5. record max PP.H4 across signal pairs + n signals each trait

run_susie_coloc <- function(name) {
  g <- anchors[[name]]
  cat(sprintf("\n=== %s (coloc.susie) ===\n", name))
  # <- PI: assemble d_eqtl / d_gwas / LD here, then:
  # S1 <- runsusie(d_eqtl); S2 <- runsusie(d_gwas)
  # cs <- coloc.susie(S1, S2)
  # best <- if (!is.null(cs$summary)) max(cs$summary$PP.H4.abf) else NA
  # data.table(gene=name, n_signal_eqtl=length(S1$sets$cs), n_signal_gwas=length(S2$sets$cs),
  #            best_PP.H4_susie = best)
  cat("  [stub] wire eQTL/GWAS/LD readers (from 09_coloc_full_local.R + D2 get_LD), then coloc.susie()\n")
  data.table(gene = name, n_signal_eqtl = NA, n_signal_gwas = NA, best_PP.H4_susie = NA_real_,
             note = "fill from coloc.susie run")
}

out <- rbindlist(lapply(names(anchors), run_susie_coloc), fill = TRUE)
fwrite(out, file.path(out_dir, "coloc_susie_results.csv"))
cat("\nWROTE coloc_susie_results.csv\n"); print(out)
cat("\nINTERPRET: compare best_PP.H4_susie to the coloc.abf PP.H4. RDH5 expected to\n",
    "hold (robust); CD55 tests prior-sensitivity under the multi-signal model;\n",
    "TGFB1/CTNNB1/FBN1 expected to remain non-colocalizing (report either way).\n", sep="")
