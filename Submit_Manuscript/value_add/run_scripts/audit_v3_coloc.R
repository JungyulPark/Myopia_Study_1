#!/usr/bin/env Rscript
# ============================================================================
# Audit v3: coloc.abf for 12 published myopia MR targets
# Method: LOCAL files only — NO OpenGWAS API, NO JWT required
# Engine: identical to CP3/scripts/09_coloc_full_local.R
# Data:
#   eQTLGen: CP3/data/2019-12-11-cis-eQTLsFDR...txt.gz  (3.6 GB)
#   UKB VCF: CP3/data/ukb-b-6353.vcf.gz                 (227 MB)
# ============================================================================
options(stringsAsFactors = FALSE)
suppressPackageStartupMessages({
  library(data.table)
  library(coloc)
})

cat("=== AUDIT v3: LOCAL coloc.abf (no OpenGWAS) ===\n")
cat(sprintf("Start: %s\n\n", Sys.time()))

ROOT       <- "C:/Projectbulid/Myopia"
EQTL_FILE  <- file.path(ROOT, "CP3/data/2019-12-11-cis-eQTLsFDR-ProbeLevel-CohortInfoRemoved-BonferroniAdded.txt.gz")
VCF_FILE   <- file.path(ROOT, "CP3/data/ukb-b-6353.vcf.gz")
OUTDIR     <- file.path(ROOT, "Submit_Manuscript/value_add/outputs")
PROG_DIR   <- file.path(ROOT, "CP6_assembly/data/coloc_progress_audit")
dir.create(PROG_DIR, showWarnings=FALSE, recursive=TRUE)

# ============================================================================
# GENE LOCI — 12 audit targets (GRCh37, same build as eQTLGen)
# CD55 included as internal validation (known PP.H4=0.80)
# ============================================================================
GENE_LOCI <- list(
  CD55    = list(ensembl="ENSG00000196352", chr=1L,  tss=207494818L, window=500000L),
  CD34    = list(ensembl="ENSG00000174059", chr=1L,  tss=207994037L, window=500000L),
  WNT3    = list(ensembl="ENSG00000108379", chr=17L, tss=44886026L,  window=500000L),
  LCAT    = list(ensembl="ENSG00000213398", chr=16L, tss=68133032L,  window=500000L),
  BTN3A1  = list(ensembl="ENSG00000026950", chr=6L,  tss=26438950L,  window=500000L),
  TSSK6   = list(ensembl="ENSG00000178093", chr=19L, tss=19535895L,  window=500000L),
  PRMT6   = list(ensembl="ENSG00000198890", chr=1L,  tss=157561046L, window=500000L),
  SH3YL1  = list(ensembl="ENSG00000035115", chr=2L,  tss=242775L,    window=500000L),
  ZKSCAN4 = list(ensembl="ENSG00000187626", chr=6L,  tss=28259888L,  window=500000L),
  GATS    = list(ensembl="ENSG00000197256", chr=19L, tss=15261725L,  window=500000L),
  NPAT    = list(ensembl="ENSG00000149308", chr=11L, tss=108954747L, window=500000L),
  UBE     = list(ensembl="ENSG00000198954", chr=11L, tss=6524024L,   window=500000L)
)

# ============================================================================
# STEP 1: Read UKB VCF (227 MB) — once
# ============================================================================
cat("Step 1: Reading UKB Myopia GWAS VCF (227 MB)...\n")
vcf <- fread(VCF_FILE, skip="#CHROM", select=c(1L, 2L, 3L, 10L))
setnames(vcf, c("CHR", "POS", "ID", "UKB"))
ukb_split  <- tstrsplit(vcf$UKB, ":")
vcf$beta   <- as.numeric(ukb_split[[1]])
vcf$se     <- as.numeric(ukb_split[[2]])
vcf$eaf    <- as.numeric(ukb_split[[4]])
vcf$rsid   <- vcf$ID
vcf <- vcf[!is.na(beta) & !is.na(se) & !is.na(eaf) & eaf > 0 & eaf < 1]
vcf <- vcf[!duplicated(rsid)]
setkey(vcf, CHR, POS)
cat(sprintf("  VCF loaded: %d SNPs\n\n", nrow(vcf)))

