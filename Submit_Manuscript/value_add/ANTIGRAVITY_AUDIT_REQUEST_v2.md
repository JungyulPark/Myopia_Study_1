# ANTIGRAVITY REQUEST v2 — COMPLETE & FAIR audit (fixes v1 gaps)

**Why v2:** the v1 audit computed colocalization and replication for **only CD55**
(1/12). For the other 11 genes only MR p-values were run, so we CANNOT claim they
"fail colocalization." A fair, publishable audit must actually compute coloc +
replication for **every** gene, use matched tissue where the original study did, and
not conflate method/threshold differences with irreproducibility.

Reuse the local pipeline (eQTLGen + UKB VCF + coloc + CREAM/Tedja/FinnGen). No OpenGWAS.
Overwrite `outputs/published_targets_audit.csv`. Branch: `claude/busy-heisenberg-lP58T`.

## For EVERY one of the 12 genes, compute (not just MR):
1. **cis-MR** vs UKB ukb-b-6353 — already done (keep).
2. **3-prior colocalization** (`coloc.abf`, ±500 kb) — REQUIRED for all. If the cis
   region has too few overlapping SNPs to run coloc, record `coloc = "not_evaluable"`
   (NOT "fail") and say why (n SNPs).
3. **Replication** — CREAM (R/L), Tedja 2018, FinnGen H7_MYOPIA — REQUIRED for all
   genes with an instrument (beta + p each).
4. **Steiger + reverse-MR** — for all.
5. **known-locus flag** — complete it for all (±500 kb GWAS Catalog/Tedja); no "unknown".

## FAIRNESS fixes (critical — reviewers/original authors will check these)
6. **Tissue matching.** Wang 2024 used blood **and retina** eQTL. For each Wang target,
   record which tissue the ORIGINAL nomination used. If a local **retina/RPE eQTL**
   panel is available (EyeGEx GSE115828 / fetal-RPE), ALSO test the target in matched
   tissue and report both. If not available, set `tissue_caveat = "blood-only; original
   used retina — non-reproduction may be tissue-specific"`. Do NOT call a retina-derived
   target "false" from a blood-only test.
7. **Method note.** The multi-omics 2024 targets (PRMT6, SH3YL1, ZKSCAN4, GATS, NPAT,
   UBE) were nominated by **SMR + mQTL/eQTL**, not coloc.abf. Add
   `method_caveat = "original used SMR/mQTL; our eQTL coloc is complementary, not
   identical"`. Frame our test as an independent check, not a refutation of their method.
8. **Instrument threshold.** For WNT3/GATS ("no instrument at P<5e-6"), also report
   whether ANY cis-eQTL exists at a relaxed threshold (e.g., P<5e-5) and what tissue.
   `no_instrument` means "not instrumentable in blood eQTLGen at our threshold", not
   "no genetic effect".

## Output columns (overwrite published_targets_audit.csv)
`gene, ensembl, source_paper, original_tissue, original_method, n_snps, F, mr_beta,
mr_pval, coloc_PP_H1, coloc_PP_H3, coloc_PP_H4, coloc_status(evaluable/not_evaluable),
cream_R_beta, cream_R_pval, tedja_beta, tedja_pval, finngen_or, finngen_pval,
known_locus, steiger_correct, retina_coloc_PP_H4(if run), tissue_caveat, method_caveat,
our_tier, reproduction_verdict`.

`reproduction_verdict` ∈ {reproduced (coloc+replication), MR_only_no_coloc,
not_reproduced_blood (tissue caveat), not_evaluable, no_instrument}.

## Summary → `outputs/AUDIT_SUMMARY_v2.txt`
Counts by reproduction_verdict, and an explicit honest sentence distinguishing
"failed colocalization" (coloc actually run and low) from "colocalization not evaluated
/ not evaluable / tissue-mismatched".

## Commit & push (safe file-copy to Myopia_Study_1 as before)
```bash
git add Submit_Manuscript/value_add/outputs/published_targets_audit.csv Submit_Manuscript/value_add/outputs/AUDIT_SUMMARY_v2.txt
git commit -m "Complete + fair audit v2: coloc+replication for all 12 targets, tissue/method caveats"
git push origin claude/busy-heisenberg-lP58T
```
**Report: for how many targets coloc was actually evaluable, and the verdict breakdown.**
