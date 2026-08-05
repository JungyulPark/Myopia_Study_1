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
| Records identified — main string (§3) | 125 |
| Records identified — supplementary A (mQTL/methylation/multi-omics) | 9 |
| Records identified — supplementary B (therapeutic target/causal gene/SMR analysis) | 135 |
| Duplicates removed | 16 |
| **Unique records identified** | **253** |
| Metadata unretrievable (PMID 36508524) | 1 |
| Title/abstract screened | 252 |
| Excluded: no myopia/refractive outcome | 21 |
| Excluded: no gene-level cis-eQTL/SMR/coloc nomination | 209 |
| Excluded: pQTL/proteome-wide nomination (method mismatch, appendix) | 3 |
| Excluded: animal-only, functional/cell-model, or review | 10 |
| **Studies included** | **9** |
| **Gene rows extracted** | **24** (12 previously audited + 11 new + 1 tissue-matched corroboration) |

Every one of the 252 records was adjudicated by reading its title, and every plausible
candidate by reading its abstract — **not** by trusting the automated filter, whose
measured sensitivity was only 62.5% (see §6a).

Included studies and the genes each nominates are in
`outputs/published_targets_master.csv`. The two studies audited in v3 are confirmed as
**Qin et al. IOVS 2024;65(10):13** (CD34, CD55, WNT3, LCAT, BTN3A1, TSSK6) and
**Dong et al. Clin Epigenetics 2024;16(1):157** (PRMT6, SH3YL1, ZKSCAN4, GATS, NPAT,
**UBE2I**). Newly identified: CPNE1; BDH1; PDGFRA, LRRTM2, PCOLCE; EPHB4; UTS2, BTBD9,
S100A3, LGALS9; TSPAN10.

### 6a. Why every record was read manually

`09_screening_agreement.R` compares the automated keyword filter against the adjudicated
decision on the 125 round-1 records: Cohen's κ = **0.180** (95% CI −0.087 to 0.448,
"slight"), observed agreement 0.776. The filter **retained only 5 of 8 eligible studies
(sensitivity 62.5%)** and the three it missed include **PMID 39538342 (Dong et al.)** —
one of the two papers this study is auditing.

An automated screen alone would therefore have dropped a core source. Every record in
both rounds was consequently adjudicated by reading, and the filter is reported as a
triage aid only, never as a screening decision.

**Excluded as pQTL/proteome-wide** (listed, not silently dropped): PMID 41718003
(proteome-wide MR, 164 plasma proteins), PMID 39408566 (plasma/brain PWAS), and the
pQTL arm of PMID 41519384 — whose blood-eQTL arm *is* included.

**Resolved (was unresolved):** PMID 40040800 (*Natl Sci Rev* 2024) — full text retrieved
from PMC11879437. It nominates **NFE2L3** p.K617T by whole-exome case–control burden
testing plus knock-in mice, not by cis-eQTL MR/SMR/colocalization → **excluded** under
eligibility criterion 3.

**Tissue-matched study added in round 2:** PMID 31123710 (Orozco et al., *Commun Biol*
2019) colocalizes fetal-RPE e/sQTLs with myopia GWAS. **RDH5** is confirmed by name in the
full text; the remaining myopia colocalization events (3 galactose-, 7 glucose-condition)
have their gene symbols stripped from the retrievable text and are recorded as
**not recoverable — requires publisher Supplementary Data**, not guessed. This is the only
*eye-tissue* eQTL study in the set and directly bears on the blood-only caveat.

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
| 2026-08-05 | Single reader; κ computed against the automated filter instead of a second reader | §5 specifies two independent human readers. κ = 0.180 is reported in §6a, but it measures filter-vs-adjudication agreement, **not** inter-reader agreement, and must never be presented as the latter. Mitigation applied: all 252 records were read rather than filtered. The human second reader remains **OUTSTANDING** and is required before this is described in print as a systematic review; until then it should be called a *systematic search*. |
| 2026-08-05 | Databases: PubMed/MEDLINE only | Embase, Web of Science and Scopus are unreachable from the analysis environment (organisation egress policy). **OUTSTANDING.** Mitigation applied: three complementary PubMed strings were run instead of one (§6), which recovered 128 records the original string missed. Coverage is still narrower than §2 specifies and must be stated as a limitation. |
| 2026-08-05 | Citation chasing performed as targeted supplementary searches rather than reference-list walking | PubMed's related-article link returns word-similarity neighbours (>600 records), not citations, and no citation database is reachable. Two additional search strings were used instead. Formal backward/forward citation chasing is **OUTSTANDING**. |
| 2026-08-05 | Known-locus reference set flagged for update | The novelty audit uses GWAS Catalog + Tedja 2018. The search surfaced a 2026 multi-ancestry refractive-error GWAS (PMID 42009823, *Nat Genet*; n ≈ 1.76 M; 932 variants, 241 new; 23 prioritized genes) that supersedes Tedja 2018 as the reference for "known locus". Novelty calls — including CD55's `not_in_GWAS_Catalog_myopia_500kb` flag — should be re-adjudicated against it. |
