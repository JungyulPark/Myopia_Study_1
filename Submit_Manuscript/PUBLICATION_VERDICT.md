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

## What still has to happen before submission

1. **Enlarge the positive-control panel — this is now the binding item.** At n = 5 the
   recovery interval is 1–72%, which is too wide to establish low sensitivity *or* rule it
   out; the central claim rests on it. `audit_v4.R` now derives the panel automatically from
   the local Tedja 2018 locus file by mapping each lead locus to its nearest eQTLGen gene, so
   this costs one more run. Target n ≥ 25 (interval ≈ 7–41%).
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
