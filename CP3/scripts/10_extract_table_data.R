###############################################################################
# Extract F-statistics and IV details for enhanced Table 1
# Run BEFORE table generation to get exact values
# Save to: c:\Projectbulid\CP3\scripts\10_extract_table_data.R
###############################################################################

library(TwoSampleMR)
library(ieugwasr)
library(dplyr)

Sys.setenv(OPENGWAS_JWT = "eyJhbGciOiJSUzI1NiIsImtpZCI6ImFwaS1qd3QiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJhcGkub3Blbmd3YXMuaW8iLCJhdWQiOiJhcGkub3Blbmd3YXMuaW8iLCJzdWIiOiJvcGhqeXBAbmF2ZXIuY29tIiwiaWF0IjoxNzc1OTc4NDcwLCJleHAiOjE3NzcxODgwNzB9.TT5w4_5V7kXgMEMwOabASlF8DEoJBay87xqTBv50QASMarmorUm9nX2BbXVkhvGuoXSKC6fJfG_8w_adXc8h1Nq4ECS9YobEst1ej7Qn9LU7oJ7OFx3NepNYKUg3keCDJVZK8_xFrlE9_aToYEe_f5bbhH2HjGOoPcLiA2_xh6UGUNIqbPELbyODpUl35MVwcuLeiNM6fMWssPXfQ3_06ibsqA6T3_uZIOdai7Eqkmo8WhOdp-HIE9M96RXHE9NCJdb7a4G0HtUsGTJYJWMrnSWJ9mKBU77CSCAG2GBnbyjlUzPeylXxRY7ZzZWzwKY2qD0GHFC3waZZ9xs0lAUFWw")

outdir <- "c:/Projectbulid/CP3/results/"

cat("=== EXTRACTING F-STATISTICS AND IV DETAILS ===\n\n")

# Use CORRECT eQTL IDs based on original scripts
eqtl_ids <- c(
  "TGFB1"  = "eqtl-a-ENSG00000105329",
  "LATS2"  = "eqtl-a-ENSG00000150768", # CORRECTED ID!
  "HIF1A"  = "eqtl-a-ENSG00000100644",
  "COMT"   = "eqtl-a-ENSG00000093010",
  "ADRA2A" = "eqtl-a-ENSG00000150594",
  "CHRM3"  = "eqtl-a-ENSG00000133019",
  "LOX"    = "eqtl-a-ENSG00000113083"
)

outcome_id <- "ukb-b-6353"
all_iv_data <- list()

for (gene in names(eqtl_ids)) {
  cat(sprintf("--- %s ---\n", gene))

  # Match the extraction threshold from specific MR runs
  p_val <- if (gene %in% c("COMT", "LATS2")) 5e-6 else 1e-4

  exp <- tryCatch(
    {
      extract_instruments(outcomes = eqtl_ids[[gene]], p1 = p_val, clump = TRUE)
    },
    error = function(e) {
      NULL
    }
  )

  if (is.null(exp) || nrow(exp) == 0) next

  # Fetch outcome and harmonize so we ONLY count surviving SNPs
  out <- tryCatch(
    {
      extract_outcome_data(snps = exp$SNP, outcomes = outcome_id)
    },
    error = function(e) {
      NULL
    }
  )

  if (is.null(out) || nrow(out) == 0) next

  dat <- harmonise_data(exp, out)
  dat <- subset(dat, mr_keep == TRUE)

  if (nrow(dat) > 0) {
    # F-statistic calculation for KEPT SNPs
    dat$F_statistic <- (dat$beta.exposure / dat$se.exposure)^2
    dat <- subset(dat, F_statistic > 10) # F filter used in all scripts

    if (nrow(dat) > 0) {
      # R² approximation
      N_eqtl <- 31684
      dat$R2 <- dat$F_statistic / (dat$F_statistic + N_eqtl - 2)

      mean_F <- mean(dat$F_statistic)
      min_F <- min(dat$F_statistic)
      total_R2 <- sum(dat$R2)

      all_iv_data[[gene]] <- data.frame(
        Gene = gene,
        N_IV = nrow(dat),
        SNPs = paste(dat$SNP, collapse = "; "),
        Effect_Alleles = paste(dat$effect_allele.exposure, collapse = "; "),
        EAF = paste(round(dat$eaf.exposure, 3), collapse = "; "),
        Beta_exposure = paste(round(dat$beta.exposure, 4), collapse = "; "),
        SE_exposure = paste(round(dat$se.exposure, 4), collapse = "; "),
        P_exposure = paste(formatC(dat$pval.exposure, format = "e", digits = 1), collapse = "; "),
        Mean_F_statistic = round(mean_F, 1),
        Min_F_statistic = round(min_F, 1),
        R2 = formatC(total_R2, format = "e", digits = 2),
        stringsAsFactors = FALSE
      )
    }
  }
}

if (length(all_iv_data) > 0) {
  iv_table <- do.call(rbind, all_iv_data)
  write.csv(iv_table, file.path(outdir, "enhanced_table1_iv_details.csv"), row.names = FALSE)
  print(iv_table[, c("Gene", "N_IV", "SNPs", "Mean_F_statistic", "Min_F_statistic")])
}
