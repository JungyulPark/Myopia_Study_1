# CP3 MR-B: Hippo-YAP Pathway → Myopia
# STRICT p1 = 5e-6 (MR standard for eQTL-based MR)
# If insufficient IVs, report as "insufficient instruments" — better than weak IV bias

Sys.setenv(OPENGWAS_JWT = "eyJhbGciOiJSUzI1NiIsImtpZCI6ImFwaS1qd3QiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJhcGkub3Blbmd3YXMuaW8iLCJhdWQiOiJhcGkub3Blbmd3YXMuaW8iLCJzdWIiOiJvcGhqeXBAbmF2ZXIuY29tIiwiaWF0IjoxNzc1OTc4NDcwLCJleHAiOjE3NzcxODgwNzB9.TT5w4_5V7kXgMEMwOabASlF8DEoJBay87xqTBv50QASMarmorUm9nX2BbXVkhvGuoXSKC6fJfG_8w_adXc8h1Nq4ECS9YobEst1ej7Qn9LU7oJ7OFx3NepNYKUg3keCDJVZK8_xFrlE9_aToYEe_f5bbhH2HjGOoPcLiA2_xh6UGUNIqbPELbyODpUl35MVwcuLeiNM6fMWssPXfQ3_06ibsqA6T3_uZIOdai7Eqkmo8WhOdp-HIE9M96RXHE9NCJdb7a4G0HtUsGTJYJWMrnSWJ9mKBU77CSCAG2GBnbyjlUzPeylXxRY7ZzZWzwKY2qD0GHFC3waZZ9xs0lAUFWw")

library(TwoSampleMR)
library(dplyr)
library(ieugwasr)

dir.create("c:/Projectbulid/CP3/results", showWarnings = FALSE, recursive = TRUE)
dir.create("c:/Projectbulid/CP3/figures", showWarnings = FALSE, recursive = TRUE)

cat("=" , rep("=", 60), "\n")
cat("CP3 Module B: Hippo-YAP Pathway -> Myopia MR\n")
cat("Strict threshold: p1 = 5e-6\n")
cat("=" , rep("=", 60), "\n")

# Hippo-YAP exposures (eQTLGen blood eQTL)
exposures <- c(
    "LATS1" = "eqtl-a-ENSG00000131023",
    "LATS2" = "eqtl-a-ENSG00000150768",
    "YAP1"  = "eqtl-a-ENSG00000137693",
    "TEAD1" = "eqtl-a-ENSG00000187079",
    "WWTR1" = "eqtl-a-ENSG00000018408"
)

# Myopia outcome (UK Biobank, N=460,536)
outcome_id <- "ukb-b-6353"

results_list <- list()
insufficient <- c()

for(gene in names(exposures)) {
    cat("\n========================================\n")
    cat("Processing Gene:", gene, "\n")
    expo_id <- exposures[[gene]]
    
    # 1. Extract Instruments (STRICT p < 5e-6)
    cat("Extracting instruments (p < 5e-6)...\n")
    exp_dat <- tryCatch({
        extract_instruments(outcomes = expo_id, p1 = 5e-06, clump = TRUE, r2 = 0.001, kb = 10000)
    }, error = function(e){ cat("  API error:", conditionMessage(e), "\n"); NULL })
    
    if (is.null(exp_dat) || nrow(exp_dat) == 0) {
        cat("  ⚠ INSUFFICIENT INSTRUMENTS for", gene, "at p<5e-6\n")
        insufficient <- c(insufficient, gene)
        next
    }
    
    # 2. F-statistic check (individual + mean)
    exp_dat$F_stat <- (exp_dat$beta.exposure / exp_dat$se.exposure)^2
    cat("  Individual F-stats:", paste(round(exp_dat$F_stat, 1), collapse=", "), "\n")
    cat("  Mean F-stat:", round(mean(exp_dat$F_stat), 1), "\n")
    exp_dat <- subset(exp_dat, F_stat > 10)
    cat("  ", nrow(exp_dat), "SNPs with F > 10\n")
    if (nrow(exp_dat) == 0) { insufficient <- c(insufficient, gene); next }
    
    # 3. Outcome data
    out_dat <- tryCatch({
        extract_outcome_data(snps = exp_dat$SNP, outcomes = outcome_id)
    }, error = function(e){ cat("  Outcome extraction error\n"); NULL })
    
    if (is.null(out_dat) || nrow(out_dat) == 0) {
        cat("  ⚠ No outcome data for", gene, "\n")
        insufficient <- c(insufficient, gene)
        next
    }
    
    # 4. Harmonize
    dat <- harmonise_data(exposure_dat = exp_dat, outcome_dat = out_dat)
    dat <- subset(dat, mr_keep == TRUE)
    cat("  ", nrow(dat), "SNPs after harmonization\n")
    if (nrow(dat) == 0) { insufficient <- c(insufficient, gene); next }
    
    # 5. MR Analysis
    if (nrow(dat) == 1) {
        res <- mr(dat, method_list = c("mr_wald_ratio"))
    } else if (nrow(dat) == 2) {
        res <- mr(dat, method_list = c("mr_ivw"))
    } else {
        res <- mr(dat, method_list = c("mr_ivw", "mr_egger_regression", "mr_weighted_median", "mr_weighted_mode"))
    }
    res$Gene <- gene
    
    cat("\n  --- PRIMARY MR RESULTS ---\n")
    print(res[, c("method", "nsnp", "b", "se", "pval")])
    results_list[[gene]] <- res
    
    # 6. Sensitivity (only if >= 3 IVs)
    if (nrow(dat) >= 3) {
        cat("\n  --- SENSITIVITY ANALYSES ---\n")
        het <- mr_heterogeneity(dat)
        cat("  Cochran's Q p-value:", het$Q_pval, "\n")
        plt <- mr_pleiotropy_test(dat)
        cat("  Egger intercept p-value:", plt$pval, "\n")
        
        # Steiger directionality
        steiger <- tryCatch(directionality_test(dat), error = function(e) NULL)
        if (!is.null(steiger)) {
            cat("  Steiger direction correct:", steiger$correct_causal_direction, "\n")
        }
        
        # Save scatter plot
        p1 <- mr_scatter_plot(res, dat)
        try({
            ggplot2::ggsave(p1[[1]], file=paste0("c:/Projectbulid/CP3/figures/MR_B_", gene, "_scatter.png"), width=7, height=7)
            cat("  Scatter plot saved\n")
        })
        
        # Forest plot
        p2 <- mr_forest_plot(mr_singlesnp(dat))
        try({
            ggplot2::ggsave(p2[[1]], file=paste0("c:/Projectbulid/CP3/figures/MR_B_", gene, "_forest.png"), width=7, height=7)
        })
    }
}

# Summary
cat("\n\n", rep("=", 60), "\n")
cat("MR-B SUMMARY\n")
cat(rep("=", 60), "\n")

if(length(results_list) > 0) {
    all_res <- bind_rows(results_list)
    write.csv(all_res, "c:/Projectbulid/CP3/results/MR_B_results.csv", row.names=FALSE)
    cat("✅ Results saved: CP3/results/MR_B_results.csv\n")
    cat("Genes with results:", paste(names(results_list), collapse=", "), "\n")
}

if(length(insufficient) > 0) {
    cat("⚠ Insufficient instruments:", paste(insufficient, collapse=", "), "\n")
    cat("  → Report as 'tissue-specific eQTL limitation' in manuscript\n")
}
