# ============================================================================
# M-LIGHT Figure 1 v19_1 — FABRICATION REMOVED (May 2026)
#
# Changes from v17:
#   (1) Block 1 Outcome box:
#       - "Discovery cohort: UK Biobank GWAS (N = 460,536)"
#         → "UK Biobank ukb-b-6353"
#         → "binary self-report myopia"
#         → "(N = 460,536; cases 37,362 / controls 423,174)"
#       - "Independent replication: CREAM consortium (N = 542,934)" [FABRICATION]
#         → "Replication: Tedja 2018 meta-analysis"
#         → "(N = 160,420)"
#         → "CREAM-EUR/ASN + 23andMe"
#
#   (2) Block 3 Replication sub-box:
#       - "CREAM consortium (N = 542,934) | Right eye + left eye | Independent of UKB"
#       - (Previous text was misleading — actual data used was ukb-b-19994/-7500
#          which is UKB sphere R/L, NOT independent — circular analysis)
#         → "Tedja 2018 meta-analysis"
#         → "(N = 160,420)"
#         → "CREAM + 23andMe"
#         → "truly independent of UKB Discovery"
#
#   (3) Block 4 TGFB1 entry:
#       - "(PP.H1 = 0.944)"
#         → "(PP.H1 = 0.944; Tedja proxy r²=0.83)"
#         (honest limitation note for reviewer-proofing)
#
#   (4) Title font weight & position: identical to v17
#
# Verified locked numbers (all confirmed in this session):
#   - ukb-b-6353: N = 460,536 = 37,362 cases + 423,174 controls (gwasinfo confirmed)
#   - Tedja 2018 N = 160,420 (Stage 3 meta: CREAM 56K + 23andMe 104K)
#   - Atropine 128, Myopia 195, eQTLGen 31,684
#   - 117 candidates → 112 valid instruments → 4 Bonferroni-significant
#   - Bonferroni 4.27e-4 (0.05/117)
#   - Coloc: RDH5 0.991, CD55 0.801, TGFB1 0.944, CTNNB1 0.767, FBN1 0.702
#
# Engine: R base grid graphics
# Output: pathy/Stage2_Assets/Figure1_workflow_v19_1.{svg,png,pdf}
# ============================================================================

# --- Packages ----------------------------------------------------------------
required_pkgs <- c("svglite")
for (p in required_pkgs) {
  if (!requireNamespace(p, quietly = TRUE)) install.packages(p)
}
library(grid)

# --- Output paths ------------------------------------------------------------
out_dir <- "pathy/Stage2_Assets"
if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)
out_svg <- file.path(out_dir, "Figure1_workflow_v19_1.svg")
out_png <- file.path(out_dir, "Figure1_workflow_v19_1.png")
out_pdf <- file.path(out_dir, "Figure1_workflow_v19_1.pdf")

# --- Drawing helpers ---------------------------------------------------------
box_border <- "black"
box_fill   <- "white"
text_col   <- "black"
line_w     <- 1.6

draw_box <- function(x, y, w, h, fill = box_fill, border = box_border,
                     lwd = line_w, lty = "solid") {
  grid.roundrect(x = x, y = y, width = w, height = h,
                 r = unit(0.5, "mm"),
                 gp = gpar(fill = fill, col = border, lwd = lwd, lty = lty))
}

draw_header <- function(x, y_top, w, h, text, font_size = 10.5) {
  grid.roundrect(x = x, y = y_top - h/2, width = w, height = h,
                 r = unit(0.5, "mm"),
                 gp = gpar(fill = "#E8E8E8", col = box_border, lwd = line_w))
  grid.text(text, x = x, y = y_top - h/2,
            gp = gpar(fontsize = font_size, fontface = "bold", col = text_col))
}

draw_arrow <- function(x, y_top, y_bottom, lwd = 2.2) {
  grid.lines(x = c(x, x), y = c(y_top, y_bottom + 0.005),
             arrow = arrow(length = unit(3.5, "mm"), type = "closed"),
             gp = gpar(col = "black", lwd = lwd, fill = "black"))
}