# ============================================================================
# STEP 2: Read eQTLGen (3.6 GB) — once, subset to needed columns
# ============================================================================
cat("Step 2: Reading eQTLGen full cis-eQTL file (3.6 GB — takes ~2 min)...\n")
eqtl_full <- fread(
  EQTL_FILE,
  select    = c("Pvalue","SNP","SNPChr","SNPPos","Zscore","Gene","NrSamples"),
  col.names = c("Pvalue","SNP","SNPChr","SNPPos","Zscore","Gene","NrSamples")
)
# Keep only target genes
target_ensgs <- sapply(GENE_LOCI, `[[`, "ensembl")
eqtl_full <- eqtl_full[Gene %in% target_ensgs]
cat(sprintf("  eQTLGen loaded and filtered: %d cis-SNP rows for %d target genes\n\n",
            nrow(eqtl_full), length(unique(eqtl_full$Gene))))

# ============================================================================
# STEP 3: Per-gene coloc
# ============================================================================
eqtl_N   <- 31684L
ukb_N    <- 460536L
ukb_s    <- 0.064      # proportion cases (self-reported myopia in UKB)
MIN_SNPS <- 30L        # minimum shared SNPs to attempt coloc

coloc_results <- list()

for (gene in names(GENE_LOCI)) {
  g    <- GENE_LOCI[[gene]]
  ckpt <- file.path(PROG_DIR, paste0(gene, "_local.rds"))

  # Resume: skip if already computed in this audit run
  if (file.exists(ckpt)) {
    cat(sprintf("[%s] Loading cached result\n", gene))
    coloc_results[[gene]] <- readRDS(ckpt)
    next
  }

  cat(sprintf("\n========== %s (chr%d, tss=%d, ensg=%s) ==========\n",
              gene, g$chr, g$tss, g$ensembl))

  # --- eQTL: filter to gene + ±500kb window ---
  eqtl_sub <- eqtl_full[Gene == g$ensembl &
                         SNPChr == g$chr &
                         abs(SNPPos - g$tss) <= g$window]
  eqtl_sub <- eqtl_sub[order(Pvalue)]
  eqtl_sub <- eqtl_sub[!duplicated(SNP)]
  cat(sprintf("  eQTL regional SNPs: %d\n", nrow(eqtl_sub)))

  if (nrow(eqtl_sub) < MIN_SNPS) {
    status <- sprintf("not_evaluable_low_blood_expression (n_cis_snps=%d)", nrow(eqtl_sub))
    cat(sprintf("  → %s\n", status))
    res <- list(gene=gene, status=status, PP.H1=NA, PP.H3=NA, PP.H4=NA,
                n_shared=nrow(eqtl_sub), interpretation="not_evaluable_blood")
    saveRDS(res, ckpt); coloc_results[[gene]] <- res; next
  }

  # beta/se from Z-score (standard eQTLGen convention)
  eqtl_sub[, beta_eqtl := Zscore / sqrt(NrSamples)]
  eqtl_sub[, se_eqtl   := 1.0    / sqrt(NrSamples)]

  # --- UKB: filter to same chromosome + window ---
  lo  <- g$tss - g$window
  hi  <- g$tss + g$window
  vcf_sub <- vcf[CHR == g$chr & POS >= lo & POS <= hi]

  # --- Merge on rsid ---
  merged <- merge(eqtl_sub, vcf_sub, by.x="SNP", by.y="rsid")
  merged <- merged[!duplicated(SNP)]
  cat(sprintf("  Merged overlapping SNPs: %d\n", nrow(merged)))

  if (nrow(merged) < MIN_SNPS) {
    status <- sprintf("insufficient_shared_snps (n=%d)", nrow(merged))
    cat(sprintf("  → %s\n", status))
    res <- list(gene=gene, status=status, PP.H1=NA, PP.H3=NA, PP.H4=NA,
                n_shared=nrow(merged), interpretation="not_evaluable_blood")
    saveRDS(res, ckpt); coloc_results[[gene]] <- res; next
  }

  # Remove any rows with NA or zero variance
  ok <- !is.na(merged$beta_eqtl) & !is.na(merged$se_eqtl) &
        !is.na(merged$beta)      & !is.na(merged$se) &
        merged$se_eqtl > 0       & merged$se > 0
  merged <- merged[ok]
  cat(sprintf("  After NA/0-var filter: %d SNPs\n", nrow(merged)))

  if (nrow(merged) < MIN_SNPS) {
    status <- sprintf("insufficient_clean_snps (n=%d after filter)", nrow(merged))
    res <- list(gene=gene, status=status, PP.H1=NA, PP.H3=NA, PP.H4=NA,
                n_shared=nrow(merged), interpretation="not_evaluable_blood")
    saveRDS(res, ckpt); coloc_results[[gene]] <- res; next
  }

  # --- Build coloc datasets ---
  maf <- pmin(merged$eaf, 1 - merged$eaf)

  dataset1 <- list(
    beta    = merged$beta_eqtl,
    varbeta = merged$se_eqtl^2,
    snp     = merged$SNP,
    position= merged$SNPPos,
    type    = "quant",
    N       = eqtl_N,
    MAF     = maf
  )
  dataset2 <- list(
    beta    = merged$beta,
    varbeta = merged$se^2,
    snp     = merged$SNP,
    position= merged$SNPPos,
    type    = "cc",
    N       = ukb_N,
    s       = ukb_s,
    MAF     = maf
  )

  # --- Run coloc.abf (3 prior sets as in recalc script) ---
  cat(sprintf("  Running coloc.abf (%d SNPs)...\n", nrow(merged)))
  cr <- tryCatch(
    coloc.abf(dataset1, dataset2, p1=1e-4, p2=1e-4, p12=1e-5),
    error=function(e) { cat(sprintf("  coloc.abf error: %s\n", e$message)); NULL }
  )

  if (is.null(cr)) {
    res <- list(gene=gene, status="coloc_error", PP.H1=NA, PP.H3=NA, PP.H4=NA,
                n_shared=nrow(merged), interpretation="not_evaluable_blood")
    saveRDS(res, ckpt); coloc_results[[gene]] <- res; next
  }

  pps  <- cr$summary
  pp4  <- pps[["PP.H4.abf"]]
  pp1  <- pps[["PP.H1.abf"]]
  pp3  <- pps[["PP.H3.abf"]]

  lead_snp <- ""
  if (!is.null(cr$results) && "SNP.PP.H4" %in% names(cr$results))
    lead_snp <- cr$results$snp[which.max(cr$results$SNP.PP.H4)]

  interp <- if      (pp4 > 0.75) "strong_shared"
            else if (pp4 > 0.50) "moderate_shared"
            else if (pp1 > 0.50) "distinct_variants"
            else                 "ambiguous"

  cat(sprintf("  ✅ PP.H4=%.4f, PP.H3=%.4f, PP.H1=%.4f → %s\n",
              pp4, pp3, pp1, interp))

  res <- list(
    gene=gene, status="ok",
    PP.H0=pps[["PP.H0.abf"]], PP.H1=pp1, PP.H2=pps[["PP.H2.abf"]],
    PP.H3=pp3, PP.H4=pp4, n_shared=nrow(merged),
    lead_snp=lead_snp, interpretation=interp
  )
  saveRDS(res, ckpt)
  coloc_results[[gene]] <- res
}

