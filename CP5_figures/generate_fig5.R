###############################################################################
# Fig 5: MR Forest Plot + CREAM Replication
# For IOVS manuscript submission
# Park Jungyul, MD, PhD | M-LIGHT | 2026-04-13
###############################################################################

if (!requireNamespace("patchwork", quietly = TRUE)) install.packages("patchwork", repos="https://cran.r-project.org")
library(ggplot2)
library(patchwork)
library(dplyr)

outdir <- "c:/Projectbulid/CP5_figures/"
dir.create(outdir, recursive = TRUE, showWarnings = FALSE)

# ============================================================================
# Panel A: Primary MR Forest Plot (all tested genes)
# ============================================================================

mr_data <- data.frame(
  gene = c("TGFB1", "LATS2", "HIF1A", "COMT", "ADRA2A", "CHRM3", "LOX"),
  pathway = c("TGFβ", "Hippo", "Hypoxia", "Dopamine", "Adrenergic", "Muscarinic", "ECM"),
  beta = c(-0.027, 0.018, -0.004, -0.008, -0.001, 0.004, -0.002),
  se = c(0.009, 0.009, 0.002, 0.006, 0.005, 0.005, 0.006),
  pval = c(0.003, 0.04, 0.068, 0.19, 0.80, 0.40, 0.74),
  n_iv = c(1, 1, 3, 5, 2, 2, 2),
  method = c("Wald", "Wald", "WM", "IVW", "IVW", "IVW", "IVW"),
  stringsAsFactors = FALSE
)

mr_data$ci_lower <- mr_data$beta - 1.96 * mr_data$se
mr_data$ci_upper <- mr_data$beta + 1.96 * mr_data$se
mr_data$significant <- ifelse(mr_data$pval < 0.05, "Significant", 
                               ifelse(mr_data$pval < 0.1, "Suggestive", "Not significant"))
mr_data$label <- paste0(mr_data$gene, " (", mr_data$pathway, ")")

mr_data <- mr_data[order(mr_data$pval), ]
mr_data$label <- factor(mr_data$label, levels = rev(mr_data$label))

fig5a <- ggplot(mr_data, aes(x = beta, y = label)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "gray50", linewidth = 0.4) +
  geom_errorbarh(aes(xmin = ci_lower, xmax = ci_upper), 
                 height = 0.25, linewidth = 0.5, color = "gray40") +
  geom_point(aes(color = significant, shape = significant), size = 3) +
  scale_color_manual(values = c("Significant" = "#185FA5",
                                 "Suggestive" = "#BA7517",
                                 "Not significant" = "#888780"),
                     name = "") +
  scale_shape_manual(values = c("Significant" = 16,
                                 "Suggestive" = 17,
                                 "Not significant" = 1),
                     name = "") +
  labs(x = expression(beta ~ "(effect on myopia risk)"), y = NULL, title = "A") +
  annotate("text", x = max(mr_data$ci_upper) + 0.005, y = 7, 
           label = "P", fontface = "bold", size = 3, hjust = 0) +
  annotate("text", x = max(mr_data$ci_upper) + 0.005, 
           y = seq(6, 0, length.out = 7) + 0.5,
           label = formatC(mr_data$pval[order(mr_data$pval)], format = "f", digits = 3),
           size = 2.8, hjust = 0) +
  theme_minimal(base_size = 11) +
  theme(legend.position = "bottom", legend.text = element_text(size = 9),
        plot.title = element_text(face = "bold", size = 14), panel.grid.minor = element_blank(),
        panel.grid.major.y = element_blank(), axis.text.y = element_text(size = 10)) +
  coord_cartesian(clip = "off")

# ============================================================================
# Panel B: TGFB1 Replication Across 3 Outcomes
# ============================================================================