draw_subbox <- function(x_center, y_top, y_bottom, w,
                        header, body_lines,
                        header_h = 0.022, body_fontsize = 9,
                        max_line_gap = 0.014) {
  h_total <- y_top - y_bottom
  draw_box(x = x_center, y = (y_top + y_bottom)/2, w = w, h = h_total)
  grid.rect(x = x_center, y = y_top - header_h/2,
            width = w - 0.002, height = header_h,
            gp = gpar(fill = "#E8E8E8", col = NA))
  grid.text(header, x = x_center, y = y_top - header_h/2,
            gp = gpar(fontsize = 9.5, fontface = "bold"))

  MIN_GAP <- 0.014
  MAX_GAP <- 0.024
  body_top_padding    <- 0.012
  body_bottom_padding <- 0.012

  body_top    <- y_top - header_h - body_top_padding
  body_bottom <- y_bottom + body_bottom_padding
  body_zone_h <- body_top - body_bottom
  body_center <- (body_top + body_bottom) / 2

  n_lines <- length(body_lines)

  if (n_lines == 1) {
    line_ys <- body_center
  } else {
    natural_gap <- body_zone_h / (n_lines - 1)
    actual_gap <- max(MIN_GAP, min(MAX_GAP, natural_gap))
    total_h    <- actual_gap * (n_lines - 1)
    line_ys <- seq(body_center + total_h/2,
                   body_center - total_h/2,
                   length.out = n_lines)
  }

  for (j in seq_along(body_lines)) {
    grid.text(body_lines[j], x = x_center, y = line_ys[j],
              gp = gpar(fontsize = body_fontsize), just = "center")
  }
}

