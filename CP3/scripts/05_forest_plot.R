# CP3 Forest Plot: Consolidated MR Results (Main Figure 3)

Sys.setenv(OPENGWAS_JWT = "eyJhbGciOiJSUzI1NiIsImtpZCI6ImFwaS1qd3QiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJhcGkub3Blbmd3YXMuaW8iLCJhdWQiOiJhcGkub3Blbmd3YXMuaW8iLCJzdWIiOiJvcGhqeXBAbmF2ZXIuY29tIiwiaWF0IjoxNzc1OTc4NDcwLCJleHAiOjE3NzcxODgwNzB9.TT5w4_5V7kXgMEMwOabASlF8DEoJBay87xqTBv50QASMarmorUm9nX2BbXVkhvGuoXSKC6fJfG_8w_adXc8h1Nq4ECS9YobEst1ej7Qn9LU7oJ7OFx3NepNYKUg3keCDJVZK8_xFrlE9_aToYEe_f5bbhH2HjGOoPcLiA2_xh6UGUNIqbPELbyODpUl35MVwcuLeiNM6fMWssPXfQ3_06ibsqA6T3_uZIOdai7Eqkmo8WhOdp-HIE9M96RXHE9NCJdb7a4G0HtUsGTJYJWMrnSWJ9mKBU77CSCAG2GBnbyjlUzPeylXxRY7ZzZWzwKY2qD0GHFC3waZZ9xs0lAUFWw")

library(ggplot2)
library(dplyr)

# Consolidate ALL MR results across modules
mr_a <- read.csv("c:/Projectbulid/CP3/results/MR_A_COMT_strict.csv")
mr_a$Gene <- "COMT"
mr_a$Module <- "Dopamine pathway"

mr_b <- read.csv("c:/Projectbulid/CP3/results/MR_B_results.csv")
mr_b$Module <- "Hippo-YAP pathway"

mr_cde <- read.csv("c:/Projectbulid/CP3/results/MR_CDE_consolidated.csv")
mr_cde$Module <- case_when(
    mr_cde$Module == "MR_C" ~ "Muscarinic pathway",
    mr_cde$Module == "MR_D" ~ "Adrenergic pathway",
    mr_cde$Module == "MR_E" ~ "ECM / TGF-beta pathway",
    TRUE ~ mr_cde$Module
)

# Select IVW or Wald ratio per gene (primary method)
pick_primary <- function(df) {
    df %>%
        filter(method %in% c("Inverse variance weighted", "Wald ratio")) %>%
        group_by(Gene) %>%
        slice(1) %>%
        ungroup()
}

all_results <- bind_rows(
    pick_primary(mr_a),
    pick_primary(mr_b),
    pick_primary(mr_cde)
)

# Calculate 95% CI
all_results <- all_results %>%
    filter(Gene != "VEGFA") %>%
    mutate(
        ci_lo = b - 1.96 * se,
        ci_hi = b + 1.96 * se,
        sig = ifelse(pval < 0.05, "Significant", "Non-significant"),
        label = paste0(Gene, " (", method, ", n=", nsnp, ")")
    )

# Order: by module, then by p-value
all_results <- all_results %>%
    arrange(Module, pval) %>%
    mutate(label = factor(label, levels = rev(label)))

cat("Forest plot data:\n")
print(all_results[, c("Gene", "Module", "method", "nsnp", "b", "se", "pval", "sig")])

