# M-LIGHT — Elevation value-add package

Executable specs + writing scaffolds that raise the paper from honest-confirmation
(BMC/PLOS tier) toward **TVST / IOVS**, without any novelty or atropine-specificity
overclaim. Driven by `Submit_Manuscript/GOAL_AND_LOOP_PLAN.md` (recommended path
**Option B-lite: druggability-first, axial-length-conditional**).

| File | Track | Needs Antigravity? | What it does |
|---|---|---|---|
| `01_druggability_map.R` | 1 | **No** — public APIs only (R + internet; a laptop works) | Open Targets/ChEMBL/Ensembl → `druggability_map.tsv`, ocular-delivery-route lens, every drug row `verify_status`-gated |
| `02_axial_length_MR.R` | 2 | **Yes** — needs axial-length GWAS + OpenGWAS auth | cis-anchored MR vs **axial length** (structural mediator) + high-myopia endpoint → `axial_length_MR_results.csv`, pre-registered interpretation grid |
| `03_eye_tissue_coloc.R` | 3 | **Yes** — needs eye eQTL panel + UKB VCF (local) | Colocalization in retina/RPE (EyeGEx / fetal-RPE) → `eye_tissue_coloc_results.csv`; answers the "blood ≠ eye" critique directly |
| `04_pathway_mechanism.R` | 4 | **Yes** — OpenGWAS auth | Pathway-axis cis-MR (visual-cycle/complement/TGF-β-ECM/Wnt) → `pathway_*.csv`; recasts genes as established axes for mechanistic depth |
| `VALUE_ADD_SECTIONS_draft.md` | 1–4 | — | Revised abstract + 4 subsections + reviewer rebuttals; all numbers are `‹FILL from run›` placeholders |

### Do I need to turn Antigravity on?

- **To build these (done — they're in this repo):** no.
- **To RUN them and get numbers:** Track 1 runs anywhere with R + internet.
  Tracks 2–4 need the PI's sensitive data (eQTLGen, UKB VCF, eye eQTL,
  axial-length GWAS) and OpenGWAS auth, which live only on the PI's machine
  → **Antigravity required for Tracks 2, 3, 4.**

## Run order (on the PI's machine)

1. **Druggability first** (critical path, no data dependency):
   ```r
   Rscript Submit_Manuscript/value_add/01_druggability_map.R
   ```
   → inspect `druggability_map.tsv`; keep only `verify_status==verified` rows.

2. **Axial-length MR** (parallel; resolve data access FIRST — Roadmap 3.1):
   - Set `AL_OUTCOME` or `AL_LOCAL` and confirm `HM_OUTCOME` in `02_axial_length_MR.R`.
   - Export `OPENGWAS_JWT` in the environment (the script refuses to run without it).
   ```r
   Rscript Submit_Manuscript/value_add/02_axial_length_MR.R
   ```
   → if no usable axial-length dataset exists, the script STOPS loudly; ship the
   honest + druggability version without this arm (gate G3 = "No path").

3. **Eye-tissue coloc** (Track 3 — answers "blood ≠ eye"):
   - Resolve an eye eQTL panel (EyeGEx retina / fetal-RPE / neural-adjacent proxy),
     set `eqtl_eye_file` + `EYE_PANEL`, and CONFIRM the genome build vs the anchor
     coordinates in `03_eye_tissue_coloc.R`.
   ```r
   Rscript Submit_Manuscript/value_add/03_eye_tissue_coloc.R
   ```

4. **Pathway-axis MR** (Track 4 — mechanistic depth):
   ```r
   Rscript Submit_Manuscript/value_add/04_pathway_mechanism.R
   ```

5. Fill the `‹FILL›` slots in `VALUE_ADD_SECTIONS_draft.md` from the outputs.

Run order is sequential by design (1 → 2 → 3 → 4), but Track 1 has no data
dependency and can go immediately; 2–4 wait on data access.

## Non-negotiables (mirror GOAL_AND_LOOP_PLAN.md §6)

- No novel-gene / atropine-specific claim. RDH5, CD55 = **positive controls**.
- TGFB1 excluded as a positive (discordant MR direction).
- No fabricated numbers; designs/specs never carry invented results.
- Drug rows: `verify_status=verified` or cut. emixustat = visual-cycle/RPE65-
  adjacent, **not** an RDH5 inhibitor. CD55 lever = downstream complement
  inhibition; CD55 is a Wang-2024 target, **not** a differentiator.
- A null axial-length result is informative, never converted to a positive.

## Security note

Existing CP3 scripts hardcode an `OPENGWAS_JWT` token. These value-add scripts do
**not** — they read it from the environment. Recommend rotating that token and
scrubbing it from history (see chat).
