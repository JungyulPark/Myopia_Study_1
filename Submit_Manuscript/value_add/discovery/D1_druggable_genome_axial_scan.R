# ============================================================================
# DISCOVERY ENGINE D1 — DRUGGABLE-GENOME MR SCAN vs AXIAL LENGTH
# ----------------------------------------------------------------------------
# The broad discovery sweep. Axial length (structural driver of pathological
# myopia) is far less MR-interrogated than refractive error. We scan the
# DRUGGABLE GENOME (Finan 2017 / Open Targets tractable set) with cis-eQTL
# instruments against an axial-length GWAS, FDR-correct, colocalize the hits,
# and flag which are NOVEL (not already known refractive-error / myopia loci).
#
# HONESTY (locked):
#   - A hit is "novel" ONLY if it clears the 4-part wall in DISCOVERY_PLAN.md
#     (not a known locus +/-500kb; coloc PP.H4>0.7; fine-map credible via D2;
#     replicates). FDR-significant-but-known = recovered positive control.
#   - The scan is hypothesis-FREE within the druggable set; multiple testing is
#     controlled by FDR, and every hit must still pass coloc + fine-map. No single
#     low p-value is reported as a discovery on its own.
#   - A scan returning no novel coloc-backed hit is an honest, publishable null.
#
# COMPUTE: this iterates thousands of genes -> RUN ON ANTIGRAVITY (the PI machine).
#   Use local eQTLGen + local AL GWAS to avoid OpenGWAS rate limits at this scale;
#   the OpenGWAS path is provided as a fallback for small reruns.
#
# DEPENDENCIES: data.table, TwoSampleMR (or local-MR), coloc, (ieugwasr fallback)
# ============================================================================

suppressMessages({ library(data.table); library(TwoSampleMR); library(ieugwasr); library(coloc) })

out_dir <- if (dir.exists("c:/Projectbulid")) "c:/Projectbulid/Submit_Manuscript/value_add/discovery" else "."
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

# ---- CONFIG (resolve per DISCOVERY_PLAN.md step 0) --------------------------
# Druggable gene list: a TSV with columns  gene, ensembl, chr, tss  (GRCh37).
#   Source: Finan et al. 2017 Sci Transl Med druggable genome, or Open Targets
#   tractable set. Provide the resolved path:
DRUGGABLE_LIST <- "c:/Projectbulid/data/druggable_genome_finan2017.tsv"
# Local eQTLGen cis file (same as 09_coloc_full_local.R):
EQTL_FILE      <- "c:/Projectbulid/CP3/data/2019-12-11-cis-eQTLsFDR-ProbeLevel-CohortInfoRemoved-BonferroniAdded.txt.gz"
EQTL_N         <- 31684
# Axial-length GWAS (LOCAL preferred at this scale). Provide a reader that returns
# data.table(SNP, CHR, POS, beta, se, eaf[, N]). Edit AL_FILE + the parser below.
AL_FILE        <- "c:/Projectbulid/data/axial_length_gwas.txt.gz"   # <- resolve (UKB 5201/5202 or CREAM)
# Known myopia/refractive loci for the novelty filter (GRCh37 positions), TSV:
#   gene, chr, pos   (Tedja 2018 + GWAS Catalog EFO refractive error/myopia)
KNOWN_LOCI     <- "c:/Projectbulid/data/known_myopia_loci_tedja2018.tsv"
WINDOW         <- 5e5
FDR_THRESH     <- 0.05
COLOC_PP4      <- 0.7

stopifnot_msg <- function(cond, msg) if (!cond) stop(msg)
stopifnot_msg(file.exists(DRUGGABLE_LIST), paste("Resolve DRUGGABLE_LIST (PLAN step 0):", DRUGGABLE_LIST))
stopifnot_msg(file.exists(AL_FILE),        paste("Resolve axial-length GWAS AL_FILE (PLAN step 0):", AL_FILE))

cat("=== D1: druggable-genome MR scan vs axial length ===\n")

# ---- load axial-length GWAS (EDIT parser to match the resolved file) --------
cat("Loading axial-length GWAS ...\n")
al <- fread(AL_FILE)
# setnames(al, c("rsid","chromosome","base_pair","beta","standard_error","effect_allele_freq"),
#              c("SNP","CHR","POS","beta","se","eaf"))   # <- map to canonical names
al <- al[!is.na(beta) & !is.na(se) & !is.na(eaf) & eaf > 0 & eaf < 1][!duplicated(SNP)]
cat("  AL SNPs:", nrow(al), "\n")

# ---- load druggable list + known loci ---------------------------------------
drug <- fread(DRUGGABLE_LIST)            # gene, ensembl, chr, tss
known <- if (file.exists(KNOWN_LOCI)) fread(KNOWN_LOCI) else data.table(gene=character(), chr=integer(), pos=numeric())
is_known <- function(chr, pos) nrow(known[chr == ..chr & abs(pos - ..pos) <= WINDOW]) > 0

