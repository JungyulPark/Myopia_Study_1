# ============================================================================
# M-LIGHT Figure 3 v1 — Colocalization 3-Panel Integrated Figure
# Created: May 14, 2026
#
# Layout: 3 panels (Wang Y IOVS style, single integrated figure)
#
#   Panel A (top-left, ~60% width): 5 anchors × 5 hypotheses heatmap
#     Rows: RDH5, CD55, TGFB1, CTNNB1, FBN1 (Tier A/A/B/B/B)
#     Cols: PP.H0, PP.H1, PP.H2, PP.H3, PP.H4
#     At DEFAULT prior (p12 = 1e-5)
#     Color: white → dark blue (0 → 1)
#     Annotation: PP value in each cell (3 decimal places)
#     => Tier A: H4 dominant (shared causal variant)
#     => Tier B: H1 or H3 dominant (distinct variants)
#
#   Panel B (top-right, ~30% width): 5 anchors × 3 priors PP.H4 sensitivity
#     Rows: same 5 anchors
#     Cols: default (1e-5) / conservative (1e-6) / liberal (1e-4)
#     Color: white → orange (sensitivity emphasis)
#     Annotation: PP.H4 value
#     => RDH5 robust, CD55 prior-dependent disclosure
#
#   Panel C (bottom, full width): per-anchor interpretation textbox
#     1 row per anchor with classification + key statistic
#
# DATA SOURCE:
#   pathy/Stage1_QC/Suppl_TableS_coloc_sensitivity.csv
#   Columns: gene, prior_set, p1, p2, p12, PP.H0, PP.H1, PP.H2, PP.H3, PP.H4
#   15 rows = 5 anchors × 3 prior_set
#
# OUTPUT:
#   pathy/Stage2_Assets/Figure3_coloc_v1.{svg,png,pdf}
#   pathy/Stage2_Assets/Figure3_coloc_v1_audit.csv
# ============================================================================

for (p in c("data.table", "svglite")) {
  if (!requireNamespace(p, quietly = TRUE)) install.packages(p)
}
library(data.table)
library(grid)

# --- Paths -------------------------------------------------------------------
ROOT     <- "C:/Projectbulid/Myopia"
ASSETS   <- file.path(ROOT, "pathy/Stage2_Assets")
QC_DIR   <- file.path(ROOT, "pathy/Stage1_QC")
OUT_BASE <- file.path(ASSETS, "Figure3_coloc_v3")

COLOC_PATH <- file.path(QC_DIR, "Suppl_TableS_coloc_sensitivity.csv")
stopifnot("Coloc sensitivity csv missing" = file.exists(COLOC_PATH))

# --- Anchor order + Tier ----------------------------------------------------
ANCHORS  <- c("RDH5", "CD55", "TGFB1", "CTNNB1", "FBN1")
TIER     <- c(RDH5 = "A", CD55 = "A", TGFB1 = "B", CTNNB1 = "B", FBN1 = "B")
PRIORS   <- c("default", "conservative", "liberal")
HYPOTHS  <- c("PP.H0", "PP.H1", "PP.H2", "PP.H3", "PP.H4")

# --- Colors ------------------------------------------------------------------
COLOR_TEXT       <- "#000000"
COLOR_AXIS       <- "#000000"
COLOR_TIER_A     <- "#C0392B"   # red — consistent with Figure 2
COLOR_TIER_B     <- "#34495E"   # dark blue — consistent with Figure 2
COLOR_FLAG_ORG   <- "#E67E22"   # orange — for CD55 conservative cell border
COLOR_SHADING    <- "#F2F2F2"

# Heatmap color ramps
# Panel A: white -> dark blue (PP magnitude)
heat_blue <- function(v) {
  v <- max(min(v, 1), 0)
  # white(255,255,255) -> dark blue(44,92,142)
  r <- round(255 + v * (44 - 255))
  g <- round(255 + v * (92 - 255))
  b <- round(255 + v * (142 - 255))
  rgb(r, g, b, maxColorValue = 255)
}
# Panel B: white -> orange (sensitivity emphasis)
heat_orange <- function(v) {
  v <- max(min(v, 1), 0)
  # white -> dark orange (216, 124, 58)
  r <- round(255 + v * (216 - 255))
  g <- round(255 + v * (124 - 255))
  b <- round(255 + v * (58  - 255))
  rgb(r, g, b, maxColorValue = 255)
}

