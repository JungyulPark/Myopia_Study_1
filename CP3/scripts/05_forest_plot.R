# CP3 Forest Plot: Consolidated MR Results (Main Figure 3)

Sys.setenv(OPENGWAS_JWT = "eyJhbGciOiJSUzI1NiIsImtpZCI6ImFwaS1qd3QiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJhcGkub3Blbmd3YXMuaW8iLCJhdWQiOiJhcGkub3Blbmd3YXMuaW8iLCJzdWIiOiJvcGhqeXBAbmF2ZXIuY29tIiwiaWF0IjoxNzc1OTc4NDcwLCJleHAiOjE3NzcxODgwNzB9.TT5w4_5V7kXgMEMwOabASlF8DEoJBay87xqTBv50QASMarmorUm9nX2BbXVkhvGuoXSKC6fJfG_8w_adXc8h1Nq4ECS9YobEst1ej7Qn9LU7oJ7OFx3NepNYKUg3keCDJVZK8_xFrlE9_aToYEe_f5bbhH2HjGOoPcLiA2_xh6UGUNIqbPELbyODpUl35MVwcuLeiNM6fMWssPXfQ3_06ibsqA6T3_uZIOdai7Eqkmo8WhOdp-HIE9M96RXHE9NCJdb7a4G0HtUsGTJYJWMrnSWJ9mKBU77CSCAG2GBnbyjlUzPeylXxRY7ZzZWzwKY2qD0GHFC3waZZ9xs0lAUFWw")

library(ggplot2)
library(dplyr)

# Consolidate ALL MR results across modules
mr_a <- read.csv("c:/Projectbulid/CP3/results/MR_A_COMT_strict.csv")
mr_a$Gene <- "COMT"; mr_a$Module <- "MR-A: Dopamine"

mr_b <- read.csv("c:/Projectbulid/CP3/results/MR_B_results.csv")
mr_b$Module <- "MR-B: Hippo-YAP"

mr_cde <- read.csv("c:/Projectbulid/CP3/results/MR_CDE_consolidated.csv")
mr_cde$Module <- case_when(
    mr_cde$Module == "MR_C" ~ "MR-C: Muscarinic",
    mr_cde$Module == "MR_D" ~ "MR-D: Adrenergic",
    mr_cde$Module == "MR_E" ~ "MR-E: ECM/HIF/TGFb",
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
        title = "Mendelian Randomization: Gene Expression → Myopia Risk",
        subtitle = "Two-sample MR using eQTLGen blood cis-eQTLs (p < 5×10⁻⁶) and UK Biobank myopia (N=460,536)",
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
        aes(label = paste0("p=", formatC(pval, format="f", digits=4))),
        hjust = -0.3, vjust = -0.8, size = 3.5, color = "#E74C3C", fontface = "bold"
    )

ggsave(p, filename = "c:/Projectbulid/CP3/figures/Fig3_MR_forest_plot.png",
       width = 10, height = 7, dpi = 300)
cat("\n✅ Forest plot saved: CP3/figures/Fig3_MR_forest_plot.png\n")

# Also save as PDF for vector
ggsave(p, filename = "c:/Projectbulid/CP3/figures/Fig3_MR_forest_plot.pdf",
       width = 10, height = 7)
cat("✅ PDF saved: CP3/figures/Fig3_MR_forest_plot.pdf\n")