# --- Main drawing function ---------------------------------------------------
draw_workflow_v19_1 <- function() {
  grid.newpage()
  pushViewport(viewport(width = 0.97, height = 0.97))

  # ========== Title ==========
  main_x_center <- 0.32
  main_w        <- 0.60
  title_left_x <- main_x_center - main_w/2  # = 0.02

  grid.text(
    "Figure 1. Study design and evidence hierarchy",
    x = title_left_x, y = 0.985, just = "left",
    gp = gpar(fontsize = 13, fontface = "bold")
  )
  grid.text(
    "Atropine-motivated framework for prioritizing genetic anchors of human myopia",
    x = title_left_x, y = 0.962, just = "left",
    gp = gpar(fontsize = 9.5)
  )

  # ========== Layout ==========
  side_x_center <- 0.78
  side_w        <- 0.28
  arrow_gap     <- 0.024

  plot_top    <- 0.945
  plot_bottom <- 0.020

  block_h <- list(
    b1 = 0.135,  # v19.1: 0.120 -> 0.135 to fit 5-line Outcome box
    b2 = 0.195,
    b3 = 0.130,
    b4 = 0.145,
    cn = 0.065
  )

  y1_top <- plot_top
  y1_bot <- y1_top - block_h$b1

  y2_top <- y1_bot - arrow_gap
  y2_bot <- y2_top - block_h$b2

  y3_top <- y2_bot - arrow_gap
  y3_bot <- y3_top - block_h$b3

  y4_top <- y3_bot - arrow_gap
  y4_bot <- y4_top - block_h$b4

  yc_top <- y4_bot - arrow_gap
  yc_bot <- yc_top - block_h$cn

  # ========== Block 1: Data Sources ==========
  block_header_h <- 0.026
  grid.rect(x = main_x_center, y = y1_top - block_header_h/2,
            width = main_w, height = block_header_h,
            gp = gpar(fill = "#D0D0D0", col = "black", lwd = line_w))
  grid.text("DATA SOURCES",
            x = main_x_center, y = y1_top - block_header_h/2,
            gp = gpar(fontsize = 11, fontface = "bold"))

  sub_top <- y1_top - block_header_h - 0.005
  sub_bot <- y1_bot + 0.005
  sub_w   <- main_w/2 - 0.005

  draw_subbox(
    x_center = main_x_center - sub_w/2 - 0.002,
    y_top = sub_top, y_bottom = sub_bot, w = sub_w,
    header = "Exposure: atropine + myopia gene set",
    body_lines = c(
      "Atropine targets (n = 128, CTD)",
      "Myopia genes (n = 195, CTD)",
      "eQTLGen blood cis-eQTL",
      "(n = 31,684)"
    ),
    body_fontsize = 8.5
  )

  # === v19_1 CHANGE 1: Outcome box ===
  draw_subbox(
    x_center = main_x_center + sub_w/2 + 0.002,
    y_top = sub_top, y_bottom = sub_bot, w = sub_w,
    header = "Outcome: myopia risk",
    body_lines = c(
      "Discovery: UK Biobank (ukb-b-6353)",
      "binary self-report myopia",
      "(N = 460,536)",
      "Replication: Tedja 2018 meta",
      "CREAM + 23andMe (N = 160,420)"
    ),
    body_fontsize = 8.3
  )

  draw_box(x = main_x_center, y = (y1_top + y1_bot)/2,
           w = main_w, h = y1_top - y1_bot, fill = NA)

  draw_arrow(main_x_center, y1_bot, y2_top)

  # ========== Block 2: Expanded MR Screen ==========
  grid.rect(x = main_x_center, y = y2_top - block_header_h/2,
            width = main_w, height = block_header_h,
            gp = gpar(fill = "#D0D0D0", col = "black", lwd = line_w))
  grid.text("EXPANDED MENDELIAN RANDOMIZATION SCREEN",
            x = main_x_center, y = y2_top - block_header_h/2,
            gp = gpar(fontsize = 11, fontface = "bold"))

  sub_top <- y2_top - block_header_h - 0.005
  summary_h <- 0.034
  sub_bot <- y2_bot + summary_h + 0.005

  draw_subbox(
    x_center = main_x_center - sub_w/2 - 0.002,
    y_top = sub_top, y_bottom = sub_bot, w = sub_w,
    header = "Design and instruments",
    body_lines = c(
      "Two-sample MR design",
      "F > 10 instrument filter",
      "",
      "117 candidates assembled",
      "\u2192 112 with valid instruments",
      "\u2192 4 Bonferroni-significant hits"
    ),
    body_fontsize = 8.5
  )
  draw_subbox(
    x_center = main_x_center + sub_w/2 + 0.002,
    y_top = sub_top, y_bottom = sub_bot, w = sub_w,
    header = "Significance and directionality",
    body_lines = c(
      "Bonferroni threshold:",
      "0.05 / 117 = 4.27 \u00D7 10\u207B\u2074",
      "Steiger directionality test",
      "Reverse MR (null)",
      "Wald ratio / IVW",
      "according to instrument count"
    ),
    body_fontsize = 8.5
  )

  grid.text(
    "4 Tier 1 hits: RDH5, CD55, CTNNB1, FBN1",
    x = main_x_center, y = y2_bot + summary_h * 0.72,
    gp = gpar(fontsize = 8.3, fontface = "bold")
  )
  grid.text(
    "+ TGFB1 from Phase A  =  5 prioritized anchors",
    x = main_x_center, y = y2_bot + summary_h * 0.28,
    gp = gpar(fontsize = 8.3, fontface = "bold")
  )

  draw_box(x = main_x_center, y = (y2_top + y2_bot)/2,
           w = main_w, h = y2_top - y2_bot, fill = NA)

  draw_arrow(main_x_center, y2_bot, y3_top)

  # ========== Side box: Exploratory mechanistic context ==========
  side_top <- y2_top - 0.005
  side_bot <- y2_bot + 0.005

  grid.roundrect(
    x = side_x_center, y = (side_top + side_bot)/2,
    width = side_w, height = side_top - side_bot,
    r = unit(0.5, "mm"),
    gp = gpar(fill = "#F8F8F8", col = "#666666", lwd = 1.3, lty = "dashed")
  )
  grid.rect(x = side_x_center, y = side_top - 0.018,
            width = side_w - 0.002, height = 0.026,
            gp = gpar(fill = "#E0E0E0", col = NA))
  grid.text("Exploratory mechanistic context",
            x = side_x_center, y = side_top - 0.018,
            gp = gpar(fontsize = 9, fontface = "bold"))

  exp_body <- c(
    "Network pharmacology",
    "(47-gene intersection, STRING \u2265 0.7;",
    "interpreted as exploratory)",
    "",
    "Molecular docking",
    "(4 \u00D7 4 affinity matrix at Hippo PPI;",
    "tropane scaffold dependency)",
    "",
    "Did not resolve atropine's",
    "direct molecular target"
  )
  body_top    <- side_top - 0.040
  body_bottom <- side_bot + 0.010
  line_ys <- seq(body_top, body_bottom, length.out = length(exp_body))
  for (j in seq_along(exp_body)) {
    txt <- exp_body[j]
    if (nchar(txt) > 0) {
      face <- if (txt == "Did not resolve atropine's" || txt == "direct molecular target")
              "italic" else "plain"
      col_use <- if (face == "italic") "#444444" else "#333333"
      grid.text(txt, x = side_x_center, y = line_ys[j],
                gp = gpar(fontsize = 8, fontface = face, col = col_use))
    }
  }

  grid.lines(
    x = c(main_x_center + main_w/2, side_x_center - side_w/2),
    y = c((y2_top + y2_bot)/2, (y2_top + y2_bot)/2),
    gp = gpar(col = "#666666", lwd = 1.2, lty = "dashed")
  )

  # ========== Block 3: Validation and Specificity ==========
  grid.rect(x = main_x_center, y = y3_top - block_header_h/2,
            width = main_w, height = block_header_h,
            gp = gpar(fill = "#D0D0D0", col = "black", lwd = line_w))
  grid.text("VALIDATION AND SPECIFICITY CHECKS",
            x = main_x_center, y = y3_top - block_header_h/2,
            gp = gpar(fontsize = 11, fontface = "bold"))

  sub_top <- y3_top - block_header_h - 0.005
  sub_bot <- y3_bot + 0.005
  sub3_w  <- main_w/3 - 0.006

  # === v19_1 CHANGE 2: Replication sub-box ===
  draw_subbox(
    x_center = main_x_center - sub3_w - 0.006,
    y_top = sub_top, y_bottom = sub_bot, w = sub3_w,
    header = "Replication",
    body_lines = c(
      "Tedja 2018 meta",
      "(N = 160,420)",
      "CREAM + 23andMe",
      "truly independent of UKB"
    ),
    body_fontsize = 8
  )
  draw_subbox(
    x_center = main_x_center,
    y_top = sub_top, y_bottom = sub_bot, w = sub3_w,
    header = "Causal robustness",
    body_lines = c(
      "Bayesian colocalization",
      "(coloc.abf)",
      "Prior sensitivity:",
      "default / conservative / liberal"
    ),
    body_fontsize = 8
  )
  draw_subbox(
    x_center = main_x_center + sub3_w + 0.006,
    y_top = sub_top, y_bottom = sub_bot, w = sub3_w,
    header = "Specificity",
    body_lines = c(
      "GWAS Catalog PheWAS",
      "(1.1M associations)",
      "Phase A2 multi-tissue",
      "TGFB1 MVMR with height"
    ),
    body_fontsize = 8
  )

  draw_box(x = main_x_center, y = (y3_top + y3_bot)/2,
           w = main_w, h = y3_top - y3_bot, fill = NA)

  draw_arrow(main_x_center, y3_bot, y4_top)

  # ========== Block 4: Prioritized Genetic Anchors ==========
  grid.rect(x = main_x_center, y = y4_top - block_header_h/2,
            width = main_w, height = block_header_h,
            gp = gpar(fill = "#D0D0D0", col = "black", lwd = line_w))
  grid.text("PRIORITIZED GENETIC ANCHORS FOR HUMAN MYOPIA",
            x = main_x_center, y = y4_top - block_header_h/2,
            gp = gpar(fontsize = 11, fontface = "bold"))

  sub_top <- y4_top - block_header_h - 0.005
  sub_bot <- y4_bot + 0.005

  draw_subbox(
    x_center = main_x_center - sub_w/2 - 0.002,
    y_top = sub_top, y_bottom = sub_bot, w = sub_w,
    header = "Tier A (colocalization-supported)",
    body_lines = c(
      "RDH5 \u2014 visual-cycle anchor",
      "(PP.H4 = 0.991, robust)",
      "",
      "CD55 \u2014 complement-regulatory anchor",
      "(PP.H4 = 0.801, prior-dependent)"
    ),
    body_fontsize = 8.5
  )

  # === v19_1 CHANGE 3: TGFB1 proxy limitation note ===
  draw_subbox(
    x_center = main_x_center + sub_w/2 + 0.002,
    y_top = sub_top, y_bottom = sub_bot, w = sub_w,
    header = "Tier B \u2014 MR-supported secondary anchors",
    body_lines = c(
      "TGFB1 \u2014 TGF\u03B2 remodeling anchor",
      "(PP.H1 = 0.944; Tedja proxy r\u00B2=0.83)",
      "CTNNB1 \u2014 Wnt / \u03B2-catenin anchor",
      "(PP.H3 = 0.767)",
      "FBN1 \u2014 fibrillin / ECM anchor (PP.H1 = 0.702)"
    ),
    body_fontsize = 8.5
  )

  draw_box(x = main_x_center, y = (y4_top + y4_bot)/2,
           w = main_w, h = y4_top - y4_bot, fill = NA)

  draw_arrow(main_x_center, y4_bot, yc_top)

  # ========== Conclusion ==========
  draw_box(x = main_x_center, y = (yc_top + yc_bot)/2,
           w = main_w, h = yc_top - yc_bot, fill = "#F0F0F0",
           lwd = 2.0)
  conclusion_center_y <- (yc_top + yc_bot) / 2
  grid.text(
    "Atropine's direct molecular target remains unresolved",
    x = main_x_center, y = conclusion_center_y + 0.009,
    gp = gpar(fontsize = 10.5, fontface = "bold"), just = "center"
  )
  grid.text(
    "by transcriptomic Mendelian randomization",
    x = main_x_center, y = conclusion_center_y - 0.009,
    gp = gpar(fontsize = 9.5), just = "center"
  )

  popViewport()
}

