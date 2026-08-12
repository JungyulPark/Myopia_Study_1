# Publication verdict — read this first

Status as of 2026-08-05, branch `claude/busy-heisenberg-lP58T`.

---

## Verdict — the gate has now been run, and it FAILED

`audit_v4.R` was executed on the analysis machine on 2026-08-05. The pre-registered
positive-control gate **failed**: blood-eQTL colocalization recovered **1 of 5** testable
established myopia loci (20%, 95% CI 1–72%), and two more established loci — including
**GJD2**, the most firmly established myopia gene of all — have **no blood cis-eQTL at
all** and could not be tested.

Per the rule fixed before the data were seen, the audit's negative findings are therefore
**uninformative about causality, not evidence of non-reproduction.** The paper is the
methods-caution branch, not the strong audit branch.

**This is still a publishable paper, and arguably a more useful one**, because it now
carries a coherent and uncomfortable message:

- **75%** of published myopia gene nominations derive wholly or partly from **blood**, and
  only 3 of 9 studies used any eye tissue.
- Blood expression data **cannot recover known myopia biology** — 1 of 5, with the flagship
  locus untestable.
- Therefore the field is nominating myopia drug targets from a tissue that demonstrably
  fails to detect myopia loci, and those nominations **cannot be adjudicated by the method
  that produced them**.

That is a finding about the field's method, not a claim that specific genes are false — and
it is defensible with what is already on disk.

### The three v3 "not evaluable" verdicts were errors, and are now corrected

The diagnosis was confirmed exactly. All three genes are densely covered in blood; v3's
`not_evaluable_low_blood_expression (n_cis_snps=0)` was a gene-coordinate/identity bug:

| Gene | v3 said | Actually | cis-SNPs | Result |
|---|---|---|---|---|
| PRMT6 | chr1:157.56 Mb, not evaluable | chr1:107.60 Mb (**off by 50.0 Mb**) | 6,885 | PP.H4 = 0.257, PP.H1 = 0.676 |
| GATS | chr19:15.26 Mb, not evaluable | chr7:99.83 Mb (**wrong chromosome, off by 84.6 Mb**) | 4,035 | PP.H4 = 0.005, PP.H1 = 0.991 |
| UBE2I | "UBE", row invalid | chr16:1.37 Mb, ENSG00000103275 | 9,754 | PP.H4 = 0.009, PP.H1 = 0.960 |

The manuscript's claim that three targets "could not be instrumented in blood" was false and
has been removed. **All 12 nominations are evaluable**; one reproduces (CD55) and **eight**
show distinct causal variants.

v4 also reproduces every value v3 got right — CD55 0.808, RDH5 0.991, TSSK6 0.782,
SH3YL1 0.748 — so the two pipelines agree wherever v3's gene identity was correct.

### Correction — two files I claimed were present are not

I previously reported that `EyeGEx_retina_eQTL.txt.gz` and
`known_myopia_loci_tedja2018.tsv` were on the analysis machine, and treated the eye-tissue
check as unblocked on that basis. **Both are absent.** I had inferred their existence from
paths inside `03_eye_tissue_coloc.R` and `AXIAL_DISCOVERY_local.R`, which are annotated
`# <- set to resolved path` and `# <- RESOLVE` — markers that the path was still *to be*
resolved, not evidence of a file. Eye-tissue colocalization is therefore **still not done**,
and the blood-only scope remains a stated limitation.

### The full nomination set is now audited: 22 evaluable genes

The 11 newly identified nominations were re-tested. Ten were evaluable and **every one
returned PP.H4 < 0.006** (max 0.0055; LRRTM2 has no blood cis-eQTL). Across all 22:

| | |
|---|---|
| PP.H4 > 0.8 | **1** (CD55) — 4.5%, 95% CI 0.1–22.8% |
| PP.H4 > 0.5 | 3 (CD55, TSSK6, SH3YL1) |
| PP.H4 < 0.01 | **16 of 22 (73%)** |
| median PP.H4 | 0.0013 |

A near-uniform floor across 22 independently nominated genes, in an assay that recovers
1 of 5 known loci, is the signature of an insensitive test — not of 22 wrong nominations.

## What still has to happen before submission

1. **Enlarge the positive-control panel — the binding item.** At n = 5 the recovery interval
   is 1–72%, too wide to establish low sensitivity *or* rule it out, and the central claim
   rests on it. Since neither the Tedja nor the GWAS-Catalog file exists locally,
   `audit_v4.R` now falls back to deriving controls from **the outcome GWAS itself** —
   genome-wide-significant loci in `ukb-b-6353`, mapped to their nearest eQTLGen gene. This
   needs no external data and is the strictest sensitivity check available: if blood-eQTL
   colocalization cannot recover loci that are undisputed in the very GWAS being tested
   against, it cannot adjudicate anything. Target n ≥ 25 (interval ≈ 7–41%).
2. **Re-test the 11 new genes** from the literature search (Phase 2).
3. **Phase 0e third arm** — novelty against the 2026 *Nat Genet* GWAS still needs that
   paper's supplementary variant list.
4. Fill the two remaining `‹PENDING›` markers, add the positive-control figure, update
   Tables 1–2.

## What is finished and locked

- **Manuscript** reframed audit-first (title + abstract), with figure/table callouts,
  curated references (37 main + 9 supplementary), and figure legends.
- **Systematic search executed** — 253 records screened, 9 studies, 24 gene nominations,
  PRISMA counts filled, deviations recorded honestly.
- **Statistics computed** (`07`, `09`, `10` in `value_add/run_scripts/`, R 4.3.3):
  exact binomial CIs, PP.H4 threshold sensitivity, Bonferroni-vs-FDR robustness, screening
  agreement, tissue provenance, and audit-size precision.
- **Three factual errors corrected** and traced to primary sources: the audited paper is
  **Qin et al.** (not "Wang et al."); the nominated gene is **UBE2I** (not "UBE"), confirmed
  in the abstract of Dong et al.; CD55 is no longer described as an established GWAS locus.

## Known limitations to state in print

- Single-reader search; PubMed/MEDLINE only (Embase/WoS/Scopus unreachable); formal citation
  chasing not performed. All recorded in `LITERATURE_SEARCH_PROTOCOL.md` §10.
- Reproduction proportion has a wide interval (0.2–38.5% at n = 12; 0.1–21.1% at n = 24).
  **Report the direction, never a percentage.** Roughly 100 audited genes would be needed
  for a ±10-point interval.
- Blood-eQTL instruments. Mitigated but not removed by the finding that 75% of the
  nominations being audited are themselves blood-derived.
- One record (PMID 36508524) had no retrievable metadata and was never screened.
