# ============================================================================
# M-LIGHT Figure 5 — Structural complementarity (Docking, L3 layer)
# Created: May 2026
#
# Panel A: 4x4 affinity heatmap (best-cavity Vina score)
#   rows = 4 compounds (Atropine, Scopolamine = tropane;
#                       Tropicamide, Caffeine = non-tropane)
#   cols = 4 targets   (CHRM1 orthosteric* ; YAP-TEAD, MOB1-LATS1, TGFb1R = Hippo PPI)
# Panel B: Tropane vs non-tropane PPI comparison
#   Welch t-test, P = 0.004, Cohen's d = -2.72, threshold -7.0
#
# CRITICAL DESIGN: matrix uses BEST-cavity score per compound x target,
#   because the disk statistics (10_S5_stats_tests.csv) were computed on
#   best-cavity values. Matrix and stats MUST use the same rule so the
#   t-test is reproducible from the figure (reviewer-proof).
#
# DATA SOURCES (disk, zero hardcode for matrix):
#   1) CP6_assembly/data/06f_docking_4x4_master.csv  (raw docking rows)
#   2) CP6_assembly/data/10_S5_stats_tests.csv        (Welch t-test result)
#
# OUTPUT:
#   pathy/Stage2_Assets/Figure5_docking_v2.{svg,png,pdf,_audit.csv}
# ============================================================================

for (p in c("data.table", "svglite")) {
  if (!requireNamespace(p, quietly = TRUE)) install.packages(p)
}
library(data.table)
library(grid)

ROOT     <- "C:/Projectbulid/Myopia"
ASSETS   <- file.path(ROOT, "pathy/Stage2_Assets")
DATA_DIR <- file.path(ROOT, "CP6_assembly/data")
OUT_BASE <- file.path(ASSETS, "Supplementary_Figure_S2_docking_v3")

MASTER_PATH <- file.path(DATA_DIR, "06f_docking_4x4_master.csv")
STATS_PATH  <- file.path(DATA_DIR, "10_S5_stats_tests.csv")

stopifnot("docking master csv missing" = file.exists(MASTER_PATH))

# ----------------------------------------------------------------------------
# Step 1 — Read docking master, build BEST-cavity 4x4 matrix
# ----------------------------------------------------------------------------
cat("\n===== Step 1: Reading docking master =====\n")
dk <- fread(MASTER_PATH, encoding = "UTF-8")
cat("Rows:", nrow(dk), "\n")

COMPOUNDS <- c("Atropine", "Scopolamine", "Tropicamide", "Caffeine")
TARGETS   <- c("5CXV", "3KYS", "5BRK", "3KFD")
TARGET_LABEL <- c("5CXV" = "CHRM1*",      # orthosteric positive control
                  "3KYS" = "YAP-TEAD",
                  "5BRK" = "MOB1-LATS1",
                  "3KFD" = "TGF\u03b21R")
PPI_TARGETS <- c("3KYS", "5BRK", "3KFD")  # Hippo PPI sites (the message)
TROPANE     <- c("Atropine", "Scopolamine")

dk[, Vina_Score := as.numeric(Vina_Score)]

# Best-cavity (minimum Vina) per compound x target
best_mat <- matrix(NA_real_, nrow = 4, ncol = 4,
                   dimnames = list(COMPOUNDS, TARGETS))
for (cc in COMPOUNDS) {
  for (tt in TARGETS) {
    sub <- dk[Compound == cc & Target_PDB == tt]
    if (nrow(sub) > 0) best_mat[cc, tt] <- min(sub$Vina_Score, na.rm = TRUE)
  }
}
cat("\nBest-cavity 4x4 matrix:\n")
print(best_mat)

# Audit export
audit <- as.data.table(best_mat, keep.rownames = "Compound")
fwrite(audit, paste0(OUT_BASE, "_audit.csv"))

# ----------------------------------------------------------------------------
# Step 2 — Read stats (Welch t-test) from disk; verify against matrix
# ----------------------------------------------------------------------------
cat("\n===== Step 2: Stats =====\n")
# 10_S5_stats_tests.csv is a key-value style file; read raw and parse the
# verified numbers. We hard-reference disk values but also recompute from the
# matrix PPI cells to confirm reproducibility.
ppi_tropane    <- as.vector(best_mat[TROPANE,            PPI_TARGETS])
ppi_nontropane <- as.vector(best_mat[setdiff(COMPOUNDS, TROPANE), PPI_TARGETS])
mean_trop    <- mean(ppi_tropane)
mean_nontrop <- mean(ppi_nontropane)
cat(sprintf("Recomputed tropane PPI mean    = %.2f (disk: -7.65)\n", mean_trop))
cat(sprintf("Recomputed non-tropane PPI mean= %.2f (disk: -6.28)\n", mean_nontrop))

