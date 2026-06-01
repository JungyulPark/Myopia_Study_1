# M-LIGHT — Project Handoff & Materials Index

**Purpose of this file:** single entry point for picking up this project across **git**, **Claude Code**, and **Antigravity**. Read this first; it points to every artifact and lists what remains before submission.

- **Manuscript title:** "An atropine-motivated MR framework prioritizes RDH5 and CD55 as genetic anchors for human myopia"
- **Target journal:** IOVS (primary), Experimental Eye Research / EER (backup)
- **GitHub repo:** https://github.com/JungyulPark/Myopia_Study_1
- **Active branch:** `claude/busy-heisenberg-lP58T`
- **Handoff date:** 2026-06-01

> Scope note: a separate protein-binder project (LAP / TGF-β force-state, branch `claude/stoic-dirac-WKSdX`) is **not** part of this repository. It is tracked independently and is out of scope here.

---

## 1. Current status at a glance

| Component | Stage | Status |
|---|---|---|
| CP1 — Network pharmacology (47 intersection genes) | done | results + figures in `CP1/` |
| CP2 — scRNA-seq evidence mapping | done | `CP2/` |
| CP3 — Mendelian randomization + colocalization | done | `CP3/` (incl. revision C2/C3) |
| CP4 — Molecular docking (4×4) | done | `CP4_docking/` |
| CP5 — CMap signature + manuscript figures | done | `CP5_cmap/`, `CP5_figures/` |
| Manuscript drafts (IOVS + EER) | done | `Submit_Manuscript/`, `manuscript/` |
| **Stage 2 final figure package** | **LOCKED** | **`Submit_Manuscript/Stage2_Figures/`** (this handoff) |
| Supplementary S1 network image | **PENDING** | generate at string-db.org (see §5) |
| Pre-submission text fixes | **PENDING** | see §6 |

---

## 2. Repository map

```
CP1/                       Network pharmacology: 47-gene intersection, PPI, KEGG
CP2/                       scRNA-seq evidence mapping
CP3/                       MR + colocalization (scripts/, results/, revision/ C2-MVMR, C3-docking)
CP4_docking/               4×4 docking prep, structures, results
CP5_cmap/  CP5_figures/    CMap gene signature; manuscript-ready figure outputs
manuscript/                Working drafts (Intro/Methods/Results/Discussion/Refs), early SVGs
Submit_Manuscript/         Submission texts — IOVS + EER/ExpEyeRes
  └─ Stage2_Figures/       ★ LOCKED final figures + manifest (added in this handoff)
Revision/                  Reviewer-response code (C1 permutation, C2 MVMR, C3 neg-control)
mmc2.pdf                   Large supplementary PDF
HANDOFF.md                 ← this file
```

`.gitignore` excludes large/binary data (`*.vcf*`, `*.gz`, `*.zip`, `*.docx/pptx`, `*.tiff/tif/jpg`)
and raw data dirs (`CP1/gene`, `CP2/data`, `CP3/data` except `*.md`). `Submit_Manuscript/` and
`Revision/` are explicitly **un-ignored**. PNG/SVG/PDF figure outputs are tracked.

---

## 3. Stage 2 final figure package (LOCKED)

Location: `Submit_Manuscript/Stage2_Figures/` — see its `README_MANIFEST.md` for full provenance.

| File | Figure | Status |
|---|---|---|
| `Figure1_workflow_v19_1.R` | F1 — study design + evidence hierarchy | LOCKED |
| `Figure2_forest_v10.R` | F2 — Z-stat forest (5 anchors × UKB/Tedja/FinnGen) | LOCKED |
| `Figure3_coloc_v3.R` | F3 — Bayesian coloc, 3 priors | LOCKED |
| `Figure4_schematic_bw.{html,svg,pdf,png}` | F4 — biological context, monochrome | LOCKED (PDF is vector; no re-render) |
| `Supplementary_Figure_S2_docking_v3.R` | S2 — 4×4 Vina heatmap + tropane vs non-tropane | LOCKED |
| `Supplementary_S1_STRING_input_package.md` | S1 — 47-gene STRING input + legend | INPUT ONLY (image pending) |

> The original `MLIGHT_Submission_Package.zip` was intentionally **not** committed (matches
> `*.zip` ignore rule and is redundant with the extracted files above).

