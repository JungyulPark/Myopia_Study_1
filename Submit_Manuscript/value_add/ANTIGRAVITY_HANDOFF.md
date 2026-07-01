# ANTIGRAVITY HANDOFF — M-LIGHT analysis execution brief

**To:** the analysis agent running on the PI's local "Antigravity" machine (has R,
sensitive data, and OpenGWAS auth).
**From:** the writing/spec side (no sensitive data).
**Goal:** run the prepared analyses, return the result CSVs, so the manuscript can
be upgraded to the honest, rigorous version. **You produce numbers; you do not
change the thesis.**

Repo: `github.com/JungyulPark/Myopia_Study_1` · branch `claude/busy-heisenberg-lP58T`
All scripts live in `Submit_Manuscript/value_add/` (and `.../discovery/`).

---

## 0. READ FIRST — the honesty contract (do not violate)

This project was audited and reframed. The paper is a **confirmation-and-methods
paper, not a discovery paper.** When you run analyses and report numbers, hold these
invariants (full list in `Submit_Manuscript/GOAL_AND_LOOP_PLAN.md` §6):

1. **No novel-gene / discovery claim.** RDH5 (known Tedja-2018 locus; published
   fetal-RPE coloc, bioRxiv 446799) and CD55 (a Wang-2024 target, PMC11314700) are
   **positive controls / known biology recovered**, never discoveries.
2. **No "five colocalized anchors."** Only RDH5 (robust) and weakly CD55 survive
   coloc. TGFB1 / CTNNB1 / FBN1 **do not colocalize** (PP.H1=0.944 / PP.H3=0.767 /
   PP.H1=0.702 = distinct variants) → candidate/hypothesis only.
3. **TGFB1 direction is DISCORDANT** (single instrument, r²=0.83 proxy). Exclude as
   a positive; no therapeutic/directional claim.
4. **No atropine-specific causal claim.** Atropine is motivation/narrative only. We
   tested CHRM3 (rs4561483) → myopia and it was **NULL (P=0.40)**; our data does not
   reveal atropine's mechanism or its 0.05%>0.01% dose-response (out of MR scope).
5. **No fabricated numbers.** Every effect size / P / PP comes from your run.
6. **Drug claims verified or cut.** emixustat = visual-cycle/RPE65-adjacent, NOT an
   RDH5 inhibitor; CD55's lever = downstream complement inhibition.
7. **"unverified" ≠ "novel."** A finding is a discovery ONLY if it clears the 4-part
   wall (§4 below).

If any result tempts an overclaim, report it plainly and flag it — do not soften the
honesty rules to fit a nicer story.

---

## 1. Setup (once)

```r
Sys.setenv(OPENGWAS_JWT = "<PI token — do NOT commit>")
install.packages(c("data.table","coloc","susieR","httr","jsonlite","dplyr"))
# remotes::install_github("MRCIEU/TwoSampleMR")
```

### Data to resolve (edit the CONFIG block at the top of each script)

| Dataset | Used by | Notes |
|---|---|---|
| Axial-length GWAS | 02, 09, D1, D3 | PI UKB fields 5201/5202 preferred; else CREAM AL; else Pan-UKBB |
| East-Asian myopia/RE GWAS | 07 | BBJ high-myopia / Asian RE meta; prefer EAS eQTL for instruments |
| Druggable-gene list (gene,ensembl,chr,tss) | D1 | Finan 2017 or Open Targets tractable set |
| Known myopia loci (gene,chr,pos) | D1, 05 | Tedja 2018 + GWAS Catalog (EFO refractive error/myopia) |
| Eye eQTL panel | 03, D4 | EyeGEx retina (GSE115828) / fetal-RPE (bioRxiv 446799) |
| LD reference (1000G EUR) | D2, 08 | PLINK bfile, matched ancestry |
| eQTLGen cis, UKB VCF (ukb-b-6353) | 03, 06, 08, D1 | already on PI machine (CP3/data) |

⚠️ **06 gotcha:** `CP3/results/enhanced_table1_iv_details.csv` holds the OLD gene set
(TGFB1/LATS2/HIF1A/COMT/ADRA2A/CHRM3/LOX) — it does NOT contain RDH5/CD55/CTNNB1/FBN1.
Supply the RDH5/CD55/CTNNB1/FBN1 IV details (+ harmonised `dat` for Egger/Q) for 06.

---

## 2. Run order (do sequentially; each writes a CSV to value_add/)

### Phase A — required honest-paper rigor (do first)
```r
Rscript Submit_Manuscript/value_add/05_novelty_audit.R          # -> novelty_audit_results.csv   [closes Gate G0]
Rscript Submit_Manuscript/value_add/06_mr_robustness_table.R    # -> mr_robustness_consolidated.csv
```

### Phase B — confirmatory value-adds (differentiate from Wang 2024)
```r
Rscript Submit_Manuscript/value_add/01_druggability_map.R       # -> druggability_map.tsv   (no sensitive data)
Rscript Submit_Manuscript/value_add/02_axial_length_MR.R        # -> axial_length_MR_results.csv
Rscript Submit_Manuscript/value_add/03_eye_tissue_coloc.R       # -> eye_tissue_coloc_results.csv
Rscript Submit_Manuscript/value_add/04_pathway_mechanism.R      # -> pathway_*.csv
```

### Phase C — high-value additions
```r
Rscript Submit_Manuscript/value_add/07_east_asian_replication.R # -> east_asian_replication.csv
Rscript Submit_Manuscript/value_add/08_coloc_susie.R            # -> coloc_susie_results.csv
Rscript Submit_Manuscript/value_add/09_axial_mediation.R        # -> axial_mediation_results.csv (after 02)
```

### Phase D — discovery engines (the genuine new-finding sweep; run in this order)
```r
Rscript Submit_Manuscript/value_add/discovery/D3_muscarinic_atropine_target_MR.R  # smallest, on-theme; GJD2=control
Rscript Submit_Manuscript/value_add/discovery/D1_druggable_genome_axial_scan.R    # broad sweep -> discovery_axial_candidates.csv
Rscript Submit_Manuscript/value_add/discovery/D2_finemap_unverified_loci.R        # SuSiE on candidates + unverified loci
```

Each script has a CONFIG block + a pre-registered interpretation/decision gate in its
header. If a dataset is missing, the script tells you what to resolve — don't fake it.

---

## 3. The 4-part novelty wall (a hit is a DISCOVERY only if ALL hold)

1. NOT a known refractive-error/myopia locus (±500 kb of Tedja 2018 / GWAS Catalog) — from 05/D1
2. Colocalizes, PP.H4 > 0.7 (shared causal variant, not LD) — from 03/08/D1
3. Is the SuSiE fine-mapped credible-set gene (not an LD neighbor) — from D2
4. Replicates direction in an independent dataset (EUR + East-Asian) — from 07

- Passes 1 but fails 2–4 → **candidate/hypothesis** (label as such).
- Fails 1 → **recovered known locus** (positive control).
- Nothing passes → **honest null**; the paper ships as the strong confirmation+value-add version.

---

## 4. What to return

Commit the result CSVs to the branch (or send them back), plus a one-paragraph note
per phase: what ran, what was null, what (if anything) cleared the wall, and any
dataset you could not resolve. The writing side will then apply the wall, fill the
`‹FILL›` slots in `VALUE_ADD_SECTIONS_draft.md`, pick the venue (IOVS/OVS if a hit
clears the wall; TVST/BMC if honest null), and rewrite the manuscript.

**Do not edit the manuscript or the honesty rules. Return numbers; flag surprises.**
