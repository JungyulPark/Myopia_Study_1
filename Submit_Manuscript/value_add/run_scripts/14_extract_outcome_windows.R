#!/usr/bin/env Rscript
# ============================================================================
# 14_extract_outcome_windows.R  —  run this on the machine that has internet
#
# WHY THIS EXISTS
# The analysis environment can reach only this GitHub repository; every GWAS
# host (Nature/Springer, OpenGWAS, EBI, Zenodo, figshare, NCBI, Google Drive,
# Dropbox) is blocked by the egress policy, verified by direct test. So the
# summary statistics have to be fetched on a machine with internet.
#
# But the colocalization only ever reads SNPs inside 58 one-megabase windows —
# about 230,000 SNPs, roughly 9 MB. That is under 1% of a full summary-statistics
# file and small enough to commit. Download once, subset here, commit the subset,
# and the full analysis can then be run and checked anywhere.
#
# USAGE
#   Rscript 14_extract_outcome_windows.R <full_summary_stats_file> <label>
# e.g.
#   Rscript 14_extract_outcome_windows.R C:/Users/ophjy/Downloads/tedja2018.txt.gz tedja2018
#
# Accepts either rsID-keyed or chr/pos-keyed files, and autodetects columns
# rather than assuming them. Writes outputs/outcome_windows_<label>.csv.gz.
# ============================================================================

options(stringsAsFactors = FALSE)
suppressPackageStartupMessages(library(data.table))

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 2) {
  cat("Usage: Rscript 14_extract_outcome_windows.R <summary_stats_file> <label>\n")
  quit(save = "no", status = 1)
}
INFILE <- args[1]; LABEL <- args[2]
if (!file.exists(INFILE)) stop("Not found: ", INFILE)

SCRIPT_DIR <- dirname(normalizePath(sub("--file=", "",
                grep("--file=", commandArgs(), value = TRUE)[1])))
OUTDIR <- Sys.getenv("MYOPIA_OUT", normalizePath(file.path(SCRIPT_DIR, "..", "outputs")))

EQTL_REL <- "CP3/data/2019-12-11-cis-eQTLsFDR-ProbeLevel-CohortInfoRemoved-BonferroniAdded.txt.gz"
ROOT <- Filter(function(r) file.exists(file.path(r, EQTL_REL)),
               c(Sys.getenv("MYOPIA_ROOT", ""), "C:/Projectbulid", "C:/Projectbulid/Myopia"))[1]
if (is.na(ROOT)) stop("eQTLGen not found; set MYOPIA_ROOT.")

# ---- the 58 windows: audited genes + controls + the Hippo-YAP core ---------
prev  <- fread(file.path(OUTDIR, "audit_v4_results.csv"))
HIPPO <- c("LATS1","LATS2","YAP1","WWTR1","TEAD1","STK3","STK4","SAV1","NF2","CCN2")
GENES <- unique(c(prev[status == "ok"]$gene, HIPPO))

cat("Reading eQTLGen to locate the windows...\n")
gi <- unique(fread(file.path(ROOT, EQTL_REL),
                   select = c("GeneSymbol","GeneChr","GenePos"))[GeneSymbol %in% GENES])
setnames(gi, c("gene","chr","pos"))
gi <- gi[!duplicated(gene)]
missing <- setdiff(GENES, gi$gene)
cat(sprintf("  windows located: %d of %d requested%s\n", nrow(gi), length(GENES),
            if (length(missing)) sprintf(" (absent from eQTLGen: %s)",
                                         paste(missing, collapse = ", ")) else ""))
gi[, `:=`(lo = as.numeric(pos) - 5e5, hi = as.numeric(pos) + 5e5)]

