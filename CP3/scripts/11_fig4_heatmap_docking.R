###############################################################################
# Figure 4: Triangulation Heatmap + Docking Bar Chart
# Output: Fig4_Triangulation_Docking.png (300 dpi, 7.5 x 8 inches)
###############################################################################

# Ensure necessary packages are installed
if (!require(ggplot2)) install.packages("ggplot2", repos = "http://cran.us.r-project.org")
if (!require(patchwork)) install.packages("patchwork", repos = "http://cran.us.r-project.org")
if (!require(dplyr)) install.packages("dplyr", repos = "http://cran.us.r-project.org")

library(ggplot2)
library(patchwork)
library(dplyr)

# ============================================================
# PANEL A: TRIANGULATION HEATMAP
# ============================================================

# Evidence matrix (1=strong, 0.7=moderate, 0.4=suggestive, 0=none)
tri_data <- data.frame(
    Gene = rep(c("TGFB1", "LATS2", "YAP1", "HIF1A", "EGFR"), each = 5),
    Method = rep(c("Network", "MR", "Literature", "CMap", "Docking"), 5),
    Score = c(
        # TGFB1: intersection deg12(+), MR P=0.003(++), Wu(+), MMP#1(+), -7.5(+)
        0.7, 1.0, 0.7, 0.7, 0.7,
        # LATS2: Ext. Layer(+), MR P=0.04(+), Liu YAP-(+), none(--), -7.6(+)
        0.7, 0.7, 0.7, 0.0, 0.7,
        # YAP1: 24 edges(+), insuff(--), Liu YAP-- (++), Src 3x(+), -7.9(++)
        0.7, 0.0, 1.0, 0.7, 1.0,
        # HIF1A: intersect(+), p=0.154(±), conflicting(+), none(--), none(--)
        0.7, 0.4, 0.7, 0.0, 0.0,
        # EGFR: hub#9(++), insuff(--), none(--), 8x(++), none(--)
        1.0, 0.0, 0.0, 1.0, 0.0
    ),
    Label = c(
        # TGFB1
        "+", "++", "+", "+", "+",
        # LATS2
        "+", "+", "+", "\u2014", "+",
        # YAP1
        "+", "\u2014", "++", "+", "++",
        # HIF1A
        "+", "\u00B1", "+", "\u2014", "\u2014",
        # EGFR
        "++", "\u2014", "\u2014", "++", "\u2014"
    ),
    Convergence = rep(c("5/5", "4/5", "4/5", "3/5", "2/5"), each = 5),
    stringsAsFactors = FALSE
)

# Order genes by convergence score
tri_data$Gene <- factor(tri_data$Gene, levels = c("TGFB1", "LATS2", "YAP1", "HIF1A", "EGFR"))
tri_data$Method <- factor(tri_data$Method, levels = c("Network", "MR", "Literature", "CMap", "Docking"))

# Convergence annotation
conv_labels <- data.frame(
    Gene = factor(c("TGFB1", "LATS2", "YAP1", "HIF1A", "EGFR"),
        levels = c("TGFB1", "LATS2", "YAP1", "HIF1A", "EGFR")
    ),
    label = c("5/5", "4/5", "4/5", "3/5", "2/5"),
    stringsAsFactors = FALSE
)

legend_cap <- "++, strong evidence: MR P<0.05 with replication; experimental validation (Western blot);\n    CMap rank 1 or \u22658 hits; docking score < -7.5 kcal/mol; hub degree \u226517.\n+, supported: MR P<0.05; published expression change in myopic tissue; CMap hit identified;\n    docking score < -7.0 kcal/mol; intersection gene.\n\u00B1, suggestive: MR 0.05<P<0.2 or conflicting published directions.\n\u2014, not tested or insufficient instrumental variables."

