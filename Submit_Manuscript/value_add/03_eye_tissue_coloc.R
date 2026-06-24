# ============================================================================
# M-LIGHT value-add 3 — EYE-TISSUE COLOCALIZATION UPGRADE
# ----------------------------------------------------------------------------
# WHY THIS ELEVATES THE PAPER
#   Our primary coloc used BLOOD eQTL (eQTLGen). The #1 reviewer critique of any
#   myopia eQTL-MR is "blood is not eye." This script re-runs colocalization for
#   the anchors in EYE-RELEVANT tissue, which:
#     (1) pre-empts the blood-vs-eye critique with a direct answer,
#     (2) STRENGTHENS RDH5 as a recovered-known result (RDH5's retina/RPE coloc
#         is already published, bioRxiv 446799 — we recover it in the right tissue),
#     (3) HONESTLY TESTS whether CD55/CTNNB1/FBN1 hold up in eye tissue or were
#         blood-specific artefacts. Either outcome is reportable and honest.
#
# HONEST FRAMING (locked):
#   - Recovering RDH5 in retina/RPE is a POSITIVE CONTROL win, NOT a discovery
#     (the eye-tissue coloc is already in the literature; we cite it as prior).
#   - If an anchor COLOCALIZES in blood but NOT in eye tissue, we report that the
#     blood signal is not supported in the disease-relevant tissue — a limitation,
#     not a finding to hide.
#   - No number here is invented; all PP.H4 etc. come from this run.
#
# DATA (PI machine / Antigravity — sensitive, not in repo). Use the best available:
#   EYE eQTL panels, best first:
#     (a) EyeGEx / Ratnapriya 2019 retina eQTL  (GSE115828 / dbGaP)  <- primary
#     (b) fetal-RPE eQTL (the bioRxiv 446799 dataset)                <- RDH5 anchor
#     (c) GTEx brain/tibial-nerve as neural-adjacent PROXY (clearly labelled proxy)
#   Refractive-error / myopia GWAS:  the same UKB VCF (ukb-b-6353) already used,
#   and/or CREAM refractive error for replication.
#
# DEPENDENCIES:  data.table, coloc   (mirrors CP3/scripts/09_coloc_full_local.R)
# ============================================================================

suppressMessages({ library(data.table); library(coloc) })

# ---- CONFIG — set the eye eQTL source per availability (Roadmap-style gate) --
# Provide a function that returns, for a gene, a data.table with columns:
#   SNP, pos, beta_eqtl, se_eqtl, (optional) maf, N
# from whichever eye panel you resolved. Stubs below show the expected shape.
EYE_PANEL <- "EyeGEx"   # label carried into the output; change to "fetal-RPE" / "GTEx-nerve(proxy)"

eqtl_eye_file <- "c:/Projectbulid/CP3/data/EyeGEx_retina_eQTL.txt.gz"   # <- set to resolved path
vcf_file      <- "c:/Projectbulid/CP3/data/ukb-b-6353.vcf.gz"           # outcome (already used)

# ---- anchors (chr/pos GRCh37; window 500kb, matching the blood coloc run) ----
genes <- list(
  RDH5   = list(ensembl = "ENSG00000135437", chr = 12, pos = 56115278, window = 500000),
  CD55   = list(ensembl = "ENSG00000196352", chr = 1,  pos = 207494853, window = 500000),
  CTNNB1 = list(ensembl = "ENSG00000168036", chr = 3,  pos = 41240936, window = 500000),
  FBN1   = list(ensembl = "ENSG00000166147", chr = 15, pos = 48700503, window = 500000)
)
# NOTE: confirm chr/pos against the genome build of the eQTL panel before running;
# a build mismatch silently empties the window. (Blood run used GRCh37/hg19.)