repl_data <- data.frame(
  outcome = c("Binary myopia\n(ukb-b-6353, N=460K)",
              "Spherical power R\n(ukb-b-19994)",
              "Spherical power L\n(ukb-b-7500)"),
  beta = c(-0.027, 0.253, 0.264),
  se = c(0.009, 0.072, 0.070),
  pval = c(0.003, 0.0004, 0.0002),
  type = c("Binary (protective)", "Continuous (positive)", "Continuous (positive)"),
  stringsAsFactors = FALSE
)

repl_data$ci_lower <- repl_data$beta - 1.96 * repl_data$se
repl_data$ci_upper <- repl_data$beta + 1.96 * repl_data$se
repl_data$outcome <- factor(repl_data$outcome, levels = rev(repl_data$outcome))
repl_data$p_label <- paste0("P = ", formatC(repl_data$pval, format = "g", digits = 2))

fig5b <- ggplot(repl_data, aes(x = beta, y = outcome)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "gray50", linewidth = 0.4) +
  geom_errorbarh(aes(xmin = ci_lower, xmax = ci_upper), 
                 height = 0.2, linewidth = 0.6, color = "#0F6E56") +
  geom_point(size = 4, color = "#0F6E56", shape = 18) +
  geom_text(aes(label = p_label), hjust = -0.3, vjust = -0.8, size = 3.2, color = "#085041") +
  labs(x = expression(beta), y = NULL, title = "B", subtitle = "TGFB1 replication across outcomes") +
  theme_minimal(base_size = 11) +
  theme(plot.title = element_text(face = "bold", size = 14), plot.subtitle = element_text(size = 10, color = "gray40"),
        panel.grid.minor = element_blank(), panel.grid.major.y = element_blank(), axis.text.y = element_text(size = 9)) +
  coord_cartesian(clip = "off")

# ============================================================================
# Panel C: Sensitivity Analyses Summary
# ============================================================================

sens_data <- data.frame(
  test = c("Steiger direction\n(TGFB1)", 
           "Steiger direction\n(LATS2)",
           "Reverse MR\n(TGFB1)",
           "Reverse MR\n(LATS2)",
           "Coloc PP.H4\n(TGFB1)"),
  value = c(1.65e-5, 1.29e-6, 0.90, 0.94, 0.018),
  result = c("TRUE", "TRUE", "Null", "Null", "Weak"),
  color_group = c("Pass", "Pass", "Pass", "Pass", "Limitation"),
  stringsAsFactors = FALSE
)

sens_data$test <- factor(sens_data$test, levels = rev(sens_data$test))
sens_data$value_label <- ifelse(sens_data$value < 0.001,
                                 formatC(sens_data$value, format = "e", digits = 1),
                                 formatC(sens_data$value, format = "f", digits = 2))

fig5c <- ggplot(sens_data, aes(x = test, y = 1, fill = color_group)) +
  geom_tile(width = 0.8, height = 0.6, color = "white", linewidth = 0.5) +
  geom_text(aes(label = paste0(result, "\n(P=", value_label, ")")), size = 2.8, lineheight = 0.9) +
  scale_fill_manual(values = c("Pass" = "#E1F5EE", "Limitation" = "#FAEEDA"), guide = "none") +
  labs(title = "C", subtitle = "Sensitivity analyses") +
  theme_void(base_size = 11) +
  theme(plot.title = element_text(face = "bold", size = 14), plot.subtitle = element_text(size = 10, color = "gray40"),
        axis.text.x = element_text(size = 8, angle = 0, hjust = 0.5)) +
  coord_flip()

# ============================================================================
# COMBINE PANELS
# ============================================================================

combined <- fig5a + (fig5b / fig5c + plot_layout(heights = c(2, 1.5))) + plot_layout(widths = c(1.2, 1))

ggsave(file.path(outdir, "Fig5_MR_forest_replication.png"), combined, width = 12, height = 7, dpi = 300, bg = "white")
ggsave(file.path(outdir, "Fig5_MR_forest_replication.tiff"), combined, width = 12, height = 7, dpi = 300, bg = "white", compression = "lzw")
cat("Fig 5 generated.\n")
