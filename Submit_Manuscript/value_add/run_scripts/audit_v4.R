#!/usr/bin/env Rscript
# ============================================================================
# audit_v4.R — Phases 0, 0e, 2, 3 in one run
#
# Replaces audit_v3_coloc.R. Written and syntax-verified on R 4.3.3; the data it
# needs (eQTLGen 3.6 GB, ukb-b-6353.vcf.gz) live only on the analysis machine.
#
#   Rscript audit_v4.R                 # everything
#   Rscript audit_v4.R --check-only    # coordinate diagnostics, no coloc
#
# ---------------------------------------------------------------------------
# WHY v4 EXISTS — the v3 "not evaluable" verdicts were a coordinate bug
# ---------------------------------------------------------------------------
# v3 selected the coloc window with
#     eqtl_full[Gene == ensembl & SNPChr == chr & abs(SNPPos - tss) <= window]
# while MR instruments were selected by gene ID alone. A wrong chr/tss therefore
# produces exactly the observed signature: instruments exist, coloc window empty,
# and the run reports "not_evaluable_low_blood_expression (n_cis_snps=0)".
#
# All three v3 not-evaluable genes are the three with suspect gene identity:
#   PRMT6  declared chr1:157.56 Mb — PRMT6 is at 1p13.3, not 1q23
#   GATS   declared chr19:15.26 Mb — GATS/CASTOR3 is on chr7q11.23
#   "UBE"  ENSG00000198954         — source gene is UBE2I, ENSG00000103275
#
# v4 removes the failure mode rather than patching the numbers: gene coordinates
# are DERIVED FROM THE eQTLGen FILE ITSELF (the cis file only contains cis-SNPs,
# so the SNPs define the cis region). No TSS is ever hard-coded, so a stale or
# mistyped coordinate cannot silently empty a window again.
# ============================================================================

options(stringsAsFactors = FALSE)
suppressPackageStartupMessages(library(data.table))

ARGS       <- commandArgs(trailingOnly = TRUE)
CHECK_ONLY <- "--check-only" %in% ARGS

# The codebase carries TWO conflicting roots — "C:/Projectbulid" (used by
# CP3/scripts/09_coloc_full_local.R, the engine v3 says it mirrors) and
# "C:/Projectbulid/Myopia" (used by audit_v3). Rather than guess, locate the data.
EQTL_REL <- "CP3/data/2019-12-11-cis-eQTLsFDR-ProbeLevel-CohortInfoRemoved-BonferroniAdded.txt.gz"
VCF_REL  <- "CP3/data/ukb-b-6353.vcf.gz"

find_root <- function() {
  cand <- c(Sys.getenv("MYOPIA_ROOT", ""), "C:/Projectbulid", "C:/Projectbulid/Myopia",
            "c:/Projectbulid", "c:/Projectbulid/Myopia", ".", "..", "../..")
  cand <- cand[nzchar(cand)]
  for (r in cand) if (file.exists(file.path(r, EQTL_REL)) && file.exists(file.path(r, VCF_REL))) return(r)
  stop("Could not locate the data under any candidate root.\n",
       "Tried: ", paste(cand, collapse = ", "), "\n",
       "Set MYOPIA_ROOT to the folder that contains ", EQTL_REL)
}
ROOT      <- find_root()
EQTL_FILE <- file.path(ROOT, EQTL_REL)
VCF_FILE  <- file.path(ROOT, VCF_REL)
OUTDIR    <- file.path(ROOT, "Submit_Manuscript/value_add/outputs")
dir.create(OUTDIR, showWarnings = FALSE, recursive = TRUE)

# Optional inputs — used when present, reported as skipped when not.
RETINA_FILE  <- file.path(ROOT, "CP3/data/EyeGEx_retina_eQTL.txt.gz")
GWASCAT_FILE <- Filter(file.exists, file.path(ROOT,
                  c("raw_data/GWAS_Catalog/gwas_catalog_myopia.tsv",
                    "Myopia/raw_data/GWAS_Catalog/gwas_catalog_myopia.tsv")))[1]
TEDJA_FILE   <- Filter(file.exists, file.path(ROOT,
                  c("data/known_myopia_loci_tedja2018.tsv",
                    "Myopia/data/known_myopia_loci_tedja2018.tsv")))[1]
