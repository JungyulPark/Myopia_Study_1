# M-LIGHT Manuscript — Stage 2 Figure Submission Package

**Manuscript title:** "An atropine-motivated MR framework prioritizes RDH5 and CD55 as genetic anchors for human myopia"
**Target journal:** IOVS (primary), EER (backup)
**GitHub repo:** https://github.com/JungyulPark/Myopia_Study_1
**Package date:** 2026-06

---

## 📦 Package contents

### Main Figures (4/4 LOCKED)

| File | Description | Source data |
|---|---|---|
| `Figure1_workflow_v19_1.R` | Study design + evidence hierarchy | (schematic) |
| `Figure2_forest_v10.R` | Z-statistic forest plot (5 anchors × 3 cohorts: UKB, Tedja 2018, FinnGen) | A3Q1*.R outputs, Tedja Suppl Data 3 |
| `Figure3_coloc_v3.R` | Bayesian colocalization 3-panel hierarchy (5 anchors × default + 2 sensitivity priors) | Suppl_TableS_coloc_sensitivity.csv |
| `Figure4_schematic_bw.{html,svg,pdf,png}` | Biological context schematic (RDH5/CD55/TGFB1·CTNNB1·FBN1, 3 axes) — monochrome, HTML/CSS+Playwright pipeline | Figure 3 tiers + textbook gene biology |

### Supplementary Figures

| File | Status | Description |
|---|---|---|
| `Supplementary_Figure_S2_docking_v3.R` | ✅ LOCKED | 4×4 best-cavity Vina heatmap + tropane vs non-tropane comparison (Welch P=0.004 exploratory, d=-2.72) |
| `Supplementary_S1_STRING_input_package.md` | ⏳ Input package only — image pending | 47-gene list + STRING settings + Cytoscape guide + final legend. Generate at string-db.org → confidence 0.700 → export |

---

## 🛡️ Data provenance (fabrication 0%)

All numerical content in every figure traces to a verified disk source:

- **Figure 2 data**: `A3Q1*.R` outputs + Tedja 2018 Suppl Data 3 (true CREAM replication, β×−1 sign-aligned)
- **Figure 3 data**: `Suppl_TableS_coloc_sensitivity.csv` (15 rows = 5 anchors × 3 priors)
- **Figure 4 content**: Figure 3 coloc tiers + textbook gene molecular function
- **Suppl S2 matrix**: `06f_docking_4x4_master.csv` (best-cavity rule, reproduces t-test)
- **Suppl S2 stats**: `10_S5_stats_tests.csv` (tropane −7.65 vs non-tropane −6.28, t=−4.71 df=5.74, P=0.004, d=−2.72)
- **Suppl S1 47-gene list**: `Step3_Intersection_Genes.csv` (verified)

---

## 🔑 Key authoritative numbers (single source of truth)

### Mendelian randomization (Stage 2 anchors)
- Discovery outcome: ukb-b-6353 (binary myopia, N=460,536; 37,362 cases)
- True replication: Tedja 2018 Suppl Data 3 (N=160,420), Path A (β×−1 to align UKB scale)
- Tier A robust: **RDH5** PP.H4 0.991 / 0.916 / 0.999
- Tier A prior-sensitive: **CD55** PP.H4 0.801 / 0.287 / 0.976
- Tier B (distinct variants, PP.H1/H3 dominant): **TGFB1, CTNNB1, FBN1**

### Network (CP-1, → Supplementary S1)
- 128 atropine targets × 195 myopia genes → **47 intersection genes**
- **44 connected + 3 singletons (ACHE, ADRA2B, CHRM4)**
- **191 edges** at STRING combined score ≥ 700
- Permutation P = 0.010 (unmatched) — exploratory only

### Docking (CP-4, → Supplementary S2)
- Compounds: Atropine, Scopolamine (tropane) | Tropicamide, Caffeine (non-tropane controls)
- Targets: 5CXV CHRM1 orthosteric (positive control) | 3KYS YAP-TEAD, 5BRK MOB1-LATS1 (Hippo PPI) | 3KFD TGFβ1R (TGFβ-related)
- Tropane PPI mean −7.65 vs non-tropane −6.28 (n=6/group)
- Welch t = −4.71 (df=5.74), P = 0.004 (exploratory), d = −2.72
- Pass rate (≤ −7.0): Atropine 3/3, Scopolamine 3/3, Tropicamide 0/3, Caffeine 0/3

---

## ⚙️ How to render

### R figures (Figures 1, 2, 3, Suppl S2)
```r
# Local R 4.3.3 (per project memory)
setwd("C:/Projectbulid/Myopia")
source("manuscript/figures/Figure1_workflow_v19_1.R", encoding = "UTF-8")
source("manuscript/figures/Figure2_forest_v10.R",     encoding = "UTF-8")
source("manuscript/figures/Figure3_coloc_v3.R",       encoding = "UTF-8")
source("manuscript/figures/Supplementary_Figure_S2_docking_v3.R", encoding = "UTF-8")
```
Each script writes its `{.svg, .png, .pdf, _audit.csv}` set to `pathy/Stage2_Assets/`.

### Figure 4 (HTML/CSS schematic)
Open `Figure4_schematic_bw.html` in a browser (already rendered to PNG 4240×3396 and PDF; SVG via foreignObject). Pure black/white. No re-render needed for submission — PDF is vector.

### Supplementary Figure S1 (network) — pending
1. Open string-db.org → "Multiple proteins"
2. Paste the 47-gene list from `Supplementary_S1_STRING_input_package.md`
3. Organism: Homo sapiens, confidence ≥ 0.700, hide-disconnected OFF
4. Export PNG/SVG
5. (Optional) Cytoscape post-processing for receptor-class color mapping per the package's color table

---

## 🚫 Figure design principles (locked, do not violate)

- L1 network connectivity / L2 genetic causality / L3 docking are **never conflated**
- Docking is exploratory — never described as confirming a molecular target
- Tier A/B classification follows colocalization PP.H4 (see Methods 3.3)
- "atropine direct molecular target: unresolved" appears in Figure 4 conclusion and Suppl S2 footnote
- Monochrome Figure 4 (no color, per user requirement)
- "coloc" in figure shorthand; "colocalization" written out in legends

---

## 📋 Outstanding items (pre-submission)

From project memory:
1. **Suppl S1 network**: generate at string-db.org from the input package (above)
2. **Methods 2.2 Hippo-YAP gene set count discrepancy**: handoff doc 14 vs Methods 2.2 four genes; actual permutation used ~12 components. Reconcile before submission.
3. **References [27][28][35][40]**: exact citations needed.
4. **Methods 2.2.5 CHRM4 location**: contradiction with 2.2.3 unresolved.
5. **CHRNA7/CHRNB4 selection justification**: pending.

