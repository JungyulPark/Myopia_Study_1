# ============================================================================
# M-LIGHT Figure 2 v6 — Z-Statistic Standardized Evidence Plot
# Created: May 14, 2026
#
# REDESIGN (Option C):
#   Title: "Standardized discovery and external outcome evidence for
#           five prioritized myopia genetic anchors"
#
#   x-axis: Z statistic = β / SE  (common evidence-strength axis)
#   Reference lines: Z = 0 (null) and Z = ±1.96 (5% significance)
#
#   Rows: RDH5, CD55, TGFB1, CTNNB1, FBN1 (5 anchors)
#   Per gene: 3 sub-rows
#     - UKB discovery
#     - Tedja 2018 external refractive-error check
#     - FinnGen H7_MYOPIA sensitivity
#
#   Markers: blue square (discovery), orange circle (Tedja),
#            open black circle (FinnGen sensitivity)
#   TGFB1 Tedja: orange open circle + "proxy; discordant" flag
#
#   Right text column: ORIGINAL scale β / logOR, 95% CI, P value
#
# v5 -> v6 changes:
#   - x-axis switched from raw β to Z = β/SE
#   - Title updated to "Standardized ... evidence"
#   - Font sizes increased ~25% across the board
#   - Row spacing tightened (no big gaps between sub-rows)
#   - Legend moved to top right (no overlap with header)
#   - "FinnGen sensitivity" never labeled as "replication"
#   - Tedja flagged as "external refractive-error check" not just "replication"
#
# All numbers from disk csv (zero hardcode).
# ============================================================================

for (p in c("data.table", "svglite")) {
  if (!requireNamespace(p, quietly = TRUE)) install.packages(p)
}
library(data.table)
library(grid)

# --- Paths -------------------------------------------------------------------
ROOT     <- "C:/Projectbulid/Myopia"
ASSETS   <- file.path(ROOT, "pathy/Stage2_Assets")
OUT_BASE <- file.path(ASSETS, "Figure2_forest_v10")

PANEL_A_PATH <- file.path(ASSETS, "Table2_v2_PanelA_5anchor_MR_Coloc.csv")
PANEL_B_PATH <- file.path(ASSETS, "Tedja_5anchor_MR_PathA_aligned.csv")
PANEL_C_PATH <- file.path(ASSETS, "PathD_FinnGen_5anchor_MR.csv")

stopifnot(
  file.exists(PANEL_A_PATH),
  file.exists(PANEL_B_PATH),
  file.exists(PANEL_C_PATH)
)

# --- Globals -----------------------------------------------------------------
ANCHORS    <- c("RDH5", "CD55", "TGFB1", "CTNNB1", "FBN1")
TIER       <- c(RDH5 = "A", CD55 = "A", TGFB1 = "B", CTNNB1 = "B", FBN1 = "B")
gene_order <- ANCHORS

# Colors (Wang Y IOVS minimal palette)
COLOR_DISCOVERY    <- "#2C5C8E"   # blue
COLOR_REPLICATION  <- "#D87C3A"   # orange
COLOR_SENSITIVITY  <- "#555555"   # gray
COLOR_TEXT         <- "#000000"
COLOR_AXIS         <- "#000000"
COLOR_NULL_LINE    <- "#888888"
COLOR_THRESHOLD    <- "#BBBBBB"   # ±1.96 reference lines
COLOR_SHADING      <- "#F2F2F2"
COLOR_FLAG_RED     <- "#C0392B"

# ============================================================================
# Read csvs & build assembled long-format table
# ============================================================================
cat("\n===== Step 1: UKB Discovery =====\n")
A_raw <- fread(PANEL_A_PATH)
parse_beta_ci <- function(s) {
  s <- gsub('"', '', s)
  m <- regmatches(s, regexec("(-?\\d*\\.?\\d+)\\s*\\(\\s*(-?\\d*\\.?\\d+)\\s*,\\s*(-?\\d*\\.?\\d+)\\s*\\)", s))[[1]]
  if (length(m) != 4) return(c(NA_real_, NA_real_, NA_real_))
  as.numeric(m[2:4])
}
df_A <- A_raw[Gene %in% ANCHORS, .(Gene, Beta_95CI, UKB_P, n_SNP)]
parsed <- t(sapply(df_A$Beta_95CI, parse_beta_ci))
df_A[, beta    := as.numeric(parsed[, 1])]
df_A[, ci_low  := as.numeric(parsed[, 2])]
df_A[, ci_up   := as.numeric(parsed[, 3])]
df_A[, se      := (ci_up - ci_low) / (2 * 1.96)]
df_A[, pval    := as.numeric(UKB_P)]
df_A[, n_snp   := as.integer(n_SNP)]
df_A[, gene    := Gene]
df_A <- df_A[, .(gene, n_snp, beta, se, ci_low, ci_up, pval)]
df_A[, cohort_id := "DISC"]
df_A[, is_proxy := FALSE]
df_A[, is_discordant := FALSE]
print(df_A)