cat(sprintf("ROOT resolved to: %s\n", ROOT))

eqtl_N <- 31684L; ukb_N <- 460536L; ukb_s <- 0.064
MIN_SNPS <- 30L; WINDOW <- 500000L

# ---------------------------------------------------------------------------
# coloc.abf — use the package when present, otherwise an equivalent base-R
# implementation of Giambartolomei et al. (2014) Wakefield ABFs, so a missing
# CRAN package cannot block the run. Validated in 11_validate_coloc.R.
# ---------------------------------------------------------------------------
logsum <- function(x) { m <- max(x); m + log(sum(exp(x - m))) }

abf_wakefield <- function(beta, varbeta, sd_prior) {
  z  <- beta / sqrt(varbeta)
  r  <- sd_prior^2 / (sd_prior^2 + varbeta)
  0.5 * (log(1 - r) + r * z^2)          # log ABF, H1 vs H0 per SNP
}

coloc_abf_base <- function(d1, d2, p1 = 1e-4, p2 = 1e-4, p12 = 1e-5) {
  sd1 <- if (identical(d1$type, "cc")) 0.2 else 0.15
  sd2 <- if (identical(d2$type, "cc")) 0.2 else 0.15
  l1 <- abf_wakefield(d1$beta, d1$varbeta, sd1)
  l2 <- abf_wakefield(d2$beta, d2$varbeta, sd2)
  lH1 <- logsum(l1); lH2 <- logsum(l2); lH4 <- logsum(l1 + l2)
  # H3: causal in both, different SNPs = all cross pairs minus the shared ones
  # log(sum_{i!=j} ABF1_i*ABF2_j) computed stably in log space
  lH3 <- lH1 + lH2 + log1p(-exp(pmin(lH4 - lH1 - lH2, -1e-12)))
  lp  <- c(H0 = 0,
           H1 = log(p1)  + lH1,
           H2 = log(p2)  + lH2,
           H3 = log(p1) + log(p2) + lH3,
           H4 = log(p12) + lH4)
  pp <- exp(lp - logsum(lp))
  list(summary = c(nsnps = length(d1$beta), PP.H0.abf = pp[["H0"]],
                   PP.H1.abf = pp[["H1"]], PP.H2.abf = pp[["H2"]],
                   PP.H3.abf = pp[["H3"]], PP.H4.abf = pp[["H4"]]))
}

HAVE_COLOC <- requireNamespace("coloc", quietly = TRUE)
run_coloc <- function(d1, d2, p12) {
  if (HAVE_COLOC)
    suppressMessages(coloc::coloc.abf(d1, d2, p1 = 1e-4, p2 = 1e-4, p12 = p12))
  else
    coloc_abf_base(d1, d2, p1 = 1e-4, p2 = 1e-4, p12 = p12)
}

# ---------------------------------------------------------------------------
# Gene set — SYMBOLS ONLY.
# The eQTLGen cis file carries GeneSymbol, Gene (Ensembl), GeneChr and GenePos,
# so identity and coordinates are resolved FROM THE DATA. Nothing is hard-coded,
# which is what makes the v3 failure mode (stale TSS -> empty window) impossible.
# A symbol that eQTLGen does not carry is reported, never guessed at.
# ---------------------------------------------------------------------------
GENES <- list(
  audited_v3 = c("CD34","CD55","WNT3","LCAT","BTN3A1","TSSK6",
                 "PRMT6","SH3YL1","ZKSCAN4","NPAT",
                 "GATS","CASTOR3",          # GATS was renamed CASTOR3; try both
                 "UBE2I"),                  # v3's "UBE" was wrong (Dong et al. name UBE2I)
  phase2_new = c("CPNE1","BDH1","PDGFRA","LRRTM2","PCOLCE","EPHB4",
                 "UTS2","BTBD9","S100A3","LGALS9","TSPAN10"),
  positive_control = c("GJD2","LAMA2","KCNQ5","ZMAT4","RBFOX1","BMP3","RDH5")
)
want <- rbindlist(lapply(names(GENES), function(p)
  data.table(gene = GENES[[p]], phase = p)))

cat("=== AUDIT v4 ===\n")
cat(sprintf("coloc engine : %s\n", if (HAVE_COLOC) "coloc package" else "base-R Wakefield ABF"))
cat(sprintf("symbols requested: %d (%s)\n\n", nrow(want),
            paste(sprintf("%s=%d", names(GENES), lengths(GENES)), collapse = ", ")))

