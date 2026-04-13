# CP3 MR-A Re-evaluation: COMT F-stat check + strict p1=5e-6

Sys.setenv(OPENGWAS_JWT = "eyJhbGciOiJSUzI1NiIsImtpZCI6ImFwaS1qd3QiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJhcGkub3Blbmd3YXMuaW8iLCJhdWQiOiJhcGkub3Blbmd3YXMuaW8iLCJzdWIiOiJvcGhqeXBAbmF2ZXIuY29tIiwiaWF0IjoxNzc1OTc4NDcwLCJleHAiOjE3NzcxODgwNzB9.TT5w4_5V7kXgMEMwOabASlF8DEoJBay87xqTBv50QASMarmorUm9nX2BbXVkhvGuoXSKC6fJfG_8w_adXc8h1Nq4ECS9YobEst1ej7Qn9LU7oJ7OFx3NepNYKUg3keCDJVZK8_xFrlE9_aToYEe_f5bbhH2HjGOoPcLiA2_xh6UGUNIqbPELbyODpUl35MVwcuLeiNM6fMWssPXfQ3_06ibsqA6T3_uZIOdai7Eqkmo8WhOdp-HIE9M96RXHE9NCJdb7a4G0HtUsGTJYJWMrnSWJ9mKBU77CSCAG2GBnbyjlUzPeylXxRY7ZzZWzwKY2qD0GHFC3waZZ9xs0lAUFWw")

library(TwoSampleMR)
library(dplyr)
library(ieugwasr)

cat("=== MR-A Re-evaluation: COMT at STRICT p<5e-6 ===\n\n")

# COMT eQTL at strict threshold
exp_dat <- extract_instruments("eqtl-a-ENSG00000093010", p1 = 5e-06, clump = TRUE, r2 = 0.001, kb = 10000)

if (!is.null(exp_dat) && nrow(exp_dat) > 0) {
    exp_dat$F_stat <- (exp_dat$beta.exposure / exp_dat$se.exposure)^2
    cat("COMT at p<5e-6:", nrow(exp_dat), "SNPs\n")
    cat("Individual F-stats:", paste(round(exp_dat$F_stat, 1), collapse=", "), "\n")
    cat("Mean F-stat:", round(mean(exp_dat$F_stat), 1), "\n")
    cat("Min F-stat:", round(min(exp_dat$F_stat), 1), "\n\n")
    
    # Run MR with strict IVs
    out_dat <- extract_outcome_data(snps = exp_dat$SNP, outcomes = "ukb-b-6353")
    if (!is.null(out_dat) && nrow(out_dat) > 0) {
        dat <- harmonise_data(exp_dat, out_dat)
        dat <- subset(dat, mr_keep == TRUE)
        cat("SNPs after harmonization:", nrow(dat), "\n")
        
        if (nrow(dat) > 0) {
            if (nrow(dat) >= 3) {
                res <- mr(dat, method_list = c("mr_ivw", "mr_egger_regression", "mr_weighted_median"))
            } else {
                res <- mr(dat)
            }
            cat("\n--- COMT STRICT MR RESULTS ---\n")
            print(res[, c("method", "nsnp", "b", "se", "pval")])
            write.csv(res, "c:/Projectbulid/CP3/results/MR_A_COMT_strict.csv", row.names=FALSE)
        }
    } else {
        cat("No outcome data available for COMT SNPs\n")
    }
} else {
    cat("COMT: 0 SNPs at p<5e-6 — insufficient instruments\n")
    cat("This is a legitimate finding: report in manuscript\n")
}

cat("\n=== TH/DRD1/DRD2 tissue limitation ===\n")
cat("TH, DRD1, DRD2: No eQTL instruments in blood (eQTLGen).\n")
cat("These are brain-specific genes. Report as:\n")
cat("'Tissue-specific eQTL limitation: dopamine synthesis/receptor genes\n")
cat(" lack blood-based cis-eQTL instruments, consistent with their\n")
cat(" predominantly neuronal expression pattern.'\n")

# Search for brain-tissue specific eQTL IDs
cat("\n=== Searching for GTEx brain eQTLs ===\n")
res_info <- gwasinfo()
brain_th <- res_info %>% filter(grepl("ENSG00000180176", id), grepl("brain|Brain", trait, ignore.case=TRUE)) %>% select(id, trait, sample_size)
if(nrow(brain_th) > 0) {
    cat("Found brain eQTL for TH:\n")
    print(brain_th)
} else {
    cat("No brain-specific eQTL for TH found in OpenGWAS\n")
}