cat("\n===== Step 2: Tedja external refractive-error check =====\n")
B_raw <- fread(PANEL_B_PATH)
df_B <- B_raw[gene %in% ANCHORS, .(
  gene,
  n_snp     = as.integer(n_snp),
  beta      = as.numeric(beta_aligned),
  se        = as.numeric(se),
  ci_low    = as.numeric(ci_lo),
  ci_up     = as.numeric(ci_hi),
  pval      = as.numeric(pval)
)]
df_B[, cohort_id := "REP"]
df_B[, is_proxy := gene == "TGFB1"]
df_B[, is_discordant := FALSE]
# TGFB1 Tedja proxy is DISCORDANT vs UKB Discovery
ukb_sign_for_B <- setNames(sign(df_A$beta), df_A$gene)
df_B[, is_discordant := {
  ukb_s  <- ukb_sign_for_B[gene]
  tedja_s <- sign(beta)
  !is.na(ukb_s) & !is.na(tedja_s) & (ukb_s != tedja_s)
}]
print(df_B)

cat("\n===== Step 3: FinnGen H7_MYOPIA sensitivity =====\n")
C_raw <- fread(PANEL_C_PATH)
df_C <- C_raw[gene %in% ANCHORS, .(
  gene,
  n_snp     = as.integer(n_snp),
  beta      = as.numeric(log_OR),
  se        = as.numeric(se),
  ci_low    = as.numeric(log_OR_ci_lo),
  ci_up     = as.numeric(log_OR_ci_hi),
  pval      = as.numeric(pval)
)]
df_C[, cohort_id := "SEN"]
df_C[, is_proxy := FALSE]
ukb_sign_for_C <- setNames(sign(df_A$beta), df_A$gene)
df_C[, is_discordant := {
  ukb_s  <- ukb_sign_for_C[gene]
  finn_s <- sign(beta)
  !is.na(ukb_s) & !is.na(finn_s) & (ukb_s != finn_s) & (pval < 0.05)
}]
print(df_C)

# Combine + compute Z statistics
all_rows <- rbindlist(list(df_A, df_B, df_C), fill = TRUE)
all_rows[, tier := TIER[gene]]
all_rows[is.na(is_proxy),      is_proxy      := FALSE]
all_rows[is.na(is_discordant), is_discordant := FALSE]

# Z statistic = beta / SE
all_rows[, Z := beta / se]
all_rows[, Z_low := Z - 1.96]
all_rows[, Z_up  := Z + 1.96]

.gene_vec <- gene_order
all_rows[, row_gene_order   := match(gene, .gene_vec)]
all_rows[, row_cohort_order := match(cohort_id, c("DISC", "REP", "SEN"))]
setorder(all_rows, row_gene_order, row_cohort_order)

audit_path <- paste0(OUT_BASE, "_audit.csv")
fwrite(all_rows, audit_path)
cat("\nAudit saved:", audit_path, "\n")
cat("\nFull 15-row Z-statistic table:\n")
print(all_rows[, .(gene, cohort_id, beta, se, pval, Z, Z_low, Z_up, is_proxy, is_discordant)])

# ============================================================================
# Plotting
# ============================================================================
fmt_p <- function(p) {
  if (is.na(p)) return("NA")
  if (p < 1e-100) return("<1e-100")
  if (p < 1e-3)  return(sprintf("%.1e", p))
  sprintf("%.3f", p)
}
fmt_beta_ci <- function(beta, lo, hi) sprintf("%.3f (%.3f, %.3f)", beta, lo, hi)

# Z-axis bounds
cat("\nZ range:", round(range(all_rows$Z), 2), "\n")
cat("Z_low / Z_up range:", round(range(all_rows$Z_low), 2),
    "/", round(range(all_rows$Z_up), 2), "\n")
