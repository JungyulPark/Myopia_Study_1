# ============================================
# C2 MVMR 수동 계산 (간단 버전)
# ============================================
library(TwoSampleMR)

Sys.setenv(OPENGWAS_JWT = "eyJhbGciOiJSUzI1NiIsImtpZCI6ImFwaS1qd3QiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJhcGkub3Blbmd3YXMuaW8iLCJhdWQiOiJhcGkub3Blbmd3YXMuaW8iLCJzdWIiOiJvcGhqeXBAbmF2ZXIuY29tIiwiaWF0IjoxNzc2MjMyODc0LCJleHAiOjE3Nzc0NDI0NzR9.E1s_0Y7WT1oM8Aj-AypV82UL0DL0hS3fJCtsiaMca9w6gsG_SjtXVoLHU7JWCLmSHG5VMQNsi_K9A5ScH3zov2mE4dvMa_m5-ylUDM_gwjIhQBUjOCerDnZ3edN64n2X-ycz-0bIMjlUIx0TOTxx1DQeU_61uLUSlIDcBcS9da1pd2hcxSxaVRh6nxbdfzlR67RcuHK5uKlAHRc1-6VzzfXLCOvgBESngodylhDD8r1wU_0o_H5swZ3lLZIbgxd9fC5zRLeylLPi5Yea3mGHvT3UwC-9kltpKqhTRirt4Pxm5wQ3sbEvEi7Ej3lS3c3Wq_V57SsDxM0gmNf_igYHgA")

snp <- "rs1963413"

cat("Step 1: Extracting TGFB1 instruments from eQTLGen...\n")
tgfb1_exp <- extract_instruments("eqtl-a-ENSG00000105329", p1 = 5e-6)
cat(sprintf("TGFB1 instruments: %d SNPs\n", nrow(tgfb1_exp)))

# Find rs1963413 in the instruments
idx <- which(tgfb1_exp$SNP == snp)
if (length(idx) == 0) {
    cat("rs1963413 not found in instruments - extracting directly from eQTLGen\n")
    snp_tgfb1 <- extract_outcome_data(snps = snp, outcomes = "eqtl-a-ENSG00000105329")
    beta_xz <- snp_tgfb1$beta.outcome[1]
    se_xz <- snp_tgfb1$se.outcome[1]
} else {
    beta_xz <- tgfb1_exp$beta.exposure[idx]
    se_xz <- tgfb1_exp$se.exposure[idx]
}

cat("Step 2: Extracting Height data for rs1963413...\n")
height_dat <- extract_outcome_data(snps = snp, outcomes = "ukb-b-10787")
beta_hz <- height_dat$beta.outcome[1]
se_hz <- height_dat$se.outcome[1]

cat("Step 3: Extracting Myopia data for rs1963413...\n")
myopia_dat <- extract_outcome_data(snps = snp, outcomes = "ukb-b-6353")
beta_yz <- myopia_dat$beta.outcome[1]
se_yz <- myopia_dat$se.outcome[1]

cat("\n=== rs1963413 Effect Sizes ===\n")
cat(sprintf("SNP -> TGFB1:  beta = %.4f, SE = %.4f\n", beta_xz, se_xz))
cat(sprintf("SNP -> Height: beta = %.4f, SE = %.4f\n", beta_hz, se_hz))
cat(sprintf("SNP -> Myopia: beta = %.4f, SE = %.4f\n", beta_yz, se_yz))

cat("\nStep 4: Height -> Myopia MR (IVW)...\n")
height_inst <- extract_instruments("ukb-b-10787", p1 = 5e-8, clump = TRUE, r2 = 0.001)
cat(sprintf("Height instruments: %d SNPs\n", nrow(height_inst)))

height_myopia_out <- extract_outcome_data(snps = height_inst$SNP, outcomes = "ukb-b-6353")
height_myopia_harm <- harmonise_data(height_inst, height_myopia_out)
height_myopia_mr <- mr(height_myopia_harm, method_list = c("mr_ivw"))
cat(sprintf(
    "Height -> Myopia IVW: beta = %.4f, P = %.2e\n",
    height_myopia_mr$b, height_myopia_mr$pval
))

beta_hy <- height_myopia_mr$b

# --- Decomposition ---
beta_total <- beta_yz / beta_xz
beta_indirect <- (beta_hz / beta_xz) * beta_hy
beta_direct <- beta_total - beta_indirect

cat("\n=== MVMR-equivalent Decomposition ===\n")
cat(sprintf("Total TGFB1->Myopia effect:    %.4f\n", beta_total))
cat(sprintf("Via-Height indirect effect:     %.4f\n", beta_indirect))
cat(sprintf("TGFB1 DIRECT effect (adjusted): %.4f\n", beta_direct))
cat(sprintf(
    "Proportion mediated by height:  %.1f%%\n",
    abs(beta_indirect / beta_total) * 100
))

if (abs(beta_direct) > abs(beta_total) * 0.5) {
    cat("\n>> TGFB1 direct effect SURVIVES height conditioning\n")
    cat(">> Height mediates only a minority of the total effect\n")
} else {
    cat("\n>> WARNING: Height may substantially mediate the TGFB1 effect\n")
}

# --- Save results ---
results <- data.frame(
    Parameter = c(
        "Total_effect", "Indirect_via_height", "Direct_effect",
        "Pct_mediated", "Height_Myopia_beta", "Height_Myopia_P"
    ),
    Value = c(
        beta_total, beta_indirect, beta_direct,
        abs(beta_indirect / beta_total) * 100,
        beta_hy, height_myopia_mr$pval
    )
)
dir.create("c:/Projectbulid/CP3/revision", showWarnings = FALSE, recursive = TRUE)
write.csv(results, "c:/Projectbulid/CP3/revision/C2_MVMR_decomposition.csv", row.names = FALSE)
cat("\nSaved: c:/Projectbulid/CP3/revision/C2_MVMR_decomposition.csv\n")
