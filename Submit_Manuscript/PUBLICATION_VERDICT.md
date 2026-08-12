# Publication verdict — read this first

Status as of 2026-08-05, branch `claude/busy-heisenberg-lP58T`.

---

## Verdict — the paper's central result is now established, and it is not what we assumed

`audit_v4.R` has been run to completion with the enlarged panel. The pre-registered gate
**failed** (3/26 established loci recovered, 12%, 95% CI 2–30%), so under the rule fixed
before the data were seen the negative results are reported as **uninformative about
causality, not as non-reproduction.** That much was expected.

What was *not* expected is why. Reading only the "PP.H4 > 0.8" count hid the finding. The
full posterior profile (`12_hypothesis_profile.R`) shows the two groups fail for **opposite
reasons**:

| Dominant hypothesis | Established myopia loci (n=26) | Published nominations (n=22) |
|---|---|---|
| **H3** — both signals present, *different* causal variants | **20 (77%)** | 2 (9%) |
| **H1** — eQTL present, **no myopia signal in the window** | 1 (4%) | **16 (73%)** |
| **H0** — no power | **0 (0%)** | 1 (5%) |
| PP.H4 > 0.8 | 3 (12%) | 1 (5%) |

Fisher P = 2.1 × 10⁻⁶ for the H3 difference; Wilcoxon P = 0.010 on the PP.H4 distributions.

### This corrects an interpretation I gave earlier

I had written that the low PP.H4 values were the signature of an insensitive assay. **That
is not what the data show.** H0 dominance is **0 of 26** at established loci — the pipeline
detects myopia signal wherever it genuinely exists. It is not blind.

Two separable findings replace the earlier one:

1. **Colocalization in blood is a very stringent filter, not a fair test.** Even at loci
   where myopia association is certain, blood expression shares the causal variant in only
   12%; in 77% the causal variants are demonstrably *distinct*. Failing blood colocalization
   is therefore weak evidence against any gene, and must never be reported as refutation.
2. **The nominated loci do not look like established myopia loci.** They show blood eQTL
   signal with essentially no myopia association in the window (H1, 73%), a qualitatively
   different profile from the established set.

### What finding 2 does NOT license

It does **not** establish that the nominations are false. H1 dominance means no myopia
association *in this outcome* — `ukb-b-6353`, self-reported myopia in UK Biobank. The source
studies used other and sometimes better-powered outcomes, and self-report is a lossy
phenotype. **Outcome choice and nomination quality are confounded here and cannot be
separated with these data.** The defensible claim is that the nominations do not replicate
against a large self-reported myopia GWAS, with that caveat stated plainly.

Similarly, the 12% recovery figure is not a property of the assay alone: the positive
controls map each GWAS lead SNP to its **nearest** eQTLGen gene, which is often not the
causal gene, so it is a lower bound.

## What still has to happen before submission

1. **Eye-tissue colocalization.** Now the most valuable remaining analysis, not the least.
   If established myopia loci colocalize in retina where they fail in blood, that converts
   finding 1 from a caution into a demonstrated tissue effect and tells the field what to do
   instead. Needs an eye eQTL dataset — `EyeGEx_retina_eQTL.txt.gz` is **not** on the
   machine (see correction below) and must be obtained.
2. **Disambiguate outcome from nomination quality.** The H1 result is confounded by the use
   of self-reported UK Biobank myopia. Re-running the nominations against a measured
   refractive-error outcome (CREAM/Tedja summary statistics, already used elsewhere in this
   project) would separate "no signal in a lossy phenotype" from "no signal".
3. **Phase 0e third arm** — novelty against the 2026 *Nat Genet* GWAS still needs that
   paper's supplementary variant list.
4. Fill the remaining `‹PENDING›` marker, add the positive-control and posterior-profile
   figures, update Tables 1–2.

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