# Forest plot
p <- ggplot(all_results, aes(x = b, y = label, color = sig)) +
    geom_vline(xintercept = 0, linetype = "dashed", color = "grey50", linewidth = 0.5) +
    geom_errorbarh(aes(xmin = ci_lo, xmax = ci_hi), height = 0.25, linewidth = 0.7) +
    geom_point(size = 3) +
    scale_color_manual(
        values = c("Significant" = "#E74C3C", "Non-significant" = "#7F8C8D"),
        name = ""
    ) +
    facet_grid(Module ~ ., scales = "free_y", space = "free_y", switch = "y") +
    labs(
        title = "A. Mendelian Randomization:\nGene Expression → Myopia Risk",
        subtitle = "Two-sample MR using eQTLGen blood cis-eQTLs (p < 5×10⁻⁶)\nand UK Biobank myopia (N=460,536)",
        x = "Beta (effect on myopia risk)",
        y = ""
    ) +
    theme_minimal(base_size = 12) +
    theme(
        plot.title = element_text(face = "bold", size = 14),
        plot.subtitle = element_text(size = 10, color = "grey40"),
        strip.text.y.left = element_text(angle = 0, face = "bold", size = 9),
        strip.placement = "outside",
        panel.grid.minor = element_blank(),
        panel.grid.major.y = element_blank(),
        legend.position = "bottom",
        axis.text.y = element_text(size = 10)
    ) +
    # Annotate significant p-values
    geom_text(
        data = all_results %>% filter(sig == "Significant"),
        aes(label = paste0("p=", formatC(pval, format = "f", digits = 4))),
        hjust = -0.3, vjust = -0.8, size = 3.5, color = "#E74C3C", fontface = "bold"
    )

ggsave(p,
    filename = "c:/Projectbulid/CP3/figures/Fig3_MR_forest_plot.png",
    width = 10, height = 7, dpi = 300
)
cat("\n✅ Forest plot saved: CP3/figures/Fig3_MR_forest_plot.png\n")

# PANEL B: CREAM Replication for TGFB1
tgfb1_rep <- data.frame(
    Outcome = c("Binary myopia", "Spherical R", "Spherical L"),
    b = c(-0.027, 0.253, 0.264),
    pval = c(0.003, 0.0004, 0.0002)
)
# Back-calculate SE for 95% CI (Z = b/se)
tgfb1_rep$se <- c(0.009, 0.253 / 3.54, 0.264 / 3.719)
tgfb1_rep <- tgfb1_rep %>%
    mutate(
        ci_lo = b - 1.96 * se,
        ci_hi = b + 1.96 * se
    )
tgfb1_rep$Outcome <- factor(tgfb1_rep$Outcome, levels = c("Spherical L", "Spherical R", "Binary myopia"))

p_b <- ggplot(tgfb1_rep, aes(x = b, y = Outcome)) +
    geom_vline(xintercept = 0, linetype = "dashed", color = "grey50", linewidth = 0.5) +
    geom_errorbarh(aes(xmin = ci_lo, xmax = ci_hi), height = 0.2, linewidth = 0.7, color = "#E74C3C") +
    geom_point(size = 3, color = "#E74C3C") +
    labs(
        title = "B. TGFB1 Replication across Myopia Clinical Outcomes",
        x = "Beta (Effect size on clinical traits)",
        y = ""
    ) +
    theme_minimal(base_size = 12) +
    theme(
        plot.title = element_text(face = "bold", size = 14),
        panel.grid.minor = element_blank(),
        panel.grid.major.y = element_blank(),
        axis.text.y = element_text(size = 10, face = "bold")
    ) +
    geom_text(
        aes(label = paste0("p=", pval)),
        vjust = -0.8, size = 3.5, color = "#E74C3C", fontface = "bold"
    )

if (!require("patchwork")) install.packages("patchwork", repos = "http://cran.us.r-project.org")
library(patchwork)

# Combine A and B
p_combined <- p / p_b + plot_layout(heights = c(3, 1.2))

ggsave(p_combined,
    filename = "c:/Projectbulid/CP3/figures/Fig3_MR_forest_plot_combined.png",
    width = 10, height = 9, dpi = 300
)
cat("\n✅ Forest plot combined saved: CP3/figures/Fig3_MR_forest_plot_combined.png\n")

ggsave(p_combined,
    filename = "c:/Projectbulid/CP3/figures/Fig3_MR_forest_plot_combined.pdf",
    width = 10, height = 9
)
cat("✅ PDF combined saved: CP3/figures/Fig3_MR_forest_plot_combined.pdf\n")

# Also save as PDF for vector
ggsave(p,
    filename = "c:/Projectbulid/CP3/figures/Fig3_MR_forest_plot.pdf",
    width = 10, height = 7
)
cat("✅ PDF saved: CP3/figures/Fig3_MR_forest_plot.pdf\n")
