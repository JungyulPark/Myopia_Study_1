# ============================================================================
# DISCOVERY ENGINE D2 — SuSiE FINE-MAPPING of unverified / candidate loci
# ----------------------------------------------------------------------------
# Part 3 of the novelty wall: confirm a locus's signal points to a CREDIBLE
# CAUSAL gene, not an LD shadow of a known gene. Applied to (a) the "unverified
# Tier-2" hits and (b) any D1 axial-scan candidate.
#
# HONESTY (locked):
#   - A credible set pointing to a NON-known gene + coloc -> promote to candidate
#     novel. A credible set landing on a KNOWN gene -> recovered known (positive
#     control), NOT a discovery. A diffuse/empty credible set -> "not fine-mappable
#     at this power" (honest limitation). No locus is upgraded on fine-mapping alone.
#   - "Unverified" never means "novel"; it means "not yet fine-mapped".
#
# METHOD: susieR::susie_rss on GWAS z-scores + an in-sample-like LD matrix from a
#   reference panel (1000G EUR via PLINK, or the study LD). Reference-LD mismatch
#   inflates false credible sets -> use a matched-ancestry panel and report it.
#
# DEPENDENCIES: susieR, data.table, coloc, (Rfast/Matrix for LD handling)
#   PLINK (external) to build per-locus LD if not supplied.
# ============================================================================

suppressMessages({ library(susieR); library(data.table); library(coloc) })

out_dir <- if (dir.exists("c:/Projectbulid")) "c:/Projectbulid/Submit_Manuscript/value_add/discovery" else "."
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

# ---- CONFIG (resolve per DISCOVERY_PLAN.md step 0) --------------------------
# Loci to fine-map: TSV  gene, chr, start, end  (GRCh37). Include unverified
# Tier-2 genes (IKZF3, H2BC4, MYBPC3, CEP250, CENPM, API5, RABEPK) and any D1
# candidate from discovery_axial_candidates.csv.
LOCI_FILE  <- "c:/Projectbulid/data/finemap_loci.tsv"
# GWAS summary stats for the OUTCOME being fine-mapped (refractive error and/or
# axial length). data.table(SNP, CHR, POS, beta, se, eaf, [n]). Edit parser.
GWAS_FILE  <- "c:/Projectbulid/data/refractive_error_gwas.txt.gz"
GWAS_N     <- 250000                      # outcome sample size (set correctly)
# LD reference: either a precomputed per-locus R matrix dir, OR a PLINK bfile to
# compute on the fly. Provide a function get_LD(snps, chr, start, end) -> matrix.
LD_BFILE   <- "c:/Projectbulid/data/1000G_EUR"   # plink prefix; or set LD_DIR
LD_DIR     <- NA_character_                       # dir of precomputed <locus>.ld

stopifnot(file.exists(LOCI_FILE), file.exists(GWAS_FILE))
loci  <- fread(LOCI_FILE)
cat("=== D2: SuSiE fine-mapping of", nrow(loci), "loci ===\n")

cat("Loading outcome GWAS ...\n")
gw <- fread(GWAS_FILE)
# setnames(gw, c("rsid","chromosome","base_pair","beta","standard_error","eaf"),
#              c("SNP","CHR","POS","beta","se","eaf"))   # <- map names
gw <- gw[!is.na(beta) & !is.na(se)][!duplicated(SNP)]
gw[, z := beta / se]

# LD provider: precomputed file preferred; else compute via PLINK (external call).
get_LD <- function(snps, chr, start, end, tag) {
  if (!is.na(LD_DIR)) {
    f <- file.path(LD_DIR, paste0(tag, ".ld.rds"))
    if (file.exists(f)) { R <- readRDS(f); return(R[snps, snps, drop = FALSE]) }
  }
  # PLINK fallback (run outside R, or via system2); pseudo:
  #   plink --bfile LD_BFILE --chr {chr} --from-bp {start} --to-bp {end} \
  #         --extract <snps> --r square --out tmp_{tag}
  stop("Provide an LD matrix for locus ", tag,
       " (precompute <tag>.ld.rds in LD_DIR, or build with PLINK --r square).")
}

results <- list()
for (i in seq_len(nrow(loci))) {
  L <- loci[i]; tag <- paste0(L$gene, "_", L$chr)
  cat(sprintf("\n--- %s  chr%s:%s-%s ---\n", L$gene, L$chr, L$start, L$end))
  reg <- gw[CHR == L$chr & POS >= L$start & POS <= L$end]
  reg <- reg[is.finite(z)]
  if (nrow(reg) < 10) { cat("  too few SNPs (", nrow(reg), ") — not fine-mappable\n"); next }

  R <- tryCatch(get_LD(reg$SNP, L$chr, L$start, L$end, tag), error = function(e) { cat("  [LD]", conditionMessage(e), "\n"); NULL })
  if (is.null(R)) next
  common <- intersect(reg$SNP, rownames(R)); reg <- reg[SNP %in% common]; R <- R[common, common]
  if (nrow(reg) < 10) { cat("  too few SNPs after LD intersect\n"); next }

  fit <- tryCatch(susie_rss(z = reg$z, R = R, n = GWAS_N, L = 10), error = function(e) { cat("  [susie]", conditionMessage(e), "\n"); NULL })
  if (is.null(fit)) next
  cs <- summary(fit)$cs
  if (is.null(cs) || nrow(cs) == 0) { cat("  diffuse / no credible set — not fine-mappable at this power\n")
    results[[tag]] <- data.table(gene = L$gene, chr = L$chr, n_snp = nrow(reg), cs_size = NA, top_snp = NA, top_pip = NA, note = "no credible set"); next }

  # report the top credible set's lead variant + PIP
  pip <- fit$pip; lead <- reg$SNP[which.max(pip)]
  cs1 <- as.integer(strsplit(cs$variable[1], ",")[[1]])
  results[[tag]] <- data.table(gene = L$gene, chr = L$chr, n_snp = nrow(reg),
                               cs_size = length(cs1), top_snp = lead, top_pip = max(pip),
                               cs_snps = paste(reg$SNP[cs1], collapse=";"),
                               note = "credible set found — annotate lead SNP -> gene; compare to L$gene")
  cat(sprintf("  credible set size %d; lead %s (PIP %.3f)\n", length(cs1), lead, max(pip)))
}

final <- rbindlist(results, fill = TRUE)
fwrite(final, file.path(out_dir, "D2_finemap_results.csv"))
cat("\nWROTE D2_finemap_results.csv\n"); print(final)

cat("\n--- DECISION GATE G-D2 ---\n",
    "- credible-set lead maps (nearest-gene / eQTL) to a NON-known gene + coloc -> candidate novel.\n",
    "- credible set lands on a KNOWN gene -> recovered known (positive control), not a discovery.\n",
    "- no/diffuse credible set -> 'not fine-mappable at current power' (honest limitation).\n",
    "ANNOTATE: map each credible lead SNP to its gene (VEP / nearest TSS / eye eQTL) before claiming.\n", sep="")
