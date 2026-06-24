# M-LIGHT — Elevation value-add package

Executable specs + writing scaffolds that raise the paper from honest-confirmation
(BMC/PLOS tier) toward **TVST / IOVS**, without any novelty or atropine-specificity
overclaim. Driven by `Submit_Manuscript/GOAL_AND_LOOP_PLAN.md` (recommended path
**Option B-lite: druggability-first, axial-length-conditional**).

| File | Roadmap phase | Risk | What it does |
|---|---|---|---|
| `01_druggability_map.R` | Phase 2 | **Low** (public APIs only; runs anywhere) | Open Targets/ChEMBL/Ensembl → `druggability_map.tsv`, ocular-delivery-route lens, every drug row `verify_status`-gated |
| `02_axial_length_MR.R` | Phase 3 | **Access-gated** (needs axial-length GWAS) | cis-anchored MR vs **axial length** + high-myopia endpoint → `axial_length_MR_results.csv`, pre-registered interpretation grid |
| `VALUE_ADD_SECTIONS_draft.md` | Phase 1/2/3 | — | Revised abstract + druggability + axial-length subsections + reviewer rebuttals; all numbers are `‹FILL from run›` placeholders |

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

3. Fill the `‹FILL›` slots in `VALUE_ADD_SECTIONS_draft.md` from the two outputs.

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
