# CP3 Sensitivity: Steiger + Reverse MR + PhenoScanner
# For TGFB1 (p=0.003) and LATS2 (p=0.04)

Sys.setenv(OPENGWAS_JWT = "eyJhbGciOiJSUzI1NiIsImtpZCI6ImFwaS1qd3QiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJhcGkub3Blbmd3YXMuaW8iLCJhdWQiOiJhcGkub3Blbmd3YXMuaW8iLCJzdWIiOiJvcGhqeXBAbmF2ZXIuY29tIiwiaWF0IjoxNzc1OTc4NDcwLCJleHAiOjE3NzcxODgwNzB9.TT5w4_5V7kXgMEMwOabASlF8DEoJBay87xqTBv50QASMarmorUm9nX2BbXVkhvGuoXSKC6fJfG_8w_adXc8h1Nq4ECS9YobEst1ej7Qn9LU7oJ7OFx3NepNYKUg3keCDJVZK8_xFrlE9_aToYEe_f5bbhH2HjGOoPcLiA2_xh6UGUNIqbPELbyODpUl35MVwcuLeiNM6fMWssPXfQ3_06ibsqA6T3_uZIOdai7Eqkmo8WhOdp-HIE9M96RXHE9NCJdb7a4G0HtUsGTJYJWMrnSWJ9mKBU77CSCAG2GBnbyjlUzPeylXxRY7ZzZWzwKY2qD0GHFC3waZZ9xs0lAUFWw")

library(TwoSampleMR)
library(dplyr)
library(ieugwasr)

dir.create("c:/Projectbulid/CP3/results", showWarnings = FALSE, recursive = TRUE)

outcome_id <- "ukb-b-6353"

# ================================================================
# PART 1: STEIGER DIRECTIONALITY TEST
# ================================================================
cat("=" , rep("=", 60), "\n")
cat("PART 1: STEIGER DIRECTIONALITY TEST\n")
cat("=" , rep("=", 60), "\n")

steiger_results <- list()

for (gene_info in list(
    list(name="TGFB1", id="eqtl-a-ENSG00000105329"),
    list(name="LATS2", id="eqtl-a-ENSG00000150768")
)) {
    cat("\n--- Steiger test:", gene_info$name, "---\n")
    
    exp_dat <- extract_instruments(outcomes = gene_info$id, p1 = 5e-06, clump = TRUE, r2 = 0.001, kb = 10000)
    if (is.null(exp_dat) || nrow(exp_dat) == 0) { cat("  No instruments\n"); next }
    
    exp_dat$F_stat <- (exp_dat$beta.exposure / exp_dat$se.exposure)^2
    exp_dat <- subset(exp_dat, F_stat > 10)
    
    out_dat <- extract_outcome_data(snps = exp_dat$SNP, outcomes = outcome_id)
    if (is.null(out_dat) || nrow(out_dat) == 0) { cat("  No outcome data\n"); next }
    
    dat <- harmonise_data(exp_dat, out_dat)
    dat <- subset(dat, mr_keep == TRUE)
    
    if (nrow(dat) == 0) { cat("  No harmonized data\n"); next }
    
    # Steiger test
    steiger <- directionality_test(dat)
    cat("  Correct causal direction:", steiger$correct_causal_direction, "\n")
    cat("  Steiger p-value:", steiger$steiger_pval, "\n")
    cat("  SNP r2 exposure:", round(steiger$snp_r2.exposure, 6), "\n")
    cat("  SNP r2 outcome:", round(steiger$snp_r2.outcome, 6), "\n")
    
    steiger$Gene <- gene_info$name
    steiger_results[[gene_info$name]] <- steiger
}

if (length(steiger_results) > 0) {
    steiger_df <- bind_rows(steiger_results)
    write.csv(steiger_df, "c:/Projectbulid/CP3/results/Steiger_directionality.csv", row.names=FALSE)
    cat("\n✅ Steiger results saved\n")
}

# ================================================================
# PART 2: REVERSE MR (Myopia → Gene Expression)
# ================================================================
cat("\n\n", rep("=", 60), "\n")
cat("PART 2: REVERSE MR (Myopia -> Gene Expression)\n")
cat(rep("=", 60), "\n")

reverse_results <- list()

# Extract myopia instruments (use ukb-b-6353 as exposure)
cat("\nExtracting myopia instruments (p<5e-8)...\n")
myopia_exp <- tryCatch({
    extract_instruments(outcomes = outcome_id, p1 = 5e-08, clump = TRUE, r2 = 0.001, kb = 10000)
}, error = function(e) { cat("  Error:", conditionMessage(e), "\n"); NULL })