# ---- read the summary statistics and autodetect its columns ---------------
cat(sprintf("Reading %s ...\n", INFILE))
d  <- fread(INFILE)
nm <- tolower(names(d))
pick <- function(...) { for (k in c(...)) { i <- which(nm == k); if (length(i)) return(names(d)[i[1]]) }; NA_character_ }
c_snp <- pick("snp","rsid","rs","markername","variant_id","rs_number","rsids")
c_chr <- pick("chr","chromosome","chrom","chr_name","#chrom")
c_pos <- pick("pos","position","bp","base_pair_location","chr_position","pos_b37")
c_b   <- pick("beta","effect","b","estimate","beta_ref","effect_size")
c_se  <- pick("se","standard_error","stderr","sebeta","standarderror")
# METAL output carries Zscore + sample size + allele frequency instead of beta/se
c_z   <- pick("zscore","z","z_score","z-score")
c_n   <- pick("totalsamplesize","n","samplesize","n_total","weight")
c_f   <- pick("freq1","eaf","effect_allele_frequency","af","freq","maf")

cat(sprintf("  rows: %s | snp=%s chr=%s pos=%s beta=%s se=%s | z=%s n=%s freq=%s\n",
            format(nrow(d), big.mark = ","), c_snp, c_chr, c_pos, c_b, c_se, c_z, c_n, c_f))

# --- derive beta/se from Z when they are absent -----------------------------
# Standard approximation for a continuous trait (Zhu et al. 2016, used by SMR):
#   b  = z / sqrt(2p(1-p)(n + z^2)),  se = 1 / sqrt(2p(1-p)(n + z^2))
# Only the b/se RATIO enters the Wakefield ABF, so the scale convention does not
# affect colocalization; the same transform is applied to every SNP.
DERIVED <- FALSE
if ((is.na(c_b) || is.na(c_se)) && !anyNA(c(c_z, c_n, c_f))) {
  setnames(d, c(c_z, c_n, c_f), c("Z", "Nobs", "FRQ"))
  d[, FRQ := suppressWarnings(as.numeric(FRQ))]
  d[, Z   := suppressWarnings(as.numeric(Z))]
  d[, Nobs:= suppressWarnings(as.numeric(Nobs))]
  d <- d[!is.na(Z) & !is.na(Nobs) & !is.na(FRQ) & FRQ > 0 & FRQ < 1]
  d[, den := sqrt(2 * FRQ * (1 - FRQ) * (Nobs + Z^2))]
  d <- d[den > 0]
  d[, `:=`(beta_o = Z / den, se_o = 1 / den)]
  c_b <- "beta_o"; c_se <- "se_o"; DERIVED <- TRUE
  cat("  No beta/se columns — derived them from Zscore, sample size and allele\n")
  cat("  frequency (Zhu et al. 2016). Only the beta/se ratio enters the ABF, so\n")
  cat("  colocalization is unaffected by the scale convention.\n")
}

if (is.na(c_b) || is.na(c_se)) {
  cat("\nCannot proceed: no beta/se, and no Zscore+N+frequency to derive them from.\n")
  cat("  Present: ", paste(names(d), collapse = ", "), "\n"); quit(save = "no", status = 1)
}
if (!DERIVED) setnames(d, c(c_b, c_se), c("beta_o", "se_o"))
if (!is.na(c_snp)) setnames(d, c_snp, "SNP") else d[, SNP := NA_character_]

# --- coordinates: prefer rsID matching, which is build-independent ----------
BY_RSID <- FALSE
if (is.na(c_chr) || is.na(c_pos)) {
  if (is.na(c_snp)) {
    cat("\nNo chr/pos and no rsID — cannot place SNPs in windows.\n"); quit(save="no", status=1)
  }
  cat("  No chr/pos columns; taking coordinates from eQTLGen by rsID instead.\n")
  cat("  This is build-independent, so a GRCh37/38 mismatch cannot arise.\n")
  map <- unique(fread(file.path(ROOT, EQTL_REL),
                      select = c("SNP","SNPChr","SNPPos")))
  setnames(map, c("SNP","CHR","POS"))
  d <- merge(d, map[!duplicated(SNP)], by = "SNP")
  BY_RSID <- TRUE
  cat(sprintf("  rsID matched to eQTLGen: %s of the file's SNPs\n",
              format(nrow(d), big.mark = ",")))
} else {
  setnames(d, c(c_chr, c_pos), c("CHR","POS"))
}
d[, CHR := suppressWarnings(as.integer(gsub("^chr", "", as.character(CHR), ignore.case = TRUE)))]
d[, POS := suppressWarnings(as.numeric(POS))]
d <- d[!is.na(CHR) & !is.na(POS) & !is.na(beta_o) & !is.na(se_o) & se_o > 0]