# Choose text color (white on dark cells, black on light)
text_on_cell <- function(v) {
  if (v > 0.55) "#FFFFFF" else "#000000"
}

# ============================================================================
# Read data
# ============================================================================
cat("\n===== Reading coloc sensitivity csv =====\n")
coloc <- fread(COLOC_PATH)
cat("Rows:", nrow(coloc), "Cols:", ncol(coloc), "\n")
cat("Columns:", paste(colnames(coloc), collapse = ", "), "\n")
print(coloc)

stopifnot(
  "Missing anchors"   = all(ANCHORS %in% coloc$gene),
  "Missing prior_set" = all(PRIORS  %in% coloc$prior_set),
  "PP.H4 missing"     = "PP.H4" %in% colnames(coloc)
)

# Panel A data: 5 anchors × 5 hypotheses @ default prior
panel_A_dt <- coloc[prior_set == "default" & gene %in% ANCHORS,
                    .(gene, PP.H0, PP.H1, PP.H2, PP.H3, PP.H4)]
panel_A_dt[, gene := factor(gene, levels = ANCHORS)]
setorder(panel_A_dt, gene)
cat("\nPanel A (5 × 5 H0-H4 at default prior):\n")
print(panel_A_dt)

# Panel B data: 5 anchors × 3 priors PP.H4
panel_B_dt <- dcast(coloc[gene %in% ANCHORS, .(gene, prior_set, PP.H4)],
                    gene ~ prior_set, value.var = "PP.H4")
panel_B_dt[, gene := factor(gene, levels = ANCHORS)]
setorder(panel_B_dt, gene)
setcolorder(panel_B_dt, c("gene", "default", "conservative", "liberal"))
cat("\nPanel B (5 × 3 priors PP.H4):\n")
print(panel_B_dt)

# Panel C data: per-anchor interpretation
# Determine each anchor's dominant hypothesis at default prior
dom_hyp <- function(row) {
  vals <- c(row$PP.H0, row$PP.H1, row$PP.H2, row$PP.H3, row$PP.H4)
  HYPOTHS[which.max(vals)]
}
classify_anchor <- function(g) {
  pa_row <- panel_A_dt[gene == g]
  pb_row <- panel_B_dt[gene == g]
  dom    <- dom_hyp(pa_row)
  tier_g <- TIER[g]
  pa_dom_val <- max(pa_row$PP.H0, pa_row$PP.H1, pa_row$PP.H2, pa_row$PP.H3, pa_row$PP.H4)

  if (tier_g == "A") {
    # Tier A: check if conservative PP.H4 also > 0.75
    if (pb_row$conservative > 0.75) {
      return(list(
        classification = "Robust Tier A",
        key_result     = sprintf("PP.H4 = %.3f / %.3f / %.3f",
                                 pb_row$default, pb_row$conservative, pb_row$liberal),
        interpretation = "Shared-variant support across all three priors"
      ))
    } else {
      return(list(
        classification = "Prior-sensitive Tier A",
        key_result     = sprintf("PP.H4 = %.3f / %.3f / %.3f",
                                 pb_row$default, pb_row$conservative, pb_row$liberal),
        interpretation = "Default/liberal support; conservative attenuated"
      ))
    }
  } else {
    # Tier B
    interp <- if (dom == "PP.H1") "Exposure-only signal / distinct variants" else
              if (dom == "PP.H3") "Both traits associated, distinct variants"  else
              if (dom == "PP.H2") "Outcome-only signal / distinct variants"    else
              "Non-colocalized"
    return(list(
      classification = "Tier B",
      key_result     = sprintf("%s = %.3f (PP.H4 only %.3f)", dom, pa_dom_val, pb_row$default),
      interpretation = interp
    ))
  }
}

