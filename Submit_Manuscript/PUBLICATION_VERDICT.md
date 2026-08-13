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

### Raw-output verification (re-checked against the committed CSVs)

| Check | Result |
|---|---|
| Row counts | 52 rows; evaluable 12 audited + 10 new + 26 controls; 4 `absent_from_eqtlgen` (CASTOR3, LRRTM2, GJD2, RBFOX1) |
| Are the 3 recovered controls independent? | Yes — chr12, chr8, chr7, three different chromosomes |
| Do control gene names look like real assignments? | Mostly. 3 of 26 are clone/lncRNA/orf identifiers, and **one of them (RP11-333A23.4, PP.H4 = 0.96) is among the three "recoveries"** — so only **2 of 26** recoveries are biologically interpretable (RDH5, AEBP1) |
| Is the H3 comparison independent of gene identity? | Yes. H3/H4 dominance only reflects whether a myopia signal exists in the window, not which gene is causal — so it is unaffected by nearest-gene error |
| PDGFRA H0 | Correct, not a bug: lead eQTL *P* = 1.1 × 10⁻³, a genuinely weak instrument |

The headline comparison is therefore the one that survives every caveat:

> **Myopia signal detected in the window: 23 of 26 established loci (88%) vs 5 of 22
> nominations (23%).**

This uses only "is there a myopia association here", so nearest-gene misassignment, lncRNA
names and the choice of PP.H4 threshold cannot touch it. The 12% *recovery* figure, by
contrast, is fragile on all three counts and should be reported as a lower bound with the
gene-assignment caveat attached.

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

## Measured-refraction resolution — ATTEMPTED AND ABANDONED (2026-08-05)

The confound behind the H1 result was pursued and could not be closed with available data.
Recorded here so it is not silently retried.

- The analysis environment reaches no GWAS host. Nature/Springer, OpenGWAS, EBI, Zenodo,
  figshare, NCBI, Dropbox, Google Drive and Google Docs were each tested directly and all
  return a policy denial; GitHub is reachable but scoped to this repository, so no external
  file can be fetched here by any route.
- A transfer path was therefore built and proven end to end: `14_extract_outcome_windows.R`
  subsets any summary-statistics file to the 58 one-megabase windows the analysis actually
  reads (~0.4 MB, committable), and `13_measured_refraction_coloc.R` consumes it and
  re-runs the self-report arm on identical SNPs so the comparison is like-for-like.
- The only measured-refraction file on the analysis machine is
  `Tedja2018_Stage3_sumstats.txt`. It extracted cleanly — METAL format, beta/se derived
  from Z, sample size and frequency; coordinates matched by rsID, so build mismatch was
  impossible; 147,273 SNPs matched, 55 windows, median 274 SNPs each — **and is
  nonetheless unusable**: median P = 0.000, P < 0.05 in 100% of SNPs, λ = 30.7. A stage-3
  file contains only variants already carried forward for showing association.
  Colocalization identifies a causal variant by contrast against surrounding nulls; with no
  nulls the contrast is gone and PP.H3/PP.H4 are arbitrary while still looking confident.
- A preliminary reading taken from that file before the check — 45% of nomination windows
  carrying genome-wide significant signal versus 92% of controls — is **retracted**. Those
  proportions are an artefact of SNP selection.
- Pursuit stopped here at the PI's decision. The scripts remain and will run unchanged the
  moment genome-wide measured-refraction statistics are available; `14` now refuses any
  selection-enriched file (λ > 5 or over half the SNPs nominally significant).

**Consequence for the paper: none fatal.** The confound is now stated as the principal
limitation rather than resolved. The H1 result is reported as outcome-specific, with no
claim about whether the nominations are correct.

## What still has to happen before submission

1. **Eye-tissue colocalization** — still the analysis that would most raise the paper's
   tier, and still needs an eye eQTL dataset that is not on the machine.
2. **Phase 0e third arm** — novelty against the 2026 *Nat Genet* GWAS needs that paper's
   supplementary variant list.
3. Fill the remaining `‹PENDING›` marker, add the positive-control and posterior-profile
   figures, update Tables 1–2.
4. Optional, if data ever becomes available: the measured-refraction re-run above.

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
