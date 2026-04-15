# R script to generate publication-ready figures for Exp Eye Res submission
# Park Jungyul - M-LIGHT Project

if (!requireNamespace("ggplot2", quietly = TRUE)) install.packages("ggplot2", repos="https://cran.r-project.org")
if (!requireNamespace("dplyr", quietly = TRUE)) install.packages("dplyr", repos="https://cran.r-project.org")
if (!requireNamespace("tidyr", quietly = TRUE)) install.packages("tidyr", repos="https://cran.r-project.org")
if (!requireNamespace("ggsci", quietly = TRUE)) install.packages("ggsci", repos="https://cran.r-project.org")

library(ggplot2)
library(dplyr)
library(tidyr)
library(ggsci)

out_dir <- "c:/Projectbulid/CP5_figures"
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

# ==============================================================================
# Figure 2A: MR Forest Plot
# ==============================================================================
mr_data <- data.frame(
  Gene = c("TGFB1", "LATS2", "HIF1A", "COMT", "ADRA2A", "CHRM3", "LOX"),
  Pathway = c("TGFβ", "Hippo", "Hypoxia", "Dopamine", "Adrenergic", "Muscarinic", "ECM"),
  Beta = c(-0.027, 0.018, -0.004, -0.008, -0.001, 0.004, -0.002),
  SE = c(0.009, 0.009, 0.002, 0.006, 0.005, 0.005, 0.006),
  Pval = c(0.003, 0.04, 0.068, 0.19, 0.80, 0.40, 0.74)
)

# Calculate 95% CI
mr_data$LCI <- mr_data$Beta - 1.96 * mr_data$SE
mr_data$UCI <- mr_data$Beta + 1.96 * mr_data$SE

# Sort by Beta
mr_data <- mr_data[order(mr_data$Beta), ]
mr_data$Gene <- factor(mr_data$Gene, levels = mr_data$Gene)
mr_data$Significance <- ifelse(mr_data$Pval < 0.05, "Significant", 
                               ifelse(mr_data$Pval < 0.1, "Suggestive", "Non-significant"))

p2_forest <- ggplot(mr_data, aes(x = Beta, y = Gene, color = Significance)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "gray50", size=1) +
  geom_errorbarh(aes(xmin = LCI, xmax = UCI), height = 0.2, size = 1) +
  geom_point(size = 4) +
  scale_color_manual(values = c("Significant" = "#D53E4F", "Suggestive" = "#FDAE61", "Non-significant" = "#999999")) +
  theme_bw(base_size = 14) +
  labs(title = "Mendelian Randomization: Causal Effects on Myopia",
       x = "Effect Size (Beta ± 95% CI)", y = "") +
  theme(panel.grid.minor = element_blank(),
        plot.title = element_text(face = "bold", hjust=0.5))

ggsave(file.path(out_dir, "Figure2A_MR_Forest.pdf"), p2_forest, width = 8, height = 5)
ggsave(file.path(out_dir, "Figure2A_MR_Forest.png"), p2_forest, width = 8, height = 5, dpi=300)


# ==============================================================================
# Figure 3: Triangulation Heatmap
# ==============================================================================
# Categories: 0=None/Insufficient, 1=Weak/Suggestive, 2=Moderate, 3=Strong
heat_data <- data.frame(
  Gene = c("TGFB1", "LATS2", "YAP1", "HIF1A", "COL1A1"),
  Network = c(3, 3, 3, 3, 2),        # 3=Hub/Intersection, 2=Downstream
  MR = c(3, 3, 0, 1, 0),             # 3=Causal, 1=Suggestive, 0=Insuff
  Literature = c(3, 3, 3, 3, 3),     # 3=Confirmed
  CMap = c(2, 0, 2, 0, 0),           # 2=Inhibitor matches
  Docking = c(3, 3, 3, 0, 0)         # 3=Strong binding
)

heat_long <- heat_data %>%
  pivot_longer(cols = -Gene, names_to = "Method", values_to = "Score")

heat_long$Gene <- factor(heat_long$Gene, levels = rev(heat_data$Gene))
heat_long$Method <- factor(heat_long$Method, levels = names(heat_data)[-1])

p3_heat <- ggplot(heat_long, aes(x = Method, y = Gene, fill = factor(Score))) +
  geom_tile(color = "white", size=1) +
  scale_fill_manual(values = c("0" = "#f0f0f0", "1" = "#ffeda0", "2" = "#feb24c", "3" = "#f03b20"),
                    labels = c("None/Null", "Suggestive/Indirect", "Moderate", "Strong/Direct"),
                    name = "Evidence Strength") +
  theme_minimal(base_size = 14) +
  labs(title = "Triangulation Evidence Convergence", x = "", y = "") +
  theme(panel.grid.major = element_blank(),
        plot.title = element_text(face = "bold", hjust=0.5),
        axis.text.x = element_text(angle = 45, hjust = 1))

ggsave(file.path(out_dir, "Figure3_Triangulation_Heatmap.pdf"), p3_heat, width = 7, height = 5)
ggsave(file.path(out_dir, "Figure3_Triangulation_Heatmap.png"), p3_heat, width = 7, height = 5, dpi=300)


# ==============================================================================
# Figure 4: Molecular Docking Bar Plot
# ==============================================================================
dock_data <- data.frame(
  Target = c("CHRM1 (Control)", "YAP-TEAD", "TGFβ1R", "LATS2"),
  Score = c(-8.8, -7.9, -7.5, -7.2)
)

dock_data$Target <- factor(dock_data$Target, levels = dock_data$Target)

p4_dock <- ggplot(dock_data, aes(x = Target, y = Score, fill = Target)) +
  geom_bar(stat = "identity", width = 0.6) +
  scale_fill_npg() +
  theme_bw(base_size = 14) +
  scale_y_continuous(limits = c(-10, 0), breaks=seq(-10, 0, by=1)) +
  labs(title = "Molecular Docking Affinity (CB-Dock2)",
       x = "Protein Target", y = "Vina Score (kcal/mol)",
       caption = "More negative score = stronger binding") +
  theme(legend.position = "none",
        plot.title = element_text(face = "bold", hjust=0.5),
        axis.text.x = element_text(face = "bold")) +
  geom_text(aes(label = Score), vjust = -0.5, size = 5, fontface="bold") # vjust=-0.5 works because values are negative but we actually want them below if we plot negative

ggsave(file.path(out_dir, "Figure4_Docking_Bar.pdf"), p4_dock, width = 7, height = 5)
ggsave(file.path(out_dir, "Figure4_Docking_Bar.png"), p4_dock, width = 7, height = 5, dpi=300)

cat("Successfully generated high-quality figures in CP5_figures/\n")