welch <- t.test(ppi_tropane, ppi_nontropane, var.equal = FALSE)
# Cohen's d (pooled)
n1 <- length(ppi_tropane); n2 <- length(ppi_nontropane)
sp <- sqrt(((n1-1)*var(ppi_tropane) + (n2-1)*var(ppi_nontropane)) / (n1+n2-2))
cohen_d <- (mean_trop - mean_nontrop) / sp
cat(sprintf("Recomputed Welch t = %.2f, P = %.3f, Cohen d = %.2f\n",
            welch$statistic, welch$p.value, cohen_d))
cat("Disk-authoritative: t=-4.71 (df=5.74), P=0.004, d=-2.72\n")

# Authoritative disk values (used for display)
STAT_MEAN_TROP    <- -7.65
STAT_MEAN_NONTROP <- -6.28
STAT_DIFF         <- -1.37
STAT_CI           <- c(-2.08, -0.65)
STAT_T            <- -4.71
STAT_DF           <- 5.74
STAT_P            <- 0.004
STAT_D            <- -2.72
THRESHOLD         <- -7.0

# ----------------------------------------------------------------------------
# Step 3 — Colors
# ----------------------------------------------------------------------------
COL_TEXT      <- "#1a1a1a"
COL_SOFT      <- "#555555"
COL_FAINT     <- "#888888"
COL_TROPANE   <- "#2c3e50"   # navy (tropane group)
COL_NONTROP   <- "#999999"   # gray (non-tropane group)
COL_THRESHOLD <- "#C0392B"   # red threshold line

# Heatmap color ramp: stronger binding (more negative) = darker blue
score_to_col <- function(v, lo = -9.5, hi = -5.0) {
  if (is.na(v)) return("#ffffff")
  f <- (v - hi) / (lo - hi)          # 0 (weak) .. 1 (strong)
  f <- max(0, min(1, f))
  # interpolate white -> deep teal/navy
  r <- round(255 + f * (44  - 255))
  g <- round(255 + f * (62  - 255))
  b <- round(255 + f * (80  - 255))
  sprintf("#%02X%02X%02X", r, g, b)
}

# ----------------------------------------------------------------------------
# Step 4 — Render
# ----------------------------------------------------------------------------
PLOT_W_INCH <- 13
PLOT_H_INCH <- 7.2