if (!is.null(myopia_exp) && nrow(myopia_exp) > 0) {
    cat("  Myopia instruments:", nrow(myopia_exp), "SNPs\n")
    
    for (gene_info in list(
        list(name="TGFB1", id="eqtl-a-ENSG00000105329"),
        list(name="LATS2", id="eqtl-a-ENSG00000150768")
    )) {
        cat("\n--- Reverse MR: Myopia ->", gene_info$name, "---\n")
        
        rev_out <- tryCatch({
            extract_outcome_data(snps = myopia_exp$SNP, outcomes = gene_info$id)
        }, error = function(e) { NULL })
        
        if (is.null(rev_out) || nrow(rev_out) == 0) {
            cat("  No outcome data for", gene_info$name, "\n")
            next
        }
        
        rev_dat <- harmonise_data(myopia_exp, rev_out)
        rev_dat <- subset(rev_dat, mr_keep == TRUE)
        cat("  Harmonized SNPs:", nrow(rev_dat), "\n")
        
        if (nrow(rev_dat) == 0) next
        
        if (nrow(rev_dat) >= 3) {
            rev_res <- mr(rev_dat, method_list = c("mr_ivw", "mr_egger_regression", "mr_weighted_median"))
        } else if (nrow(rev_dat) == 1) {
            rev_res <- mr(rev_dat, method_list = "mr_wald_ratio")
        } else {
            rev_res <- mr(rev_dat, method_list = "mr_ivw")
        }
        rev_res$Gene <- gene_info$name
        rev_res$Direction <- "Reverse (Myopia -> Gene)"
        
        cat("  REVERSE MR RESULTS:\n")
        print(rev_res[, c("method", "nsnp", "b", "se", "pval")])
        reverse_results[[gene_info$name]] <- rev_res
    }
} else {
    cat("  Could not extract myopia instruments\n")
}

if (length(reverse_results) > 0) {
    rev_df <- bind_rows(reverse_results)
    write.csv(rev_df, "c:/Projectbulid/CP3/results/Reverse_MR.csv", row.names=FALSE)
    cat("\n✅ Reverse MR results saved\n")
}

# ================================================================
# PART 3: PHENOSCANNER (Pleiotropy Screening)
# ================================================================
cat("\n\n", rep("=", 60), "\n")
cat("PART 3: PHENOSCANNER PLEIOTROPY SCREENING\n")
cat(rep("=", 60), "\n")

# Get SNPs used as IVs for TGFB1 and LATS2
pheno_results <- list()

for (gene_info in list(
    list(name="TGFB1", id="eqtl-a-ENSG00000105329"),
    list(name="LATS2", id="eqtl-a-ENSG00000150768")
)) {
    cat("\n--- PhenoScanner:", gene_info$name, "---\n")
    
    exp_dat <- extract_instruments(outcomes = gene_info$id, p1 = 5e-06, clump = TRUE, r2 = 0.001, kb = 10000)
    if (is.null(exp_dat) || nrow(exp_dat) == 0) { cat("  No instruments\n"); next }
    exp_dat$F_stat <- (exp_dat$beta.exposure / exp_dat$se.exposure)^2
    exp_dat <- subset(exp_dat, F_stat > 10)
    
    snps <- exp_dat$SNP
    cat("  Checking", length(snps), "SNPs:", paste(snps, collapse=", "), "\n")
    
    # Query PhenoScanner via ieugwasr
    pheno <- tryCatch({
        phewas(variants = snps, pval = 5e-8)
    }, error = function(e) { cat("  PhenoScanner error:", conditionMessage(e), "\n"); NULL })
    
    if (!is.null(pheno) && nrow(pheno) > 0) {
        cat("  Found", nrow(pheno), "associations at p<5e-8\n")
        
        # Check for concerning pleiotropic associations
        concerning <- pheno %>%
            filter(grepl("height|autoimmune|inflam|cancer|BMI|body mass|blood pressure",
                         trait, ignore.case=TRUE))
        
        if (nrow(concerning) > 0) {
            cat("  ⚠ CONCERNING pleiotropy found:\n")
            print(concerning[, c("rsid", "trait", "p")])
        } else {
            cat("  ✅ No concerning horizontal pleiotropy detected\n")
        }
        
        # All associations
        cat("  All traits:\n")
        trait_summary <- pheno %>% group_by(trait) %>% summarise(n=n(), min_p=min(as.numeric(p), na.rm=TRUE)) %>% arrange(min_p)
        print(head(trait_summary, 20))
        
        pheno$Gene <- gene_info$name
        pheno_results[[gene_info$name]] <- pheno
    } else {
        cat("  ✅ No GWAS associations found at p<5e-8 (clean IV)\n")
    }
}

if (length(pheno_results) > 0) {
    pheno_df <- bind_rows(pheno_results)
    write.csv(pheno_df, "c:/Projectbulid/CP3/results/PhenoScanner_pleiotropy.csv", row.names=FALSE)
    cat("\n✅ PhenoScanner results saved\n")
}

# ================================================================
# FINAL SUMMARY
# ================================================================
cat("\n\n", rep("=", 60), "\n")
cat("SENSITIVITY ANALYSIS COMPLETE\n")
cat(rep("=", 60), "\n")
cat("Files saved:\n")
cat("  1. CP3/results/Steiger_directionality.csv\n")
cat("  2. CP3/results/Reverse_MR.csv\n")
cat("  3. CP3/results/PhenoScanner_pleiotropy.csv\n")