# Wide enough to include Tedja RDH5 Z=+12, CD55 Z=-7.5
# CI extents: Z_up max ~ +13.96, Z_low min ~ -9.46
X_AXIS_MIN <- -10
X_AXIS_MAX <- 14
X_TICKS    <- c(-10, -5, 0, 5, 10)

cat(sprintf("\nUsing Z-axis: [%g, %g]\n", X_AXIS_MIN, X_AXIS_MAX))
clipped <- all_rows[Z_low < X_AXIS_MIN | Z_up > X_AXIS_MAX,
                    .(gene, cohort_id, Z, Z_low, Z_up)]
if (nrow(clipped) > 0) { cat("Rows clipped:\n"); print(clipped) } else cat("No clipping.\n")

PLOT_W_INCH <- 13
PLOT_H_INCH <- 11

# Layout — tightened from v5
COL_GENE_X       <- 0.015
COL_NSNP_X       <- 0.245
COL_PVAL_X       <- 0.305
FOREST_LEFT      <- 0.355
FOREST_RIGHT     <- 0.74
COL_BETA_X       <- 0.755

Y_TITLE        <- 0.972
Y_SUBTITLE     <- 0.948
Y_LEGEND       <- 0.910
Y_HEADER       <- 0.870
Y_DATA_TOP     <- 0.840
Y_DATA_BOT     <- 0.220
Y_AXIS         <- 0.180
Y_TICKS        <- 0.155
Y_196_LABEL    <- 0.133
Y_BOTTOM_LBL   <- 0.110
Y_ARROW_LBL    <- 0.088
Y_DIR_LABEL    <- 0.068
# v9 footnote band
Y_FOOTNOTE_TOP <- 0.045

# Per gene: 4 slots (header, disc, rep, sen)
# v6 tighter: row spacing reduced by ~30%
N_GENES <- length(gene_order)
total_slots <- N_GENES * 4
slot_height <- (Y_DATA_TOP - Y_DATA_BOT) / (total_slots - 1)
slot_ys <- Y_DATA_TOP - (seq_len(total_slots) - 1) * slot_height

x_to_fig <- function(zd) {
  zd_clipped <- max(min(zd, X_AXIS_MAX), X_AXIS_MIN)
  FOREST_LEFT + (zd_clipped - X_AXIS_MIN) / (X_AXIS_MAX - X_AXIS_MIN) * (FOREST_RIGHT - FOREST_LEFT)
}

draw_marker <- function(x_fig, y_fig, cohort_id, is_proxy) {
  if (cohort_id == "DISC") {
    grid.rect(x = x_fig, y = y_fig, width = 0.013, height = 0.017,
              gp = gpar(fill = COLOR_DISCOVERY, col = COLOR_DISCOVERY))
  } else if (cohort_id == "REP") {
    if (is_proxy) {
      grid.circle(x = x_fig, y = y_fig, r = 0.010,
                  gp = gpar(fill = "white", col = COLOR_REPLICATION, lwd = 2.2))
    } else {
      grid.circle(x = x_fig, y = y_fig, r = 0.010,
                  gp = gpar(fill = COLOR_REPLICATION, col = COLOR_REPLICATION))
    }
  } else {
    grid.circle(x = x_fig, y = y_fig, r = 0.010,
                gp = gpar(fill = "white", col = COLOR_SENSITIVITY, lwd = 1.8))
  }
}