# ---------------------------------------------------------------------------
# Load eQTLGen and resolve symbols
# ---------------------------------------------------------------------------
cat("Reading eQTLGen cis file...\n")
eqtl <- fread(EQTL_FILE, select = c("Pvalue","SNP","SNPChr","SNPPos","Zscore",
                                    "Gene","GeneSymbol","GeneChr","GenePos","NrSamples"))
eqtl <- eqtl[GeneSymbol %in% want$gene]
cat(sprintf("  %d cis-SNP rows covering %d of %d requested symbols\n",
            nrow(eqtl), uniqueN(eqtl$GeneSymbol), nrow(want)))

missing <- setdiff(want$gene, unique(eqtl$GeneSymbol))
if (length(missing))
  cat(sprintf("  NOT PRESENT in eQTLGen (reported, not guessed): %s\n",
              paste(missing, collapse = ", ")))

# ---------------------------------------------------------------------------
# STEP A — coordinate diagnostics. Derive the cis region from the data.
# ---------------------------------------------------------------------------
cat("\n--- Resolved identity and coordinates (from eQTLGen itself) ---\n")
loci <- eqtl[, .(ensembl = Gene[1], gene_chr = GeneChr[1], gene_pos = GenePos[1],
                 chr = as.integer(names(sort(table(SNPChr), decreasing = TRUE))[1]),
                 n_cis = .N, pos_lo = min(SNPPos), pos_hi = max(SNPPos),
                 min_P = min(Pvalue)), by = .(gene = GeneSymbol)]
loci <- merge(want, loci, by = "gene", all.x = TRUE)

# v3's hard-coded values, kept only to show which ones were wrong.
V3 <- data.table(
  gene = c("CD34","CD55","WNT3","LCAT","BTN3A1","TSSK6","PRMT6","SH3YL1",
           "ZKSCAN4","GATS","NPAT"),
  v3_chr = c(1,1,17,16,6,19,1,2,6,19,11),
  v3_tss = c(207994037,207494818,44886026,68133032,26438950,19535895,
             157561046,242775,28259888,15261725,108954747))
loci <- merge(loci, V3, by = "gene", all.x = TRUE)
loci[, v3_offset_Mb := ifelse(is.na(v3_tss) | is.na(gene_pos), NA_real_,
                              abs(as.numeric(gene_pos) - v3_tss) / 1e6)]
loci[, v3_wrong := !is.na(v3_offset_Mb) & (v3_offset_Mb > 1 | v3_chr != gene_chr)]

for (i in seq_len(nrow(loci))) {
  r <- loci[i]
  if (is.na(r$n_cis)) {
    cat(sprintf("  %-9s [%-16s] ABSENT from eQTLGen\n", r$gene, r$phase)); next
  }
  flag <- if (isTRUE(r$v3_wrong))
    sprintf("  <== v3 HAD chr%s:%.2fMb, off by %.1f Mb", r$v3_chr, r$v3_tss/1e6, r$v3_offset_Mb) else ""
  cat(sprintf("  %-9s %-16s chr%-2d TSS %.2f Mb  cis-SNPs=%-6d lead P=%.1e%s\n",
              r$gene, r$ensembl, r$gene_chr, r$gene_pos/1e6, r$n_cis, r$min_P, flag))
}
if (any(loci$v3_wrong, na.rm = TRUE))
  cat(sprintf("\n*** %d gene(s) had a wrong hard-coded locus in v3 — this is the cause of\n    the 'not_evaluable_low_blood_expression' verdicts. ***\n",
              sum(loci$v3_wrong, na.rm = TRUE)))

fwrite(loci, file.path(OUTDIR, "derived_gene_loci.csv"))
cat("\nWritten: derived_gene_loci.csv\n")
if (CHECK_ONLY) { cat("\n--check-only: stopping before coloc.\n"); quit(save = "no") }

