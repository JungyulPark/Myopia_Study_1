# ANTIGRAVITY REQUEST — export reproducibility files & commit them

**To the local analysis agent (Antigravity).** Task: make the M-LIGHT analysis 100%
reproducible by committing the derived outputs, the exact run-scripts, the environment
capture, and data checksums to the repo. **Do not recompute anything — just locate,
copy, capture, and commit files that already exist on this machine.** No OpenGWAS
needed. Repo branch: `claude/busy-heisenberg-lP58T`.

Work inside the repo working copy (e.g. `c:/Projectbulid/Myopia/`). First:
```bash
git fetch origin && git checkout claude/busy-heisenberg-lP58T && git pull origin claude/busy-heisenberg-lP58T
```

---

## STEP 1 — copy result CSVs into `Submit_Manuscript/value_add/outputs/`

Find each file on disk (search if the path differs) and copy it into
`Submit_Manuscript/value_add/outputs/`. Keep the exact filename.

| # | File (search for this name) | Likely location |
|---|---|---|
| 1 | **`Suppl_TableS_full_denominator_v2.csv`** ← TOP PRIORITY (full 113-gene MR table) | `pathy/Stage1_QC/` |
| 2 | `mr_robustness_consolidated.csv` | `Submit_Manuscript/value_add/` |
| 3 | `novelty_audit_results.csv` | `Submit_Manuscript/value_add/` |
| 4 | `Suppl_TableS_coloc_sensitivity.csv` (5 anchors × 3 priors) | `pathy/` or `CP3/results/` |
| 5 | `Tedja_5anchor_MR_for_Figure2.csv` | `pathy/Stage2_Assets/` |
| 6 | `PathD_FinnGen_5anchor_MR.csv` | `pathy/Stage2_Assets/` |

If any file's name/location differs, copy the closest correct file and note the mapping
in a one-line `outputs/NOTES.txt`.

## STEP 2 — build the anchor instrument list (`outputs/anchor_instruments.csv`)

From `CP6_assembly/data/a3q1b_cache/`, extract, for RDH5, CD55, TGFB1, CTNNB1, FBN1,
the lead cis-eQTL SNP(s) actually used, with columns:
`gene, ensembl, rsid, chr, pos, effect_allele, other_allele, eaf, beta_eqtl, se_eqtl, F_stat`.
Write to `Submit_Manuscript/value_add/outputs/anchor_instruments.csv`.
(If the full 113-gene instrument list is easy to include too, add
`outputs/all_instruments.csv` in the same schema.)

## STEP 3 — commit the EXACT scripts you ran

Copy the locally-modified scripts that actually produced the numbers (not the specs)
into `Submit_Manuscript/value_add/run_scripts/` — at minimum your run versions of:
- `05_novelty_audit.R`, `06_mr_robustness_table.R`
- the primary 113-gene MR script(s)
- the coloc script that produced the 3-prior sensitivity table
- the Tedja/CREAM and FinnGen replication scripts

## STEP 4 — environment capture

```r
writeLines(capture.output(sessionInfo()), "Submit_Manuscript/value_add/outputs/sessionInfo.txt")
# optional but ideal:
# renv::init(); renv::snapshot()   # commit renv.lock
```

## STEP 5 — checksums for the large restricted inputs (originals NOT committed)

```bash
md5sum \
  <eQTLGen cis file> \
  <ukb-b-6353.vcf.gz> \
  <FinnGen H7_MYOPIA file> \
  <Tedja 2018 file> \
  > data/CHECKSUMS.md5
```
(create the `data/` folder if needed)

## STEP 6 — confirm provenance (write into `outputs/PROVENANCE.txt`)

Three facts we need pinned:
1. **FinnGen release version** for H7_MYOPIA (e.g., R10/R11/R12) + case/control N.
2. **Tedja 2018** exact file/accession used (and N).
3. **Genome build of each dataset**: eQTLGen (GRCh37?), UKB VCF, FinnGen (GRCh38?),
   and — if used — GERA GCST90301672. Flag any build mismatch.

## STEP 7 — commit & push

```bash
git add Submit_Manuscript/value_add/outputs/ Submit_Manuscript/value_add/run_scripts/ data/CHECKSUMS.md5
git commit -m "Add reproducibility artifacts: full-gene MR table, robustness/novelty/coloc/replication outputs, instruments, run-scripts, sessionInfo, checksums, provenance"
git push origin claude/busy-heisenberg-lP58T
```

---

## Acceptance checklist (all must be true when done)
- [ ] `outputs/Suppl_TableS_full_denominator_v2.csv` present (full 113-gene table)
- [ ] outputs 2–6 present (robustness, novelty, coloc-sensitivity, Tedja, FinnGen)
- [ ] `outputs/anchor_instruments.csv` present
- [ ] `run_scripts/` has the exact scripts that produced the numbers
- [ ] `outputs/sessionInfo.txt` present (+ renv.lock if possible)
- [ ] `data/CHECKSUMS.md5` present
- [ ] `outputs/PROVENANCE.txt` answers the 3 provenance questions
- [ ] committed and pushed to `claude/busy-heisenberg-lP58T`

**Do not modify the manuscript or any honest-framing text. Only add reproducibility
files. Report back the commit hash.**
