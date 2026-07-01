# ============================================================================
# AXIAL_DISCOVERY_local.R — TRANSCRIPTOME-WIDE cis-MR + coloc vs AXIAL LENGTH
#   *** 100% LOCAL — needs NO OpenGWAS (works while OpenGWAS is down) ***
# ----------------------------------------------------------------------------
# THE genuine new-discovery attempt, chosen because it is (a) runnable offline and
# (b) aimed at AXIAL LENGTH — the structural driver of pathological myopia, far less
# MR-interrogated than refractive error, so the prior odds of a NOVEL colocalizing
# gene are higher than for the (saturated) refractive-error phenotype.
#
# WHAT IT DOES (offline):
#   1. For EVERY gene in the local eQTLGen cis file, take the lead cis-eQTL as a
#      single instrument (standard cis-MR), harmonize with the LOCAL axial-length
#      GWAS, and compute a Wald-ratio MR of expression -> axial length.
#   2. FDR-correct across the transcriptome.
#   3. Colocalize (coloc.abf) every FDR-significant gene in its cis window.
#   4. Novelty filter: flag each hit KNOWN vs NOT-KNOWN vs the catalogued refractive-
#      error/myopia loci (+/-500 kb). Candidate-novel = FDR-sig + PP.H4>0.7 + not-known.
#   5. Separately print the 5 pre-specified anchors' axial-length results.
#
# HONEST WALL (a hit is a DISCOVERY only if it clears all 4, DISCOVERY_PLAN.md):
#   not-known + coloc + fine-map credible (D2) + replication. This script settles
#   parts 1-2; parts 3-4 are downstream. Report FDR-sig-but-known as recovered loci;
#   report the honest null if nothing not-known colocalizes.
#
# NEEDS (all local; edit CONFIG): eQTLGen cis file, UKB axial-length GWAS, known-loci
#   list. NO internet, NO OpenGWAS token.
# DEPENDENCIES: data.table, coloc
# ============================================================================

suppressMessages({ library(data.table); library(coloc) })
out_dir <- if (dir.exists("c:/Projectbulid")) "c:/Projectbulid/Myopia/Submit_Manuscript/value_add/discovery" else "."
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

# ---- CONFIG (all LOCAL) -----------------------------------------------------
EQTL_FILE <- "c:/Projectbulid/Myopia/CP3/data/2019-12-11-cis-eQTLsFDR-ProbeLevel-CohortInfoRemoved-BonferroniAdded.txt.gz"
EQTL_N    <- 31684
# Axial-length GWAS (PI's UKB fields 5201/5202, or CREAM AL). Provide a reader that
# returns data.table(SNP, CHR, POS, beta, se, eaf[, N]). EDIT parser to your file.
AL_FILE   <- "c:/Projectbulid/Myopia/data/axial_length_gwas.txt.gz"          # <- RESOLVE
# Known myopia/refractive loci for novelty (gene,chr,pos GRCh37): Tedja 2018 + GWAS Catalog
KNOWN_LOCI<- "c:/Projectbulid/Myopia/data/known_myopia_loci_tedja2018.tsv"   # <- RESOLVE
IV_P      <- 5e-8      # lead cis-eQTL threshold
WINDOW    <- 5e5
FDR_THRESH<- 0.05
COLOC_PP4 <- 0.7
ANCHORS   <- c(RDH5="ENSG00000135437", CD55="ENSG00000196352",
               TGFB1="ENSG00000105329", CTNNB1="ENSG00000168036", FBN1="ENSG00000166147")

stopifnot(file.exists(EQTL_FILE))
if (!file.exists(AL_FILE)) stop("Resolve the axial-length GWAS path (AL_FILE). This is the one dataset the scan needs.")

cat("=== AXIAL transcriptome-wide cis-MR (LOCAL, no OpenGWAS) ===\n")

# ---- axial-length GWAS (EDIT parser to your columns) ------------------------
al <- fread(AL_FILE)
# setnames(al, c("rsid","chr","pos","beta","se","eaf"), c("SNP","CHR","POS","beta","se","eaf"))
al <- al[!is.na(beta) & !is.na(se) & !is.na(eaf) & eaf>0 & eaf<1][!duplicated(SNP)]
setkey(al, SNP); cat("AL SNPs:", nrow(al), "\n")

