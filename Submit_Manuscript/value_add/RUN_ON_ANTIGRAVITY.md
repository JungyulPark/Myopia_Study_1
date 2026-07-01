# RUN ON ANTIGRAVITY — PI command sheet

Everything Claude built that needs the PI's machine to **execute** (sensitive data
+ OpenGWAS auth live only there). Claude has written all scripts; you run them and
paste the result CSVs back, and Claude fills the manuscript and applies the
novelty/honesty wall. **Numbers come only from these runs — nothing is invented.**

## 0. One-time setup (do first)

```r
# in R, every session:
Sys.setenv(OPENGWAS_JWT = "<your token>")   # do NOT commit this
# packages (once):
install.packages(c("data.table","coloc","susieR","httr","jsonlite","dplyr"))
# remotes::install_github("MRCIEU/TwoSampleMR")
```

Resolve these data paths (edit the CONFIG block at the top of each script):

| Dataset | Used by | Suggested source |
|---|---|---|
| Axial-length GWAS | D1, D3, 02 | UKB fields 5201/5202 (your GWAS) ▸ best; else CREAM AL; else Pan-UKBB |
| Druggable-gene list (gene,ensembl,chr,tss) | D1 | Finan 2017 Sci Transl Med; or Open Targets tractable set |
| Known myopia loci (gene,chr,pos) | D1 | Tedja 2018 + GWAS Catalog (EFO refractive error/myopia) |
| Eye eQTL panel | 03, D4 | EyeGEx retina (GSE115828); fetal-RPE (bioRxiv 446799) |
| LD reference (1000G EUR) | D2 | PLINK bfile, matched ancestry |
| eQTLGen cis, UKB VCF | 03, D1 | already on your machine (CP3/data) |

---

## 1. CONFIRMATORY value-adds (raise rigor / differentiate from Wang 2024)

```r
# Track 1 — druggability map (NO sensitive data; could even run on a laptop)
Rscript Submit_Manuscript/value_add/01_druggability_map.R
#   -> druggability_map.tsv      (keep verify_status==verified rows only)

# Track 2 — axial-length MR of the 5 anchors  (set AL_OUTCOME / AL_LOCAL first)
Rscript Submit_Manuscript/value_add/02_axial_length_MR.R
#   -> axial_length_MR_results.csv

# Track 3 — eye-tissue colocalization  (set eqtl_eye_file + EYE_PANEL; CHECK build)
Rscript Submit_Manuscript/value_add/03_eye_tissue_coloc.R
#   -> eye_tissue_coloc_results.csv

# Track 4 — pathway/mechanism axes
Rscript Submit_Manuscript/value_add/04_pathway_mechanism.R
#   -> pathway_mr_per_gene.csv, pathway_axis_summary.csv
```

## 1b. REQUIRED + HIGH-VALUE analyses (honest-paper rigor)

```r
# 05 — Novelty audit (public APIs; runs anywhere w/ internet). Fill lead SNPs from
#      CP3/results/enhanced_table1_iv_details.csv first. Closes Gate G0.
Rscript Submit_Manuscript/value_add/05_novelty_audit.R          # -> novelty_audit_results.csv

# 06 — Consolidated MR robustness table. NOTE: enhanced_table1_iv_details.csv holds
#      the OLD gene set (TGFB1/LATS2/HIF1A/COMT/ADRA2A/CHRM3/LOX) — supply the
#      RDH5/CD55/CTNNB1/FBN1 IV details + harmonised dat for the Egger/Q columns.
Rscript Submit_Manuscript/value_add/06_mr_robustness_table.R    # -> mr_robustness_consolidated.csv

# 07 — East-Asian ancestry replication (set EAS_OUTCOME; prefer EAS eQTL instruments)
Rscript Submit_Manuscript/value_add/07_east_asian_replication.R # -> east_asian_replication.csv

# 08 — coloc-SuSiE upgrade (multiple causal variants; reuse D2 LD provider)
Rscript Submit_Manuscript/value_add/08_coloc_susie.R            # -> coloc_susie_results.csv

# 09 — Axial-length mediation (run AFTER Track 2; two-step MR / MVMR)
Rscript Submit_Manuscript/value_add/09_axial_mediation.R        # -> axial_mediation_results.csv
```

## 2. DISCOVERY engines (the genuine new-finding sweep — run in THIS order)

```r
# D3 FIRST — muscarinic / atropine-target MR vs axial length (smallest, on-theme)
Rscript Submit_Manuscript/value_add/discovery/D3_muscarinic_atropine_target_MR.R
#   -> D3_muscarinic_MR_results.csv      (GJD2 = known positive-control check)

# D1 — druggable-genome MR scan vs axial length (broad sweep; set DRUGGABLE_LIST,
#      AL_FILE, KNOWN_LOCI). Heaviest run.
Rscript Submit_Manuscript/value_add/discovery/D1_druggable_genome_axial_scan.R
#   -> D1_axial_scan_all.csv, discovery_axial_candidates.csv

# D2 — SuSiE fine-map the candidates + unverified Tier-2 loci (set LOCI_FILE,
#      GWAS_FILE, LD reference). Put D1 candidates into finemap_loci.tsv first.
Rscript Submit_Manuscript/value_add/discovery/D2_finemap_unverified_loci.R
#   -> D2_finemap_results.csv

# (D4) re-run Track 3 eye-tissue coloc on any D1 candidate gene for tissue confirmation
```

## 3. The novelty/honesty wall — a hit is a DISCOVERY only if ALL hold

1. NOT a known refractive-error/myopia locus (±500 kb of Tedja 2018 / GWAS Catalog)
2. Colocalizes (PP.H4 > 0.7) — shared causal variant, not LD
3. Is the SuSiE fine-mapped credible-set gene (D2), not an LD neighbor
4. Replicates direction in an independent dataset (or flagged "needs replication")

- Passes 1 but fails 2–4 → **candidate / hypothesis** (reported as such).
- Fails 1 → **recovered known locus** (positive control).
- Nothing passes → **honest null**; ship the strong confirmation + value-add paper.

## 4. Hand back to Claude

Paste (or commit) the result CSVs. Claude will: apply the wall, fill the `‹FILL›`
slots in `VALUE_ADD_SECTIONS_draft.md` + `discovery/` results, decide the venue
(IOVS/OVS if a hit clears the wall; TVST/BMC if honest null), and draft Results/
Discussion + cover letter.

> Reminder (do-not-regress): no fabricated numbers; TGFB1 excluded as a positive
> (discordant); drug rows verified-or-cut; a null axial result is informative, not
> converted to a positive; "unverified" ≠ "novel".
