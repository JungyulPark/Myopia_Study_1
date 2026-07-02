# ANTIGRAVITY REQUEST v3 — actually COMPUTE colocalization for the 11 missing targets

**Why v3:** v2 correctly stopped claiming "coloc failed", but it only *read pre-saved*
coloc for CD55 and marked the other 11 "not_evaluable — no GWAS window data". That is
not true: the **same local data that produced the 113-gene screen's coloc** (full
eQTLGen cis file + UKB `ukb-b-6353` VCF) can compute coloc.abf for these 11 genes too.
They were simply never in the original screen, so no `.rds` existed. **Compute it now**
so the audit is complete and accurate.

## Task
For each of the 11 genes **run `coloc.abf` from scratch** (do NOT just look for a saved
.rds), using the SAME engine/script that produced the 113-gene coloc
(`run_scripts/Stage1_Task1_4b_Coloc_Recalc.R` or `09_coloc_full_local.R`):

Genes (ensembl): CD34 (ENSG00000174059), WNT3 (ENSG00000108379), LCAT (ENSG00000213398),
BTN3A1 (ENSG00000026950), TSSK6 (ENSG00000178093), PRMT6 (ENSG00000198890),
SH3YL1 (ENSG00000035115), ZKSCAN4 (ENSG00000187626), GATS/CASTOR3 (confirm ENSG),
NPAT (ENSG00000149308), UBE (confirm exact ENSG from source paper).

Procedure per gene (identical to the screen):
1. Extract eQTLGen cis SNPs in ±500 kb of the gene TSS (ALL SNPs, not just P<5e-6 —
   coloc uses the full regional signal).
2. Extract UKB ukb-b-6353 regional stats for the same SNPs.
3. Run `coloc.abf` (3 priors: p12 = 1e-5, 1e-6, 5e-6). Record PP.H0/H1/H3/H4.
4. If eQTLGen has **too few cis SNPs** in the region (e.g., a gene not expressed in
   blood, like possibly WNT3), record `coloc_status = "not_evaluable_low_blood_expression
   (n_cis_snps=X)"` — an HONEST, specific reason, distinct from a computed low PP.H4.

## Update `outputs/published_targets_audit.csv`
Fill real `coloc_PP_H1/H3/H4` + `coloc_status` for all 12. Then set
`reproduction_verdict` precisely:
- `reproduced` = coloc PP.H4>0.8 (computed) + replication p<0.05
- `not_reproduced_coloc_low` = coloc **computed**, PP.H4≤0.8  ← now usable for real
- `MR_only` = MR sig, coloc computed but ambiguous (H3/H1 mixed)
- `not_evaluable_blood` = too few blood cis SNPs (state n)
- `no_instrument` = no cis-eQTL at P<5e-6 (but coloc region may still be reported)

## Update `outputs/AUDIT_SUMMARY_v2.txt` → `AUDIT_SUMMARY_v3.txt`
State plainly, now with coloc actually run: of 12 targets, how many have PP.H4>0.8
(reproduced), how many computed-but-low, how many not-evaluable-in-blood. Keep the
tissue caveat (Wang used retina) and method caveat (multi-omics used SMR/mQTL).

## Commit (safe file-copy to Myopia_Study_1)
```bash
git add Submit_Manuscript/value_add/outputs/published_targets_audit.csv Submit_Manuscript/value_add/outputs/AUDIT_SUMMARY_v3.txt Submit_Manuscript/value_add/run_scripts/audit_v3_coloc.R
git commit -m "Audit v3: compute coloc.abf from scratch for the 11 remaining published targets"
git push origin claude/busy-heisenberg-lP58T
```
**Report: how many of the 12 now have coloc actually computed, and the final PP.H4 per
gene. THIS is the number the paper's central claim depends on — it must be real.**
