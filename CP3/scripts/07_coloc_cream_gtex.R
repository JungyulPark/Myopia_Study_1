# CP3 MR Strengthening: Coloc + CREAM Replication + GTEx Fibroblast
# Single script for all 3 analyses

Sys.setenv(OPENGWAS_JWT = "eyJhbGciOiJSUzI1NiIsImtpZCI6ImFwaS1qd3QiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJhcGkub3Blbmd3YXMuaW8iLCJhdWQiOiJhcGkub3Blbmd3YXMuaW8iLCJzdWIiOiJvcGhqeXBAbmF2ZXIuY29tIiwiaWF0IjoxNzc1OTc4NDcwLCJleHAiOjE3NzcxODgwNzB9.TT5w4_5V7kXgMEMwOabASlF8DEoJBay87xqTBv50QASMarmorUm9nX2BbXVkhvGuoXSKC6fJfG_8w_adXc8h1Nq4ECS9YobEst1ej7Qn9LU7oJ7OFx3NepNYKUg3keCDJVZK8_xFrlE9_aToYEe_f5bbhH2HjGOoPcLiA2_xh6UGUNIqbPELbyODpUl35MVwcuLeiNM6fMWssPXfQ3_06ibsqA6T3_uZIOdai7Eqkmo8WhOdp-HIE9M96RXHE9NCJdb7a4G0HtUsGTJYJWMrnSWJ9mKBU77CSCAG2GBnbyjlUzPeylXxRY7ZzZWzwKY2qD0GHFC3waZZ9xs0lAUFWw")

# Install coloc if needed
if (!requireNamespace("coloc", quietly = TRUE)) {
    install.packages("coloc", repos = "https://cran.r-project.org")
}

library(TwoSampleMR)
library(ieugwasr)
library(coloc)
library(dplyr)

dir.create("c:/Projectbulid/CP3/results", showWarnings = FALSE, recursive = TRUE)

# ================================================================
# PART 1: COLOCALIZATION (TGFB1 + LATS2)
# ================================================================
cat("=", rep("=", 60), "\n")
cat("PART 1: COLOCALIZATION ANALYSIS\n")
cat("Testing shared causal variants for TGFB1 and LATS2\n")
cat("=", rep("=", 60), "\n\n")