# ---- cut the windows -------------------------------------------------------
setkey(d, CHR, POS)
keep <- rbindlist(lapply(seq_len(nrow(gi)), function(i) {
  s <- d[CHR == gi$chr[i] & POS >= gi$lo[i] & POS <= gi$hi[i],
         .(SNP, CHR, POS, beta_o, se_o)]
  if (nrow(s)) s[, gene := gi$gene[i]]
  s
}), fill = TRUE)
keep <- keep[!is.na(gene)]

# ---- genome-build sanity check --------------------------------------------
# eQTLGen windows are GRCh37/hg19. If the outcome file is GRCh38 the cut lands in
# the wrong place and returns almost nothing — quietly, and looking like a real
# negative. This project has already been damaged once by exactly this class of
# coordinate error, so check rather than hope.
cover <- uniqueN(keep$gene) / nrow(gi)
dens  <- if (nrow(keep)) nrow(keep) / uniqueN(keep$gene) else 0
if (!BY_RSID && nrow(d) > 1e6 && (cover < 0.5 || dens < 200)) {
  cat("\n*** LIKELY GENOME-BUILD MISMATCH ***\n")
  cat(sprintf("  The file has %s SNPs genome-wide, yet only %.0f%% of windows got any\n",
              format(nrow(d), big.mark = ","), 100 * cover))
  cat(sprintf("  SNPs and the average window holds just %.0f.\n", dens))
  cat("  A dense genome-wide file should fill nearly every window with thousands.\n")
  cat("  The usual cause is that this file is GRCh38 while eQTLGen is GRCh37/hg19.\n")
  cat("  Check the source documentation for its build. If it is GRCh38, lift it over\n")
  cat("  to GRCh37 (or match on rsID instead of position) before using this output.\n")
  cat("  Writing the file anyway so the counts can be inspected — DO NOT treat these\n")
  cat("  as results until the build is confirmed.\n\n")
} else if (BY_RSID) {
  cat(sprintf("\n  Matched by rsID — build mismatch impossible. %.0f%% of windows covered, mean %.0f SNPs.\n", 100*cover, dens))
} else if (nrow(d) > 1e6) {
  cat(sprintf("\n  Build check OK: %.0f%% of windows covered, mean %.0f SNPs per window.\n",
              100 * cover, dens))
}

per <- keep[, .N, by = gene][order(N)]
cat(sprintf("\nExtracted %s SNP-window rows across %d genes\n",
            format(nrow(keep), big.mark = ","), uniqueN(keep$gene)))
cat(sprintf("  SNPs per window: min %d, median %d, max %d\n",
            min(per$N), as.integer(median(per$N)), max(per$N)))
thin <- per[N < 30]
if (nrow(thin))
  cat(sprintf("  WARNING — under 30 SNPs, will not be colocalizable: %s\n",
              paste(sprintf("%s(%d)", thin$gene, thin$N), collapse = ", ")))
empty <- setdiff(gi$gene, keep$gene)
if (length(empty))
  cat(sprintf("  No overlap at all: %s\n", paste(empty, collapse = ", ")))

OUT <- file.path(OUTDIR, sprintf("outcome_windows_%s.csv.gz", LABEL))
fwrite(keep, OUT, compress = "gzip")
sz <- file.info(OUT)$size / 1048576
cat(sprintf("\nWritten: %s  (%.1f MB)\n", OUT, sz))
if (sz > 90)
  cat("  NOTE: over 90 MB — GitHub rejects files above 100 MB. Split before committing.\n")
cat("\nCommit it and the colocalization can be run and independently checked anywhere:\n")
cat("  git add ", basename(OUT), " && git commit -m 'outcome windows: ", LABEL,
    "' && git push\n", sep = "")