# ============================================================================
# STEP 4: Update published_targets_audit.csv
# ============================================================================
cat("\n\n=== Updating published_targets_audit.csv ===\n")
audit_file <- file.path(OUTDIR, "published_targets_audit.csv")
if (!file.exists(audit_file)) stop("Run audit_v2_run.R first to create the CSV")
audit <- fread(audit_file)

for (gene in names(coloc_results)) {
  r   <- coloc_results[[gene]]
  idx <- which(audit$gene == gene)
  if (length(idx) == 0) next

  audit[idx, coloc_PP_H1   := r$PP.H1]
  audit[idx, coloc_PP_H3   := r$PP.H3]
  audit[idx, coloc_PP_H4   := r$PP.H4]
  audit[idx, coloc_status  := r$status]

  # Update tier
  pp4 <- r$PP.H4
  if (!is.na(pp4)) {
    audit[idx, our_tier :=
            ifelse(pp4 > 0.8, "Tier_A_coloc_supported",
            ifelse(!is.na(audit[idx, mr_pval]) && audit[idx, mr_pval] < 0.05,
                   "Tier_B_MR_only", "Null"))]
  }

  # Update verdict
  mr_pval_i  <- audit[idx, mr_pval]
  mr_sig     <- !is.na(mr_pval_i) && mr_pval_i < 0.05
  cream_p    <- audit[idx, cream_R_pval]
  tedja_p    <- audit[idx, tedja_pval]
  repl_ok    <- (!is.na(cream_p) && cream_p < 0.05) | (!is.na(tedja_p) && tedja_p < 0.05)

  verdict <- if (grepl("not_evaluable|insufficient|error", r$status, ignore.case=TRUE)) {
    paste0("not_evaluable_blood (", r$status, ")")
  } else if (is.na(pp4)) {
    "not_evaluable_blood"
  } else if (pp4 > 0.8 && repl_ok) {
    "reproduced (coloc+replication)"
  } else if (pp4 > 0.8) {
    "MR_coloc_supported_replication_incomplete"
  } else if (r$status == "ok" && pp4 <= 0.8) {
    "not_reproduced_coloc_low"
  } else if (mr_sig) {
    "MR_only"
  } else {
    "MR_null"
  }
  audit[idx, reproduction_verdict := verdict]
}

