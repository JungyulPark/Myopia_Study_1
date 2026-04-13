# CP3 MR-C/D/E: Unified script for remaining modules
# MR-C: Muscarinic Receptors → Myopia
# MR-D: Adrenergic (ADRA2A) → Myopia
# MR-E: HIF-1α / TGFβ / ECM → Myopia
# All at STRICT p1 = 5e-6

Sys.setenv(OPENGWAS_JWT = "eyJhbGciOiJSUzI1NiIsImtpZCI6ImFwaS1qd3QiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJhcGkub3Blbmd3YXMuaW8iLCJhdWQiOiJhcGkub3Blbmd3YXMuaW8iLCJzdWIiOiJvcGhqeXBAbmF2ZXIuY29tIiwiaWF0IjoxNzc1OTc4NDcwLCJleHAiOjE3NzcxODgwNzB9.TT5w4_5V7kXgMEMwOabASlF8DEoJBay87xqTBv50QASMarmorUm9nX2BbXVkhvGuoXSKC6fJfG_8w_adXc8h1Nq4ECS9YobEst1ej7Qn9LU7oJ7OFx3NepNYKUg3keCDJVZK8_xFrlE9_aToYEe_f5bbhH2HjGOoPcLiA2_xh6UGUNIqbPELbyODpUl35MVwcuLeiNM6fMWssPXfQ3_06ibsqA6T3_uZIOdai7Eqkmo8WhOdp-HIE9M96RXHE9NCJdb7a4G0HtUsGTJYJWMrnSWJ9mKBU77CSCAG2GBnbyjlUzPeylXxRY7ZzZWzwKY2qD0GHFC3waZZ9xs0lAUFWw")

library(TwoSampleMR)
library(dplyr)
library(ieugwasr)

dir.create("c:/Projectbulid/CP3/results", showWarnings = FALSE, recursive = TRUE)
dir.create("c:/Projectbulid/CP3/figures", showWarnings = FALSE, recursive = TRUE)

outcome_id <- "ukb-b-6353"  # UKB Myopia N=460K

# Define all remaining modules
modules <- list(
    "MR_C" = list(
        name = "Muscarinic Receptors",
        exposures = c(
            "CHRM1" = "eqtl-a-ENSG00000168539",
            "CHRM2" = "eqtl-a-ENSG00000181072",
            "CHRM3" = "eqtl-a-ENSG00000133019",
            "CHRM4" = "eqtl-a-ENSG00000180720",
            "CHRM5" = "eqtl-a-ENSG00000184984"
        )
    ),
    "MR_D" = list(
        name = "Adrenergic / Non-cholinergic",
        exposures = c(
            "ADRA2A" = "eqtl-a-ENSG00000150594",
            "GABRA1" = "eqtl-a-ENSG00000022355",
            "EGFR"   = "eqtl-a-ENSG00000146648"
        )
    ),
    "MR_E" = list(
        name = "HIF-1a / TGFb / ECM",
        exposures = c(
            "HIF1A" = "eqtl-a-ENSG00000100644",
            "TGFB1" = "eqtl-a-ENSG00000105329",
            "LOX"   = "eqtl-a-ENSG00000113083",
            "MMP2"  = "eqtl-a-ENSG00000087245",
            "VEGFA" = "eqtl-a-ENSG00000112715"
        )
    )
)

all_results <- list()
all_insufficient <- list()

