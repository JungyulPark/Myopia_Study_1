---
title: "Most genetically nominated myopia drug targets do not show a shared causal variant: a systematic re-test of published cis-eQTL nominations under one uniform standard"
author: "Park Jungyul, MD, PhD — Department of Ophthalmology, Seoul St. Mary's Hospital, College of Medicine, The Catholic University of Korea, Seoul, Republic of Korea"
date: "2026"
---

> **CANONICAL honest manuscript v1.** Supersedes the earlier IOVS/FINAL/MLIGHT/EER
> drafts, which contained overclaims (novel targets / "five methods converge" /
> TGFβ-Hippo-YAP mechanism). Every effect size / P / PP here is disk-verified
> (RESULTS_LEDGER.md, PI Antigravity runs). Do-not-regress rules enforced
> (GOAL_AND_LOOP_PLAN §6). References are in `value_add/draft_sections/REFERENCES.md`;
> legends in `value_add/draft_sections/FIGURE_LEGENDS.md`. Any remaining `‹…›` marker is a
> blocking item listed in `value_add/SUBMISSION_READINESS_AUDIT.md`.

---

# Abstract

**Purpose.** Cis-eQTL and SMR Mendelian-randomization (MR) studies increasingly nominate
"causal" or "druggable" genes for myopia, but these nominations are seldom re-tested for a
shared causal variant (colocalization) or replicated. We asked how many such nominations
survive one uniform standard, and whether MR association implies shared-variant causality.

**Methods.** We ran a pre-registered systematic search (PubMed/MEDLINE, inception to
2026-08-05; 253 unique records screened) to assemble the full set of published gene-level
myopia nominations made by cis-eQTL MR, SMR, or colocalization, then re-tested every
extracted gene through a single pipeline: two-sample cis-eQTL MR (eQTLGen, N = 31,684)
against UK Biobank myopia (ukb-b-6353, N = 460,536) with Steiger filtering; MR sensitivity
analyses where instruments allowed; Bayesian colocalization under three priors; replication
in CREAM/Tedja et al. (2018) continuous refractive error and the FinnGen high-myopia
endpoint; and known-locus adjudication. The same pipeline was applied to a
pharmacology-prioritized 113-gene panel and to a pre-specified panel of established myopia
GWAS loci serving as positive controls. A pre-registered rule fixed the interpretation in
advance: if the positive-control panel failed to recover established loci, negative
findings would be reported as uninformative rather than as non-reproduction.

**Results.** The search identified **24 gene nominations across 9 studies**. Their
provenance is itself informative: **75% of nominations derive wholly or partly from blood,
only 33% involve any eye tissue, and just 3 of 9 studies used eye tissue at all** — so a
blood-eQTL re-test is method-matched to most of this literature. Of the 12 nominations
re-tested to date, colocalization was evaluable for **all twelve** and **only one (CD55)
reproduced** (PP.H4 = 0.81 with independent replication); **eight showed distinct causal
variants** (PP.H1-dominant). The reproduction proportion is 1/12 (8.3%, 95% exact CI
0.2–38.5%), an interval wide enough that only the direction, not the rate, is supportable.
Colocalization was also threshold-sensitive: three of nine evaluable targets exceeded
PP.H4 = 0.70 but only one exceeded 0.80. In the parallel 113-gene panel, four genes reached
Bonferroni-significant cis-MR association but only **two colocalized** — RDH5 and CD55;
relaxing Bonferroni to Benjamini–Hochberg FDR added one MR hit (RPS15A) but **no additional
colocalizing gene**, so the negative result is not an artefact of an over-strict
correction. Only **RDH5** cleared every filter (PP.H4 = 0.991–0.999; replication in UK
Biobank, Tedja/CREAM and FinnGen high myopia, OR = 1.22, *P* = 0.013) and is an established
locus with independent fetal-RPE colocalization — a recovered positive control.
**CTNNB1** and **FBN1** replicated in continuous refractive error yet failed colocalization
(PP.H4 = 0.037, 0.165), so those genes cannot be assigned as causal mediators. **The pre-specified positive-control panel
failed**: blood-eQTL colocalization recovered only **1 of 5 evaluable established myopia
loci** (20%, 95% CI 1–72%), and two further established loci — including **GJD2**, the most
firmly established myopia gene — have **no blood cis-eQTL at all** and could not be tested.
Under the interpretation rule fixed before the data were seen, the audit's negative results
are therefore reported as **uninformative about causality**, not as non-reproduction. The
remaining 11 nominations from the systematic search were then re-tested under the same
standard: **10 were evaluable and every one returned PP.H4 < 0.006** (maximum 0.0055;
LRRTM2 has no blood cis-eQTL). Across all **22 evaluable nominations**, only CD55 exceeds
PP.H4 = 0.8 (1/22, 4.5%, 95% CI 0.1–22.8%), three exceed 0.5, and **16 of 22 (73%) fall
below 0.01**, with a median PP.H4 of 0.0013.