panel_C_list <- lapply(ANCHORS, function(g) {
  ci <- classify_anchor(g)
  data.table(gene = g, tier = TIER[g],
             classification = ci$classification,
             key_result     = ci$key_result,
             interpretation = ci$interpretation)
})
panel_C_dt <- rbindlist(panel_C_list)
cat("\nPanel C (4-column interpretation table):\n")
print(panel_C_dt)

# Save audit
audit_path <- paste0(OUT_BASE, "_audit.csv")
audit_dt <- coloc[gene %in% ANCHORS][, .(gene, prior_set, p12,
                                         PP.H0, PP.H1, PP.H2, PP.H3, PP.H4,
                                         tier = TIER[gene])]
fwrite(audit_dt, audit_path)
cat("\nAudit saved:", audit_path, "\n")

# ============================================================================
# Plotting
# ============================================================================

# Figure dimensions
PLOT_W_INCH <- 13
PLOT_H_INCH <- 10

# Helper: draw a heatmap cell
draw_cell <- function(x_center, y_center, cell_w, cell_h, value,
                      color_fn, border_color = NA, border_lwd = 0.5,
                      label_fontsize = 10) {
  fill_col <- color_fn(value)
  grid.rect(x = x_center, y = y_center, width = cell_w, height = cell_h,
            gp = gpar(fill = fill_col,
                      col = if (is.na(border_color)) "#CCCCCC" else border_color,
                      lwd = if (is.na(border_color)) 0.5 else border_lwd))
  txt_col <- text_on_cell(value)
  # Format text
  lbl <- if (value < 0.001) sprintf("%.0e", value) else sprintf("%.3f", value)
  grid.text(lbl, x = x_center, y = y_center,
            gp = gpar(fontsize = label_fontsize, col = txt_col))
}