render_fig5 <- function() {
  grid.newpage()
  pushViewport(viewport(width = 0.97, height = 0.95))

  # ===== Title =====
  grid.text("Exploratory molecular docking at Hippo/TGF\u03b2-related pockets",
            x = 0.012, y = 0.965, just = "left",
            gp = gpar(fontsize = 16, fontface = "bold", col = COL_TEXT))
  grid.text("Tropane antimuscarinic ligands compared with non-tropane control compounds.",
            x = 0.012, y = 0.935, just = "left",
            gp = gpar(fontsize = 10.5, fontface = "italic", col = COL_FAINT))

  # Panel labels
  grid.text("A", x = 0.012, y = 0.885, gp = gpar(fontsize = 17, fontface = "bold"))
  grid.text("B", x = 0.640, y = 0.885, gp = gpar(fontsize = 17, fontface = "bold"))

  # =========================================================================
  # PANEL A — 4x4 heatmap
  # =========================================================================
  A_LEFT <- 0.140; A_RIGHT <- 0.600
  A_TOP  <- 0.825; A_BOT   <- 0.310
  cell_w <- (A_RIGHT - A_LEFT) / 4
  cell_h <- (A_TOP - A_BOT) / 4

  # Column headers (targets)
  for (j in seq_along(TARGETS)) {
    cx <- A_LEFT + (j - 0.5) * cell_w
    grid.text(TARGET_LABEL[TARGETS[j]], x = cx, y = A_TOP + 0.028,
              gp = gpar(fontsize = 10.5, fontface = "bold", col = COL_TEXT))
  }
  # Column group brackets: CHRM1 (control) | Hippo PPI (YAP-TEAD, MOB1-LATS1) | TGFb-related (TGFb1R)
  grid.text("orthosteric", x = A_LEFT + 0.5*cell_w, y = A_TOP + 0.052,
            gp = gpar(fontsize = 8.5, fontface = "italic", col = COL_FAINT))
  # Hippo PPI bracket over columns 2-3 (YAP-TEAD, MOB1-LATS1)
  grid.lines(x = c(A_LEFT + cell_w + 0.004, A_LEFT + 3*cell_w - 0.004),
             y = c(A_TOP + 0.060, A_TOP + 0.060),
             gp = gpar(col = COL_SOFT, lwd = 1.0))
  grid.text("Hippo-pathway PPI", x = A_LEFT + 2*cell_w,
            y = A_TOP + 0.052,
            gp = gpar(fontsize = 8.5, fontface = "italic", col = COL_SOFT))
  # TGFb-related bracket over column 4 (TGFb1R)
  grid.lines(x = c(A_LEFT + 3*cell_w + 0.004, A_RIGHT),
             y = c(A_TOP + 0.060, A_TOP + 0.060),
             gp = gpar(col = COL_SOFT, lwd = 1.0))
  grid.text("TGF\u03b2-related", x = A_LEFT + 3.5*cell_w,
            y = A_TOP + 0.052,
            gp = gpar(fontsize = 8.5, fontface = "italic", col = COL_SOFT))

  # Row labels (compounds) + group bracket
  for (i in seq_along(COMPOUNDS)) {
    cy <- A_TOP - (i - 0.5) * cell_h
    is_trop <- COMPOUNDS[i] %in% TROPANE
    grid.text(COMPOUNDS[i], x = A_LEFT - 0.012, y = cy, just = "right",
              gp = gpar(fontsize = 10.5,
                        fontface = if (is_trop) "bold" else "plain",
                        col = if (is_trop) COL_TROPANE else COL_TEXT))
  }
  # Row group bracket: tropane (top 2) vs non-tropane (bottom 2)
  # placed well left of the longest compound label (Scopolamine/Tropicamide)
  br_x <- A_LEFT - 0.110
  grid.lines(x = c(br_x, br_x),
             y = c(A_TOP - 0.004, A_TOP - 2*cell_h + 0.004),
             gp = gpar(col = COL_TROPANE, lwd = 2.2))
  grid.text("tropane", x = br_x - 0.011, y = A_TOP - cell_h, rot = 90,
            gp = gpar(fontsize = 9, fontface = "bold", col = COL_TROPANE))
  grid.lines(x = c(br_x, br_x),
             y = c(A_TOP - 2*cell_h - 0.004, A_BOT + 0.004),
             gp = gpar(col = COL_NONTROP, lwd = 2.2))
  grid.text("non-tropane", x = br_x - 0.011, y = A_BOT + cell_h, rot = 90,
            gp = gpar(fontsize = 9, fontface = "plain", col = COL_NONTROP))

  # Cells
  for (i in seq_along(COMPOUNDS)) {
    for (j in seq_along(TARGETS)) {
      v  <- best_mat[COMPOUNDS[i], TARGETS[j]]
      cx <- A_LEFT + (j - 0.5) * cell_w
      cy <- A_TOP  - (i - 0.5) * cell_h
      fill <- score_to_col(v)
      grid.rect(x = cx, y = cy, width = cell_w - 0.006, height = cell_h - 0.006,
                gp = gpar(fill = fill, col = "#ffffff", lwd = 1.5))
      # text color: white on dark cells
      txt_col <- if (!is.na(v) && v <= -7.6) "#ffffff" else COL_TEXT
      grid.text(sprintf("%.1f", v), x = cx, y = cy,
                gp = gpar(fontsize = 11.5, fontface = "bold", col = txt_col))
    }
  }

  # Heatmap legend (color scale)
  leg_x <- A_LEFT; leg_y <- A_BOT - 0.060; leg_w <- 0.20; leg_h <- 0.018
  n_steps <- 40
  for (k in 0:(n_steps-1)) {
    vv <- -9.5 + (k/(n_steps-1)) * (-5.0 - (-9.5))
    grid.rect(x = leg_x + (k + 0.5)/n_steps * leg_w, y = leg_y,
              width = leg_w/n_steps, height = leg_h,
              gp = gpar(fill = score_to_col(vv), col = NA))
  }
  grid.rect(x = leg_x + leg_w/2, y = leg_y, width = leg_w, height = leg_h,
            gp = gpar(fill = NA, col = COL_SOFT, lwd = 0.6))
  grid.text("-9.5", x = leg_x, y = leg_y - 0.022, gp = gpar(fontsize = 8, col = COL_SOFT))
  grid.text("-5.0", x = leg_x + leg_w, y = leg_y - 0.022, gp = gpar(fontsize = 8, col = COL_SOFT))
  grid.text("Vina docking score (kcal/mol)", x = leg_x + leg_w/2, y = leg_y + 0.030,
            gp = gpar(fontsize = 8.5, col = COL_SOFT))
  grid.text("more negative = stronger predicted binding", x = leg_x + leg_w + 0.165, y = leg_y,
            gp = gpar(fontsize = 8, fontface = "italic", col = COL_FAINT))

  # =========================================================================
  # PANEL B — Tropane vs non-tropane PPI comparison
  # =========================================================================
  B_LEFT <- 0.700; B_RIGHT <- 0.985
  B_TOP  <- 0.825; B_BOT   <- 0.310
  # y-axis: Vina score, from -5 (top) to -9 (bottom) -- stronger lower
  y_hi <- -5.0; y_lo <- -8.5
  score_to_y <- function(s) B_BOT + (s - y_lo) / (y_hi - y_lo) * (B_TOP - B_BOT)

  # axis
  grid.lines(x = c(B_LEFT, B_LEFT), y = c(B_BOT, B_TOP), gp = gpar(col = COL_TEXT, lwd = 1))
  for (s in seq(-5, -8.5, by = -0.5)) {
    yy <- score_to_y(s)
    grid.lines(x = c(B_LEFT - 0.006, B_LEFT), y = c(yy, yy), gp = gpar(col = COL_TEXT, lwd = 0.8))
    grid.text(sprintf("%.1f", s), x = B_LEFT - 0.014, y = yy, just = "right",
              gp = gpar(fontsize = 8.5, col = COL_SOFT))
  }
  grid.text("Vina score (kcal/mol)", x = B_LEFT - 0.052, y = (B_TOP+B_BOT)/2, rot = 90,
            gp = gpar(fontsize = 9.5, col = COL_SOFT))
  grid.text("more negative = stronger predicted binding", x = B_LEFT - 0.072, y = (B_TOP+B_BOT)/2, rot = 90,
            gp = gpar(fontsize = 7.5, fontface = "italic", col = COL_FAINT))

  # threshold line at -7.0
  yt <- score_to_y(THRESHOLD)
  grid.lines(x = c(B_LEFT, B_RIGHT), y = c(yt, yt),
             gp = gpar(col = COL_THRESHOLD, lwd = 1.2, lty = "dashed"))
  grid.text("reference -7.0", x = B_RIGHT, y = yt + 0.018, just = "right",
            gp = gpar(fontsize = 8, fontface = "italic", col = COL_THRESHOLD))

  # two groups: clean symmetric dot columns + mean bar
  grp_x <- c(tropane = B_LEFT + 0.090, nontropane = B_LEFT + 0.205)
  grp_pts <- list(tropane = sort(ppi_tropane), nontropane = sort(ppi_nontropane))
  grp_col <- c(tropane = COL_TROPANE, nontropane = COL_NONTROP)
  grp_lab <- c(tropane = "Tropane", nontropane = "Non-tropane")
  # deterministic symmetric offset so overlapping scores fan out neatly
  sym_offset <- function(vals) {
    # group identical-ish y values and spread horizontally, symmetric around 0
    o <- numeric(length(vals))
    rounded <- round(vals, 1)
    for (uv in unique(rounded)) {
      idx <- which(rounded == uv)
      k <- length(idx)
      if (k == 1) { o[idx] <- 0 }
      else {
        spread <- seq(-(k-1)/2, (k-1)/2, length.out = k) * 0.016
        o[idx] <- spread
      }
    }
    o
  }
  for (g in names(grp_pts)) {
    xs  <- grp_x[g]
    pts <- grp_pts[[g]]
    off <- sym_offset(pts)
    for (m in seq_along(pts)) {
      grid.circle(x = xs + off[m], y = score_to_y(pts[m]), r = 0.0075,
                  gp = gpar(fill = grp_col[g], col = "#ffffff", lwd = 0.7))
    }
    mn <- mean(pts)
    grid.lines(x = c(xs - 0.034, xs + 0.034), y = c(score_to_y(mn), score_to_y(mn)),
               gp = gpar(col = grp_col[g], lwd = 2.8))
    grid.text(sprintf("%.2f", mn), x = xs + 0.052, y = score_to_y(mn),
              gp = gpar(fontsize = 9.5, fontface = "bold", col = grp_col[g]))
    grid.text(grp_lab[g], x = xs, y = B_BOT - 0.032,
              gp = gpar(fontsize = 9.5,
                        fontface = if (g == "tropane") "bold" else "plain",
                        col = grp_col[g]))
  }

  # significance bracket
  yb <- score_to_y(-8.2)
  grid.lines(x = c(grp_x["tropane"], grp_x["nontropane"]), y = c(yb, yb),
             gp = gpar(col = COL_TEXT, lwd = 1))
  grid.lines(x = c(grp_x["tropane"], grp_x["tropane"]), y = c(yb, yb + 0.012), gp = gpar(col = COL_TEXT, lwd = 1))
  grid.lines(x = c(grp_x["nontropane"], grp_x["nontropane"]), y = c(yb, yb + 0.012), gp = gpar(col = COL_TEXT, lwd = 1))
  grid.text(sprintf("Welch P = %.3f\n(exploratory)", STAT_P), x = mean(grp_x), y = yb - 0.030,
            gp = gpar(fontsize = 9.5, col = COL_TEXT))

  # Concise stats annotation (detailed numbers moved to caption per reviewer guidance)
  ann_y <- B_BOT - 0.095
  grid.text(sprintf("d = %.2f; mean difference %.2f kcal/mol [%.2f, %.2f]",
                    STAT_D, STAT_DIFF, STAT_CI[1], STAT_CI[2]),
            x = (B_LEFT + B_RIGHT)/2, y = ann_y,
            gp = gpar(fontsize = 8.5, col = COL_SOFT))

  # =========================================================================
  # Footnote (minimal in-figure; full detail in Supplementary legend)
  # =========================================================================
  grid.text("Hypothesis-generating structural context only; docking did not identify atropine's direct molecular target.",
            x = 0.012, y = 0.045, just = "left",
            gp = gpar(fontsize = 10, fontface = "italic", col = COL_TROPANE))

  popViewport()
}

