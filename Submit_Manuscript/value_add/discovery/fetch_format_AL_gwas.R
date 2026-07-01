# ============================================================================
# fetch_format_AL_gwas.R — reshape a downloaded axial-length GWAS into the schema
#   AXIAL_DISCOVERY_local.R expects:  data.table(SNP, CHR, POS, beta, se, eaf[, N])
# ----------------------------------------------------------------------------
# WHY: getting the axial-length GWAS is a separate task. Once the PI downloads a
# summary-stats file (GWAS Catalog harmonized FTP, or a local UKB AL GWAS), this
# maps its columns to the canonical schema so the discovery scan runs unchanged.
#
# NO OpenGWAS needed. Network only if you download here; otherwise point to a local file.
#
# GWAS Catalog harmonized files use a standard column set:
#   hm_rsid, hm_chrom, hm_pos, hm_beta, standard_error, hm_effect_allele_frequency
# (older/raw files vary — inspect names() first and adjust the mapping block).
# ============================================================================

suppressMessages(library(data.table))

# ---- CONFIG -----------------------------------------------------------------
IN_FILE  <- "c:/Projectbulid/Myopia/data/AL_gwas_downloaded.tsv.gz"  # <- the file you downloaded
OUT_FILE <- "c:/Projectbulid/Myopia/data/axial_length_gwas.txt.gz"  # <- what AXIAL_DISCOVERY_local.R reads
BUILD_NOTE <- "CONFIRM genome build matches eQTLGen (GRCh37/hg19). If GRCh38, liftOver POS first."

stopifnot(file.exists(IN_FILE))
d <- fread(IN_FILE)
cat("Columns found:\n"); print(names(d))

# ---- MAP columns -> canonical schema (edit RHS to match your file) ----------
# Example for a GWAS Catalog harmonized file:
map <- list(
  SNP  = "hm_rsid",
  CHR  = "hm_chrom",
  POS  = "hm_pos",
  beta = "hm_beta",
  se   = "standard_error",
  eaf  = "hm_effect_allele_frequency"
)
# --- verify each source column exists; stop with a helpful message if not ---
missing <- setdiff(unlist(map), names(d))
if (length(missing)) stop("These expected source columns are absent -> edit `map`: ",
                          paste(missing, collapse=", "),
                          "\nAvailable: ", paste(names(d), collapse=", "))

out <- d[, .(SNP = get(map$SNP), CHR = get(map$CHR), POS = get(map$POS),
             beta = as.numeric(get(map$beta)), se = as.numeric(get(map$se)),
             eaf = as.numeric(get(map$eaf)))]
if ("N" %in% names(d)) out[, N := d$N]
out <- out[!is.na(SNP) & SNP != "" & !is.na(beta) & !is.na(se) & !is.na(eaf) & eaf>0 & eaf<1][!duplicated(SNP)]

fwrite(out, OUT_FILE, sep="\t")
cat("\nWROTE", OUT_FILE, "  rows:", nrow(out), "\n")
cat("!!", BUILD_NOTE, "\n")
cat("Now set AL_FILE <-", OUT_FILE, "in AXIAL_DISCOVERY_local.R and run it (no OpenGWAS).\n")
