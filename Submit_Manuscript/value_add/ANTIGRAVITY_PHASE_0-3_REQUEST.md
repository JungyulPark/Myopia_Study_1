# ANTIGRAVITY REQUEST — Phases 0, 2, 3 (audit corrections + expansion + positive controls)

Everything here runs **locally with no OpenGWAS** (local eQTLGen cis file +
`ukb-b-6353.vcf.gz`), exactly as `run_scripts/audit_v3_coloc.R` already does.
Branch `claude/busy-heisenberg-lP58T`; push via the safe file-copy route; **never force-push**.

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

## PHASE 2 — Expand the audit systematically

Follow `Submit_Manuscript/value_add/LITERATURE_SEARCH_PROTOCOL.md` (pre-registered).

1. Run the §3 search string in PubMed (and, if available, Embase / Web of Science / Scopus).
2. Screen per §4 eligibility. **Exclude pQTL/proteome-wide nominations** with the stated
   method-mismatch justification — list them in an appendix rather than dropping silently.
3. Extract every nominated gene into `outputs/published_targets_master.csv` with the §5
   columns; resolve every gene ID **against the source paper**.
4. Fill the PRISMA counts in §6 of the protocol and record the execution date.
5. Re-test every extracted gene with the same local pipeline → append to
   `outputs/published_targets_audit.csv` (or a v4 file), including the **evaluability
   annotation** (n cis-SNPs in window, instrument strength) so "no colocalization" is
   separable from "no power".

Expected scale: ~15–25 genes plus the positive controls — comfortably within local capacity.

---

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