draw_ci <- function(Z_low, Z_up, y_fig, cohort_id, is_discordant) {
  color <- switch(cohort_id, "DISC" = COLOR_DISCOVERY,
                  "REP" = COLOR_REPLICATION, "SEN" = COLOR_SENSITIVITY)
  clip_low <- Z_low < X_AXIS_MIN
  clip_up  <- Z_up  > X_AXIS_MAX
  if (Z_up < X_AXIS_MIN || Z_low > X_AXIS_MAX) return(invisible())
  xL <- x_to_fig(max(Z_low, X_AXIS_MIN))
  xU <- x_to_fig(min(Z_up,  X_AXIS_MAX))
  lty <- if (is_discordant) "dashed" else "solid"
  grid.lines(x = c(xL, xU), y = c(y_fig, y_fig),
             gp = gpar(col = color, lwd = 2.2, lty = lty))
  if (!clip_low) {
    grid.lines(x = c(xL, xL), y = c(y_fig - 0.009, y_fig + 0.009),
               gp = gpar(col = color, lwd = 1.8))
  } else {
    grid.lines(x = c(xL + 0.009, xL), y = c(y_fig, y_fig),
               arrow = arrow(length = unit(2.5, "mm"), ends = "first", type = "closed"),
               gp = gpar(col = color, lwd = 1.8, fill = color))
  }
  if (!clip_up) {
    grid.lines(x = c(xU, xU), y = c(y_fig - 0.009, y_fig + 0.009),
               gp = gpar(col = color, lwd = 1.8))
  } else {
    grid.lines(x = c(xU - 0.009, xU), y = c(y_fig, y_fig),
               arrow = arrow(length = unit(2.5, "mm"), ends = "last", type = "closed"),
               gp = gpar(col = color, lwd = 1.8, fill = color))
  }
}