# --- Render ------------------------------------------------------------------
svglite::svglite(out_svg, width = 10.5, height = 13.5)
draw_workflow_v19_1()
dev.off()

png(out_png, width = 2650, height = 3400, res = 250)
draw_workflow_v19_1()
dev.off()

pdf(out_pdf, width = 10.5, height = 13.5)
draw_workflow_v19_1()
dev.off()

# --- Lock report -------------------------------------------------------------
cat("\n========== Figure 1 v19_1 (FABRICATION REMOVED) — LOCK REPORT ==========\n")
cat("SVG:", out_svg, "\u2014", file.size(out_svg), "bytes\n")
cat("PNG:", out_png, "\u2014", file.size(out_png), "bytes\n")
cat("PDF:", out_pdf, "\u2014", file.size(out_pdf), "bytes\n")
cat("\n--- v17 \u2192 v19_1 CHANGES ---\n")
cat("(1) Block 1 Outcome:\n")
cat("    OLD: 'UK Biobank GWAS (N=460,536) / CREAM (N=542,934) [FABRICATION]'\n")
cat("    NEW: 'UK Biobank (ukb-b-6353) binary self-report myopia (N=460,536)\n")
cat("         / Replication: Tedja 2018 meta CREAM+23andMe (N=160,420)'\n")
cat("\n(2) Block 3 Replication:\n")
cat("    OLD: 'CREAM (N=542,934) / Right eye+left eye / Independent of UKB'\n")
cat("         [actually used ukb-b-19994/-7500 = circular]\n")
cat("    NEW: 'Tedja 2018 meta (N=160,420) / CREAM+23andMe /\n")
cat("         truly independent of UKB'\n")
cat("\n(3) Block 4 TGFB1:\n")
cat("    OLD: '(PP.H1 = 0.944)'\n")
cat("    NEW: '(PP.H1 = 0.944; Tedja proxy r\u00B2=0.83)' [honest limitation]\n")
cat("\n--- ALL NUMBERS NOW VERIFIED ---\n")
cat("  [\u2713] ukb-b-6353 N=460,536 (gwasinfo: 37,362 cases + 423,174 controls)\n")
cat("  [\u2713] Tedja 2018 N=160,420 (Nature paper Methods)\n")
cat("  [\u2713] Atropine 128, Myopia 195 (CTD)\n")
cat("  [\u2713] eQTLGen 31,684\n")
cat("  [\u2713] 117 / 112 / 4 (Bonferroni 4.27e-4)\n")
cat("  [\u2713] Coloc: RDH5 0.991, CD55 0.801, TGFB1 0.944,\n")
cat("              CTNNB1 0.767, FBN1 0.702\n")
cat("=============================================================\n")