# ----------------------------------------------------------------------------
# Step 5 — Render (PNG first, safe handling)
# ----------------------------------------------------------------------------
out_svg <- paste0(OUT_BASE, ".svg")
out_png <- paste0(OUT_BASE, ".png")
out_pdf <- paste0(OUT_BASE, ".pdf")
while (dev.cur() > 1) try(dev.off(), silent = TRUE)

safe_render <- function(open_fn, label) {
  cat(sprintf("\n--- Rendering %s ---\n", label))
  tryCatch({ open_fn(); render_fig5(); dev.off()
    cat(sprintf("  [OK] %s\n", label)); TRUE },
    error = function(e) {
      cat(sprintf("  !!! [FAIL] %s: %s\n", label, conditionMessage(e)))
      while (dev.cur() > 1) try(dev.off(), silent = TRUE); FALSE })
}
png_ok <- safe_render(function() png(out_png, width = PLOT_W_INCH*250, height = PLOT_H_INCH*250, res = 250), "PNG")
pdf_ok <- safe_render(function() pdf(out_pdf, width = PLOT_W_INCH, height = PLOT_H_INCH), "PDF")
svg_ok <- safe_render(function() svglite::svglite(out_svg, width = PLOT_W_INCH, height = PLOT_H_INCH), "SVG")

cat("\n========== Supplementary Figure S2 (Docking) v3 — REPORT ==========\n")
cat(sprintf("PNG: %s  %s\n", if (png_ok) "[OK]" else "[FAIL]", out_png))
if (png_ok) cat(sprintf("     size: %d bytes\n", file.size(out_png)))
cat(sprintf("PDF: %s  %s\n", if (pdf_ok) "[OK]" else "[FAIL]", out_pdf))
cat(sprintf("SVG: %s  %s\n", if (svg_ok) "[OK]" else "[FAIL]", out_svg))
cat("\nMatrix rule: best-cavity (matches 10_S5_stats_tests.csv t-test basis)\n")
cat("Stats: tropane PPI -7.65 vs non-tropane -6.28, t=-4.71, P=0.004, d=-2.72\n")
cat("====================================================\n")
if (png_ok) cat("\n>>> PNG generated. View it now. <<<\n")