cat("\nReading UKB VCF...\n")
vcf <- fread(VCF_FILE, skip = "#CHROM", select = c(1L,2L,3L,10L))
setnames(vcf, c("CHR","POS","ID","UKB"))
sp <- tstrsplit(vcf$UKB, ":")
vcf[, `:=`(beta = as.numeric(sp[[1]]), se = as.numeric(sp[[2]]), eaf = as.numeric(sp[[4]]), rsid = ID)]
vcf <- vcf[!is.na(beta) & !is.na(se) & !is.na(eaf) & eaf > 0 & eaf < 1][!duplicated(rsid)]
setkey(vcf, CHR, POS)
cat(sprintf("  %d SNPs\n", nrow(vcf)))

# ---------------------------------------------------------------------------
# STEP B — per-gene coloc under three priors
# ---------------------------------------------------------------------------
PRIORS <- c(1e-5, 1e-6, 5e-6)
out <- list()

for (i in seq_len(nrow(loci))) {
  r <- loci[i]; gene <- r$gene
  base <- data.table(gene = gene, ensembl = r$ensembl, phase = r$phase,
                     n_cis_eqtl = r$n_cis, derived_chr = r$chr, derived_tss = r$gene_pos,
                     PP.H0 = NA_real_, PP.H1 = NA_real_, PP.H2 = NA_real_,
                     PP.H3 = NA_real_, PP.H4 = NA_real_,
                     PP.H4_p12_1e6 = NA_real_, PP.H4_p12_5e6 = NA_real_,
                     n_shared = NA_integer_, status = NA_character_)

  if (is.na(r$n_cis)) {
    base$status <- "absent_from_eqtlgen"; out[[gene]] <- base; next
  }

  centre <- as.integer(r$gene_pos)          # eQTLGen's own TSS, not a literal
  es <- eqtl[GeneSymbol == gene & SNPChr == r$chr & abs(SNPPos - centre) <= WINDOW]
  es <- es[order(Pvalue)][!duplicated(SNP)]
  es[, `:=`(beta_eqtl = Zscore / sqrt(NrSamples), se_eqtl = 1 / sqrt(NrSamples))]

  vs <- vcf[CHR == r$chr & POS >= centre - WINDOW & POS <= centre + WINDOW]
  mg <- merge(es, vs, by.x = "SNP", by.y = "rsid")[!duplicated(SNP)]
  mg <- mg[!is.na(beta_eqtl) & !is.na(beta) & se_eqtl > 0 & se > 0]
  base$n_shared <- nrow(mg)

  if (nrow(mg) < MIN_SNPS) {
    # Distinguish the two causes that v3 conflated.
    base$status <- if (r$n_cis >= MIN_SNPS)
      sprintf("no_overlap_with_ukb (cis=%d, shared=%d) — CHECK rsid build/liftover", r$n_cis, nrow(mg))
    else
      sprintf("sparse_cis_eqtl (cis=%d) — genuinely weak in blood", r$n_cis)
    out[[gene]] <- base; next
  }

  maf <- pmin(mg$eaf, 1 - mg$eaf)
  d1 <- list(beta = mg$beta_eqtl, varbeta = mg$se_eqtl^2, snp = mg$SNP,
             type = "quant", N = eqtl_N, MAF = maf)
  d2 <- list(beta = mg$beta, varbeta = mg$se^2, snp = mg$SNP,
             type = "cc", N = ukb_N, s = ukb_s, MAF = maf)

  pps <- lapply(PRIORS, function(p12) run_coloc(d1, d2, p12)$summary)
  s <- pps[[1]]
  base$PP.H0 <- s[["PP.H0.abf"]]; base$PP.H1 <- s[["PP.H1.abf"]]
  base$PP.H2 <- s[["PP.H2.abf"]]; base$PP.H3 <- s[["PP.H3.abf"]]
  base$PP.H4 <- s[["PP.H4.abf"]]
  base$PP.H4_p12_1e6 <- pps[[2]][["PP.H4.abf"]]
  base$PP.H4_p12_5e6 <- pps[[3]][["PP.H4.abf"]]
  base$status <- "ok"
  cat(sprintf("  %-9s shared=%-5d PP.H4 = %.3f / %.3f / %.3f\n",
              gene, nrow(mg), base$PP.H4, base$PP.H4_p12_1e6, base$PP.H4_p12_5e6))
  out[[gene]] <- base
}

# `loci` already carries every requested symbol (all.x = TRUE), so symbols absent
# from eQTLGen are present exactly once with status "absent_from_eqtlgen".
res <- rbindlist(out)
stopifnot(!anyDuplicated(res$gene), nrow(res) == nrow(want))