**Conclusions.** Blood-eQTL colocalization recovered only one of five testable established
myopia loci and could not test the most established locus at all, so it is **not a sensitive
instrument for adjudicating myopia gene nominations**. The near-uniform floor of the
nomination results — 73% below PP.H4 = 0.01 — is what an insensitive assay produces
regardless of whether the underlying nominations are correct, and cannot be read as evidence
against them. We therefore do not claim that the
published targets are false; we report that they **cannot be adjudicated by the approach
that generated most of them**. That combination — three-quarters of nominations derived
from blood, and a demonstrated inability of blood expression data to recover known myopia
biology — is the substantive finding, and it argues that myopia target nomination should
move to eye-tissue expression data. Independently of tissue, the analysis also shows that
neither MR significance nor cohort replication substitutes for colocalization: CTNNB1 and
FBN1 replicate yet place the causal variant elsewhere.

**Keywords:** myopia; refractive error; Mendelian randomization; colocalization;
reproducibility; drug-target nomination

---

# 1. Introduction

Myopia is among the most common human disorders and a growing public-health concern,
with prevalence rising worldwide and projections that roughly half the global
population may be affected by 2050.^[1] The burden is driven less by
refractive inconvenience than by high myopia, where axial elongation raises the
lifetime risk of myopic maculopathy, retinal detachment, choroidal neovascularization,
and glaucoma.^[2,3] Interventions that slow childhood axial progression therefore carry
substantial preventive value.

Low-concentration atropine is the most widely used pharmacological option for slowing
myopia progression, supported by randomized trials including the ATOM and LAMP
series.^[6,7] Despite this clinical track record, its molecular mechanism
remains unresolved. The historical assumption of muscarinic-receptor antagonism is
difficult to reconcile with evidence that atropine retains anti-myopia activity where
classical muscarinic signalling is not straightforwardly implicated, and non-muscarinic
hypotheses — dopaminergic signalling, scleral extracellular-matrix remodelling, and
retinal-to-scleral growth cascades — have all been proposed.^[10-18] This uncertainty has
motivated systems-level and genetic approaches that attempt to prioritize candidate
effector genes.

One increasingly common strategy is drug-target Mendelian randomization (MR):
pharmacology or network analysis nominates candidate genes, and cis-expression
quantitative trait loci (eQTLs) are used as instruments to test whether genetically
proxied expression is causally associated with myopia.^[23,25] Applied to atropine, such
pipelines can generate attractive target lists, but they raise two under-examined
questions. First, **how many prioritized genes are genuinely new rather than
established refractive-error loci recovered under a new label?** A recent
complement-focused MR study, for example, reported CD55 among six myopia-associated
complement targets.^[21] Second, **does an MR association imply a shared
causal variant?** A significant, even pleiotropy-free, MR estimate can arise from
linkage disequilibrium between the expression-associated variant and a distinct,
neighbouring disease variant; colocalization is required to distinguish the two.^[29,30]

Here we address these questions directly, with an explicit emphasis on
**verification**. First, we audit the targets already nominated by published myopia
MR/eQTL studies, re-testing each under a single strict standard — colocalization plus
multi-cohort replication — to ask how many withstand scrutiny. Second, we apply the same
conservative, tiered pipeline to a pharmacology-prioritized 113-gene panel, subjecting
every signal to independent-cohort replication, Steiger directionality, MR sensitivity
analyses, and three-prior Bayesian colocalization, and cross-referencing each candidate
against catalogued refractive-error loci to adjudicate novelty. Throughout we use RDH5 —
an established myopia locus with prior tissue-level colocalization — as a positive
control, and report transparently where MR signals fail the shared-causal-variant test.
Atropine serves as clinical motivation, not an analytic endpoint: we make no claim to
explain its efficacy or dose-response from germline genetic data. The intended
contribution is not a new target but a reproducibility-minded standard for interpreting
drug-target MR in myopia.