render_figure2 <- function() {
  grid.newpage()
  pushViewport(viewport(width = 0.97, height = 0.97))

  # Title
  # Title (short)
  grid.text("Figure 2. Standardized evidence for prioritized myopia genetic anchors",
            x = COL_GENE_X, y = Y_TITLE, just = "left",
            gp = gpar(fontsize = 16, fontface = "bold"))
  grid.text("Z statistics place UKB, Tedja, and FinnGen outcomes on a common evidence-strength axis.",
            x = COL_GENE_X, y = Y_SUBTITLE, just = "left",
            gp = gpar(fontsize = 12))

  # Legend (top of figure, spread across full width)
  lg_y <- Y_LEGEND
  # Discovery
  grid.rect(x = COL_GENE_X + 0.005, y = lg_y, width = 0.014, height = 0.017,
            gp = gpar(fill = COLOR_DISCOVERY, col = COLOR_DISCOVERY))
  grid.text("UKB discovery (binary, log-odds)",
            x = COL_GENE_X + 0.020, y = lg_y, just = "left",
            gp = gpar(fontsize = 12))
  # Replication
  grid.circle(x = COL_GENE_X + 0.265, y = lg_y, r = 0.010,
              gp = gpar(fill = COLOR_REPLICATION, col = COLOR_REPLICATION))
  grid.text("Tedja 2018 external refractive-error check",
            x = COL_GENE_X + 0.280, y = lg_y, just = "left",
            gp = gpar(fontsize = 12))
  # Sensitivity
  grid.circle(x = COL_GENE_X + 0.610, y = lg_y, r = 0.010,
              gp = gpar(fill = "white", col = COLOR_SENSITIVITY, lwd = 1.8))
  grid.text("FinnGen H7_MYOPIA sensitivity (n_case = 1,640)",
            x = COL_GENE_X + 0.625, y = lg_y, just = "left",
            gp = gpar(fontsize = 12))

  # Column headers
  hdr_gp <- gpar(fontsize = 13, fontface = "bold", col = COLOR_TEXT)
  grid.text("Gene / Outcome", x = COL_GENE_X,  y = Y_HEADER, just = "left",  gp = hdr_gp)
  grid.text("No. SNP",        x = COL_NSNP_X,  y = Y_HEADER, just = "center", gp = hdr_gp)
  grid.text("P value",        x = COL_PVAL_X,  y = Y_HEADER, just = "center", gp = hdr_gp)
  grid.text("Z = β / SE",     x = (FOREST_LEFT + FOREST_RIGHT) / 2,
            y = Y_HEADER, just = "center", gp = hdr_gp)
  grid.text(expression(paste("Risk-aligned ", beta, " / logOR (95% CI)")),
            x = COL_BETA_X, y = Y_HEADER, just = "left", gp = hdr_gp)

  # Iterate over genes
  for (gi in seq_along(gene_order)) {
    g     <- gene_order[gi]
    t_g   <- TIER[g]
    slot_base <- (gi - 1) * 4
    y_gene <- slot_ys[slot_base + 1]
    y_disc <- slot_ys[slot_base + 2]
    y_rep  <- slot_ys[slot_base + 3]
    y_sen  <- slot_ys[slot_base + 4]

    # Alternating row shading
    if (gi %% 2 == 1) {
      block_top <- y_gene + slot_height * 0.55
      block_bot <- y_sen  - slot_height * 0.55
      grid.rect(x = (COL_GENE_X + COL_BETA_X + 0.24) / 2,
                y = (block_top + block_bot) / 2,
                width  = (COL_BETA_X + 0.24) - COL_GENE_X,
                height = block_top - block_bot,
                gp = gpar(fill = COLOR_SHADING, col = NA))
    }

    # Gene header (bold)
    gene_label <- sprintf("%s [Tier %s]", g, t_g)
    grid.text(gene_label,
              x = COL_GENE_X, y = y_gene, just = "left",
              gp = gpar(fontsize = 14, fontface = "bold", col = COLOR_TEXT))

    # Sub-row labels — v6 uses descriptive names
    sub_lbl_gp <- gpar(fontsize = 12, col = COLOR_TEXT)
    grid.text("  UKB discovery",       x = COL_GENE_X, y = y_disc, just = "left", gp = sub_lbl_gp)
    grid.text("  Tedja external check", x = COL_GENE_X, y = y_rep, just = "left", gp = sub_lbl_gp)
    grid.text("  FinnGen sensitivity",  x = COL_GENE_X, y = y_sen, just = "left", gp = sub_lbl_gp)

    # Data rows
    for (this_cohort in c("DISC", "REP", "SEN")) {
      r <- all_rows[gene == g & cohort_id == this_cohort]
      if (nrow(r) == 0) next
      yp <- switch(this_cohort, "DISC" = y_disc, "REP" = y_rep, "SEN" = y_sen)

      is_proxy_v      <- isTRUE(r$is_proxy)
      is_discordant_v <- isTRUE(r$is_discordant)

      # No. SNP
      grid.text(as.character(r$n_snp),
                x = COL_NSNP_X, y = yp, just = "center",
                gp = gpar(fontsize = 12, col = COLOR_TEXT))

      # P value
      grid.text(fmt_p(r$pval),
                x = COL_PVAL_X, y = yp, just = "center",
                gp = gpar(fontsize = 12, col = COLOR_TEXT))

      # Z CI line + marker
      draw_ci(r$Z_low, r$Z_up, yp, this_cohort, is_discordant_v)
      if (r$Z >= X_AXIS_MIN && r$Z <= X_AXIS_MAX) {
        draw_marker(x_to_fig(r$Z), yp, this_cohort, is_proxy_v)
      }

      # Original β / logOR text — short dagger for TGFB1 Tedja, full footnote at figure bottom
      beta_txt <- fmt_beta_ci(r$beta, r$ci_low, r$ci_up)
      if (is_proxy_v && is_discordant_v) {
        beta_txt <- paste0(beta_txt, "†")
      } else if (is_proxy_v) {
        beta_txt <- paste0(beta_txt, "†")
      } else if (is_discordant_v) {
        beta_txt <- paste0(beta_txt, "*")
      }
      txt_color <- if (is_discordant_v) COLOR_FLAG_RED else COLOR_TEXT
      grid.text(beta_txt,
                x = COL_BETA_X, y = yp, just = "left",
                gp = gpar(fontsize = 11.5, col = txt_color))
    }
  }

  # Reference lines: Z = 0, ±1.96
  for (zref in c(-1.96, 0, 1.96)) {
    xf <- x_to_fig(zref)
    line_color <- if (zref == 0) COLOR_NULL_LINE else COLOR_THRESHOLD
    line_lty <- if (zref == 0) "dashed" else "dotted"
    grid.lines(x = c(xf, xf),
               y = c(Y_AXIS, Y_DATA_TOP + 0.012),
               gp = gpar(col = line_color, lwd = 1.0, lty = line_lty))
  }

  # x-axis line
  grid.lines(x = c(FOREST_LEFT, FOREST_RIGHT), y = c(Y_AXIS, Y_AXIS),
             gp = gpar(col = COLOR_AXIS, lwd = 1.4))

  # ticks
  for (tv in X_TICKS) {
    xf <- x_to_fig(tv)
    grid.lines(x = c(xf, xf), y = c(Y_AXIS - 0.007, Y_AXIS),
               gp = gpar(col = COLOR_AXIS, lwd = 1.0))
    grid.text(sprintf("%g", tv), x = xf, y = Y_TICKS,
              gp = gpar(fontsize = 12, col = COLOR_TEXT))
  }

  # ±1.96 reference markers: small italic labels on dedicated row below ticks
  for (zref in c(-1.96, 1.96)) {
    xf <- x_to_fig(zref)
    label_text <- if (zref > 0) "+1.96" else "−1.96"
    grid.text(label_text, x = xf, y = Y_196_LABEL,
              gp = gpar(fontsize = 9, fontface = "italic",
                        col = "#888888"))
  }

  # X-axis title
  grid.text("Z statistic = β / SE",
            x = (FOREST_LEFT + FOREST_RIGHT) / 2, y = Y_BOTTOM_LBL,
            gp = gpar(fontsize = 13, fontface = "bold", col = COLOR_TEXT))

  # Directional arrows
  arrow_y <- Y_ARROW_LBL
  grid.lines(x = c(x_to_fig(-3), x_to_fig(-8)),
             y = c(arrow_y, arrow_y),
             arrow = arrow(length = unit(2.8, "mm"), ends = "last", type = "closed"),
             gp = gpar(col = COLOR_TEXT, lwd = 1.4, fill = COLOR_TEXT))
  grid.lines(x = c(x_to_fig(3), x_to_fig(8)),
             y = c(arrow_y, arrow_y),
             arrow = arrow(length = unit(2.8, "mm"), ends = "last", type = "closed"),
             gp = gpar(col = COLOR_TEXT, lwd = 1.4, fill = COLOR_TEXT))
  grid.text("Lower myopia risk",
            x = x_to_fig(-5.5), y = Y_DIR_LABEL,
            gp = gpar(fontsize = 11.5, fontface = "italic", col = COLOR_TEXT))
  grid.text("Higher myopia risk",
            x = x_to_fig(5.5), y = Y_DIR_LABEL,
            gp = gpar(fontsize = 11.5, fontface = "italic", col = COLOR_TEXT))

  # ====== Footnotes (v9) ======
  footnote_gp <- gpar(fontsize = 9.5, col = "#444444")
  grid.text("† TGFB1 Tedja estimate used LD proxy rs34503210 (r² = 0.83); direction discordant with UKB discovery (shown in red).",
            x = COL_GENE_X, y = Y_FOOTNOTE_TOP, just = "left",
            gp = footnote_gp)
  grid.text("Horizontal bars in the central plot represent ±1.96 standardized units (visual reference, not original-scale CI). Original-scale 95% CIs are in the right column.",
            x = COL_GENE_X, y = Y_FOOTNOTE_TOP - 0.022, just = "left",
            gp = footnote_gp)
  grid.text("Tedja refractive-error estimates were sign-aligned (β × −1) so that positive Z values indicate higher myopia risk consistent with the UKB scale.",
            x = COL_GENE_X, y = Y_FOOTNOTE_TOP - 0.044, just = "left",
            gp = footnote_gp)

  popViewport()
}