fwrite(res, file.path(OUTDIR, "audit_v4_results.csv"))

# ---------------------------------------------------------------------------
# STEP C — positive-control recovery, the pre-registered gate
# ---------------------------------------------------------------------------
pc <- res[phase == "positive_control" & status == "ok"]
cat("\n=== POSITIVE-CONTROL RECOVERY (pre-registered gate, protocol §8) ===\n")
if (nrow(pc) == 0) {
  cat("No positive control produced an evaluable result — the gate CANNOT be assessed.\n")
} else {
  k <- sum(pc$PP.H4 > 0.8); n <- nrow(pc)
  ci <- binom.test(k, n)$conf.int
  cat(sprintf("Recovered at PP.H4 > 0.8: %d/%d (%.0f%%, 95%% CI %.0f-%.0f%%)\n",
              k, n, 100*k/n, 100*ci[1], 100*ci[2]))
  cat(if (k / n >= 0.5)
        ">>> GATE PASSED — negative findings may be reported as non-reproduction.\n"
      else
        ">>> GATE FAILED — per the pre-registered rule the audit's negative findings\n    MUST be reported as UNINFORMATIVE, not as non-reproduction.\n")
}
cat(sprintf("\nWritten: audit_v4_results.csv  (%d rows)\n", nrow(res)))


# ============================================================================
# STEP D — EYE-TISSUE COLOCALIZATION (EyeGEx retina), when the file is present
#
# This is the single biggest caveat on the whole audit: our re-test is blood.
# EyeGEx_retina_eQTL.txt.gz is referenced by 03_eye_tissue_coloc.R and lives on
# this machine, so the check can actually be run. A gene that fails in blood but
# colocalizes in retina is NOT a failed nomination — it is tissue-specific, and
# must be reported that way.
# ============================================================================
if (!file.exists(RETINA_FILE)) {
  cat("\n[STEP D] EyeGEx retina eQTL not found — eye-tissue check SKIPPED.\n")
  cat("         Blood-only scope must then be stated as a limitation.\n")
} else {
  cat("\n[STEP D] Eye-tissue colocalization (EyeGEx retina)\n")
  ret <- fread(RETINA_FILE)
  nm  <- tolower(names(ret))
  pick <- function(...) { for (k in c(...)) { i <- which(nm == k); if (length(i)) return(names(ret)[i[1]]) }; NA_character_ }
  c_snp <- pick("snp","rsid","variant_id","rs_id_dbsnp151_gr" )
  c_gen <- pick("gene","gene_id","ensembl","genesymbol","gene_name")
  c_b   <- pick("beta","slope","effect","b")
  c_se  <- pick("se","slope_se","standard_error","stderr")
  if (anyNA(c(c_snp, c_gen, c_b, c_se))) {
    cat(sprintf("  Column autodetect failed (snp=%s gene=%s beta=%s se=%s).\n",
                c_snp, c_gen, c_b, c_se))
    cat("  Columns present:", paste(names(ret), collapse = ", "), "\n")
    cat("  Set the four column names by hand and re-run STEP D.\n")
  } else {
    setnames(ret, c(c_snp, c_gen, c_b, c_se), c("SNP","GENEKEY","beta_r","se_r"))
    ret <- ret[!is.na(beta_r) & !is.na(se_r) & se_r > 0]
    rows <- list()
    for (i in seq_len(nrow(loci))) {
      r <- loci[i]; if (is.na(r$n_cis)) next
      sub <- ret[GENEKEY == r$gene | GENEKEY == r$ensembl]
      if (nrow(sub) < MIN_SNPS) {
        rows[[r$gene]] <- data.table(gene = r$gene, retina_n = nrow(sub),
                                     retina_PP.H4 = NA_real_,
                                     retina_status = "not_evaluable_in_retina"); next
      }
      vs <- vcf[CHR == r$chr]
      mg <- merge(sub, vs, by.x = "SNP", by.y = "rsid")[!duplicated(SNP)]
      if (nrow(mg) < MIN_SNPS) {
        rows[[r$gene]] <- data.table(gene = r$gene, retina_n = nrow(mg),
                                     retina_PP.H4 = NA_real_,
                                     retina_status = "no_overlap_with_ukb"); next
      }
      maf <- pmin(mg$eaf, 1 - mg$eaf)
      s <- run_coloc(list(beta = mg$beta_r, varbeta = mg$se_r^2, snp = mg$SNP,
                          type = "quant", N = 406L, MAF = maf),
                     list(beta = mg$beta, varbeta = mg$se^2, snp = mg$SNP,
                          type = "cc", N = ukb_N, s = ukb_s, MAF = maf), 1e-5)$summary
      rows[[r$gene]] <- data.table(gene = r$gene, retina_n = nrow(mg),
                                   retina_PP.H4 = s[["PP.H4.abf"]], retina_status = "ok")
      cat(sprintf("  %-9s retina PP.H4 = %.3f (n=%d)\n", r$gene, s[["PP.H4.abf"]], nrow(mg)))
    }
    if (length(rows)) {
      rt <- rbindlist(rows)
      res <- merge(res, rt, by = "gene", all.x = TRUE)
      res[, tissue_discordant := !is.na(PP.H4) & !is.na(retina_PP.H4) &
                                 PP.H4 < 0.5 & retina_PP.H4 > 0.8]
      nd <- sum(res$tissue_discordant, na.rm = TRUE)
      cat(sprintf("\n  Genes failing in blood but colocalizing in retina: %d\n", nd))
      if (nd) cat("  >>> These are TISSUE-SPECIFIC, not failed nominations. Report as such:",
                  paste(res[tissue_discordant == TRUE]$gene, collapse = ", "), "\n")
      fwrite(res, file.path(OUTDIR, "audit_v4_results.csv"))
    }
  }
}