# Function to run coloc for a gene
run_coloc <- function(gene_name, eqtl_id, outcome_id = "ukb-b-6353", region_kb = 500) {
    cat(sprintf("\n--- Coloc for %s ---\n", gene_name))
    
    # Step 1: Get eQTL associations in the region
    cat("  Extracting eQTL data...\n")
    eqtl_instruments <- tryCatch({
        extract_instruments(outcomes = eqtl_id, p1 = 5e-4)  # Use liberal p for coloc
    }, error = function(e) { cat("  Error:", conditionMessage(e), "\n"); NULL })
    
    if (is.null(eqtl_instruments) || nrow(eqtl_instruments) == 0) {
        cat("  No eQTL instruments found\n")
        return(NULL)
    }
    cat("  eQTL SNPs:", nrow(eqtl_instruments), "\n")
    
    # Step 2: Get GWAS associations for the same SNPs
    cat("  Extracting GWAS outcome data...\n")
    gwas_data <- tryCatch({
        extract_outcome_data(snps = eqtl_instruments$SNP, outcomes = outcome_id)
    }, error = function(e) { cat("  Error:", conditionMessage(e), "\n"); NULL })
    
    if (is.null(gwas_data) || nrow(gwas_data) == 0) {
        cat("  No GWAS data found\n")
        return(NULL)
    }
    cat("  GWAS SNPs:", nrow(gwas_data), "\n")
    
    # Step 3: Merge and prepare for coloc
    merged <- merge(eqtl_instruments, gwas_data, by.x = "SNP", by.y = "SNP")
    cat("  Merged SNPs:", nrow(merged), "\n")
    
    if (nrow(merged) < 5) {
        cat("  Insufficient SNPs for coloc (need >= 5)\n")
        return(NULL)
    }
    
    # Step 4: Prepare coloc datasets
    dataset1 <- list(
        pvalues = merged$pval.exposure,
        N = merged$samplesize.exposure[1],
        MAF = merged$eaf.exposure,
        type = "quant",
        snp = merged$SNP,
        beta = merged$beta.exposure,
        varbeta = merged$se.exposure^2
    )
    
    dataset2 <- list(
        pvalues = merged$pval.outcome,
        N = merged$samplesize.outcome[1],
        MAF = merged$eaf.outcome,
        type = "cc",  # case-control for binary myopia
        snp = merged$SNP,
        beta = merged$beta.outcome,
        varbeta = merged$se.outcome^2
    )
    
    # Remove NAs
    valid <- !is.na(dataset1$pvalues) & !is.na(dataset2$pvalues) & 
             !is.na(dataset1$MAF) & !is.na(dataset2$MAF) &
             dataset1$MAF > 0 & dataset1$MAF < 1 &
             dataset2$MAF > 0 & dataset2$MAF < 1
    
    if (sum(valid) < 5) {
        cat("  Insufficient valid SNPs after filtering\n")
        return(NULL)
    }
    
    dataset1$pvalues <- dataset1$pvalues[valid]
    dataset1$MAF <- dataset1$MAF[valid]
    dataset1$snp <- dataset1$snp[valid]
    dataset1$beta <- dataset1$beta[valid]
    dataset1$varbeta <- dataset1$varbeta[valid]
    
    dataset2$pvalues <- dataset2$pvalues[valid]
    dataset2$MAF <- dataset2$MAF[valid]
    dataset2$snp <- dataset2$snp[valid]
    dataset2$beta <- dataset2$beta[valid]
    dataset2$varbeta <- dataset2$varbeta[valid]
    
    cat("  Valid SNPs for coloc:", sum(valid), "\n")
    
    # Step 5: Run coloc
    cat("  Running colocalization...\n")
    result <- tryCatch({
        coloc.abf(dataset1, dataset2)
    }, error = function(e) { cat("  Coloc error:", conditionMessage(e), "\n"); NULL })
    
    if (!is.null(result)) {
        cat(sprintf("\n  === %s COLOC RESULTS ===\n", gene_name))
        cat(sprintf("  H0 (no association): %.4f\n", result$summary["PP.H0.abf"]))
        cat(sprintf("  H1 (eQTL only):     %.4f\n", result$summary["PP.H1.abf"]))
        cat(sprintf("  H2 (GWAS only):     %.4f\n", result$summary["PP.H2.abf"]))
        cat(sprintf("  H3 (both, diff SNP): %.4f\n", result$summary["PP.H3.abf"]))
        cat(sprintf("  H4 (shared variant): %.4f\n", result$summary["PP.H4.abf"]))
        
        h4 <- result$summary["PP.H4.abf"]
        if (h4 > 0.8) {
            cat(sprintf("  ✅ STRONG colocalization (H4=%.3f > 0.8)\n", h4))
        } else if (h4 > 0.5) {
            cat(sprintf("  ⚠️ MODERATE colocalization (H4=%.3f)\n", h4))
        } else {
            cat(sprintf("  ❌ WEAK colocalization (H4=%.3f < 0.5)\n", h4))
        }
        
        return(data.frame(
            Gene = gene_name,
            nSNPs = sum(valid),
            H0 = result$summary["PP.H0.abf"],
            H1 = result$summary["PP.H1.abf"],
            H2 = result$summary["PP.H2.abf"],
            H3 = result$summary["PP.H3.abf"],
            H4 = result$summary["PP.H4.abf"]
        ))
    }
    return(NULL)
}

# Run coloc for both genes
tgfb1_coloc <- run_coloc("TGFB1", "eqtl-a-ENSG00000105329")
lats2_coloc <- run_coloc("LATS2", "eqtl-a-ENSG00000150082")

coloc_results <- rbind(tgfb1_coloc, lats2_coloc)
if (!is.null(coloc_results)) {
    write.csv(coloc_results, "c:/Projectbulid/CP3/results/coloc_results.csv", row.names = FALSE)
    cat("\n✅ Coloc results saved\n")
}

# ================================================================
# PART 2: CREAM REFRACTIVE ERROR REPLICATION
# ================================================================
cat("\n\n", rep("=", 60), "\n")
cat("PART 2: CREAM REFRACTIVE ERROR REPLICATION\n")
cat("Replicating MR with continuous refractive error outcome\n")
cat(rep("=", 60), "\n\n")

# Search for CREAM/refractive error GWAS
cat("Searching for refractive error GWAS...\n")
all_gwas <- tryCatch(gwasinfo(), error = function(e) NULL)