# ---- eQTLGen cis (stream; keep needed cols) ---------------------------------
eqtl <- fread(EQTL_FILE, select=c(1,2,3,4,5,7,8,13),
              col.names=c("Pvalue","SNP","SNPChr","SNPPos","AssessedAllele","Zscore","Gene","NrSamples"))
eqtl[, `:=`(beta_eqtl = Zscore/sqrt(NrSamples), se_eqtl = 1/sqrt(NrSamples))]

# ---- lead cis-eQTL per gene as the instrument -------------------------------
lead <- eqtl[Pvalue < IV_P][order(Gene, Pvalue)][, .SD[1], by=Gene]
cat("genes with a lead cis-eQTL:", nrow(lead), "\n")

# ---- Wald-ratio MR expression -> axial length -------------------------------
m <- merge(lead, al, by="SNP")
m <- m[abs(beta_eqtl) > 0]
m[, `:=`(b_mr = beta/beta_eqtl, se_mr = abs(se/beta_eqtl))]
m[, p_mr := 2*pnorm(-abs(b_mr/se_mr))]
m[, fdr := p.adjust(p_mr, "BH")]
setorder(m, fdr)
fwrite(m[, .(Gene, SNP, SNPChr, SNPPos, b_mr, se_mr, p_mr, fdr)],
       file.path(out_dir, "axial_TWMR_all.csv"))
cat("WROTE axial_TWMR_all.csv (", nrow(m), "genes tested)\n")

# ---- known-locus novelty filter --------------------------------------------
known <- if (file.exists(KNOWN_LOCI)) fread(KNOWN_LOCI) else { cat("[!] KNOWN_LOCI missing -> novelty flag NA\n"); data.table(chr=integer(),pos=numeric()) }
is_known <- function(chr,pos) if(nrow(known)==0) NA else nrow(known[chr==..chr & abs(pos-..pos)<=WINDOW])>0

hits <- m[fdr < FDR_THRESH]
cat(nrow(hits), "FDR<", FDR_THRESH, "hits. Colocalizing...\n")

coloc_gene <- function(g, chr, pos) {
  sub <- eqtl[Gene==g & abs(SNPPos-pos)<=WINDOW]
  mm <- merge(sub, al, by="SNP")[!duplicated(SNP)]; if(nrow(mm)<5) return(NA_real_)
  r <- coloc.abf(list(snp=mm$SNP, beta=mm$beta_eqtl, varbeta=mm$se_eqtl^2, type="quant", N=EQTL_N),
                 list(snp=mm$SNP, beta=mm$beta,      varbeta=mm$se^2,      type="quant", MAF=mm$eaf))
  as.numeric(r$summary["PP.H4.abf"])
}
if (nrow(hits)) {
  hits[, PP.H4 := mapply(coloc_gene, Gene, SNPChr, SNPPos)]
  hits[, known := mapply(is_known, SNPChr, SNPPos)]
}
candidates <- if (nrow(hits)) hits[(!is.na(PP.H4) & PP.H4>COLOC_PP4) & (known==FALSE | is.na(known))][order(-PP.H4)] else hits[0]
fwrite(hits,       file.path(out_dir, "axial_TWMR_FDRhits_coloc.csv"))
fwrite(candidates, file.path(out_dir, "axial_DISCOVERY_candidates.csv"))

cat("\n===== CANDIDATE NOVEL AXIAL-LENGTH GENES (FDR-sig + coloc>0.7 + not-known) =====\n")
if (nrow(candidates)) print(candidates[, .(Gene, SNPChr, SNPPos, b_mr, p_mr, fdr, PP.H4, known)]) else
  cat("NONE. Honest null: no gene shows novel, coloc-backed axial-length causal support.\n")

# ---- the 5 pre-specified anchors' axial-length result -----------------------
cat("\n===== ANCHORS vs axial length =====\n")
anc <- m[Gene %in% ANCHORS]
if (nrow(anc)) { anc[, name := names(ANCHORS)[match(Gene, ANCHORS)]]; print(anc[, .(name, Gene, b_mr, se_mr, p_mr, fdr)]) } else
  cat("(no anchor had a lead cis-eQTL passing", IV_P, ")\n")

cat("\nNEXT for any candidate: fine-map (D2) + replicate (2nd AL GWAS) before calling it a discovery.\n")