# ============================================================================
# STEP E — NOVELTY (Phase 0e, the part that needs no Nat Genet supplement)
#
# 05_novelty_audit.R hard-coded `tedja_known := FALSE`, so the Tedja 2018 arm was
# never actually evaluated even though the file is on this machine. Both arms are
# run here. The 2026 Nat Genet variant list is a THIRD arm, still outstanding.
# ============================================================================
cat("\n[STEP E] Known-locus adjudication\n")
near <- function(chr, pos, tab, cc, pc, win = 500000L) {
  if (is.null(tab)) return(NA)
  any(tab[[cc]] == chr & abs(as.numeric(tab[[pc]]) - pos) <= win)
}
gc_tab <- if (!is.na(GWASCAT_FILE)) fread(GWASCAT_FILE) else NULL
td_tab <- if (!is.na(TEDJA_FILE))   fread(TEDJA_FILE)   else NULL
cat(sprintf("  GWAS Catalog : %s\n", ifelse(is.null(gc_tab), "NOT FOUND", GWASCAT_FILE)))
cat(sprintf("  Tedja 2018   : %s%s\n", ifelse(is.null(td_tab), "NOT FOUND", TEDJA_FILE),
            ifelse(is.null(td_tab), "", "   <== never evaluated before; v3 stubbed it to FALSE")))

find_col <- function(tab, opts) { if (is.null(tab)) return(NA_character_)
  i <- which(tolower(names(tab)) %in% opts); if (length(i)) names(tab)[i[1]] else NA_character_ }
gc_c <- find_col(gc_tab, c("chr_id","chromosome","chr")); gc_p <- find_col(gc_tab, c("chr_pos","position","pos","bp"))
td_c <- find_col(td_tab, c("chr","chromosome","chr_id"));  td_p <- find_col(td_tab, c("pos","position","bp","chr_pos"))

nov <- loci[!is.na(n_cis), .(gene, chr = gene_chr, pos = gene_pos)]
nov[, in_gwas_catalog := if (!is.na(gc_c) && !is.na(gc_p))
      mapply(function(c, p) near(c, p, gc_tab, gc_c, gc_p), chr, pos) else NA]
nov[, in_tedja2018 := if (!is.na(td_c) && !is.na(td_p))
      mapply(function(c, p) near(c, p, td_tab, td_c, td_p), chr, pos) else NA]
nov[, known_locus := (in_gwas_catalog %in% TRUE) | (in_tedja2018 %in% TRUE)]
nov[, natgenet2026_checked := FALSE]   # third arm — needs PMID 42009823 supplement
print(nov)
fwrite(nov, file.path(OUTDIR, "novelty_v4.csv"))
cat("\nWritten: novelty_v4.csv  (natgenet2026_checked = FALSE for every row — that arm is still outstanding)\n")