if (!is.null(all_gwas)) {
    refr <- all_gwas %>% 
        filter(grepl("refract", trait, ignore.case = TRUE) | 
               grepl("spherical", trait, ignore.case = TRUE)) %>%
        filter(sample_size > 10000) %>%
        arrange(desc(sample_size)) %>%
        select(id, trait, sample_size, year) %>%
        head(10)
    
    cat("Available refractive error GWAS:\n")
    print(refr)
    
    # Try the best available
    cream_ids <- c()
    if (nrow(refr) > 0) {
        cream_ids <- refr$id[1:min(3, nrow(refr))]
    }
    
    # Also try known IDs
    known_ids <- c("ukb-a-458", "ebi-a-GCST006085")
    cream_ids <- unique(c(cream_ids, known_ids))
    
    cream_results <- list()
    
    for (outcome_id in cream_ids) {
        cat(sprintf("\n--- Testing outcome: %s ---\n", outcome_id))
        
        # TGFB1
        tgfb1_iv <- tryCatch(extract_instruments("eqtl-a-ENSG00000105329", p1 = 5e-6), error = function(e) NULL)
        if (!is.null(tgfb1_iv) && nrow(tgfb1_iv) > 0) {
            tgfb1_out <- tryCatch(extract_outcome_data(snps = tgfb1_iv$SNP, outcomes = outcome_id), error = function(e) NULL)
            if (!is.null(tgfb1_out) && nrow(tgfb1_out) > 0) {
                dat <- harmonise_data(tgfb1_iv, tgfb1_out)
                dat <- subset(dat, mr_keep == TRUE)
                if (nrow(dat) > 0) {
                    res <- mr(dat)
                    res$Replication <- outcome_id
                    cream_results[["TGFB1"]] <- rbind(cream_results[["TGFB1"]], res)
                    cat("  TGFB1: b=", round(res$b[1], 4), " p=", round(res$pval[1], 4), "\n")
                }
            }
        }
        
        # LATS2
        lats2_iv <- tryCatch(extract_instruments("eqtl-a-ENSG00000150082", p1 = 5e-6), error = function(e) NULL)
        if (!is.null(lats2_iv) && nrow(lats2_iv) > 0) {
            lats2_out <- tryCatch(extract_outcome_data(snps = lats2_iv$SNP, outcomes = outcome_id), error = function(e) NULL)
            if (!is.null(lats2_out) && nrow(lats2_out) > 0) {
                dat <- harmonise_data(lats2_iv, lats2_out)
                dat <- subset(dat, mr_keep == TRUE)
                if (nrow(dat) > 0) {
                    res <- mr(dat)
                    res$Replication <- outcome_id
                    cream_results[["LATS2"]] <- rbind(cream_results[["LATS2"]], res)
                    cat("  LATS2: b=", round(res$b[1], 4), " p=", round(res$pval[1], 4), "\n")
                }
            }
        }
    }
    
    if (length(cream_results) > 0) {
        cream_df <- bind_rows(cream_results)
        write.csv(cream_df, "c:/Projectbulid/CP3/results/CREAM_replication.csv", row.names = FALSE)
        cat("\n✅ CREAM replication results saved\n")
    }
}

# ================================================================
# PART 3: GTEx FIBROBLAST eQTL
# ================================================================
cat("\n\n", rep("=", 60), "\n")
cat("PART 3: GTEx FIBROBLAST eQTL SEARCH\n")
cat(rep("=", 60), "\n\n")

if (!is.null(all_gwas)) {
    # Search for GTEx fibroblast eQTLs
    fibroblast <- all_gwas %>%
        filter(grepl("fibroblast", trait, ignore.case = TRUE) |
               grepl("fibro", id, ignore.case = TRUE)) %>%
        filter(grepl("ENSG00000105329|ENSG00000150082", id)) %>%
        select(id, trait, sample_size)
    
    cat("Fibroblast eQTL datasets for TGFB1/LATS2:\n")
    if (nrow(fibroblast) > 0) {
        print(fibroblast)
        for (i in 1:nrow(fibroblast)) {
            iv <- tryCatch(extract_instruments(outcomes = fibroblast$id[i], p1 = 5e-6), error = function(e) NULL)
            if (!is.null(iv) && nrow(iv) > 0) {
                cat("  ✅ Found", nrow(iv), "IVs from", fibroblast$id[i], "\n")
            } else {
                cat("  ❌ No IVs at p<5e-6 from", fibroblast$id[i], "\n")
            }
        }
    } else {
        cat("  No fibroblast-specific eQTL datasets found in OpenGWAS\n")
    }
    
    # Also search GTEx all tissues for these genes
    gtex_tgfb1 <- all_gwas %>%
        filter(grepl("ENSG00000105329", id)) %>%
        select(id, trait, sample_size)
    
    gtex_lats2 <- all_gwas %>%
        filter(grepl("ENSG00000150082", id)) %>%
        select(id, trait, sample_size)
    
    cat("\nAll eQTL datasets for TGFB1:", nrow(gtex_tgfb1), "\n")
    if (nrow(gtex_tgfb1) > 0) print(gtex_tgfb1)
    
    cat("\nAll eQTL datasets for LATS2:", nrow(gtex_lats2), "\n")
    if (nrow(gtex_lats2) > 0) print(gtex_lats2)
    
    cat("\n→ GTEx fibroblast searched. Results above.\n")
    cat("→ If no fibroblast eQTLs found: report as 'searched but insufficient power'\n")
}

cat("\n\n", rep("=", 60), "\n")
cat("ALL 3 SUPPLEMENTARY ANALYSES COMPLETE\n")
cat(rep("=", 60), "\n")