render_figure3 <- function() {
  grid.newpage()
  pushViewport(viewport(width = 0.97, height = 0.97))

  # ====== Title block ======
  grid.text("Figure 3. Bayesian colocalization hierarchy for prioritized myopia genetic anchors",
            x = 0.01, y = 0.972, just = "left",
            gp = gpar(fontsize = 15, fontface = "bold"))
  grid.text("Panel A: posterior probabilities at default prior reveal whether evidence concentrates in PP.H4 (shared variant) versus PP.H1 / PP.H3 (distinct variants). Panel B: PP.H4 sensitivity across three priors.",
            x = 0.01, y = 0.945, just = "left",
            gp = gpar(fontsize = 10))

  # ====== Layout coordinates ======
  # Panel A: top-left
  A_LEFT  <- 0.07
  A_RIGHT <- 0.58
  A_TOP   <- 0.88
  A_BOT   <- 0.50

  # Panel B: top-right
  B_LEFT  <- 0.66
  B_RIGHT <- 0.95
  B_TOP   <- A_TOP
  B_BOT   <- A_BOT

  # Panel C: bottom full width
  C_LEFT  <- 0.07
  C_RIGHT <- 0.95
  C_TOP   <- 0.33
  C_BOT   <- 0.07

  # Panel labels (A/B/C)
  grid.text("A", x = 0.01, y = A_TOP + 0.03, just = "left",
            gp = gpar(fontsize = 18, fontface = "bold"))
  grid.text("B", x = B_LEFT - 0.04, y = B_TOP + 0.03, just = "left",
            gp = gpar(fontsize = 18, fontface = "bold"))
  grid.text("C", x = 0.01, y = C_TOP + 0.030, just = "left",
            gp = gpar(fontsize = 18, fontface = "bold"))

  # ====== PANEL A: 5 anchors × 5 hypotheses heatmap ======
  grid.text("Posterior probabilities across all 5 hypotheses (default prior, p12 = 1e-5)",
            x = (A_LEFT + A_RIGHT) / 2, y = A_TOP + 0.040,
            gp = gpar(fontsize = 11, fontface = "bold"))

  n_rows_A <- length(ANCHORS)
  n_cols_A <- length(HYPOTHS)
  cell_w_A <- (A_RIGHT - A_LEFT) / n_cols_A
  cell_h_A <- (A_TOP - A_BOT) / n_rows_A

  # Column headers (PP.H0 / PP.H1 / ...)  — placed clearly below panel title
  for (j in seq_along(HYPOTHS)) {
    cx <- A_LEFT + (j - 0.5) * cell_w_A
    grid.text(HYPOTHS[j], x = cx, y = A_TOP + 0.013,
              gp = gpar(fontsize = 11, fontface = "bold"))
  }

  # Row labels + cells
  for (i in seq_along(ANCHORS)) {
    g     <- ANCHORS[i]
    t_g   <- TIER[g]
    cy    <- A_TOP - (i - 0.5) * cell_h_A
    row_data <- panel_A_dt[gene == g]

    # Row label (left side, gene + tier)
    tier_color <- if (t_g == "A") COLOR_TIER_A else COLOR_TIER_B
    grid.text(sprintf("%s [%s]", g, t_g),
              x = A_LEFT - 0.008, y = cy, just = "right",
              gp = gpar(fontsize = 11, fontface = "bold", col = tier_color))

    # 5 cells
    for (j in seq_along(HYPOTHS)) {
      cx  <- A_LEFT + (j - 0.5) * cell_w_A
      val <- as.numeric(row_data[[HYPOTHS[j]]])
      draw_cell(cx, cy, cell_w_A * 0.94, cell_h_A * 0.88, val,
                heat_blue, label_fontsize = 10)
    }
  }

  # Color scale legend for Panel A
  legend_y <- A_BOT - 0.045
  legend_w <- 0.25
  legend_x_left <- A_LEFT
  n_grad <- 50
  for (k in seq_len(n_grad)) {
    v <- (k - 1) / (n_grad - 1)
    cx <- legend_x_left + (k - 0.5) / n_grad * legend_w
    grid.rect(x = cx, y = legend_y,
              width = legend_w / n_grad, height = 0.018,
              gp = gpar(fill = heat_blue(v), col = NA))
  }
  # Border around legend
  grid.rect(x = legend_x_left + legend_w / 2, y = legend_y,
            width = legend_w, height = 0.018,
            gp = gpar(fill = NA, col = COLOR_AXIS, lwd = 0.8))
  for (lv in c(0, 0.25, 0.5, 0.75, 1)) {
    lx <- legend_x_left + lv * legend_w
    grid.lines(x = c(lx, lx), y = c(legend_y - 0.012, legend_y - 0.007),
               gp = gpar(col = COLOR_AXIS, lwd = 0.8))
    grid.text(sprintf("%.2f", lv), x = lx, y = legend_y - 0.024,
              gp = gpar(fontsize = 9))
  }
  grid.text("Posterior probability", x = legend_x_left + legend_w + 0.015,
            y = legend_y, just = "left",
            gp = gpar(fontsize = 10, fontface = "italic"))

  # ====== PANEL B: 5 anchors × 3 priors PP.H4 sensitivity ======
  grid.text("PP.H4 sensitivity across three priors",
            x = (B_LEFT + B_RIGHT) / 2, y = B_TOP + 0.040,
            gp = gpar(fontsize = 11, fontface = "bold"))

  n_cols_B <- length(PRIORS)
  cell_w_B <- (B_RIGHT - B_LEFT) / n_cols_B
  cell_h_B <- (B_TOP - B_BOT) / n_rows_A

  # Column headers — single line, aligned at same Y as Panel A headers
  col_labels_B <- c("default", "conservative", "liberal")
  for (j in seq_along(PRIORS)) {
    cx <- B_LEFT + (j - 0.5) * cell_w_B
    grid.text(col_labels_B[j], x = cx, y = B_TOP + 0.013,
              gp = gpar(fontsize = 11, fontface = "bold"))
  }

  # Rows + cells
  for (i in seq_along(ANCHORS)) {
    g     <- ANCHORS[i]
    t_g   <- TIER[g]
    cy    <- B_TOP - (i - 0.5) * cell_h_B

    # Row label (right side this time, since Panel A has left labels)
    # Actually no row labels needed if aligned with Panel A — just align by y
    for (j in seq_along(PRIORS)) {
      cx <- B_LEFT + (j - 0.5) * cell_w_B
      val <- as.numeric(panel_B_dt[gene == g][[PRIORS[j]]])

      # CD55 conservative: orange border (prior-dependent flag)
      is_flag <- (g == "CD55" && PRIORS[j] == "conservative")
      brd_col <- if (is_flag) COLOR_FLAG_ORG else NA
      brd_lwd <- if (is_flag) 2.0 else 0.5

      draw_cell(cx, cy, cell_w_B * 0.94, cell_h_B * 0.88, val,
                heat_orange, border_color = brd_col, border_lwd = brd_lwd,
                label_fontsize = 11)
    }
  }

  # Panel B legend
  legend_y_B <- B_BOT - 0.045
  legend_w_B <- 0.22
  legend_x_left_B <- B_LEFT
  for (k in seq_len(n_grad)) {
    v <- (k - 1) / (n_grad - 1)
    cx <- legend_x_left_B + (k - 0.5) / n_grad * legend_w_B
    grid.rect(x = cx, y = legend_y_B,
              width = legend_w_B / n_grad, height = 0.018,
              gp = gpar(fill = heat_orange(v), col = NA))
  }
  grid.rect(x = legend_x_left_B + legend_w_B / 2, y = legend_y_B,
            width = legend_w_B, height = 0.018,
            gp = gpar(fill = NA, col = COLOR_AXIS, lwd = 0.8))
  for (lv in c(0, 0.5, 1)) {
    lx <- legend_x_left_B + lv * legend_w_B
    grid.lines(x = c(lx, lx), y = c(legend_y_B - 0.012, legend_y_B - 0.007),
               gp = gpar(col = COLOR_AXIS, lwd = 0.8))
    grid.text(sprintf("%.1f", lv), x = lx, y = legend_y_B - 0.024,
              gp = gpar(fontsize = 9))
  }
  grid.text("PP.H4",
            x = legend_x_left_B + legend_w_B + 0.010, y = legend_y_B,
            just = "left",
            gp = gpar(fontsize = 10, fontface = "italic"))

  # Orange border legend
  grid.rect(x = legend_x_left_B + 0.005, y = legend_y_B - 0.045,
            width = 0.015, height = 0.013,
            gp = gpar(fill = "white", col = COLOR_FLAG_ORG, lwd = 2.0))
  grid.text("prior-dependent flag",
            x = legend_x_left_B + 0.025, y = legend_y_B - 0.045,
            just = "left",
            gp = gpar(fontsize = 8.5, fontface = "italic", col = COLOR_FLAG_ORG))

  # ====== PANEL C: 4-column interpretation table ======
  grid.text("Tier classification and key colocalization statistic",
            x = (C_LEFT + C_RIGHT) / 2, y = C_TOP + 0.025,
            gp = gpar(fontsize = 11.5, fontface = "bold"))

  # 4 columns: Gene | Classification | Key result | Interpretation
  COL_C_GENE_X      <- C_LEFT + 0.008
  COL_C_CLASS_X     <- C_LEFT + 0.120
  COL_C_RESULT_X    <- C_LEFT + 0.320
  COL_C_INTERP_X    <- C_LEFT + 0.540

  # Column headers (just above data rows, below Panel C title)
  hdr_y <- C_TOP - 0.006
  grid.text("Gene",            x = COL_C_GENE_X,   y = hdr_y, just = "left",
            gp = gpar(fontsize = 10.5, fontface = "bold", col = COLOR_TEXT))
  grid.text("Classification",  x = COL_C_CLASS_X,  y = hdr_y, just = "left",
            gp = gpar(fontsize = 10.5, fontface = "bold", col = COLOR_TEXT))
  grid.text("Key result",      x = COL_C_RESULT_X, y = hdr_y, just = "left",
            gp = gpar(fontsize = 10.5, fontface = "bold", col = COLOR_TEXT))
  grid.text("Interpretation",  x = COL_C_INTERP_X, y = hdr_y, just = "left",
            gp = gpar(fontsize = 10.5, fontface = "bold", col = COLOR_TEXT))

  # Horizontal rule under header
  grid.lines(x = c(C_LEFT, C_RIGHT), y = c(hdr_y - 0.014, hdr_y - 0.014),
             gp = gpar(col = COLOR_AXIS, lwd = 0.8))

  # Data rows
  data_top <- hdr_y - 0.024
  row_h_C  <- (data_top - C_BOT) / n_rows_A
  for (i in seq_along(ANCHORS)) {
    g     <- ANCHORS[i]
    t_g   <- TIER[g]
    row   <- panel_C_dt[gene == g]
    cy    <- data_top - (i - 0.5) * row_h_C

    tier_color <- if (t_g == "A") COLOR_TIER_A else COLOR_TIER_B

    # Alternating shading
    if (i %% 2 == 1) {
      grid.rect(x = (C_LEFT + C_RIGHT) / 2, y = cy,
                width = C_RIGHT - C_LEFT, height = row_h_C * 0.94,
                gp = gpar(fill = COLOR_SHADING, col = NA))
    }

    # Gene column (bold, tier color)
    grid.text(g,
              x = COL_C_GENE_X, y = cy, just = "left",
              gp = gpar(fontsize = 11, fontface = "bold", col = tier_color))

    # Classification (bold black)
    grid.text(row$classification,
              x = COL_C_CLASS_X, y = cy, just = "left",
              gp = gpar(fontsize = 10.5, fontface = "bold", col = COLOR_TEXT))

    # Key result
    grid.text(row$key_result,
              x = COL_C_RESULT_X, y = cy, just = "left",
              gp = gpar(fontsize = 10, col = COLOR_TEXT))

    # Interpretation
    grid.text(row$interpretation,
              x = COL_C_INTERP_X, y = cy, just = "left",
              gp = gpar(fontsize = 10, col = COLOR_TEXT))
  }

  # ====== Footnotes ======
  footnote_gp <- gpar(fontsize = 9, col = "#444444")
  grid.text("PP.H0: no association.  PP.H1: gene expression only (= distinct variants).  PP.H2: outcome only.  PP.H3: both, distinct causal variants.  PP.H4: shared causal variant.",
            x = C_LEFT, y = 0.043, just = "left", gp = footnote_gp)
  grid.text("RDH5 was classified as robustly colocalization-supported because PP.H4 remained > 0.75 across default, conservative, and liberal priors. CD55 was classified as prior-sensitive because PP.H4 was high under default and liberal priors but attenuated under the conservative prior.",
            x = C_LEFT, y = 0.024, just = "left", gp = footnote_gp)
  grid.text("Tier B anchors (TGFB1, CTNNB1, FBN1) showed dominant PP.H1 or PP.H3 rather than robust PP.H4, indicating MR-supported associations with distinct-variant evidence.  Prior sets: default p12 = 1e-5, conservative p12 = 1e-6, liberal p12 = 1e-4.",
            x = C_LEFT, y = 0.005, just = "left", gp = footnote_gp)

  popViewport()
}

