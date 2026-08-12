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

cat(sprintf("  rows: %s | columns detected: snp=%s chr=%s pos=%s beta=%s se=%s\n",
            format(nrow(d), big.mark = ","), c_snp, c_chr, c_pos, c_b, c_se))
if (is.na(c_b) || is.na(c_se)) {
  cat("\nCannot proceed: no beta/se columns found. Present:\n  ",
      paste(names(d), collapse = ", "), "\n")
  cat("Colocalization needs per-SNP effect sizes and standard errors. If this file\n")
  cat("carries only P-values or Z-scores, say so and the script can be adapted —\n")
  cat("do not rename columns by hand and hope.\n")
  quit(save = "no", status = 1)
}
if (is.na(c_chr) || is.na(c_pos)) {
  cat("\nNo chr/pos columns. Windows can only be cut on coordinates.\n")
  cat("Supply a file with chromosome and position, or add them by rsID lookup first.\n")
  quit(save = "no", status = 1)
}
if (nrow(d) < 1e5)
  cat("\nWARNING: only ", nrow(d), " rows. This looks like a lead-SNP table, not\n",
      "genome-wide summary statistics. Colocalization needs the latter.\n", sep = "")

setnames(d, c(c_chr, c_pos, c_b, c_se), c("CHR","POS","beta_o","se_o"))
if (!is.na(c_snp)) setnames(d, c_snp, "SNP") else d[, SNP := paste0(CHR, ":", POS)]
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
