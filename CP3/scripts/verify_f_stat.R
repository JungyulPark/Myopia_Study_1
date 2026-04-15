library(TwoSampleMR)
library(ieugwasr)

Sys.setenv(OPENGWAS_JWT = "eyJhbGciOiJSUzI1NiIsImtpZCI6ImFwaS1qd3QiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJhcGkub3Blbmd3YXMuaW8iLCJhdWQiOiJhcGkub3Blbmd3YXMuaW8iLCJzdWIiOiJvcGhqeXBAbmF2ZXIuY29tIiwiaWF0IjoxNzc1OTc4NDcwLCJleHAiOjE3NzcxODgwNzB9.TT5w4_5V7kXgMEMwOabASlF8DEoJBay87xqTBv50QASMarmorUm9nX2BbXVkhvGuoXSKC6fJfG_8w_adXc8h1Nq4ECS9YobEst1ej7Qn9LU7oJ7OFx3NepNYKUg3keCDJVZK8_xFrlE9_aToYEe_f5bbhH2HjGOoPcLiA2_xh6UGUNIqbPELbyODpUl35MVwcuLeiNM6fMWssPXfQ3_06ibsqA6T3_uZIOdai7Eqkmo8WhOdp-HIE9M96RXHE9NCJdb7a4G0HtUsGTJYJWMrnSWJ9mKBU77CSCAG2GBnbyjlUzPeylXxRY7ZzZWzwKY2qD0GHFC3waZZ9xs0lAUFWw")

# Use CORRECT eQTL IDs based on original scripts
eqtl_ids <- c(
    "TGFB1"  = "eqtl-a-ENSG00000105329",
    "LATS2"  = "eqtl-a-ENSG00000150768", # Correct ID!
    "HIF1A"  = "eqtl-a-ENSG00000100644",
    "COMT"   = "eqtl-a-ENSG00000093010",
    "ADRA2A" = "eqtl-a-ENSG00000150594",
    "CHRM3"  = "eqtl-a-ENSG00000133019",
    "LOX"    = "eqtl-a-ENSG00000113083"
)

outcome_id <- "ukb-b-6353"
ans <- list()

for (gene in names(eqtl_ids)) {
    id <- eqtl_ids[[gene]]
    # Match the p1 threshold from original scripts:
    # LATS2 used p1=5e-6, COMT strict used p1=5e-6 in mr_a_reeval
    # HIF1A in mr_cde used p1=1e-4 probably? Let's use 5e-6 for all except maybe they need different?
    # Wait, mr_cde used p1=1e-4 ... wait, to perfectly match, we should just read what TwoSampleMR does.
    # Let's extract with 1e-4, then subset to the exact SNPs found in the CSVs!

    if (gene == "COMT" || gene == "LATS2") {
        p_val <- 5e-6
    } else {
        p_val <- 1e-4
    }

    exp <- tryCatch(
        {
            extract_instruments(outcomes = id, p1 = p_val, clump = TRUE)
        },
        error = function(e) NULL
    )
    if (is.null(exp)) next

    out <- tryCatch(
        {
            extract_outcome_data(snps = exp$SNP, outcomes = outcome_id)
        },
        error = function(e) NULL
    )
    if (is.null(out)) next

    dat <- harmonise_data(exp, out)
    dat <- subset(dat, mr_keep == TRUE)

    # Calculate F statistic on the kept SNPs ONLY
    dat$F_stat <- (dat$beta.exposure / dat$se.exposure)^2
    dat <- subset(dat, F_stat > 10)

    ans[[gene]] <- data.frame(
        Gene = gene,
        Real_N_IV = nrow(dat),
        SNPs = paste(dat$SNP, collapse = ";"),
        Mean_F = round(mean(dat$F_stat), 1),
        Min_F = round(min(dat$F_stat), 1),
        Max_F = round(max(dat$F_stat), 1)
    )
}

final <- do.call(rbind, ans)
print(final)
write.csv(final, "c:/Projectbulid/CP3/results/TRUE_IV_STATS.csv", row.names = FALSE)