# ---- read outcome VCF (same parser as 09_coloc_full_local.R) -----------------
cat("Reading refractive-error GWAS VCF ...\n")
vcf <- fread(vcf_file, skip = "#CHROM", select = c(1, 2, 3, 10))
setnames(vcf, c("CHR", "POS", "ID", "UKB"))
sp <- tstrsplit(vcf$UKB, ":")
vcf$beta <- as.numeric(sp[[1]]); vcf$se <- as.numeric(sp[[2]]); vcf$eaf <- as.numeric(sp[[4]])
vcf$rsid <- vcf$ID
vcf <- vcf[!is.na(beta) & !is.na(se) & !is.na(eaf) & eaf > 0 & eaf < 1][!duplicated(rsid)]
cat("  outcome SNPs:", nrow(vcf), "\n")

# ---- read eye eQTL panel (EDIT column mapping to match the resolved file) -----
cat("Reading eye eQTL panel:", EYE_PANEL, "\n")
# Expected after mapping: columns SNP, gene(ensembl), pos, beta_eqtl, se_eqtl, (maf)
eqtl <- fread(eqtl_eye_file)
# --- mapping stub: rename to the canonical schema used below ---
# setnames(eqtl, c("variant_id","gene_id","position","slope","slope_se","maf"),
#                c("SNP","gene","pos","beta_eqtl","se_eqtl","maf"))

run_coloc <- function(gene_name) {
  g <- genes[[gene_name]]
  cat(sprintf("\n========== %s (%s tissue) ==========\n", gene_name, EYE_PANEL))
  sub <- eqtl[gene == g$ensembl]
  sub <- sub[order(abs(pos - g$pos))][abs(pos - g$pos) <= g$window]
  if (nrow(sub) < 5) { cat("  insufficient eye-eQTL SNPs (", nrow(sub), ") — REPORT as 'not testable in", EYE_PANEL, "'\n"); return(NULL) }

  m <- merge(sub, vcf, by.x = "SNP", by.y = "rsid")[!duplicated(SNP)]
  cat("  overlapping SNPs:", nrow(m), "\n")
  if (nrow(m) < 5) { cat("  insufficient overlap — REPORT as not testable\n"); return(NULL) }

  d_eqtl <- list(snp = m$SNP, beta = m$beta_eqtl, varbeta = m$se_eqtl^2, type = "quant",
                 N = if ("N" %in% names(m)) m$N[1] else NA,
                 MAF = if ("maf" %in% names(m)) m$maf else NULL)
  d_out  <- list(snp = m$SNP, beta = m$beta, varbeta = m$se^2, type = "cc", MAF = m$eaf)
  res <- coloc.abf(d_eqtl, d_out)

  pph <- as.list(res$summary)
  data.table(gene = gene_name, tissue = EYE_PANEL, nsnps = pph$nsnps,
             PP.H0 = pph$PP.H0.abf, PP.H1 = pph$PP.H1.abf, PP.H2 = pph$PP.H2.abf,
             PP.H3 = pph$PP.H3.abf, PP.H4 = pph$PP.H4.abf)
}

out <- rbindlist(Filter(Negate(is.null), lapply(names(genes), run_coloc)), fill = TRUE)
out_dir <- if (dir.exists("c:/Projectbulid")) "c:/Projectbulid/Submit_Manuscript/value_add" else "."
out_csv <- file.path(out_dir, "eye_tissue_coloc_results.csv")
fwrite(out, out_csv)
cat("\nWROTE", out_csv, "\n")
print(out)

cat("\nINTERPRETATION (pre-registered):\n",
    "- PP.H4 high in eye tissue  -> coloc holds in disease-relevant tissue (RDH5 = recovered known positive control; cite bioRxiv 446799 as prior).\n",
    "- PP.H4 high in blood, low in eye -> blood-specific; REPORT as limitation, NOT a finding.\n",
    "- PP.H3/H1 high -> distinct variants; candidate/hypothesis only (consistent with blood-coloc failures for CTNNB1/FBN1).\n",
    "- Too few SNPs -> 'not testable in this panel', reported honestly.\n", sep = "")
