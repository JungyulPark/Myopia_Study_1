# ===== Stage 1, Task 1.4b: Coloc sensitivity recalculation =====
# Goal: recalculate PP.H0-H4 under 3 prior sets using saved lABF

library(data.table)
library(coloc)

ROOT <- "C:/Projectbulid/Myopia"
COLOC_PROG <- file.path(ROOT, "CP6_assembly/data/coloc_progress")
PATHY_QC <- file.path(ROOT, "pathy/Stage1_QC")
dir.create(PATHY_QC, showWarnings = FALSE, recursive = TRUE)

# Manual PP recalculation from lABF
# Reference: Giambartolomei 2014, coloc.abf source code
# 
# PP.H0 prop to 1
# PP.H1 prop to p1 * sum(exp(lABF.df1))
# PP.H2 prop to p2 * sum(exp(lABF.df2))
# PP.H3 prop to p1*p2 * (sum(exp(lABF.df1)) * sum(exp(lABF.df2)) - sum(exp(lABF.df1+lABF.df2)))
# PP.H4 prop to p12 * sum(exp(lABF.df1 + lABF.df2))
#
# All proportional; normalize to sum 1

recalc_PP <- function(results, p1, p2, p12) {
  l1 <- results$lABF.df1
  l2 <- results$lABF.df2
  l12 <- l1 + l2
  
  # log-sum-exp trick for numerical stability
  lse <- function(x) {
    m <- max(x)
    if (!is.finite(m)) return(-Inf)
    m + log(sum(exp(x - m)))
  }
  
  lH1 <- log(p1) + lse(l1)
  lH2 <- log(p2) + lse(l2)
  
  # H3: distinct variants - need pairwise sum minus diagonal
  # log(sum_{i != j} exp(l1[i] + l2[j])) = log( sum_i exp(l1[i]) * sum_j exp(l2[j]) - sum_i exp(l1[i] + l2[i]) )
  # Use logspace: lH3 = log(p1*p2) + log(exp(lse_l1+lse_l2) - exp(lse_l12))
  lse_l1  <- lse(l1)
  lse_l2  <- lse(l2)
  lse_l12 <- lse(l12)
  
  if (lse_l1 + lse_l2 > lse_l12) {
    # log(exp(a) - exp(b)) = a + log(1 - exp(b - a))
    a <- lse_l1 + lse_l2
    b <- lse_l12
    lH3 <- log(p1) + log(p2) + a + log1p(-exp(b - a))
  } else {
    lH3 <- -Inf
  }
  
  lH4 <- log(p12) + lse_l12
  
  # H0 contribution: 1 (log = 0)
  lH0 <- 0
  
  # Normalize
  all_l <- c(lH0, lH1, lH2, lH3, lH4)
  m <- max(all_l)
  PP <- exp(all_l - m) / sum(exp(all_l - m))
  names(PP) <- c("PP.H0", "PP.H1", "PP.H2", "PP.H3", "PP.H4")
  PP
}

# Verify against default first
cat("===== Verification: recalculate vs original (default priors) =====\n")
genes <- c("RDH5", "CD55", "CTNNB1", "FBN1", "TGFB1")
for (g in genes) {
  rds <- readRDS(file.path(COLOC_PROG, paste0(g, ".rds")))
  pp_recalc <- recalc_PP(rds$results, p1 = 1e-4, p2 = 1e-4, p12 = 1e-5)
  pp_orig <- c(rds$row$PP.H0, rds$row$PP.H1, rds$row$PP.H2,
               rds$row$PP.H3, rds$row$PP.H4)
  cat(sprintf("\n%s:\n", g))
  cat(sprintf("  Original  PP.H4 = %.6f, PP.H1 = %.6f\n",
              pp_orig[5], pp_orig[2]))
  cat(sprintf("  Recalc    PP.H4 = %.6f, PP.H1 = %.6f\n",
              pp_recalc["PP.H4"], pp_recalc["PP.H1"]))
  cat(sprintf("  Diff PP.H4 = %.2e\n",
              abs(pp_orig[5] - pp_recalc["PP.H4"])))
}

# Now run 3 prior sets
cat("\n\n===== Sensitivity analysis under 3 prior sets =====\n")
prior_sets <- list(
  default      = list(p1 = 1e-4, p2 = 1e-4, p12 = 1e-5),
  conservative = list(p1 = 1e-4, p2 = 1e-4, p12 = 1e-6),
  liberal      = list(p1 = 1e-4, p2 = 1e-4, p12 = 1e-4)
)

results_all <- list()
for (g in genes) {
  rds <- readRDS(file.path(COLOC_PROG, paste0(g, ".rds")))
  for (ps_name in names(prior_sets)) {
    ps <- prior_sets[[ps_name]]
    pp <- recalc_PP(rds$results, p1 = ps$p1, p2 = ps$p2, p12 = ps$p12)
    results_all[[length(results_all) + 1L]] <- data.table(
      gene = g, prior_set = ps_name,
      p1 = ps$p1, p2 = ps$p2, p12 = ps$p12,
      PP.H0 = pp["PP.H0"], PP.H1 = pp["PP.H1"],
      PP.H2 = pp["PP.H2"], PP.H3 = pp["PP.H3"],
      PP.H4 = pp["PP.H4"]
    )
  }
}
sens_dt <- rbindlist(results_all)

cat("\n===== Sensitivity table =====\n")
print(sens_dt[, .(gene, prior_set, p12, PP.H1, PP.H3, PP.H4)])

# Wide format for paper
cat("\n===== Wide format: PP.H4 across priors =====\n")
wide_h4 <- dcast(sens_dt, gene ~ prior_set, value.var = "PP.H4")
print(wide_h4)

cat("\n===== Wide format: PP.H1 across priors =====\n")
wide_h1 <- dcast(sens_dt, gene ~ prior_set, value.var = "PP.H1")
print(wide_h1)

# Save
out_path <- file.path(PATHY_QC, "Suppl_TableS_coloc_sensitivity.csv")
fwrite(sens_dt, out_path)
cat(sprintf("\nWrote: %s\n", out_path))

# Verdict for Tier A
cat("\n===== Tier A verdict =====\n")
for (g in c("RDH5", "CD55")) {
  sub <- sens_dt[gene == g]
  h4_default <- sub[prior_set == "default", PP.H4]
  h4_cons    <- sub[prior_set == "conservative", PP.H4]
  h4_lib     <- sub[prior_set == "liberal", PP.H4]
  cat(sprintf("%s: default PP.H4=%.3f, conservative=%.3f, liberal=%.3f\n",
              g, h4_default, h4_cons, h4_lib))
  if (h4_cons > 0.5) {
    cat(sprintf("  -> ROBUST: PP.H4 > 0.5 even under conservative prior\n"))
  } else {
    cat(sprintf("  -> PRIOR-DEPENDENT: PP.H4 drops below 0.5 with conservative\n"))
  }
}

cat("\n===== Done =====\n")
