# ============================================================================
# Figure 1 — Study pipeline flowchart  (clean rewrite, text guaranteed to fit)
# Fix: previous version had text larger than boxes / overflow.
# Solution: ggfittext::geom_fit_text auto-shrinks + reflows every label to fit
#           its box exactly; generous boxes; theme_void; 300 dpi.
# Data is fixed/verified (no external file needed): 113 -> 5 anchors ->
#   Tier A n=2 (RDH5,CD55) / Tier B n=3 (CTNNB1,FBN1,TGFB1) / Null n=108.
# ============================================================================
# install.packages(c("ggplot2","ggfittext"))  # if needed
suppressPackageStartupMessages({ library(ggplot2); library(ggfittext) })

OUT <- "Submit_Manuscript/value_add/figures_honest"   # adjust ROOT if needed
dir.create(OUT, showWarnings = FALSE, recursive = TRUE)

# ---- box geometry -----------------------------------------------------------
# canvas: x in [0,10], y in [0,14]
box <- function(id, xc, yc, w, h, label, fill, border, textcol = "black", bold = TRUE)
  data.frame(id, xmin = xc - w/2, xmax = xc + w/2, ymin = yc - h/2, ymax = yc + h/2,
             label, fill, border, textcol, fontface = ifelse(bold, "bold", "plain"),
             stringsAsFactors = FALSE)

boxes <- rbind(
  box("b1", 5, 13.0, 6.2, 1.5,
      "113 pharmacology-prioritized candidate genes\n(nominated from prior myopia MR / eQTL literature)",
      "#DCE6F5", "#1F4E79"),
  box("b2", 5, 10.7, 6.2, 1.5,
      "Primary cis-MR screen\n(eQTLGen blood eQTL  →  UK Biobank myopia)",
      "#DCE6F5", "#1F4E79"),
  box("b3", 5,  8.4, 6.2, 1.5,
      "Bonferroni-significant + Steiger-directional\n(n = 5 anchor genes)",
      "#DCE6F5", "#1F4E79"),
  box("b4", 5,  6.1, 6.2, 1.5,
      "Replication + 3-prior colocalization audit\n(CREAM / Tedja / FinnGen  +  coloc.abf)",
      "#DCE6F5", "#1F4E79"),
  # ---- three outcome boxes ----
  box("tA", 2.0, 3.0, 3.2, 2.0,
      "Tier A — Colocalization-supported\n(n = 2: RDH5, CD55)\nPP.H4 > 0.8 & replicated",
      "#D6EAD4", "#2E7D32"),
  box("tB", 5.0, 3.0, 3.2, 2.0,
      "Tier B — MR-supported, distinct variant\n(n = 3: CTNNB1, FBN1, TGFB1)\nPP.H4 ≤ 0.8",
      "#FBE3D3", "#E06B1F"),
  box("tN", 8.0, 3.0, 3.2, 2.0,
      "Null / excluded\n(n = 108)\nMR non-significant",
      "#ECECEC", "#7F7F7F")
)

# ---- arrows -----------------------------------------------------------------
seg <- function(x, xend, y, yend) data.frame(x, xend, y, yend)
arrows_v <- rbind(
  seg(5, 5, 13.0 - 0.75, 10.7 + 0.75),   # b1 -> b2
  seg(5, 5, 10.7 - 0.75,  8.4 + 0.75),   # b2 -> b3
  seg(5, 5,  8.4 - 0.75,  6.1 + 0.75)    # b3 -> b4
)
# split from b4 bottom (5, 6.1-0.75=5.35) to top of each outcome box (y 3+1=4)
arrows_split <- rbind(
  seg(5, 2.0, 5.35, 4.0),
  seg(5, 5.0, 5.35, 4.0),
  seg(5, 8.0, 5.35, 4.0)
)

# ---- plot -------------------------------------------------------------------
p <- ggplot() +
  # boxes
  geom_rect(data = boxes, aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax,
                              fill = fill, colour = border), linewidth = 0.9) +
  scale_fill_identity() + scale_colour_identity() +
  # arrows
  geom_segment(data = arrows_v, aes(x = x, xend = xend, y = y, yend = yend),
               arrow = arrow(length = unit(0.18, "cm"), type = "closed"),
               linewidth = 0.7, colour = "#404040") +
  geom_segment(data = arrows_split, aes(x = x, xend = xend, y = y, yend = yend),
               arrow = arrow(length = unit(0.18, "cm"), type = "closed"),
               linewidth = 0.7, colour = "#404040") +
  # auto-fitted text (reflow + shrink so it never overflows the box)
  geom_fit_text(data = boxes,
                aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax,
                    label = label, fontface = fontface, colour = textcol),
                reflow = TRUE, grow = FALSE, min.size = 6, padding.x = grid::unit(1.5, "mm"),
                padding.y = grid::unit(1.0, "mm"), lineheight = 0.95) +
  coord_cartesian(xlim = c(0, 10), ylim = c(1.6, 14), expand = FALSE) +
  theme_void() +
  theme(plot.margin = margin(6, 6, 6, 6))

ggsave(file.path(OUT, "Figure1_Pipeline.png"), p, width = 9, height = 7.5, dpi = 300, bg = "white")
ggsave(file.path(OUT, "Figure1_Pipeline.pdf"), p, width = 9, height = 7.5, bg = "white")
cat("WROTE Figure1_Pipeline.png/.pdf\n")
