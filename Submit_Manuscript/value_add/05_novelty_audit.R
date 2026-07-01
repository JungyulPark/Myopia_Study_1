# ============================================================================
# REQUIRED ANALYSIS 05 — NOVELTY AUDIT (gates the "no defensibly-novel gene" claim)
# ----------------------------------------------------------------------------
# WHY REQUIRED (not optional): the honest thesis is "the pipeline recovers KNOWN
# loci as positive controls; no defensibly-novel myopia gene." That sentence is
# indefensible until every candidate lead SNP is cross-referenced against the
# known-locus catalogues. This produces the verifiable artifact that closes
# GOAL_AND_LOOP_PLAN Phase 0 (Gate G0). Without it, a reviewer can ask "did you
# actually check?" and we have no table to show.
#
# WHAT IT DOES (no fabrication — pure lookup):
#   For each anchor + each UNVERIFIED Tier-2 gene, take the MR lead/instrument SNP,
#   and flag as KNOWN if a myopia / refractive-error association sits within
#   +/-500 kb, checking BOTH:
#     (a) GWAS Catalog REST API (EFO_0004647 myopia, EFO_0004633 refractive error
#         + descendants) — PUBLIC, runs anywhere with internet, and
#     (b) Tedja 2018 supplementary lead-SNP list (local file).
#   Also confirms CD55 is one of Wang 2024's (PMC11314700) six complement targets
#   and lists the other five to check no other anchor overlaps.
#
# HONEST RULES:
#   - "unverified" != "novel". A gene is reported novel ONLY if it clears the
#     4-part wall (DISCOVERY_PLAN.md); THIS script only settles part 1 (not-known).
#   - LD-clustered Tier-2 genes (SPACA3/TSSK6, GATAD2A/TMEM98, TMEM258/SREBF2,
#     IKZF3 17q21, H2BC4 HIST1/MHC) get a needs-fine-mapping flag, never a lead-gene
#     attribution here.
#
# RUNS ANYWHERE with internet (public APIs + one local Tedja file). No sensitive data.
# DEPENDENCIES: httr, jsonlite, data.table
# ============================================================================

suppressMessages({ library(httr); library(jsonlite); library(data.table) })

out_dir <- if (dir.exists("c:/Projectbulid")) "c:/Projectbulid/Submit_Manuscript/value_add" else "."

# ---- inputs -----------------------------------------------------------------
# Lead/instrument SNPs per gene (rsID + chr + pos GRCh37). Pull from the disk MR
# results (enhanced_table1_iv_details.csv) + Tier-2 instrument list. Fill here:
genes <- data.table(
  gene = c("RDH5","CD55","TGFB1","CTNNB1","FBN1",
           "IKZF3","H2BC4","MYBPC3","CEP250","CENPM","API5","RABEPK"),
  tier = c(rep("anchor",5), rep("tier2_unverified",7)),
  lead_rsid = NA_character_,  chr = NA_integer_,  pos = NA_real_,
  ld_cluster_note = c("","","","","",
                      "17q21 IKZF3/ZPBP2/GSDMB/ORMDL3 cluster",
                      "HIST1/MHC region — dense LD",
                      "","","", "","")
)
# <- FILL lead_rsid/chr/pos from enhanced_table1_iv_details.csv before running.

TEDJA_LEADS <- "c:/Projectbulid/data/tedja2018_lead_snps.tsv"   # gene, rsid, chr, pos (GRCh37)
WINDOW <- 5e5

# ---- (a) GWAS Catalog REST lookup within +/-500kb ---------------------------
gc_known <- function(chr, pos) {
  if (is.na(chr) || is.na(pos)) return(NA)
  url <- sprintf("https://www.ebi.ac.uk/gwas/rest/api/singleNucleotidePolymorphisms/search/findByChromBpLocationRange?chrom=%s&bpStart=%.0f&bpEnd=%.0f",
                 chr, max(0, pos - WINDOW), pos + WINDOW)
  r <- tryCatch(GET(url, timeout(30)), error = function(e) NULL)
  if (is.null(r) || status_code(r) != 200) return(NA)
  js <- content(r, as = "text", encoding = "UTF-8")
  # any association mapped to myopia / refractive error trait?
  grepl("myopia|refractive error|refractive.error|spherical equivalent", js, ignore.case = TRUE)
}

# ---- (b) Tedja 2018 local lead-SNP proximity --------------------------------
tedja <- if (file.exists(TEDJA_LEADS)) fread(TEDJA_LEADS) else data.table(chr=integer(), pos=numeric())
tedja_known <- function(chr, pos) {
  if (is.na(chr) || is.na(pos) || nrow(tedja) == 0) return(NA)
  nrow(tedja[chr == ..chr & abs(pos - ..pos) <= WINDOW]) > 0
}

genes[, gwas_catalog_known := mapply(gc_known, chr, pos)]
genes[, tedja_known        := mapply(tedja_known, chr, pos)]
genes[, known_locus := (isTRUE(gwas_catalog_known) | isTRUE(tedja_known)), by = seq_len(nrow(genes))]
genes[, novelty_status := fifelse(ld_cluster_note != "", "needs_finemap_before_any_claim",
                           fifelse(known_locus == TRUE, "known_locus_positive_control",
                                   "not-known_part1_only__still_needs_coloc+finemap+replication"))]

fwrite(genes, file.path(out_dir, "novelty_audit_results.csv"))
cat("WROTE novelty_audit_results.csv\n"); print(genes[, .(gene, tier, known_locus, novelty_status)])

# ---- CD55 vs Wang 2024 six complement targets -------------------------------
wang2024_targets <- c("CD55","CD46","CFH","C2","C3","CFB")  # CONFIRM exact six from PMC11314700 text
cat("\nWang 2024 (PMC11314700) complement MR targets:", paste(wang2024_targets, collapse=", "), "\n")
cat("CD55 in Wang set:", "CD55" %in% wang2024_targets,
    " | any OTHER anchor overlaps Wang set:", any(setdiff(genes[tier=='anchor']$gene,'CD55') %in% wang2024_targets), "\n")

cat("\nGATE G0: if every row is known_locus / needs_finemap and none is a clean\n",
    "'not-known + coloc + finemap + replication' pass -> LOCK 'no defensibly-novel gene'.\n", sep="")
