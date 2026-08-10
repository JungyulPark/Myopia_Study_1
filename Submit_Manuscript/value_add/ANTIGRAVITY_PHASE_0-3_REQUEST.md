# ANTIGRAVITY REQUEST — run one script

**`Rscript run_scripts/audit_v4.R`** — that is the whole request. The script is written
and verified; it covers Phases 0, 0e, 2 and 3 in a single run. The sections below explain
what it does and what to report back.

Set `MYOPIA_ROOT` if the repo is not at `C:/Projectbulid/Myopia`. Start with
`Rscript run_scripts/audit_v4.R --check-only` — it prints the identity/coordinate
diagnostics in seconds without touching coloc, and that alone answers Phase 0.

### What was already verified here (R 4.3.3, no project data required)
- Parses cleanly.
- End-to-end run on synthetic data: a shared causal variant returns PP.H4 = 1.000, a
  distinct causal variant returns PP.H4 = 0.000, sparse genes are separated out, and the
  positive-control gate reports correctly when it cannot be assessed.
- The base-R `coloc.abf` fallback (used only if the `coloc` package is missing) passes all
  five known-answer scenarios in `run_scripts/11_validate_coloc.R`, posteriors summing to
  1 within 1.6e-15.

### The PRMT6 diagnosis — read this before re-running anything
v3 chose the coloc window with `Gene == ensembl & SNPChr == chr & abs(SNPPos - tss) <= 5e5`
while MR selected instruments by gene ID alone. **A wrong chr/tss therefore yields exactly
the reported signature: instruments present, coloc window empty,
`not_evaluable_low_blood_expression (n_cis_snps=0)`.** All three v3 not-evaluable genes are
the three with suspect identity — PRMT6 (declared chr1:157.6 Mb; PRMT6 is at 1p13.3), GATS
(declared chr19; GATS/CASTOR3 is chr7q11.23) and "UBE" (not a real symbol; the source gene
is UBE2I). So that label is almost certainly a **misdiagnosis**, not low expression.

v4 does not patch the coordinates — it removes the failure mode. Gene identity, chromosome
and TSS are read from eQTLGen's own `GeneSymbol` / `Gene` / `GeneChr` / `GenePos` columns,
so nothing is hard-coded and a stale coordinate cannot empty a window again. The
`--check-only` output prints, per gene, the resolved locus and how far v3's hard-coded
value was from it.

### What to report back
1. The `--check-only` table (this settles Phase 0/0c).
2. `outputs/audit_v4_results.csv` and `outputs/derived_gene_loci.csv`.
3. **The positive-control recovery line** — the script prints GATE PASSED or GATE FAILED
   per the pre-registered rule. This decides what the paper can claim, so report it
   verbatim whichever way it goes.
4. Any symbol reported `absent_from_eqtlgen` — those are genuinely untestable in blood and
   must be stated, not quietly dropped.

Phase 0e (novelty vs the 2026 multi-ancestry GWAS) still needs the variant list from
PMID 42009823 supplementary data, which this environment cannot download — see below.

---

## PHASE 0 — Correct three defects in the existing audit (highest priority)

### 0a. `UBE` is the wrong gene → **UBE2I**
The source paper (*Clin Epigenetics* 2024, PMC11562087) nominates **UBE2I**, not "UBE".
The audit assigned `ENSG00000198954` to a non-standard symbol, so that row is invalid.
→ Re-run with **UBE2I = ENSG00000103275**.

### 0b. Verify **all 12** Ensembl IDs against the source publications
Confirm each ID actually corresponds to the gene the paper named — especially
**GATS / CASTOR3**, whose assignment (`ENSG00000197256`) is unverified. If a symbol cannot
be resolved from the source, record it as `symbol_ambiguous_not_auditable` rather than
guessing. Report the final verified ID table.

### 0c. Resolve the **PRMT6 contradiction**
`published_targets_audit.csv` currently has PRMT6 with `n_snps=3, F=2465, MR P=1.9e-4`
(instruments exist) but `coloc_status = not_evaluable_low_blood_expression (n_cis_snps=0)`.
**Both cannot be true.** Debug the cis-window lookup in `run_scripts/audit_v3_coloc.R`
(likely a gene-ID or coordinate/build mismatch when selecting the ±500 kb window), re-run,
and report the real PP.H4 — or, if genuinely not evaluable, explain how a gene with three
genome-wide-significant cis-eQTLs yields an empty coloc window.

### 0d. Also re-label the source study in the output
`source_paper` currently reads "Wang 2024 (PMC11314700)". The correct citation is
**Qin Y, Lei C, Lin T, Han X, Wang D. Invest Ophthalmol Vis Sci 2024;65(10):13**
(PMID 39110588) — Wang is the *last* author. Update the label in the script so regenerated
outputs are correct (the manuscript text has already been fixed).

---

## PHASE 3 — Positive-control panel ⭐ (the paper's credibility anchor — do this even if nothing else)