# ---- stream eQTLGen once, keep only druggable-gene cis rows ------------------
cat("Loading eQTLGen (cis) ...\n")
eqtl <- fread(EQTL_FILE, select = c(1,2,4,7,8,13),
              col.names = c("Pvalue","SNP","SNPPos","Zscore","Gene","NrSamples"))
eqtl <- eqtl[Gene %in% drug$ensembl]
eqtl[, `:=`(beta_eqtl = Zscore / sqrt(NrSamples), se_eqtl = 1 / sqrt(NrSamples))]
setkey(eqtl, Gene)

# ---- per-gene cis-MR (Wald ratio / IVW) + record for FDR --------------------
res <- list()
genes <- drug[ensembl %in% unique(eqtl$Gene)]
cat("Scanning", nrow(genes), "druggable genes with cis-eQTL ...\n")
for (i in seq_len(nrow(genes))) {
  g <- genes[i]; sub <- eqtl[Gene == g$ensembl]
  # cis instruments: genome-wide-ish eQTL, LD-pruned externally if needed
  iv <- sub[Pvalue < 5e-8]
  iv$F <- (iv$beta_eqtl / iv$se_eqtl)^2; iv <- iv[F > 10]
  if (nrow(iv) < 1) next
  m <- merge(iv, al, by = "SNP"); if (nrow(m) < 1) next
  # IVW (or Wald ratio if single IV); harmonisation assumes aligned alleles in prep
  if (nrow(m) == 1) {
    b <- m$beta / m$beta_eqtl; se <- abs(m$se / m$beta_eqtl); p <- 2*pnorm(-abs(b/se)); method <- "Wald"
  } else {
    w <- 1 / (m$se^2); bx <- m$beta_eqtl; by <- m$beta
    b <- sum(w*bx*by)/sum(w*bx^2); se <- sqrt(1/sum(w*bx^2)); p <- 2*pnorm(-abs(b/se)); method <- "IVW"
  }
  res[[g$ensembl]] <- data.table(gene = g$gene, ensembl = g$ensembl, chr = g$chr, tss = g$tss,
                                 n_iv = nrow(m), method = method, b = b, se = se, pval = p)
}
scan <- rbindlist(res, fill = TRUE)
scan[, fdr := p.adjust(pval, "BH")]
scan[, known := mapply(is_known, chr, tss)]
setorder(scan, fdr)
fwrite(scan, file.path(out_dir, "D1_axial_scan_all.csv"))
cat("WROTE D1_axial_scan_all.csv  (", nrow(scan), "genes)\n")

# ---- coloc the FDR-significant hits ------------------------------------------
hits <- scan[fdr < FDR_THRESH]
cat(nrow(hits), "FDR<", FDR_THRESH, "hits ->", sum(!hits$known), "are NOT known loci. Colocalizing ...\n")
coloc_one <- function(g) {
  sub <- eqtl[Gene == g$ensembl]; sub <- sub[abs(SNPPos - g$tss) <= WINDOW]
  m <- merge(sub, al, by = "SNP")[!duplicated(SNP)]; if (nrow(m) < 5) return(NA_real_)
  r <- coloc.abf(list(snp=m$SNP, beta=m$beta_eqtl, varbeta=m$se_eqtl^2, type="quant", N=EQTL_N),
                 list(snp=m$SNP, beta=m$beta, varbeta=m$se^2, type="quant", MAF=m$eaf))
  as.numeric(r$summary["PP.H4.abf"])
}
if (nrow(hits)) hits[, PP.H4 := sapply(seq_len(.N), function(j) coloc_one(hits[j]))]

# ---- final candidate table: the novelty wall (parts 1-2 here; 3-4 downstream)
candidates <- if (nrow(hits)) hits[known == FALSE & !is.na(PP.H4) & PP.H4 > COLOC_PP4][order(-PP.H4)] else hits[0]
fwrite(candidates, file.path(out_dir, "discovery_axial_candidates.csv"))
cat("\n=== CANDIDATE NOVEL AXIAL GENES (pass parts 1-2 of the wall) ===\n")
if (nrow(candidates)) print(candidates[, .(gene, chr, tss, n_iv, b, pval, fdr, PP.H4)]) else
  cat("NONE. Honest null: no druggable-genome gene shows novel, coloc-backed axial-specific causal support.\n")

cat("\nNEXT: hand any candidate to D2 (fine-map credible set) and Track-3 eye-tissue coloc;\n",
    "promote to 'discovery' ONLY after passing all 4 parts of the wall + replication.\n", sep="")