fwrite(audit, audit_file)
cat(sprintf("Updated: %s\n", audit_file))

# ============================================================================
# STEP 5: AUDIT_SUMMARY_v3.txt
# ============================================================================
summary_file <- file.path(OUTDIR, "AUDIT_SUMMARY_v3.txt")
sink(summary_file)
cat("AUDIT_SUMMARY v3 — coloc.abf computed from LOCAL data for all 12 targets\n")
cat(sprintf("Generated: %s\n", Sys.time()))
cat(strrep("=", 72), "\n")
cat(sprintf("Targets: %d (Wang 2024 n=6; Multi-omics 2024 n=6)\n\n", nrow(audit)))
cat("Method: local eQTLGen cis-eQTL file + local UKB ukb-b-6353.vcf.gz\n")
cat("        coloc.abf(p1=1e-4, p2=1e-4, p12=1e-5), ±500kb cis window\n\n")

cat("--- COLOC RESULTS (de novo computation) ---\n")
for (gene in names(coloc_results)) {
  r   <- coloc_results[[gene]]
  idx <- which(audit$gene == gene)
  pp4 <- if (!is.na(r$PP.H4)) sprintf("%.4f", r$PP.H4) else "  NA  "
  pp1 <- if (!is.na(r$PP.H1)) sprintf("%.4f", r$PP.H1) else "  NA  "
  vrd <- if (length(idx) > 0) audit$reproduction_verdict[idx] else "?"
  cat(sprintf("  %-10s PP.H4=%s PP.H1=%s  n_shared=%-5s  status=%-40s  verdict=%s\n",
              gene, pp4, pp1,
              ifelse(is.null(r$n_shared)||is.na(r$n_shared), "?", r$n_shared),
              r$status, vrd))
}

cat("\n--- VERDICT COUNTS ---\n")
vc <- as.data.frame(table(audit$reproduction_verdict))
names(vc) <- c("verdict", "n")
print(vc, row.names=FALSE)

n_repro    <- sum(audit$reproduction_verdict == "reproduced (coloc+replication)", na.rm=TRUE)
n_col_low  <- sum(audit$reproduction_verdict == "not_reproduced_coloc_low", na.rm=TRUE)
n_col_supp <- sum(audit$reproduction_verdict == "MR_coloc_supported_replication_incomplete", na.rm=TRUE)
n_not_eval <- sum(grepl("not_evaluable_blood", audit$reproduction_verdict), na.rm=TRUE)
n_no_instr <- sum(audit$reproduction_verdict == "no_instrument", na.rm=TRUE)

cat("\n--- KEY FINDINGS ---\n")
cat(sprintf("  Fully reproduced (PP.H4>0.8 + replication p<0.05):  %d/12\n", n_repro))
cat(sprintf("  Coloc-supported only (PP.H4>0.8, repl incomplete):  %d/12\n", n_col_supp))
cat(sprintf("  Coloc computed, PP.H4<=0.8 (not reproduced):        %d/12\n", n_col_low))
cat(sprintf("  Not evaluable in blood eQTLGen (too few cis SNPs):  %d/12\n", n_not_eval))
cat(sprintf("  No blood eQTL instrument at P<5e-6:                 %d/12\n", n_no_instr))

cat("\n--- CAVEATS ---\n")
cat("TISSUE: Wang 2024 used blood+retina eQTL. This pipeline is blood-only.\n")
cat("  Non-reproduction for retina-derived targets may reflect tissue specificity.\n")
cat("METHOD: Multi-omics 2024 used SMR+mQTL; our coloc.abf is complementary.\n")
cat("THRESHOLD: 'no_instrument' = no cis-eQTL at P<5e-6 in blood eQTLGen only.\n")
cat(strrep("=", 72), "\n")
sink()
cat(sprintf("Written: %s\n", summary_file))
cat(sprintf("\n=== AUDIT v3 COMPLETE: %s ===\n", Sys.time()))
