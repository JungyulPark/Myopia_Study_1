# M-LIGHT value-add manuscript sections — DRAFT

> **Status:** writing scaffold for the two elevation tracks. **All numeric slots
> are `‹FILL from run›` placeholders** — they are populated only from the PI's
> `druggability_map.tsv` and `axial_length_MR_results.csv` outputs. No number in
> this file may be invented (do-not-regress rule #6). Every drug named below must
> map to a `verify_status=verified` row or be deleted (rule #7).

---

## A. Revised abstract (honest-elevated, ~190 words)

**Background.** Atropine slows myopia progression, motivating a search for the
causal genes that pharmacology prioritizes. We asked whether a transparent,
replication- and colocalization-filtered Mendelian randomization (MR) pipeline,
seeded by atropine-relevant pharmacology, identifies *atropine-specific* myopia
targets — or recovers generic refractive-error biology.

**Methods.** Drug-target/cis-eQTL MR of candidate loci against refractive error,
filtered by independent replication and Bayesian colocalization, then extended
to (i) a public, ocular-delivery-route–aware druggability map and (ii) MR against
**axial length**, the structural mediator of pathological myopia.

**Results.** Anchors surviving replication and colocalization were *already-known*
refractive-error genes used here as positive controls (RDH5; weakly CD55); no
locus was defensibly novel, and pharmacology-prioritized hits were **not**
atropine-specific. Axial-length MR ‹FILL: concordant / null per gene›.
Druggability mapping identified ‹FILL: N verified› tractable handles, all via
established ocular routes.

**Conclusions.** A rigorous MR framework recovers known myopia biology as
positive controls and, honestly applied, bounds novelty rather than inflating it
— a corrective, triangulation-first contribution.

---

## B. Druggability / repurposing subsection (Results + Discussion)

*Source: `druggability_map.tsv` (Open Targets / ChEMBL / Ensembl, public APIs;
verified rows only).*

We mapped each colocalization-supported anchor to its **tractability bucket** and
**known drugs**, read through an **ocular-delivery-route** lens that distinguishes
this analysis from prior complement-focused MR (Wang Y 2024, IOVS): we ask not
"is there a binder?" but "is there an *eye-deliverable* pharmacological handle on
this pathway?". We performed no docking and predicted no novel binders.

- **RDH5 — visual-cycle handle (pathway-adjacent, not on-target).** RDH5 sits in
  the retinoid visual cycle; clinical modulators (e.g. emixustat, an RPE65/visual-
  cycle agent) act on the *pathway*, **not on RDH5 itself**. We therefore describe
  a visual-cycle repurposing hypothesis, explicitly not an "RDH5 inhibitor" claim.
  Tractability: ‹FILL›. Known drugs: ‹FILL verified rows›.
- **CD55 — downstream complement, already a known target.** CD55 is a complement
  regulator; the actionable lever is **downstream complement inhibition**
  (intravitreal pegcetacoplan / avacincaptad, approved for geographic atrophy),
  not drugging CD55. We state plainly that CD55 is one of Wang 2024's targets and
  is therefore **not a point of differentiation**. Tractability: ‹FILL›.
- **CTNNB1 / FBN1 — honest negative.** Wnt/β-catenin core node (CTNNB1) and a
  structural ECM protein (FBN1) are low/no small-molecule tractability
  (‹FILL buckets›). We report this as part of the negative result, not as a gap to
  paper over. (These loci also failed colocalization — candidate/hypothesis only.)
- **TGFB1 — excluded from any directional/therapeutic claim** (discordant MR
  direction; single instrument; coloc fail).

**Differentiation statement (for cover letter & Discussion):** unlike Wang 2024,
which prioritized complement targets against refractive error, we (a) benchmark
pharmacology-prioritized hits against known GWAS loci and find them generic,
(b) read druggability through a delivery-route lens, and (c) extend to the
structural axial-length phenotype (Section C). CD55 overlap is disclosed, not
claimed as novel.

---

## C. Axial-length / high-myopia MR subsection (Results + Discussion)

*Source: `axial_length_MR_results.csv`. Pre-registered interpretation grid in
`02_axial_length_MR.R` header — applied as written.*

Refractive error is a composite; **axial length** is the structural driver of
pathological, vision-threatening myopia, and was **not** tested by prior
complement MR. We re-ran the four non-discordant cis-anchored instruments
(RDH5, CD55, CTNNB1, FBN1; TGFB1 excluded for discordant direction) against an
axial-length GWAS ‹FILL: source + N› and a high/degenerative-myopia clinical
endpoint ‹FILL: FinnGen endpoint + N›.

Per the pre-registered grid:

| Anchor | RE MR (prior) | Axial-length MR (here) | Interpretation |
|---|---|---|---|
| RDH5 | sig (positive control) | ‹FILL β, 95% CI, P, n_IV, F› | ‹concordant → stronger positive control / null → non-axial route + power note› |
| CD55 | sig-ish | ‹FILL› | ‹…› |
| CTNNB1 | candidate | ‹FILL› | ‹…› |
| FBN1 | candidate | ‹FILL› | ‹…› |

**Interpretation rules honored:** a locus moving both refractive error and axial
length in the **same** direction is reported as a *stronger positive control*
(structural concordance), **never** as a new gene. A **null** axial-length result
is reported as informative — non-axial/refractive route or limited power (power
note mandatory) — and is **never** converted into a positive. Opposite-direction
signals are treated as pleiotropy/harmonisation red flags and investigated, not
reported as findings.

**If axial-length data access is not resolved in time (Roadmap gate G3 = "No
path"),** this subsection ships as a clearly-labelled limitation ("structural-
phenotype MR not yet testable — axial-length summary statistics access pending")
and the paper is submitted on the honest core + druggability map without it.

---

## D. Reviewer-rebuttal seeds (cover letter / response)

- *"Confirmation only."* → Yes, by design and by honest result: the contribution
  is a corrective, replication-+coloc-filtered framework that recovers known
  biology as positive controls and **bounds** novelty. We add a delivery-route
  druggability map and a **structural axial-length** MR arm that prior work did
  not test.
- *"How is this different from Wang 2024?"* → We disclose CD55 overlap; our adds
  are the delivery-route lens and the axial-length/structural extension, plus an
  explicit benchmark of pharmacology-prioritized hits against known GWAS.
- *"Blood eQTL ≠ eye."* → Now directly answered by the eye-tissue coloc arm
  (Section E); RDH5's stronger fetal-RPE coloc (bioRxiv 446799) is cited as prior,
  more-relevant evidence we recover.

---

## E. Eye-tissue colocalization subsection (Results + Discussion)

*Source: `eye_tissue_coloc_results.csv` (EyeGEx retina / fetal-RPE / neural-adjacent
proxy). Pre-registered interpretation in `03_eye_tissue_coloc.R` header.*

Because our primary colocalization used blood eQTL (eQTLGen), we re-tested each
anchor in **disease-relevant ocular tissue**. This directly addresses the
blood-vs-eye limitation rather than merely conceding it.

| Anchor | Blood coloc (prior) | Eye-tissue coloc (here) | Interpretation |
|---|---|---|---|
| RDH5 | PP.H4 0.99 | ‹FILL PP.H4, tissue, nsnps› | ‹holds in retina/RPE → recovered known positive control (cite bioRxiv 446799)› |
| CD55 | PP.H4 0.80 (prior-sensitive) | ‹FILL› | ‹holds / blood-specific› |
| CTNNB1 | coloc fail (PP.H3) | ‹FILL› | ‹candidate only› |
| FBN1 | coloc fail (PP.H1) | ‹FILL› | ‹candidate only› |

**Rules honored:** recovering RDH5 in retina/RPE is a *positive-control* win and is
cited against prior published eye-tissue coloc — **not** a discovery. An anchor
that colocalizes in blood but **not** in eye tissue is reported as blood-specific
(a limitation), never as a finding. Panels with too few overlapping SNPs are
reported as "not testable in this tissue."

---

## F. Mechanism / pathway-axis subsection (Results + Discussion)

*Source: `pathway_mr_per_gene.csv`, `pathway_axis_summary.csv`. Reporting rules in
`04_pathway_mechanism.R` header.*

We recast the anchors as a small number of **established biological axes** the
pipeline recovers — visual cycle (RDH5), complement regulation (CD55), TGF-β/ECM
scleral remodelling (FBN1; TGFB1 as context only, discordant direction), and
Wnt/β-catenin (CTNNB1) — and asked, per axis, how many *member* genes show a
consistent-direction cis-MR effect on refractive error.

| Axis | Anchor | Members tested | Concordant w/ anchor | Note |
|---|---|---|---|---|
| Visual cycle | RDH5 | ‹FILL› | ‹FILL› | established retinoid biology recovered |
| Complement | CD55 | ‹FILL› | ‹FILL› | overlaps Wang 2024 (disclosed) |
| TGF-β / ECM | FBN1 | ‹FILL› | ‹FILL› | TGFB1 context only — discordant, no positive claim |
| Wnt/β-catenin | CTNNB1 | ‹FILL› | ‹FILL› | coloc-failed anchor — hypothesis only |

**Rules honored:** axes are framed as *established* biology recovered, not new
mechanisms; the axis summary is **descriptive** (count of consistent members),
with **no pooling of p-values** into an inflated meta-test; TGFB1 is context only.
This gives mechanism-level narrative depth without a single new-gene claim.