# --- Render ------------------------------------------------------------------
out_svg <- paste0(OUT_BASE, ".svg")
out_png <- paste0(OUT_BASE, ".png")
out_pdf <- paste0(OUT_BASE, ".pdf")

svglite::svglite(out_svg, width = PLOT_W_INCH, height = PLOT_H_INCH)
render_figure3()
dev.off()

png(out_png, width = PLOT_W_INCH * 250, height = PLOT_H_INCH * 250, res = 250)
render_figure3()
dev.off()

pdf(out_pdf, width = PLOT_W_INCH, height = PLOT_H_INCH)
render_figure3()
dev.off()

cat("\n========== Figure 3 v3 (senior 6 polish: softer title, A1/A2 logic, 4-col table) — LOCK REPORT ==========\n")
cat("SVG:", out_svg, "(", file.size(out_svg), "bytes)\n")
cat("PNG:", out_png, "(", file.size(out_png), "bytes)\n")
cat("PDF:", out_pdf, "(", file.size(out_pdf), "bytes)\n")
cat("Audit CSV:", audit_path, "\n")
cat("\nDESIGN:\n")
cat("  Panel A: 5 anchors × 5 hypotheses (H0-H4) heatmap @ default prior\n")
cat("  Panel B: 5 anchors × 3 priors PP.H4 sensitivity\n")
cat("  Panel C: per-anchor classification + key statistic\n")
cat("  All numbers from Suppl_TableS_coloc_sensitivity.csv (zero hardcode)\n")
cat("================================================\n")
