# Pre-registered literature search protocol — systematic audit of genetically-nominated myopia targets

> **Register this before running the search.** The single biggest reviewer objection to the
> current draft is *"why only 12 targets from two papers?"* A pre-specified, reproducible
> search converts an ad-hoc sample into a systematic assessment. Reported per PRISMA 2020.
>
> Status: **EXECUTED 2026-08-05** (PubMed/MEDLINE only, single reader). Counts in §6;
> departures from this protocol recorded in §10 — two of them are outstanding.

---

## 1. Question

Among genes nominated as causal or druggable myopia targets by published Mendelian
randomization / eQTL studies, **what proportion show evidence of a shared causal variant
(colocalization) with myopia, and independent replication, when re-tested under a single
uniform standard?**

## 2. Databases and date

- PubMed/MEDLINE, Embase, Web of Science, Scopus.
- Search executed on: **2026-08-05**. Coverage: inception → execution date.
- **Actually searched: PubMed/MEDLINE only** — see §10.
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

## 6. PRISMA flow (executed 2026-08-05)

Executed via the PubMed E-utilities MCP interface. Records were screened by the
automated eligibility filter in `screen1.csv`, then every candidate was adjudicated by
reading its title and abstract.

| Stage | n |
|---|---|
| Records identified (main string) | 125 |
| Records identified (supplementary mQTL/methylation/multi-omics string) | 9 |
| Duplicates removed | 1 |
| Title/abstract screened | 133 |
| Excluded: no myopia/refractive outcome | 21 |
| Excluded: no gene-level cis-eQTL/SMR/coloc nomination | 95 |
| Excluded: pQTL/proteome-wide nomination (method mismatch, appendix) | 3 |
| Excluded: animal-only or functional/cell-model | 5 |
| Unresolved (abstract unavailable, needs full text) | 1 |
| **Studies included** | **8** |
| **Unique genes extracted** | **23** (12 previously audited + 11 new) |

Included studies and the genes each nominates are in
`outputs/published_targets_master.csv`. The two studies audited in v3 are confirmed as
**Qin et al. IOVS 2024;65(10):13** (CD34, CD55, WNT3, LCAT, BTN3A1, TSSK6) and
**Dong et al. Clin Epigenetics 2024;16(1):157** (PRMT6, SH3YL1, ZKSCAN4, GATS, NPAT,
**UBE2I**). Newly identified: CPNE1; BDH1; PDGFRA, LRRTM2, PCOLCE; EPHB4; UTS2, BTBD9,
S100A3, LGALS9; TSPAN10.

**Excluded as pQTL/proteome-wide** (listed, not silently dropped): PMID 41718003
(proteome-wide MR, 164 plasma proteins), PMID 39408566 (plasma/brain PWAS), and the
pQTL arm of PMID 41519384 — whose blood-eQTL arm *is* included.

**Unresolved:** PMID 40040800 (*Natl Sci Rev* 2024, multi-omics variant in choroidal
vasculature in high myopia) — PubMed carries no abstract; full text required before it
can be included or excluded.

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

| Date | Deviation | Reason |
|---|---|---|
| 2026-08-05 | Added `mQTL`, `methylation`, `multi-omics`, `multiomics` to the search string as a supplementary query | The §3 string missed studies indexed under methylation/multi-omics wording. The supplementary query returned 9 records, 8 of them not in the main 125. This is a real sensitivity gap and the combined string should be used in any re-run. |
| 2026-08-05 | `SMR[Title/Abstract]` treated as ambiguous and adjudicated manually | **SMR** denotes both *summary-data-based Mendelian randomization* and *standardized mortality ratio*. It pulled in unrelated papers from 1983, 1996, 1998 and 1999. Either pair it with a myopia-genetics term or replace it with the spelled-out phrase. |
| 2026-08-05 | Single reader (no second screener, no κ) | §5 specifies two independent readers. This execution had one. The screening decisions are reproducible from `screen1.csv` plus the recorded abstracts, but the protocol's inter-rater step is **outstanding** and must be completed before the systematic claim is made in print. |
| 2026-08-05 | Databases: PubMed/MEDLINE only | Embase, Web of Science and Scopus were not searched — they are not reachable from the analysis environment. Coverage is therefore narrower than §2 specifies and must be stated as a limitation or completed elsewhere. |
