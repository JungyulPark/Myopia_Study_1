# M-LIGHT — Reproducibility Manifest (target: 100% reproducible)

Goal: anyone can regenerate **every number and figure** in the honest manuscript from
inputs + scripts in this repo, or from documented, accessible external sources.
This file lists (1) the pipeline, (2) data sources, (3) exactly which files still
need to be committed from the PI's machine, and (4) environment capture.

Status legend: ✅ in repo · ⬜ NEEDED from PI · 🔒 access-restricted (document, don't commit)

---

## 1. Pipeline (script → output)

| Step | Script | Output | Status |
|---|---|---|---|
| Primary cis-MR (113 genes) | `CP3/scripts/*` + PI run scripts | full 113-gene MR table | ⬜ output + exact scripts |
| MR robustness (Egger/median/Q) | `Submit_Manuscript/value_add/06_mr_robustness_table.R` (PI-modified) | `mr_robustness_consolidated.csv` | ⬜ output + PI's run version |
| Colocalization (3 priors) | `CP3/scripts/09_coloc_full_local.R` | `Suppl_TableS_coloc_sensitivity.csv` | ⬜ output |
| Replication — Tedja/CREAM | PI script | `Tedja_5anchor_MR_for_Figure2.csv` | ⬜ output |
| Replication — FinnGen | PI script | `PathD_FinnGen_5anchor_MR.csv` | ⬜ output |
| Novelty audit | `Submit_Manuscript/value_add/05_novelty_audit.R` (PI-modified) | `novelty_audit_results.csv` | ⬜ output + PI's run version |
| Integrated review doc | `Submit_Manuscript/value_add/build_integrated_review.py` | `Submit_Manuscript/M-LIGHT_Integrated_Review.html` | ✅ |

---

## 2. Data sources (inputs)

| Input | Source / accession | Build | Access |
|---|---|---|---|
| eQTLGen cis-eQTL | eQTLGen 2019 full cis (`2019-12-11-cis-eQTLsFDR...`) | GRCh37 | public (large) 🔒 |
| UK Biobank myopia | OpenGWAS `ukb-b-6353` (local VCF) | GRCh37 | public 🔒 |
| Tedja 2018 refractive error | CREAM/Tedja 2018 Suppl (N=160,420) | ‹confirm› | public |
| CREAM continuous RE | `ukb-b-19994`, `ukb-b-7500` | GRCh37 | public |
| FinnGen high myopia | FinnGen `H7_MYOPIA` — ‹release Rxx› (8,266 / 254,189) | GRCh38 | public |
| GERA axial length (opt.) | GWAS Catalog `GCST90301672` (Jiang 2023) | ‹confirm 37/38› | public (FTP) |
| Known myopia loci | Tedja 2018 + GWAS Catalog EFO refractive error/myopia | — | public |

**Rule:** large/restricted raw inputs are NOT committed; instead this table +
accession + a checksum (below) make them retrievable. Commit only derived outputs.

---

## 3. ⬜ NEEDED FROM PI — export these to the repo (small, safe to commit)

Copy each to `Submit_Manuscript/value_add/outputs/` (create it) and commit:

1. **Full 113-gene MR results** — the real denominator table
   (`Suppl_TableS_full_denominator_v2.csv`). *This is the single most important file
   for 100% reproducibility — it lets the whole gene table be verified.*
2. **`mr_robustness_consolidated.csv`** (the generated 06 output).
3. **`novelty_audit_results.csv`** (the generated 05 output).
4. **`Suppl_TableS_coloc_sensitivity.csv`** (5 anchors × 3 priors coloc).
5. **`Tedja_5anchor_MR_for_Figure2.csv`** and **`PathD_FinnGen_5anchor_MR.csv`** (replication).
6. **Instrument lists** — the per-gene lead cis-eQTL SNPs actually used
   (from `CP6_assembly/data/a3q1b_cache/`): rsID, chr, pos, effect/other allele, EAF,
   beta, se, F. One CSV is fine.
7. **The exact R scripts you RAN** (your locally-modified 05/06 and the primary-MR
   scripts) — commit the versions that produced the numbers, not only the specs.

## 4. ⬜ Environment capture (for exact reproducibility)

Run once on the PI machine and commit the outputs:
```r
writeLines(capture.output(sessionInfo()), "sessionInfo.txt")   # R + package versions
# (optional but ideal) renv::init(); renv::snapshot()          # -> renv.lock
```
Also note: R version, OS, and that clumping used 1000G EUR (which build/version).
MR/coloc are deterministic; if any step uses sampling, record `set.seed()`.

## 5. Data checksums (so restricted inputs are verifiable)

Run and commit:
```bash
md5sum <eQTLGen file> <ukb-b-6353.vcf.gz> <FinnGen H7_MYOPIA file> <Tedja file> > data/CHECKSUMS.md5
```

---

## 6. What is ALREADY reproducible in-repo
- All value-add / discovery scripts (01–10, D1–D3, AXIAL_DISCOVERY_local) ✅
- Manuscript + section drafts + RESULTS_LEDGER (every quoted number traced) ✅
- Integrated review HTML + its generator ✅
- Old-module MR outputs (COMT/LATS2/CHRM3/ADRA2A/HIF1A/VEGFA/LOX/TGFB1) ✅

Once items in §3–§5 land, the manuscript is **fully reproducible end-to-end**.