# Render
out_svg <- paste0(OUT_BASE, ".svg")
out_png <- paste0(OUT_BASE, ".png")
out_pdf <- paste0(OUT_BASE, ".pdf")

svglite::svglite(out_svg, width = PLOT_W_INCH, height = PLOT_H_INCH)
render_figure2()
dev.off()

png(out_png, width = PLOT_W_INCH * 250, height = PLOT_H_INCH * 250, res = 250)
render_figure2()
dev.off()

pdf(out_pdf, width = PLOT_W_INCH, height = PLOT_H_INCH)
render_figure2()
dev.off()

cat("\n========== Figure 2 v10 (bottom layout spread) — LOCK REPORT ==========\n")
cat("SVG:", out_svg, "(", file.size(out_svg), "bytes)\n")
cat("PNG:", out_png, "(", file.size(out_png), "bytes)\n")
cat("PDF:", out_pdf, "(", file.size(out_pdf), "bytes)\n")
cat("Audit CSV:", audit_path, "\n")
cat("\nDESIGN (Option C — Z-statistic standardized evidence plot):\n")
cat("  - x-axis: Z = β / SE (common evidence-strength scale)\n")
cat("  - Reference lines: Z = 0 (null), Z = ±1.96 (5% significance)\n")
cat("  - Original β/logOR (95% CI) preserved in right text column\n")
cat("  - 5 anchors × 3 outcomes = 15 data points\n")
cat("  - TGFB1 Tedja: proxy + discordant flags\n")
cat("  - FinnGen labeled 'sensitivity' (NOT 'replication')\n")
cat("=============================================================\n")
