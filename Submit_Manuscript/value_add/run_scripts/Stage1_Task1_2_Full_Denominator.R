# ===== Stage 1, Task 1.2: Full Denominator Suppl Table =====
# Goal: prepare 112-gene full denominator table for Suppl
#       - rank by p-value
#       - flag Bonferroni pass, Tier 1, Tier 2
#       - export as Suppl_TableS_full_denominator.csv

library(data.table)

ROOT  <- "C:/Projectbulid/Myopia"
DATA  <- file.path(ROOT, "CP6_assembly/data")
PATHY <- file.path(ROOT, "pathy")
dir.create(file.path(PATHY, "Stage1_QC"), showWarnings = FALSE, recursive = TRUE)

# 1. Load expanded MR results
expanded <- fread(file.path(DATA, "38_expanded_mr_results_tier1_primary.csv"))
cat(sprintf("Expanded MR rows: %d\n", nrow(expanded)))
cat(sprintf("Columns: %s\n\n", paste(names(expanded), collapse = ", ")))

# 2. Load Tier 1 validated hits
tier1 <- fread(file.path(DATA, "39_validated_hits_tier1.csv"))
cat(sprintf("Tier 1 validated hits: %d genes\n", nrow(tier1)))
cat(sprintf("Tier 1 genes: %s\n\n", paste(tier1$gene, collapse = ", ")))

# 3. Load independent anchors (Tier 1 + Tier 2)
anchors <- fread(file.path(DATA, "41_independent_anchors.csv"))
cat(sprintf("Independent anchors total: %d (T1=%d, T2=%d)\n\n",
            nrow(anchors),
            sum(anchors$tier_origin == "T1"),
            sum(anchors$tier_origin == "T2")))

# 4. Load coloc results
coloc <- fread(file.path(DATA, "43_coloc_results.csv"))
cat(sprintf("Coloc results: %d genes\n", nrow(coloc)))
cat(sprintf("Coloc genes: %s\n\n", paste(coloc$gene, collapse = ", ")))

# 5. Merge into single Suppl Table
# Start with full 112 genes from expanded MR
suppl <- expanded[, .(
  gene, eqtl_id, n_snps, method, F_statistic,
  beta, se, pval, bonferroni_alpha, bonferroni_pass,
  steiger_pval, steiger_correct
)]

# Add Tier 1 validation columns
t1_lookup <- tier1[, .(
  gene,
  cream_R_beta, cream_R_pval, cream_L_beta, cream_L_pval,
  cream_directional_consistency,
  reverse_mr_pval, reverse_mr_null,
  tier_T1_strong_secondary
)]
suppl <- merge(suppl, t1_lookup, by = "gene", all.x = TRUE)

# Add Tier 2 flag
t2_genes <- anchors[tier_origin == "T2", gene]
suppl[, in_tier2_anchors := gene %in% t2_genes]

# Add coloc columns
coloc_lookup <- coloc[, .(
  gene,
  coloc_PP_H1 = PP.H1, coloc_PP_H3 = PP.H3, coloc_PP_H4 = PP.H4,
  coloc_lead_snp = lead_snp_PP4, coloc_interpretation = interpretation
)]
suppl <- merge(suppl, coloc_lookup, by = "gene", all.x = TRUE)

# Define final tier
suppl[, final_tier := fcase(
  gene %in% c("RDH5", "CD55") & !is.na(coloc_PP_H4) & coloc_PP_H4 > 0.75,
    "Tier_A_coloc_supported",
  gene == "TGFB1",
    "Tier_B_MR_supported_distinct_variants",
  tier_T1_strong_secondary == TRUE & gene %in% c("CTNNB1", "FBN1"),
    "Tier_B_MR_supported_distinct_variants",
  in_tier2_anchors == TRUE,
    "Tier_2_independent_anchor",
  bonferroni_pass == TRUE,
    "Bonferroni_pass_no_validation",
  default = "Null"
)]

# Sort by pvalue
setorder(suppl, pval)

# Summary
cat("===== Final Tier Distribution =====\n")
print(suppl[, .N, by = final_tier])

cat("\n===== Tier A / B preview (top 10 by P) =====\n")
print(suppl[final_tier %in% c("Tier_A_coloc_supported",
                              "Tier_B_MR_supported_distinct_variants",
                              "Tier_2_independent_anchor")][1:10,
       .(gene, n_snps, beta, pval, bonferroni_pass,
         coloc_PP_H4, final_tier)])

# Export
out_path <- file.path(PATHY, "Stage1_QC", "Suppl_TableS_full_denominator.csv")
fwrite(suppl, out_path)
cat(sprintf("\nWrote: %s\n", out_path))
cat(sprintf("Total rows: %d\n", nrow(suppl)))
cat(sprintf("Columns: %d\n", ncol(suppl)))

cat("\n===== Final tier breakdown =====\n")
tier_summary <- suppl[, .N, by = final_tier]
setorder(tier_summary, -N)
print(tier_summary)