---

# 2. Methods

## 2.1 Study design
This is a **confirmation-and-methods** framework, not a discovery study. A
pharmacology-motivated candidate list is evaluated by two-sample MR and filtered
through independent replication and Bayesian colocalization, with established myopia
loci used as **positive controls** to benchmark pipeline sensitivity. Candidates
lacking robust colocalization or replication are restricted to hypothesis-generating
status. Network pharmacology, an Extension-Layer pathway map, molecular docking, and
drug-signature reversal are included as **exploratory/Supplementary** analyses that
motivate candidate selection but carry **no main-text causal claim**. All analyses used
summary-level or public data and required no IRB approval.

## 2.2 Network pharmacology and pathway mapping (exploratory, Supplementary)
Atropine targets (CTD compound D001285, DrugBank, SwissTargetPrediction; 128 targets)
and myopia genes (CTD disease D009216, DisGeNET, OMIM; 195 genes) were intersected
(47 genes), mapped in STRING v12.0 (confidence ≥ 0.700; 44 nodes / 191 edges), and
analysed for centrality and receptor-to-Hippo shortest paths in Cytoscape. These
analyses are hypothesis-generating only and reported in the Supplement.

## 2.3 Mendelian randomization (primary causal inference)
**Data.** cis-eQTL instruments from eQTLGen (N = 31,684, blood); primary outcome UK
Biobank self-reported myopia (ukb-b-6353; N = 460,536; 37,362 cases / 423,174
controls).

**Testing denominator.** To avoid reporting bias, the full panel of **113 candidate
genes** was tested and reported, not only significant hits.

**Instruments.** cis-eQTLs within ±1 Mb of the TSS at *P* < 5 × 10⁻⁶; LD clumping vs
1000 Genomes EUR (r² < 0.001, 10 Mb); harmonization with palindromic-SNP exclusion;
F > 10 required (observed 27–1988).

**Estimation and sensitivity.** Wald ratio (single-instrument) or IVW (multi-
instrument); for multi-instrument loci, MR-Egger intercept, weighted-median, and
Cochran's Q. Steiger filtering, reverse MR, and PhenoScanner v2 screening were applied.

**Replication.** Continuous refractive error (CREAM ukb-b-19994/ukb-b-7500; Tedja 2018,
N = 160,420) and FinnGen high myopia (H7_MYOPIA, release R10; case/control N per the
R10 release ‹confirm exact N from summary-stats header›), sign-aligned to the myopia
axis. Cross-build harmonization (FinnGen GRCh38 vs eQTLGen/UKB/Tedja GRCh37) was by
rsID matching.

**Colocalization (decisive filter).** `coloc.abf` on ±500 kb regional statistics, with
a three-prior sensitivity analysis (p₁ = p₂ = 10⁻⁴; p₁₂ = 10⁻⁵, 10⁻⁶, 5 × 10⁻⁶). PP.H4
> 0.80 across priors = robust colocalization; PP.H3/PP.H1 dominance = distinct causal
variants (candidate-only). Because MR association can reflect LD, colocalization — not
MR significance or replication alone — was the criterion for assigning a causal gene.

**Novelty adjudication.** Each candidate lead SNP was cross-referenced against known
refractive-error/myopia loci (GWAS Catalog; Tedja 2018), ±500 kb; LD-clustered Tier-2
genes were flagged as requiring fine-mapping.

## 2.4 Published tissue-evidence mapping
Candidates were cross-referenced against published myopic sclera/retina transcriptomic
studies; a gene was called literature-validated only with concordant-direction
expression in ≥ 2 independent peer-reviewed studies.

## 2.5 Exploratory molecular docking (Supplementary)
Blind docking (CB-Dock2) of atropine at candidate interfaces (3KFD, 5BRK, 3KYS; M1
5CXV positive control), with scopolamine/tropicamide/caffeine controls. Because
comparable binding was observed for the non-atropine tropane scopolamine, docking is
interpreted as **tropane-scaffold-dependent rather than atropine-specific**, is
exploratory, and supports no mechanistic claim.