---

## 4. Authoritative numbers (single source of truth)

**Mendelian randomization**
- Discovery outcome: `ukb-b-6353` (binary myopia, N=460,536; 37,362 cases)
- Replication: Tedja 2018 Suppl Data 3 (N=160,420), Path A (β×−1 to align UKB scale)
- Tier A robust: **RDH5** PP.H4 0.991 / 0.916 / 0.999
- Tier A prior-sensitive: **CD55** PP.H4 0.801 / 0.287 / 0.976
- Tier B (distinct variants, PP.H1/H3 dominant): **TGFB1, CTNNB1, FBN1**

**Network (CP1 → Suppl S1)**
- 128 atropine targets × 195 myopia genes → **47 intersection genes**
- 44 connected + 3 singletons (ACHE, ADRA2B, CHRM4); **191 edges** at STRING ≥ 700
- Permutation P = 0.010 (unmatched) — exploratory only

**Docking (CP4 → Suppl S2)**
- Tropane (Atropine, Scopolamine) PPI mean −7.65 vs non-tropane (Tropicamide, Caffeine) −6.28
- Welch t = −4.71 (df=5.74), P = 0.004 (exploratory), d = −2.72
- Pass rate (≤ −7.0): Atropine 3/3, Scopolamine 3/3, Tropicamide 0/3, Caffeine 0/3
- Targets: 5CXV CHRM1 (positive ctrl) | 3KYS YAP-TEAD, 5BRK MOB1-LATS1 (Hippo) | 3KFD TGFβ1R

---

## 5. How to render figures

**R figures (F1, F2, F3, Suppl S2)** — local R 4.3.3:
```r
setwd("Submit_Manuscript/Stage2_Figures")
source("Figure1_workflow_v19_1.R",            encoding = "UTF-8")
source("Figure2_forest_v10.R",                encoding = "UTF-8")
source("Figure3_coloc_v3.R",                  encoding = "UTF-8")
source("Supplementary_Figure_S2_docking_v3.R", encoding = "UTF-8")
```
Each script writes its `{.svg, .png, .pdf, _audit.csv}` set. Verify source data paths
(`A3Q1*.R` outputs, `Suppl_TableS_coloc_sensitivity.csv`, `06f_docking_4x4_master.csv`,
`10_S5_stats_tests.csv`) resolve on the rendering machine.

**Figure 4 (HTML/CSS schematic):** open `Figure4_schematic_bw.html` in a browser; already
rendered to PNG (4240×3396) and vector PDF. Monochrome — no color, no re-render needed.

**Supplementary S1 (network):** generate at string-db.org → Multiple proteins → paste 47-gene
list from the input package → Homo sapiens, confidence ≥ 0.700, hide-disconnected OFF → export.

---

## 6. Outstanding items before submission

1. **Suppl S1 network image** — generate at string-db.org from the input package (§5).
2. **Methods 2.2 Hippo-YAP gene-set count** — handoff doc says 14, Methods 2.2 says four genes;
   actual permutation used ~12 components. Reconcile before submission.
3. **References [27][28][35][40]** — exact citations still needed.
4. **Methods 2.2.5 CHRM4 location** — contradiction with 2.2.3 unresolved.
5. **CHRNA7/CHRNB4 selection justification** — pending.

---

## 7. Figure design principles (locked — do not violate)

- L1 network connectivity / L2 genetic causality / L3 docking are **never conflated**.
- Docking is **exploratory**; never described as confirming a molecular target.
- Tier A/B follows colocalization PP.H4 (Methods 3.3).
- "atropine direct molecular target: unresolved" stays in F4 conclusion and Suppl S2 footnote.
- Figure 4 is monochrome (per requirement). "coloc" in shorthand; "colocalization" in legends.
- Data provenance target: every figure number traces to a verified disk source (fabrication 0%).

---

## 8. Tool handoff notes

- **git** — work on `claude/busy-heisenberg-lP58T`; push with `git push -u origin <branch>`.
  Do not open a PR unless explicitly requested.
- **Claude Code** — start here, then open the relevant `CP*/` or `Submit_Manuscript/` artifact.
- **Antigravity** — same repo/branch; this file plus `Stage2_Figures/README_MANIFEST.md` are the
  authoritative context. Outstanding items (§6) are the actionable queue.