panelA <- ggplot(tri_data, aes(x = Method, y = Gene, fill = Score)) +
    geom_tile(color = "white", linewidth = 1.5) +
    geom_text(aes(label = Label), size = 6.5, color = "white", fontface = "bold", lineheight = 0.85) +
    # Override text color for empty cells
    geom_text(
        data = tri_data %>% filter(Score == 0),
        aes(label = Label), size = 6, color = "grey50", fontface = "bold"
    ) +
    # Convergence score on right
    geom_text(
        data = conv_labels, aes(x = 5.7, y = Gene, label = label, fill = NULL),
        size = 4, fontface = "bold", color = "#2C3E50", hjust = 0.5
    ) +
    scale_fill_gradientn(
        colors = c("#ECF0F1", "#F39C12", "#C0392B"), # grey, amber, red
        values = c(0, 0.6, 1),
        limits = c(0, 1),
        name = "Evidence\nstrength"
    ) +
    scale_x_discrete(position = "top", expand = expansion(add = c(0.5, 1.2))) +
    labs(
        title = "A. Five-method triangulation matrix",
        caption = legend_cap,
        x = NULL, y = NULL
    ) +
    annotate("text", x = 5.7, y = 5.6, label = "Score", fontface = "bold", size = 3.5, color = "#2C3E50") +
    coord_cartesian(clip = "off") +
    theme_minimal(base_size = 13, base_family = "sans") +
    theme(
        plot.title = element_text(face = "bold", size = 14, hjust = 0, margin = margin(b = 10)),
        plot.caption = element_text(hjust = 0, size = 9, color = "grey30", lineheight = 1.1, margin = margin(t = 15)),
        axis.text.x.top = element_text(face = "bold", size = 10, color = "#2C3E50"),
        axis.text.y = element_text(face = "bold", size = 11, color = "#2C3E50"),
        panel.grid = element_blank(),
        legend.position = "right",
        legend.key.height = unit(0.8, "cm"),
        legend.key.width = unit(0.4, "cm"),
        legend.title = element_text(size = 9, face = "bold"),
        legend.text = element_text(size = 8),
        plot.margin = margin(15, 30, 15, 15)
    )

# ============================================================
# PANEL B: DOCKING BAR CHART
# ============================================================

dock_data <- data.frame(
    Target = c(
        "CHRM1\n(FitDock)", "CHRM1\n(CB-Dock2)", "YAP-TEAD\n(3KYS)",
        "MOB1-LATS1\n(5BRK)", "TGF\u03B21R\n(3KFD)"
    ),
    Score = c(-9.0, -8.8, -7.9, -7.6, -7.5),
    Type = c("Control", "Control", "Novel", "Novel", "Novel"),
    MR = c("Known", "Known", "Insuff. IV", "P=0.040", "P=0.003"),
    stringsAsFactors = FALSE
)

dock_data$Target <- factor(dock_data$Target, levels = rev(dock_data$Target))

panelB <- ggplot(dock_data, aes(x = Target, y = Score, fill = Type)) +
    geom_col(width = 0.65) +
    geom_hline(yintercept = -7.0, linetype = "dashed", color = "#E74C3C", linewidth = 0.6) +
    # Shift Drug-like text and ensure it isn't clipped
    annotate("text",
        x = 5.4, y = -7.0, label = "Drug-like threshold (-7.0)",
        size = 3.2, color = "#E74C3C", hjust = 0.5, vjust = -0.5, fontface = "italic"
    ) +
    # MR annotation fully moved to the POSITIVE side (outside the bar)
    geom_text(aes(label = MR, y = 0.2), size = 3.5, color = "#7F8C8D", fontface = "italic", hjust = 0) +
    # Score labels tucked cleanly inside the left end of the bar
    geom_text(aes(label = Score, y = Score + 0.15), size = 3.5, color = "white", fontface = "bold", hjust = 0) +
    scale_fill_manual(
        values = c("Control" = "#95A5A6", "Novel" = "#E67E22"),
        name = "Target type"
    ) +
    # Extend limits to positive 2.5 to accommodate MR labels and completely prevent truncation
    scale_y_continuous(
        limits = c(-10, 2.5), breaks = seq(-10, 0, 2),
        labels = function(x) paste0(x, "")
    ) +
    labs(
        title = "B. Atropine molecular docking (CB-Dock2 / FitDock)",
        x = NULL,
        y = "Vina score (kcal/mol)"
    ) +
    # This disables clipping outside the panel bounds!
    coord_flip(clip = "off") +
    theme_minimal(base_size = 13, base_family = "sans") +
    theme(
        plot.title = element_text(face = "bold", size = 14, hjust = 0, margin = margin(t = 15, b = 10)),
        axis.text.y = element_text(face = "bold", size = 10, color = "#2C3E50"),
        axis.text.x = element_text(size = 10),
        panel.grid.major.y = element_blank(),
        panel.grid.minor = element_blank(),
        legend.position = "right",
        legend.title = element_text(size = 9, face = "bold"),
        legend.text = element_text(size = 8),
        plot.margin = margin(10, 10, 10, 10)
    )

# ============================================================
# COMBINE AND SAVE
# ============================================================

fig4 <- panelA / panelB + plot_layout(heights = c(1.3, 0.7))

out_png <- "c:/Projectbulid/CP3/figures/Fig4_Triangulation_Docking.png"
out_tiff <- "c:/Projectbulid/CP3/figures/Fig4_Triangulation_Docking.tiff"

ggsave(out_png, fig4, width = 7.5, height = 9, dpi = 300, bg = "white")
ggsave(out_tiff, fig4, width = 7.5, height = 9, dpi = 300, bg = "white", compression = "lzw")

cat("✅ Figure 4 saved successfully!\n")
cat("  PNG: ", out_png, "\n")
cat("  TIFF: ", out_tiff, "\n")