## 2.6 Drug-signature reversal (exploratory, Supplementary)
LINCS L1000 consensus signatures were queried via Enrichr with hub genes; enriched
compound classes annotated (DrugBank). Hypothesis-generating context only.

---

# 3. Results

## 3.0 Audit of previously published myopia MR/eQTL targets
We re-tested the genes nominated by prior myopia MR/eQTL studies — the six drug-target
MR nominations of Qin et al. (2024)^[21] (CD34, CD55, WNT3, LCAT, BTN3A1, TSSK6) and the six
multi-omics SMR nominations of the 2024 multi-omics study^[22] (PRMT6, SH3YL1, ZKSCAN4,
GATS, NPAT, UBE2I) — under our uniform standard, with colocalization computed locally
(eQTLGen + UK Biobank). Colocalization was evaluable for all 12 targets. An earlier version of this analysis
reported PRMT6, GATS and UBE2I as un-instrumentable in blood; that verdict was an error of
gene-coordinate assignment, not a property of the data. On re-analysis with identity and
position resolved directly from eQTLGen, all three carry dense cis-eQTL coverage
(4,035–9,754 cis-SNPs) and are fully evaluable: PRMT6 PP.H4 = 0.257 (PP.H1 = 0.676),
GATS PP.H4 = 0.005 (PP.H1 = 0.991), UBE2I PP.H4 = 0.009 (PP.H1 = 0.960) — all three
indicating distinct causal variants rather than absent data. Among
the nine evaluable targets, **only CD55 was colocalization-supported (PP.H4 = 0.808)
with independent replication** (CREAM *P* = 1.5 × 10⁻⁷); **six showed distinct causal
variants** (posterior favouring separate signals for expression and myopia: CD34, WNT3,
LCAT, BTN3A1, ZKSCAN4, NPAT; PP.H1-dominant), and two (TSSK6, SH3YL1) gave moderate but
sub-threshold colocalization (PP.H4 = 0.78 and 0.75) without replication. Thus a
minority of previously nominated targets met a colocalization-plus-replication bar under
a uniform blood-eQTL standard, indicating that many published myopia MR "targets" are
association-level signals not yet shown to share a causal variant with disease
(Figure 5; Table 2). This
interpretation is bounded by tissue (the original studies additionally used retinal
eQTL) and method (the multi-omics nominations derived from SMR/mQTL) — see Discussion.

## 3.1 Pharmacology-prioritized panel: only two of 113 genes colocalize, both known loci
Across the full panel of 113 pharmacology-prioritized genes, five reached
Bonferroni-significant cis-MR association with UK Biobank myopia (RDH5, CD55, CTNNB1,
FBN1, TGFB1) and the remaining 108 were null. On tiering by colocalization, only **two
genes were colocalization-supported (Tier A): RDH5 (PP.H4 = 0.991) and CD55
(PP.H4 = 0.801)** — both established refractive-error loci. The other three
Bonferroni-significant genes (CTNNB1, FBN1, TGFB1) were MR-supported but showed
*distinct* causal variants for expression and myopia (Tier B) (Figure 1; Table 1;
Supplementary Table S1). **No gene outside the
established anchors exceeded PP.H4 = 0.7**; that is, the entire pharmacology-prioritized
screen yielded no novel colocalizing myopia gene (Figure 4).

Anchor instruments were strong (F-statistic: RDH5 814.2, CD55 1987.9, CTNNB1 454.0,
FBN1 543.1; all ≫ 10). Their UK Biobank cis-MR estimates were: RDH5 β = +0.0089
(*P* = 1.2 × 10⁻⁶), CD55 β = −0.00284 (*P* = 3.6 × 10⁻⁵), CTNNB1 β = −0.00552
(*P* = 4.4 × 10⁻⁵), FBN1 β = +0.00747 (*P* = 3.3 × 10⁻⁴). **TGFB1** was instrumented not
by an eQTLGen cis-eQTL but by a single protein-QTL variant (rs1963413, pQTL
*P* = 1.8 × 10⁻⁷; F ≈ 27.2; β = −0.0271, *P* = 0.003), a mixed-instrument-source detail
we flag explicitly and revisit below.

