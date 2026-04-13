# CP3 MVMR v2: Expanded model with TGFB1 + HIF1A + VEGFA
# Need more instruments for MVMR to work

Sys.setenv(OPENGWAS_JWT = "eyJhbGciOiJSUzI1NiIsImtpZCI6ImFwaS1qd3QiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJhcGkub3Blbmd3YXMuaW8iLCJhdWQiOiJhcGkub3Blbmd3YXMuaW8iLCJzdWIiOiJvcGhqeXBAbmF2ZXIuY29tIiwiaWF0IjoxNzc1OTc4NDcwLCJleHAiOjE3NzcxODgwNzB9.TT5w4_5V7kXgMEMwOabASlF8DEoJBay87xqTBv50QASMarmorUm9nX2BbXVkhvGuoXSKC6fJfG_8w_adXc8h1Nq4ECS9YobEst1ej7Qn9LU7oJ7OFx3NepNYKUg3keCDJVZK8_xFrlE9_aToYEe_f5bbhH2HjGOoPcLiA2_xh6UGUNIqbPELbyODpUl35MVwcuLeiNM6fMWssPXfQ3_06ibsqA6T3_uZIOdai7Eqkmo8WhOdp-HIE9M96RXHE9NCJdb7a4G0HtUsGTJYJWMrnSWJ9mKBU77CSCAG2GBnbyjlUzPeylXxRY7ZzZWzwKY2qD0GHFC3waZZ9xs0lAUFWw")

library(TwoSampleMR)
library(dplyr)
library(ieugwasr)

cat("=== MVMR v2: TGFB1 + HIF1A + VEGFA → Myopia ===\n\n")

# Include VEGFA (5 IVs) to provide enough instruments
exposure_ids <- c(
    "eqtl-a-ENSG00000105329",  # TGFB1
    "eqtl-a-ENSG00000100644",  # HIF1A
    "eqtl-a-ENSG00000112715"   # VEGFA
)

cat("Extracting multivariable exposures (3 genes)...\n")
mv_exposures <- tryCatch({
    mv_extract_exposures(
        id_exposure = exposure_ids,
        clump_r2 = 0.001,
        pval_threshold = 5e-6
    )
}, error = function(e) { cat("Error:", conditionMessage(e), "\n"); NULL })

if (!is.null(mv_exposures) && nrow(mv_exposures) > 0) {
    cat("Total instruments:", nrow(mv_exposures), "\n")
    cat("By exposure:\n")
    print(table(mv_exposures$exposure))
    
    # Check minimum instruments
    if (nrow(mv_exposures) >= 4) {
        mv_outcome <- extract_outcome_data(
            snps = mv_exposures$SNP,
            outcomes = "ukb-b-6353"
        )
        
        if (!is.null(mv_outcome) && nrow(mv_outcome) > 0) {
            mv_harmonised <- mv_harmonise_data(mv_exposures, mv_outcome)
            
            cat("\nRunning MVMR...\n")
            mv_result <- tryCatch({
                mv_multiple(mv_harmonised)
            }, error = function(e) {
                cat("MVMR error:", conditionMessage(e), "\n")
                cat("Trying mv_basic instead...\n")
                tryCatch(mv_basic(mv_harmonised), error = function(e2) {
                    cat("mv_basic also failed:", conditionMessage(e2), "\n")
                    NULL
                })
            })
            
            if (!is.null(mv_result)) {
                cat("\n--- MVMR RESULTS ---\n")
                if ("result" %in% names(mv_result)) {
                    print(mv_result$result)
                    write.csv(mv_result$result, "c:/Projectbulid/CP3/results/MVMR_results.csv", row.names=FALSE)
                } else {
                    print(mv_result)
                    write.csv(as.data.frame(mv_result), "c:/Projectbulid/CP3/results/MVMR_results.csv", row.names=FALSE)
                }
                cat("\n✅ MVMR results saved\n")
            }
        }
    } else {
        cat("Only", nrow(mv_exposures), "instruments — insufficient for MVMR\n")
        cat("MVMR requires at least k+1 instruments (k=number of exposures)\n")
        cat("→ Document as methodological limitation in manuscript\n")
    }
} else {
    cat("MVMR exposure extraction failed\n")
}

# ================================================================
# PART 2: GTEx tissue-specific eQTL for key missing genes
# ================================================================
cat("\n\n=== GTEx TISSUE-SPECIFIC eQTL SEARCH ===\n")

all_gwas <- tryCatch(gwasinfo(), error = function(e) NULL)

if (!is.null(all_gwas)) {
    key_genes <- c(
        "YAP1" = "ENSG00000137693",
        "LATS1" = "ENSG00000131023",
        "DRD1" = "ENSG00000184845",
        "TH" = "ENSG00000180176",
        "TEAD1" = "ENSG00000187079"
    )
    
    gtex_found <- list()
    
    for (gene_name in names(key_genes)) {
        ensembl <- key_genes[[gene_name]]
        
        # Search for tissue-specific eQTL (not eqtl-a which is eQTLGen blood)
        matches <- all_gwas %>%
            filter(grepl(ensembl, id, ignore.case=TRUE)) %>%
            select(id, trait, sample_size)
        
        cat("\n", gene_name, "(", ensembl, "):", nrow(matches), "datasets\n")
        
        if (nrow(matches) > 1) {
            # Show non-blood options
            for (j in 1:min(nrow(matches), 5)) {
                cat("  ", matches$id[j], "→", matches$trait[j], "\n")
            }
        }
        
        # Try non-eqtl-a sources
        non_blood <- matches %>% filter(!grepl("^eqtl-a-", id))
        if (nrow(non_blood) > 0) {
            for (k in 1:min(nrow(non_blood), 2)) {
                iv <- tryCatch(extract_instruments(outcomes = non_blood$id[k], p1 = 5e-6), error = function(e) NULL)
                if (!is.null(iv) && nrow(iv) > 0) {
                    cat("  ✅", gene_name, ":", nrow(iv), "IVs from", non_blood$id[k], "\n")
                    gtex_found[[gene_name]] <- list(id = non_blood$id[k], iv = iv)
                    
                    # Run MR immediately
                    iv$F_stat <- (iv$beta.exposure / iv$se.exposure)^2
                    iv <- subset(iv, F_stat > 10)
                    out <- tryCatch(extract_outcome_data(snps=iv$SNP, outcomes="ukb-b-6353"), error=function(e) NULL)
                    if (!is.null(out) && nrow(out) > 0) {
                        dat <- harmonise_data(iv, out)
                        dat <- subset(dat, mr_keep == TRUE)
                        if (nrow(dat) > 0) {
                            res <- mr(dat)
                            cat("  MR result:", gene_name, "→ IVW p =", round(res$pval[1], 4), "\n")
                        }
                    }
                    break  # Found one, move to next gene
                }
            }
        }
    }
    
    if (length(gtex_found) == 0) {
        cat("\nNo tissue-specific eQTL instruments found.\n")
        cat("This confirms: blood eQTL limitation for tissue-specific genes\n")
        cat("Report in manuscript as acknowledged limitation\n")
    }
}