**Why:** a reviewer can currently dismiss every negative result with *"your blood-eQTL
colocalization just fails everything."* We must show the pipeline detects genuine myopia
signal.

Run the **identical** pipeline (MR + 3-prior coloc + replication) on established myopia GWAS
loci: **GJD2, LAMA2, KCNQ5, ZMAT4, RBFOX1, BMP3** (RDH5 already gives PP.H4 = 0.991 as an
internal benchmark). Add more established Tedja-2018 loci if convenient.

→ `outputs/positive_controls_audit.csv` (same columns as the target audit) and report the
recovery rate at PP.H4 > 0.8.

**Pre-registered rule (fixed in advance, in `LITERATURE_SEARCH_PROTOCOL.md` §8):** if the
panel does *not* recover a substantial fraction of established loci, the audit's negative
findings must be reported as **uninformative**, not as non-reproduction. Report the result
either way — do not tune the panel to get a nicer number.

---

## PHASE 2 — DONE (search executed 2026-08-05); you only need to re-test the gene list

The systematic search has already been run and screened; **no literature work is needed
from you.** Results: 8 included studies, **23 unique genes** (up from 12). PRISMA counts
are in `LITERATURE_SEARCH_PROTOCOL.md` §6; the extraction table with source PMID/DOI,
tissue and method per gene is `outputs/published_targets_master.csv`.

**Run the same local pipeline on the 11 new genes** (identical settings to Phase 0/3 —
MR + 3-prior coloc + replication + evaluability annotation), and append to the audit:

| Gene | Source | PMID |
|---|---|---|
| CPNE1 | J Transl Med 2026 (GWAS meta + SMR + coloc + functional) | 41888893 |
| BDH1 | Transl Vis Sci Technol 2026 (SMR mQTL/eQTL/pQTL + coloc) | 41533846 |
| PDGFRA, LRRTM2, PCOLCE | Asia Pac J Ophthalmol 2026 (blood eQTL + pQTL, MR + coloc) | 41519384 |
| EPHB4 | Indian J Ophthalmol 2026 (gene-level MR) | 41669769 |
| UTS2, BTBD9, S100A3, LGALS9 | J Comput Aided Mol Des 2026 (DEG + ML + MR) | 41492036 |
| TSPAN10 | Invest Ophthalmol Vis Sci 2026 (MTAG + coloc + fine-map) | 42530915 |

Resolve each Ensembl ID **against the source publication**, exactly as in Phase 0b.
Genes whose symbol cannot be resolved are reported `symbol_ambiguous_not_auditable`
rather than guessed.

Note for interpretation: the newly added studies are 2026 publications, so several are
very recent; report them with the same evaluability annotation as the rest.

## PHASE 0e — Re-adjudicate "known locus" against the 2026 multi-ancestry GWAS ⚠ NEW

The novelty audit currently calls a gene "known" using GWAS Catalog + **Tedja 2018**. The
literature search surfaced **PMID 42009823 (*Nat Genet* 2026)**: a multi-ancestry
refractive-error GWAS in ~1.76 M people (European 1,495,159; East Asian 121,172; African
144,737) reporting **932 associated variants (241 previously unknown)** and **23
prioritized genes**.

That supersedes Tedja 2018 as the novelty reference, and it can change our calls in both
directions — most importantly **CD55**, currently flagged
`not_in_GWAS_Catalog_myopia_500kb`. Re-run `05_novelty_audit.R` with the 2026 variant list
added (±500 kb) and report which known/novel flags change. If any anchor's status flips,
say so explicitly — the manuscript's novelty claims depend on it.

Also add its 23 prioritized genes to the positive-control candidate pool if they are
established loci.

## Additional reporting requirement (Phase 3, applies to every gene)

Report **all three priors** (p₁₂ = 1e-5, 1e-6, 5e-6) and the full PP.H0–PP.H4 vector for
*every* audited gene, not just the anchors. The manuscript now reports PP.H4 as a continuum
because several genes sit near the 0.8 convention (TSSK6 0.782, SH3YL1 0.748) and CD55 itself
falls 0.801 → 0.287 across priors.

---

## Deliverables to commit

| File | Contents |
|---|---|
| `outputs/published_targets_audit.csv` | corrected + expanded audit (UBE2I, PRMT6 resolved, verified IDs, Qin label, 3 priors, evaluability) |
| `outputs/published_targets_master.csv` | extraction table from the systematic search |
| `outputs/positive_controls_audit.csv` | positive-control panel results |
| `outputs/AUDIT_SUMMARY_v4.txt` | counts by verdict + positive-control recovery rate |
| updated `run_scripts/audit_v3_coloc.R` (or v4) | the script that produced them |
| PRISMA counts | filled into `LITERATURE_SEARCH_PROTOCOL.md` §6 |

**Do not edit the manuscript text** — references, legends and in-text callouts are already
written. Report the commit hash, the positive-control recovery rate, and the final verdict
breakdown.