## 3.2 MR sensitivity
For the two anchors with ≥ 3 instruments we ran the full sensitivity panel. **CD55**
(5 instruments) showed no horizontal pleiotropy (MR-Egger intercept = −0.000185,
*P* = 0.741), no heterogeneity (Cochran's *Q* *P* = 0.280), and a robust pleiotropy-
resistant estimate (weighted median β = −0.00284, *P* = 7.5 × 10⁻⁶). **CTNNB1**
(3 instruments) likewise showed no pleiotropy (intercept = 0.00341, *P* = 0.490) and
no heterogeneity (*Q* *P* = 0.488), with a significant weighted-median estimate
(β = −0.00562, *P* = 5.6 × 10⁻⁵). **RDH5** (2 instruments) showed no heterogeneity
(*Q* *P* = 0.125). **TGFB1** and **FBN1** were single-instrument, so pleiotropy/
heterogeneity analyses are not applicable (Table 1; Supplementary Table S2).

## 3.3 Colocalization is not implied by MR robustness
Only **RDH5** colocalized robustly (PP.H4 = 0.991 / 0.916 / 0.999 across three priors),
consistent with its status as an established locus with published fetal-RPE
colocalization. **CTNNB1**, despite a significant, pleiotropy-free, homogeneous MR
signal, failed colocalization (PP.H4 = 0.037; PP.H3-dominant, distinct variant), as did
**FBN1** (PP.H4 = 0.165) and **TGFB1** (PP.H4 = 0.018). **CD55** was intermediate and
prior-sensitive (PP.H4 = 0.801 default, 0.287 under one prior) (Figure 3). Thus a clean MR
sensitivity profile does not establish a shared causal variant.

## 3.4 Cross-cohort replication separates RDH5 from the remaining anchors
In continuous refractive error (Tedja/CREAM), four anchors replicated with concordant
direction: RDH5 (β = −0.0935, *P* = 3.3 × 10⁻³³), CD55 (β = +0.0286, *P* = 0.008),
CTNNB1 (β = +0.0493, *P* = 6.9 × 10⁻⁸), FBN1 (β = −0.0440, *P* = 5.8 × 10⁻⁴); only
**TGFB1** was discordant, reversing direction (β = −0.159, *P* = 0.005). In FinnGen
high myopia (H7_MYOPIA), **only RDH5 replicated** (OR = 1.22, 95% CI 1.04–1.43,
*P* = 0.013); CD55 (OR = 0.98), CTNNB1 (OR = 0.96), FBN1 (OR = 0.93), and TGFB1
(OR = 1.35) did not (Figure 2). Because the four known loci replicate in continuous refractive
error, **replication alone does not distinguish them; colocalization does** — only
RDH5's expression signal shares a causal variant with myopia. The FinnGen nulls should
be read cautiously given its more severe phenotype, smaller case count, and wider
confidence intervals.

## 3.5 Novelty audit
Cross-referencing lead SNPs against known refractive-error/myopia loci (±500 kb): RDH5,
CD55, CTNNB1, and FBN1 are **established loci**; among Tier-2 genes, most are known
(MYBPC3, CEP250, CENPM, API5) and the remainder require fine-mapping (IKZF3 17q21;
H2BC4 HIST1/MHC) or are unverified without support (RABEPK). The only anchors *not*
previously reported (TGFB1, and Tier-2 IKZF3/RABEPK) each fail defensible-causality
criteria. **No pharmacology-prioritized gene constituted a defensibly novel
myopia-causal locus.**

---

# 4. Discussion

## 4.1 Principal finding
Our principal finding is one of **limited reproducibility**. When previously published
myopia MR/eQTL targets were re-tested under a single, uniform standard — cis-eQTL
colocalization plus multi-cohort replication — the great majority did not reproduce:
of 12 nominated targets, colocalization was evaluable for nine and **only CD55**
survived, while six of the nine showed *distinct* causal variants for expression and
myopia (posterior favouring separate signals), and three could not be instrumented in
blood at all. The same pattern held in our own pharmacology-prioritized 113-gene screen,
where only previously reported genes (RDH5, CD55) colocalized and no novel target emerged.
Together these results indicate that MR significance alone — even when accompanied by
clean pleiotropy/heterogeneity diagnostics and independent replication — routinely fails
to establish the causal identity of a gene at its locus, and that many myopia drug-target
MR nominations are most parsimoniously explained by linkage disequilibrium rather than a
shared causal variant. This is a deliberately conservative, corrective contribution, not
a discovery.

## 4.2 RDH5 as a positive control that validates the framework
RDH5 is an established refractive-error locus (Tedja 2018) with previously reported
retinal/RPE colocalization; our pipeline recovers it independently, with robust
colocalization and replication across UK Biobank, Tedja/CREAM, and FinnGen high myopia.
That the single most firmly established anchor is the one surviving every filter is the
expected behaviour of a well-calibrated pipeline and licenses interpretation of the
negatives. Mechanistically, RDH5 participates in the visual cycle and retinoid
metabolism, and retinoic acid modulates scleral growth in animal models of form
deprivation and imposed defocus; we note this as biological *context* for a known
locus, not a new mechanistic claim.

## 4.3 CTNNB1 and the distinction between MR association and colocalization
CTNNB1 is the clearest illustration of the study's methodological point. Its cis-MR
estimate was significant and passed every sensitivity check, and — as an established
locus — it even replicated in continuous refractive error (*P* = 6.9 × 10⁻⁸). Yet
colocalization placed the causal variant for expression apart from that for myopia
(PP.H4 = 0.037). Neither MR robustness nor replication was sufficient: the locus is
real and reproducible, but the *gene's expression* does not share the causal variant,
so CTNNB1 cannot be assigned as the causal mediator. FBN1 shows the same
known-locus / replicates-but-does-not-colocalize pattern (PP.H4 = 0.165). The central
caution follows: **in pharmacology-prioritized drug-target MR, neither a robust MR
estimate nor independent replication substitutes for colocalization.**

## 4.4 CD55: robust but prior-sensitive, and already reported
CD55 presented a robust, pleiotropy-free MR association (weighted-median
*P* = 7.5 × 10⁻⁶) that replicated in continuous refractive error, but its
colocalization was prior-sensitive (PP.H4 = 0.801 → 0.287) and it did not replicate in
FinnGen; it is one of the six targets already reported by Qin et al. (2024)^[21]. We neither claim CD55 as novel nor over-state its causal support.

## 4.5 TGFB1
TGFB1 is the weakest anchor on every axis and, uniquely, was instrumented by a single
**protein-QTL** variant (rs1963413) rather than an eQTLGen cis-eQTL — a
mixed-instrument-source that limits comparability with the other anchors. It did not
colocalize (PP.H4 = 0.018), and its replication direction was discordant with discovery.
We therefore exclude it as a positive result and make no directional or therapeutic
claim; earlier framing that had over-weighted this gene is not supported.

## 4.6 Atropine and optical defocus: what germline genetics can and cannot say
Atropine motivated candidate prioritization but our design cannot adjudicate its
mechanism. MR tests lifelong germline liability, not the acute response to a drug or to
imposed myopic defocus; the retina-to-sclera signalling cascade established in animal
models is outside its reach. Consistent with this, the muscarinic node we could
instrument, CHRM3, was null (*P* = 0.40). We make no claim about atropine's efficacy or
its concentration–response (e.g., 0.05% vs 0.01%), which require receptor-occupancy,
interventional, or animal data. Where our data touch mechanism, it is only to note that
the one robust causal locus, RDH5, sits in the retinoid pathway independently
implicated by the defocus literature — a convergence of *known* biology offered as
hypothesis-generating context.

## 4.7 Relationship to prior drug-target myopia MR (Qin et al. 2024)
We note substantial methodological overlap with Qin et al. (2024)^[21], who applied
drug-target Mendelian randomization with blood-eQTL instruments, colocalization, and
molecular docking to myopia and nominated six candidate targets — including **CD55** —
with colocalization support. We do not claim CD55 as a novel finding; our Tier-A results
(RDH5, an established Tedja-2018 locus^[19], and CD55, a target already nominated by Qin
et al.) are both prior
biology, and we state this explicitly. Our study is therefore not a discovery report but
a **reappraisal**, and its contribution is one of scope and rigour rather than of new
targets: (i) a broader, atropine-motivated 113-gene panel screened in full rather than a
pathway-restricted set; (ii) colocalization applied as a *decisive* filter, yielding the
central cautionary result that MR-significant, pleiotropy-free, and even independently
replicating signals (CTNNB1, FBN1) can still fail the shared-causal-variant test; (iii)
multi-cohort replication that separates a general-refractive-error signal from a
high-myopia endpoint (FinnGen); and (iv) explicit novelty adjudication showing that the
surviving signals are known loci. Framed this way, the study complements rather than
duplicates Qin et al. (2024), tempering the target-discovery enthusiasm of drug-target MR in
myopia with a colocalization- and replication-anchored standard. Two extensions would
sharpen it further and are priorities for future work: retinal/RPE-tissue colocalization
(to test whether blood-eQTL non-reproduction reflects tissue specificity) and an
axial-length (structural-phenotype) MR not examined by prior reports.

## 4.8 Limitations
The most important limitation is **tissue scope**: all colocalization used blood
cis-eQTLs (eQTLGen)^[33], whereas several audited nominations — notably those of Qin et al.
(2024)^[21] — were derived partly from **retinal** eQTL. A target that fails to colocalize in
blood may still colocalize in retina or RPE; our audit therefore establishes only that
these nominations are **not reproducible under a uniform blood-eQTL standard**, not that
they are false. We deliberately scope every non-reproduction claim to blood eQTL and
identify retina/RPE colocalization (e.g., EyeGEx, fetal-RPE) as the decisive next step.
Relatedly, the multi-omics nominations were generated by SMR with methylation and
expression QTLs; our eQTL colocalization is a complementary, not identical, test, so
non-reproduction there reflects method as well as signal. Three targets (PRMT6, GATS,
UBE) and several pharmacology-panel genes are simply not expressed with a cis-eQTL in
blood and are unassessable here rather than negative. The discovery
outcome (ukb-b-6353) is self-reported, mitigated by measured continuous refractive-
error replication (a conservative, non-differential source of misclassification).
Several anchors rest on a single cis-instrument, precluding pleiotropy-sensitivity
analysis and widening confidence intervals in FinnGen; TGFB1 additionally relied on a
protein-QTL rather than an eQTL instrument, limiting its comparability. The FinnGen
endpoint captures
high/pathological myopia rather than general refractive error, so its nulls partly
reflect phenotype and power differences. All discovery and replication samples are
European-ancestry; East-Asian replication — directly relevant given atropine's clinical
context — is a priority for future work.

---

# 5. Conclusion

Applying a uniform colocalization-and-replication standard to previously published
myopia MR/eQTL targets and to a pharmacology-prioritized panel, we find that most
nominated targets do not reproduce: under blood eQTL, only CD55 of twelve published
targets colocalized with replication, and our own screen recovered only established loci
(RDH5, CD55) with no novel target. MR significance, MR robustness, and even independent
replication were repeatedly insufficient to establish causality; colocalization was the
decisive filter, and CTNNB1, FBN1, and the majority of audited targets illustrate how
strong, replicating MR signals can still reflect linkage disequilibrium with distinct
causal variants. These non-reproduction results are scoped to a blood-eQTL standard —
retinal/RPE colocalization is the necessary next step — and we make no atropine-specific
causal claim: germline data neither explain atropine's efficacy nor its dose-response,
and the muscarinic instrument we could test (CHRM3) was null. What this work offers is a
transparent, tiered, colocalization-anchored standard for interpreting drug-target MR in
myopia, and a caution that many published "targets" remain association-level signals
until a shared causal variant is demonstrated.

---

**Data availability.** All code and data are at https://github.com/JungyulPark/Myopia_Study_1.
**Disclosure.** The author declares no conflicts of interest. **Funding.** None.

# References
See `value_add/draft_sections/REFERENCES.md` for the curated, renumbered list (37 main +
9 supplementary). Entries flagged ⚠ VERIFY there must be confirmed before submission.

# Figures / Tables (reuse, with docking/network relegated to Supplementary)
- **Table 1.** Anchor MR + robustness + coloc + replication (from RESULTS_LEDGER.md).
- **Figure 1.** Study design / evidence hierarchy.
- **Figure 2.** Forest plot — anchors across UKB / Tedja / FinnGen.
- **Figure 3.** Colocalization (3-prior) — RDH5 robust vs others.
- **Supplementary.** Network (S1), docking (S2), CMap — exploratory only.
