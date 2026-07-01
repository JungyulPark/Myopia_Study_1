# ANTIGRAVITY REQUEST — regenerate honest figures/tables in R

The existing figures (CP3/CP5 forest plots, triangulation heatmap, docking bar) were
built for the OLD gene set and overclaiming frame. Regenerate the honest figure set in R
from the **committed** `Submit_Manuscript/value_add/outputs/` CSVs, and commit PNG+PDF
(300 dpi) to `Submit_Manuscript/value_add/figures_honest/`. Branch: `claude/busy-heisenberg-lP58T`.

**Data sources (all already in repo):**
- `outputs/Suppl_TableS_full_denominator_v2.csv` (113-gene screen: F, beta, pval, coloc_PP_H1/H3/H4, final_tier, cream_*)
- `outputs/mr_robustness_consolidated.csv` (Egger/median/Q)
- `outputs/PathD_FinnGen_5anchor_MR.csv`, `outputs/Tedja_5anchor_MR_for_Figure2.csv`
- `outputs/Suppl_TableS_coloc_sensitivity.csv` (3-prior coloc)

## Figure 1 — Study design / pipeline (schematic)
Flow: 113 pharmacology-prioritized genes → cis-MR vs UKB myopia → 5 Bonferroni-significant
→ replication (CREAM/Tedja/FinnGen) + 3-prior colocalization → **2 Tier-A coloc-supported
(RDH5, CD55), 3 Tier-B distinct-variant, 108 null**. (Can be a clean flow diagram.)

## Figure 2 — Multi-cohort forest plot (5 anchors)
For RDH5, CD55, CTNNB1, FBN1, TGFB1, plot the MR estimate ± 95% CI in each cohort:
UKB (beta), CREAM (cream_R_beta), Tedja, FinnGen (log-OR). Facet or color by cohort.
Sign-align to the myopia-risk axis and note the coding in the caption. Mark TGFB1's
discordant direction.

## Figure 3 — Colocalization stacked bars (5 anchors)
Stacked bar of PP.H1 / PP.H3 / PP.H4 per anchor (default prior), with the 3-prior
sensitivity (from `Suppl_TableS_coloc_sensitivity.csv`) shown as points/error range on
PP.H4. Make visually obvious: RDH5 & CD55 = high PP.H4 (shared); CTNNB1 (H3 high), FBN1
& TGFB1 (H1 high) = distinct variants.

## Figure 4 — ⭐ Screen-wide scatter (NEW headline figure)
Across all 113 genes: x = MR −log10(P), y = coloc PP.H4. Draw thresholds (Bonferroni x;
PP.H4 = 0.7 y). Color: Tier_A (RDH5, CD55) highlighted, Tier_B (CTNNB1/FBN1/TGFB1), and
the 108 Null in grey. Label the 5 named genes. **This figure is the paper's honest
signature — it shows the whole screen and that only two known loci colocalize.**

## Supplementary figures (exploratory — keep, relabel as Sxx)
- S1 network (CP1/figures/Fig2_PPI_Network) — exploratory only.
- S2 docking (CP5_figures/Figure4_Docking_Bar) — MUST relabel/caption as
  tropane-scaffold-dependent (scopolamine binds comparably), NOT atropine-specific.

## Tables to finalize
- **Table 1** (main): anchor detail — build from `draft_sections/TABLE1_honest.md` (data verified).
- **Table S1** (supplement): the full 113-gene table = `Suppl_TableS_full_denominator_v2.csv` as-is.
- **Table S2**: MR sensitivity = `mr_robustness_consolidated.csv`.

## Commit
```bash
git add Submit_Manuscript/value_add/figures_honest/
git commit -m "Regenerate honest figures (multi-cohort forest, coloc bars, screen-wide scatter) from verified outputs"
git push origin claude/busy-heisenberg-lP58T
```
**Do not modify the manuscript text. Figures must plot only the committed verified data.
Report the commit hash.**
