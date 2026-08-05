# Pre-registered literature search protocol — systematic audit of genetically-nominated myopia targets

> **Register this before running the search.** The single biggest reviewer objection to the
> current draft is *"why only 12 targets from two papers?"* A pre-specified, reproducible
> search converts an ad-hoc sample into a systematic assessment. Reported per PRISMA 2020.
>
> Status: **DRAFT — not yet executed.** Fill the counts and the date at execution.

---

## 1. Question

Among genes nominated as causal or druggable myopia targets by published Mendelian
randomization / eQTL studies, **what proportion show evidence of a shared causal variant
(colocalization) with myopia, and independent replication, when re-tested under a single
uniform standard?**

## 2. Databases and date

- PubMed/MEDLINE, Embase, Web of Science, Scopus.
- Search executed on: `‹DATE›`. Coverage: inception → execution date.
- No language restriction; no date restriction.

## 3. Search string (PubMed syntax; adapt per database)

```
(myopia[Title/Abstract] OR "refractive error"[Title/Abstract] OR
 "axial length"[Title/Abstract] OR "spherical equivalent"[Title/Abstract])
AND
("Mendelian randomization"[Title/Abstract] OR "Mendelian randomisation"[Title/Abstract]
 OR "summary-data-based Mendelian randomization"[Title/Abstract] OR SMR[Title/Abstract]
 OR colocali*[Title/Abstract] OR "expression quantitative trait"[Title/Abstract]
 OR eQTL[Title/Abstract] OR "drug target"[Title/Abstract]
 OR "druggable genome"[Title/Abstract] OR transcriptome-wide[Title/Abstract])
```
Supplemented by backward/forward citation chasing of all included records.

## 4. Eligibility

**Include** a study if all hold:
1. Human study with a myopia or refractive-error outcome (binary myopia, high myopia,
   spherical equivalent, or axial length).
2. It nominates **named gene-level targets** as causal/druggable.
3. Nomination is based on **cis-eQTL Mendelian randomization, SMR, or colocalization**
   (method-matched to our eQTLGen-based re-test).
4. Peer-reviewed primary research (preprints recorded separately, in a sensitivity set).

**Exclude**, recording the reason:
- **pQTL / proteome-wide nominations** (e.g. plasma-protein MR studies). *Justification:*
  our re-test uses blood **eQTL** instruments; re-testing a pQTL-nominated protein with
  eQTL is a method mismatch and a non-reproduction would be uninterpretable. These studies
  are listed in an appendix as an acknowledged gap, not silently dropped.
- Nominations of variants/loci without a specified gene.
- Non-gene exposures (lifestyle, biomarkers, education, sleep).
- Reviews, commentary, conference abstracts without extractable target lists.
- Animal-only studies.

## 5. Screening and extraction

- Title/abstract screening then full-text screening, **two independent readers**,
  disagreements resolved by discussion. Record κ.
- From each included study extract, into `outputs/published_targets_master.csv`:
  `gene_symbol, ensembl_id, source_study, pmid_doi, original_tissue, original_method,
  original_effect_direction, original_evidence (coloc PP / SMR P / HEIDI), claim_strength`.
- **Gene identity is resolved against the source publication, not from memory.** Ambiguous
  or non-standard symbols are queried back to the paper; if unresolvable, the gene is
  reported as "symbol ambiguous — not auditable" rather than guessed.
  *(This rule exists because the first pass mis-resolved "UBE" — the source gene is
  **UBE2I** — and mis-attributed Qin et al. 2024 as "Wang et al.")*

## 6. PRISMA flow (fill at execution)

| Stage | n |
|---|---|
| Records identified | ‹ › |
| Duplicates removed | ‹ › |
| Title/abstract screened | ‹ › |
| Full texts assessed | ‹ › |
| Studies included | ‹ › |
| Excluded: pQTL-based | ‹ › |
| Excluded: other reasons | ‹ › |
| **Unique genes extracted** | ‹ › |

Known to be included at protocol time (already audited): Qin et al. *IOVS* 2024;65(10):13
(CD34, CD55, WNT3, LCAT, BTN3A1, TSSK6); multi-omics *Clin Epigenetics* 2024
(PRMT6, SH3YL1, ZKSCAN4, GATS, NPAT, UBE2I).

## 7. Uniform re-test (identical for every extracted gene)

Run with the existing local pipeline — `run_scripts/audit_v3_coloc.R`, local eQTLGen +
`ukb-b-6353.vcf.gz`, **no OpenGWAS**:
1. cis-eQTL instruments (±1 Mb of TSS, *P* < 5 × 10⁻⁶, LD-clumped r² < 0.001), F-statistic.
2. Two-sample MR vs UK Biobank myopia; Steiger filtering; reverse MR.
3. `coloc.abf` over the ±500 kb window under **three priors**
   (p₁ = p₂ = 1 × 10⁻⁴; p₁₂ = 1 × 10⁻⁵, 1 × 10⁻⁶, 5 × 10⁻⁶); report PP.H0–PP.H4 in full.
4. Replication: CREAM, Tedja 2018, FinnGen H7_MYOPIA.
5. Known-locus flag vs GWAS Catalog + Tedja 2018 (±500 kb).
6. **Evaluability annotation**: n cis-SNPs in the window and instrument strength, so
   "no colocalization" is distinguishable from "no power to test colocalization".

## 8. Positive-control panel (pre-specified — the calibration anchor)

The same pipeline is run on established myopia GWAS loci: **GJD2, LAMA2, KCNQ5, ZMAT4,
RBFOX1, BMP3**, with **RDH5** as an internal benchmark (already PP.H4 = 0.991).

**Pre-registered interpretation rule:** if the positive-control panel does not recover a
substantial fraction of established loci at PP.H4 > 0.8, then blood-eQTL colocalization is
demonstrably insensitive in this setting and **the audit's negative findings must be
reported as uninformative rather than as non-reproduction.** This rule is fixed in advance
so the conclusion cannot be chosen after seeing the result.

## 9. Analysis and reporting

- Primary outcome: proportion of nominated genes reaching PP.H4 > 0.8 **and** nominal
  replication, with an exact binomial 95% CI.
- PP.H4 reported as a **continuum**, not only dichotomized; the 0.8 cut is presented as a
  convention and its sensitivity shown (several genes sit near it — TSSK6 0.782,
  SH3YL1 0.748).
- Multiple-testing statement for the audit set, separate from the 113-gene screen.
- Non-reproduction claims scoped to a **uniform blood-eQTL standard**; tissue (retinal eQTL
  in the source studies) and method (SMR/mQTL) differences reported per gene.

## 10. Deviations

Any departure from this protocol after execution is recorded here with its reason.

| Date | Deviation | Reason |
|---|---|---|
| | | |
