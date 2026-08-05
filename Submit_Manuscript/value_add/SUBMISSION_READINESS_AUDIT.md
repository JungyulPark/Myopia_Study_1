# SUBMISSION READINESS AUDIT — final pre-submission check

Audited: manuscript (424 lines, ~3,540 words), verified outputs, 5 figures.
**Verdict: NOT yet submittable. 8 defects — 3 are blocking accuracy/integrity issues.**

---

## 🔴 BLOCKING — accuracy / integrity (must fix; reviewers or original authors will catch)

### B1. PRMT6 — internal contradiction between MR and coloc
`published_targets_audit.csv`: PRMT6 has **n_snps = 3, F = 2465, MR P = 1.9×10⁻⁴** (so it
WAS instrumented), yet `coloc_status = "not_evaluable_low_blood_expression (n_cis_snps=0)"`.
Both cannot be true — if 3 cis-eQTLs pass P<5×10⁻⁶, the cis window is not empty.
**Manuscript currently states** (§3.0): *"the other three (PRMT6, GATS, UBE) had no
cis-eQTL in blood and could not be instrumented"* — **factually wrong for PRMT6.**
→ Fix: re-run PRMT6 coloc (likely a gene-ID/window lookup bug in `audit_v3_coloc.R`),
or, if truly not evaluable, explain why a gene with 3 instruments has an empty coloc
window. Correct the manuscript sentence either way.

### B2. CD55 "established refractive-error locus" — contradicted by our own data
The audit table flags CD55 `known_locus = "not_in_GWAS_Catalog_myopia_500kb"` (NOT a
catalogued myopia locus), but the earlier 05 novelty audit called CD55
`known_locus_positive_control = TRUE`, and the **manuscript asserts CD55 is an
"established refractive-error locus" in 4 places** (lines 43, 268, 287, 350).
→ Resolve which is correct. Most defensible statement: *CD55 is not a catalogued
GWAS myopia locus but was previously nominated as an MR drug target (Wang 2024)* —
so it is "previously reported", not "an established locus". Fix all 4 sentences.

### B3. Gene-identity verification for ambiguous symbols
`UBE` is **not a standard gene symbol**; the audit assigned ENSG00000198954, and `GATS`
(CASTOR3) was assigned ENSG00000197256 — neither verified against the source paper.
An audit that mis-maps a gene is indefensible.
→ Confirm each of the 12 ensembl IDs against the source publications; drop or relabel
any that cannot be resolved (report as "symbol ambiguous — not auditable").

---

## 🟠 REQUIRED — completeness (paper cannot be submitted without these)

### B4. References are entirely missing
8 open citation slots (`‹ref›`) plus an empty References section. Needed at minimum:
Holden 2016, Tedja 2018, ATOM/LAMP, Wang 2024 (PMC11314700), multi-omics 2024
(PMC11562087), eQTLGen (Võsa 2021), coloc (Giambartolomei 2014), FinnGen (Kurki 2023),
CREAM, TwoSampleMR (Hemani 2018), Steiger, PhenoScanner.

### B5. No Figure/Table citations in the text
The Results section never cites "Figure 1–5" or "Table 1–2". Every journal requires
in-text callouts at the point each result is described.

### B6. No figure legends
Only a placeholder list exists. Each of the 5 figures needs a full caption (what is
plotted, cohorts, thresholds, abbreviations, and — for Fig 5 — the blood-eQTL scope).

### B7. Two unresolved data facts
- FinnGen H7_MYOPIA exact case/control N (`‹confirm from summary-stats header›`)
- `‹CHECK 113 matches results row count›` (verified as 113 rows — just delete the flag)

### B8. Figure defects (from the figure audit)
Fig1 text overflow (new script written, **not yet run**), Fig3 error-bar too thick +
legend clipped, Fig4 threshold label overlaps the line, **Fig5 subtitle says
"false-positives" — an overclaim contradicting our own Limitations**, Fig2 subtitle
overstates CD55 replication.

---

## 🟡 WEAKNESSES reviewers will raise (not blocking, but must be pre-empted in the text)

1. **The audit covers only 12 targets from 2 papers.** This is not a systematic review,
   so "most published myopia MR targets fail" over-generalizes. → Either state the scope
   explicitly ("two recent drug-target/multi-omics MR studies") or expand the search
   systematically (PubMed sweep for myopia MR target papers) and audit all nominations.
2. **PP.H4 > 0.8 threshold is arbitrary**, and TSSK6 (0.782) / SH3YL1 (0.748) sit just
   below it. A reviewer will ask why 0.8. → Report as a continuum, show the sensitivity,
   and avoid binary "reproduced/failed" language for borderline genes.
3. **CD55's own colocalization is prior-sensitive** (0.801 default → 0.287 under one
   prior). Calling it "reproduced" while calling others "failed" is inconsistent unless
   the prior sensitivity is stated in the same breath.
4. **Blood-only tissue scope** — already owned in Limitations, but it genuinely caps the
   strength of every non-reproduction claim.
5. **No multiple-testing correction is described for the 12-target audit** (Bonferroni
   was applied only to the 113-gene screen).

---

## VERDICT

**Submittable after B1–B8 are fixed. Not before.** B1 and B2 are factual errors in the
current text; submitting with them risks a correction or a hostile review from the
authors whose work is being audited.

Realistic target after fixes: **Genes (MDPI)**, **Frontiers in Genetics**, or **BMC
Medical Genomics** — the contribution is a competent, honest, negative/corrective
reproducibility audit, incremental rather than landmark.

**Estimated remaining work:** references + legends + in-text callouts (writing, ~1 day),
PRMT6/CD55/gene-ID reconciliation (analysis, short), figure regeneration (5 scripts).
