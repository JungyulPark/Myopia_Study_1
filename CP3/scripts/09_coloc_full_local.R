library(data.table)
library(coloc)

cat("=== COLOC WITH LOCAL eQTLGen AND UKB VCF DATA ===\n")

eqtl_file <- "c:/Projectbulid/CP3/data/2019-12-11-cis-eQTLsFDR-ProbeLevel-CohortInfoRemoved-BonferroniAdded.txt.gz"
vcf_file <- "c:/Projectbulid/CP3/data/ukb-b-6353.vcf.gz"

genes <- list(
    TGFB1 = list(ensembl = "ENSG00000105329", gene = "TGFB1", chr = 19, pos = 41836812, window = 500000),
    LATS2 = list(ensembl = "ENSG00000150082", gene = "LATS2", chr = 13, pos = 21546299, window = 500000)
)

# 1. Read UKB Myopia GWAS VCF
cat("\n1. Reading UKB Myopia GWAS VCF file (238MB)...\n")
# Select only needed columns: POS, ID, UKB format
vcf <- fread(vcf_file, skip="#CHROM", select=c(1, 2, 3, 10))
setnames(vcf, c("CHR", "POS", "ID", "UKB"))

cat("Parsing FORMAT data...\n")
# ES:SE:LP:AF:ID
ukb_split <- tstrsplit(vcf$UKB, ":")
vcf$beta <- as.numeric(ukb_split[[1]])
vcf$se <- as.numeric(ukb_split[[2]])
vcf$eaf <- as.numeric(ukb_split[[4]])
vcf$rsid <- vcf$ID

# Filter and clean
vcf <- vcf[!is.na(beta) & !is.na(se) & !is.na(eaf) & eaf > 0 & eaf < 1]
vcf <- vcf[!duplicated(rsid)]
cat("VCF reading completed. Rows:", nrow(vcf), "\n")

# 2. Read eQTLGen
cat("\n2. Reading eQTLGen full summary stats (3.8GB)...\n")
cat("This may take 1-3 minutes. Only importing necessary columns to save memory...\n")
col_names <- c("Pvalue", "SNP", "SNPChr", "SNPPos", "AssessedAllele", 
               "OtherAllele", "Zscore", "Gene", "GeneSymbol", 
               "GeneChr", "GenePos", "NrCohorts", "NrSamples", 
               "FDR", "BonferroniP")
# Select only columns needed
eqtl_full <- fread(eqtl_file, select=c(1, 2, 4, 7, 8, 13), col.names = c("Pvalue", "SNP", "SNPPos", "Zscore", "Gene", "NrSamples"))
cat("eQTLGen reading completed. Rows:", nrow(eqtl_full), "\n")

coloc_results <- list()
eqtl_N <- 31684

# 3. Perform Coloc
cat("\n3. Performing Coloc...\n")
for (gene_name in names(genes)) {
    g <- genes[[gene_name]]
    cat(sprintf("\n========== %s ==========\n", gene_name))
    
    eqtl_sub <- eqtl_full[Gene == g$ensembl]
    
    # Handle duplicates by keeping the one with the lowest P-value
    eqtl_sub <- eqtl_sub[order(Pvalue)]
    eqtl_sub <- eqtl_sub[!duplicated(SNP)]
    
    eqtl_sub <- eqtl_sub[abs(SNPPos - g$pos) <= g$window]
    cat("  eQTL regional SNPs:", nrow(eqtl_sub), "\n")
    
    if (nrow(eqtl_sub) < 5) {
        cat("  Insufficient eQTL SNPs\n")
        next
    }
    
    # beta/se approx for eQTLGen
    eqtl_sub$beta_eqtl <- eqtl_sub$Zscore / sqrt(eqtl_sub$NrSamples)
    eqtl_sub$se_eqtl <- 1 / sqrt(eqtl_sub$NrSamples)
    
    merged <- merge(eqtl_sub, vcf, by.x = "SNP", by.y = "rsid")
    # Also remove duplicate SNPs in merged just in case
    merged <- merged[!duplicated(SNP)]
    cat("  Merged overlapping SNPs:", nrow(merged), "\n")
    
    if (nrow(merged) < 5) {
        cat("  Insufficient overlapping SNPs\n")
        next
    }
    
    # Prepare datasets
    dataset1 <- list(
        beta = merged$beta_eqtl,
        varbeta = merged$se_eqtl^2,
        snp = merged$SNP,
        position = merged$SNPPos,
        type = "quant",
        N = eqtl_N,
        MAF = pmin(merged$eaf, 1 - merged$eaf)
    )
    
    dataset2 <- list(
        beta = merged$beta,
        varbeta = merged$se^2,
        snp = merged$SNP,
        position = merged$SNPPos,
        type = "cc",
        N = 460536,
        s = 37362/460536, # proportion of cases
        MAF = pmin(merged$eaf, 1 - merged$eaf)
    )
    
    result <- tryCatch({
        coloc.abf(dataset1, dataset2)
    }, error = function(e){
        cat("  Coloc error:", e$message, "\n")
        NULL
    })
    
    if (!is.null(result)) {
        cat(sprintf("  ✅ COLOC H4 (Shared Causal): %.4f\n", result$summary["PP.H4.abf"]))
        
        coloc_results[[gene_name]] <- data.frame(
            Gene = gene_name,
            nSNPs = nrow(merged),
            H0 = result$summary["PP.H0.abf"],
            H1 = result$summary["PP.H1.abf"],
            H2 = result$summary["PP.H2.abf"],
            H3 = result$summary["PP.H3.abf"],
            H4 = result$summary["PP.H4.abf"]
        )
    }
}

if (length(coloc_results) > 0) {
    df <- do.call(rbind, coloc_results)
    write.csv(df, "c:/Projectbulid/CP3/results/coloc_results_local_vcf.csv", row.names=FALSE)
    cat("\n✅ Results saved to CP3/results/coloc_results_local_vcf.csv\n")
} else {
    cat("\n❌ No coloc results generated.\n")
}
