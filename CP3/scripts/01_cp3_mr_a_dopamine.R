# CP3 MR-A: Dopamine Pathway → Myopia

# Load packages safely
if(!require("TwoSampleMR")) stop("Please install TwoSampleMR: remotes::install_github('MRCIEU/TwoSampleMR')")
if(!require("dplyr")) install.packages("dplyr")
library(TwoSampleMR)
library(dplyr)
library(ieugwasr)

# OpenGWAS JWT Authentication
Sys.setenv(OPENGWAS_JWT = "eyJhbGciOiJSUzI1NiIsImtpZCI6ImFwaS1qd3QiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJhcGkub3Blbmd3YXMuaW8iLCJhdWQiOiJhcGkub3Blbmd3YXMuaW8iLCJzdWIiOiJvcGhqeXBAbmF2ZXIuY29tIiwiaWF0IjoxNzc1OTc4NDcwLCJleHAiOjE3NzcxODgwNzB9.TT5w4_5V7kXgMEMwOabASlF8DEoJBay87xqTBv50QASMarmorUm9nX2BbXVkhvGuoXSKC6fJfG_8w_adXc8h1Nq4ECS9YobEst1ej7Qn9LU7oJ7OFx3NepNYKUg3keCDJVZK8_xFrlE9_aToYEe_f5bbhH2HjGOoPcLiA2_xh6UGUNIqbPELbyODpUl35MVwcuLeiNM6fMWssPXfQ3_06ibsqA6T3_uZIOdai7Eqkmo8WhOdp-HIE9M96RXHE9NCJdb7a4G0HtUsGTJYJWMrnSWJ9mKBU77CSCAG2GBnbyjlUzPeylXxRY7ZzZWzwKY2qD0GHFC3waZZ9xs0lAUFWw")

dir.create("c:/Projectbulid/CP3/results", showWarnings = FALSE, recursive = TRUE)
dir.create("c:/Projectbulid/CP3/figures", showWarnings = FALSE, recursive = TRUE)

cat("Starting CP3 Module A: Dopamine -> Myopia MR\n")

# Exposures from GTEx v8 eQTLs
# We use p < 5e-6 to ensure sufficient IVs if 5e-8 is too strict
exposures <- c(
    "TH"   = "eqtl-a-ENSG00000180176",  # Tyrosine hydroxylase
    "DRD1" = "eqtl-a-ENSG00000184845",  # D1 receptor
    "DRD2" = "eqtl-a-ENSG00000149295",  # D2 receptor
    "COMT" = "eqtl-a-ENSG00000093010"   # COMT
)

# Outcome: Refractive error / Myopia
# ukb-b-6353: Reason for glasses/contact lenses: For short-sightedness, i.e. myopia (N=460,536)
outcome_id <- "ukb-b-6353"

results_list <- list()

for(gene in names(exposures)) {
    cat("\n========================================\n")
    cat("Processing Gene:", gene, "\n")
    expo_id <- exposures[[gene]]
    
    # 1. Extract Instruments
    cat("Extracting instruments from OpenGWAS...\n")
    exp_dat <- tryCatch({
        extract_instruments(outcomes = expo_id, p1 = 1e-04, clump = TRUE, r2 = 0.001, kb = 10000)
    }, error = function(e){ NULL })
    
    if (is.null(exp_dat) || nrow(exp_dat) == 0) {
        cat("No SNPs found for", gene, "at p<5e-6\n")
        next
    }
    
    # 2. F-statistic check
    exp_dat$F_stat <- (exp_dat$beta.exposure / exp_dat$se.exposure)^2
    exp_dat <- subset(exp_dat, F_stat > 10)
    cat(nrow(exp_dat), "SNPs passed F-statistic > 10 filter.\n")
    
    if (nrow(exp_dat) == 0) next
    
    # 3. Outcome data
    out_dat <- tryCatch({
        extract_outcome_data(snps = exp_dat$SNP, outcomes = outcome_id)
    }, error = function(e){ NULL })
    
    if (is.null(out_dat) || nrow(out_dat) == 0) {
        cat("Outcome data not available for SNPs in", gene, "\n")
        next
    }
    
    # 4. Harmonize
    dat <- harmonise_data(exposure_dat = exp_dat, outcome_dat = out_dat)
    
    # Filter out ambiguous palindromic
    dat <- subset(dat, mr_keep == TRUE)
    cat(nrow(dat), "SNPs available after harmonization.\n")
    if (nrow(dat) == 0) next
    
    # 5. MR Analysis
    res <- mr(dat, method_list = c("mr_wald_ratio", "mr_ivw", "mr_egger_regression", "mr_weighted_median"))
    res$Gene <- gene
    
    print(res)
    results_list[[gene]] <- res
    
    # 6. Sensitivity Ploting
    if (nrow(dat) >= 3) {
        cat("Running sensitivity analysis...\n")
        het <- mr_heterogeneity(dat)
        plt <- mr_pleiotropy_test(dat)
        print(het)
        print(plt)
        
        # Save scatter plot
        p1 <- mr_scatter_plot(res, dat)
        try({
            ggplot2::ggsave(p1[[1]], file=paste0("c:/Projectbulid/CP3/figures/MR_A_", gene, "_scatter.png"), width=7, height=7)
        })
    }
}

if(length(results_list) > 0) {
    all_res <- bind_rows(results_list)
    write.csv(all_res, "c:/Projectbulid/CP3/results/MR_A_results.csv", row.names=FALSE)
    cat("\n✅ Saved MR-A results to CP3/results/MR_A_results.csv\n")
} else {
    cat("\n❌ No results generated for MR-A.\n")
}