for (mod_id in names(modules)) {
    mod <- modules[[mod_id]]
    cat("\n", rep("=", 60), "\n")
    cat("MODULE", mod_id, ":", mod$name, "\n")
    cat(rep("=", 60), "\n")
    
    mod_results <- list()
    mod_insuf <- c()
    
    for (gene in names(mod$exposures)) {
        cat("\n--- Gene:", gene, "---\n")
        expo_id <- mod$exposures[[gene]]
        
        # Extract instruments at STRICT p<5e-6
        exp_dat <- tryCatch({
            extract_instruments(outcomes = expo_id, p1 = 5e-06, clump = TRUE, r2 = 0.001, kb = 10000)
        }, error = function(e) { cat("  API error:", conditionMessage(e), "\n"); NULL })
        
        if (is.null(exp_dat) || nrow(exp_dat) == 0) {
            cat("  INSUFFICIENT INSTRUMENTS at p<5e-6\n")
            mod_insuf <- c(mod_insuf, gene)
            next
        }
        
        # F-statistic
        exp_dat$F_stat <- (exp_dat$beta.exposure / exp_dat$se.exposure)^2
        exp_dat <- subset(exp_dat, F_stat > 10)
        cat("  IVs:", nrow(exp_dat), "| Mean F:", round(mean(exp_dat$F_stat), 1), "\n")
        if (nrow(exp_dat) == 0) { mod_insuf <- c(mod_insuf, gene); next }
        
        # Outcome
        out_dat <- tryCatch({
            extract_outcome_data(snps = exp_dat$SNP, outcomes = outcome_id)
        }, error = function(e) { NULL })
        
        if (is.null(out_dat) || nrow(out_dat) == 0) {
            cat("  No outcome data\n")
            mod_insuf <- c(mod_insuf, gene)
            next
        }
        
        # Harmonize
        dat <- harmonise_data(exp_dat, out_dat)
        dat <- subset(dat, mr_keep == TRUE)
        cat("  Harmonized SNPs:", nrow(dat), "\n")
        if (nrow(dat) == 0) { mod_insuf <- c(mod_insuf, gene); next }
        
        # MR
        if (nrow(dat) == 1) {
            res <- mr(dat, method_list = "mr_wald_ratio")
        } else if (nrow(dat) == 2) {
            res <- mr(dat, method_list = "mr_ivw")
        } else {
            res <- mr(dat, method_list = c("mr_ivw", "mr_egger_regression", "mr_weighted_median", "mr_weighted_mode"))
        }
        res$Gene <- gene
        res$Module <- mod_id
        
        cat("  RESULTS:\n")
        print(res[, c("method", "nsnp", "b", "se", "pval")])
        mod_results[[gene]] <- res
        
        # Sensitivity (if >= 3 IVs)
        if (nrow(dat) >= 3) {
            het <- tryCatch(mr_heterogeneity(dat), error = function(e) NULL)
            plt <- tryCatch(mr_pleiotropy_test(dat), error = function(e) NULL)
            if (!is.null(het)) cat("  Cochran's Q p:", round(het$Q_pval[1], 4), "\n")
            if (!is.null(plt)) cat("  Egger intercept p:", round(plt$pval, 4), "\n")
            
            # Save plots
            try({
                p1 <- mr_scatter_plot(res, dat)
                ggplot2::ggsave(p1[[1]], file=paste0("c:/Projectbulid/CP3/figures/", mod_id, "_", gene, "_scatter.png"), width=7, height=7)
            }, silent = TRUE)
        }
    }
    
    if (length(mod_results) > 0) {
        mod_df <- bind_rows(mod_results)
        all_results[[mod_id]] <- mod_df
        write.csv(mod_df, paste0("c:/Projectbulid/CP3/results/", mod_id, "_results.csv"), row.names=FALSE)
        cat("\nResults saved for", mod_id, "\n")
    }
    
    all_insufficient[[mod_id]] <- mod_insuf
    if (length(mod_insuf) > 0) {
        cat("Insufficient instruments:", paste(mod_insuf, collapse=", "), "\n")
    }
}

# Consolidated summary
cat("\n\n", rep("=", 60), "\n")
cat("CONSOLIDATED CP3 SUMMARY (MR-C/D/E)\n")
cat(rep("=", 60), "\n\n")

if (length(all_results) > 0) {
    final <- bind_rows(all_results)
    write.csv(final, "c:/Projectbulid/CP3/results/MR_CDE_consolidated.csv", row.names=FALSE)
    cat("All results saved to CP3/results/MR_CDE_consolidated.csv\n\n")
    
    # Print summary table
    sig <- final %>% filter(pval < 0.05)
    if (nrow(sig) > 0) {
        cat("SIGNIFICANT RESULTS (p<0.05):\n")
        print(sig[, c("Gene", "Module", "method", "nsnp", "b", "pval")])
    } else {
        cat("No significant results at p<0.05\n")
    }
}

cat("\nInsufficient instruments by module:\n")
for (mod_id in names(all_insufficient)) {
    insuf <- all_insufficient[[mod_id]]
    if (length(insuf) > 0) {
        cat("  ", mod_id, ":", paste(insuf, collapse=", "), "\n")
    }
}
