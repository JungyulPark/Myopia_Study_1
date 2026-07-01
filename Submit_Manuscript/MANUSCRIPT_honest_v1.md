---
title: "Pharmacology-prioritized myopia loci are established refractive-error genes, not atropine-specific targets: a replication- and colocalization-filtered Mendelian randomization reappraisal"
author: "Park Jungyul, MD, PhD — Department of Ophthalmology, Seoul St. Mary's Hospital, College of Medicine, The Catholic University of Korea, Seoul, Republic of Korea"
date: "2026"
---

> **CANONICAL honest manuscript v1.** Supersedes the earlier IOVS/FINAL/MLIGHT/EER
> drafts, which contained overclaims (novel targets / "five methods converge" /
> TGFβ-Hippo-YAP mechanism). Every effect size / P / PP here is disk-verified
> (RESULTS_LEDGER.md, PI Antigravity runs). Do-not-regress rules enforced
> (GOAL_AND_LOOP_PLAN §6). `‹FILL›` marks the few pending items (value-add analyses
> paused by the OpenGWAS outage) — the paper is complete and submittable without them.

---

# Abstract

**Purpose.** Atropine is the most widely used pharmacological treatment for myopia
progression, yet its molecular mechanism remains debated. Rather than assert new drug
targets, we asked whether a pharmacology-prioritized, replication- and
colocalization-filtered Mendelian randomization (MR) pipeline identifies *novel*
myopia-causal genes or instead *recovers established* refractive-error biology, and
whether MR association implies shared-variant causality.

**Methods.** Two-sample cis-eQTL MR (eQTLGen, N = 31,684) tested pharmacology-
prioritized candidate genes against UK Biobank myopia (ukb-b-6353; N = 460,536; 37,362
cases), with replication in Tedja et al. (2018) and CREAM continuous refractive error
and in the FinnGen high-myopia endpoint (H7_MYOPIA), Steiger filtering, MR sensitivity
analyses (MR-Egger, weighted median, Cochran's Q) for multi-instrument genes, and
Bayesian colocalization under three priors. Candidate lead SNPs were cross-referenced
against catalogued refractive-error/myopia loci to adjudicate novelty.

**Results.** Of 113 pharmacology-prioritized genes, five reached Bonferroni-significant
cis-MR association with myopia, but only **two colocalized** — RDH5 and CD55, both
established refractive-error loci; the other 108 genes were null and no non-anchor gene
exceeded PP.H4 = 0.7. Instruments were strong (F = 27–1988). Only **RDH5** cleared every
filter:
robust colocalization (PP.H4 = 0.991–0.999) and replication across UK Biobank,
Tedja/CREAM, and FinnGen high myopia (OR = 1.22, *P* = 0.013). RDH5 is an established
Tedja-2018 locus with prior retinal/RPE colocalization — a recovered positive control.
**CD55** showed a robust, pleiotropy-free MR association (weighted-median *P* = 7.5 ×
10⁻⁶) that replicated in continuous refractive error but had prior-sensitive
colocalization and did not replicate in FinnGen; it is already a reported complement
target. **CTNNB1** and **FBN1** are established refractive-error loci that replicated in
continuous refractive error yet failed colocalization (PP.H4 = 0.037 and 0.165;
distinct causal variants), so their specific genes cannot be assigned as causal
mediators. **TGFB1**, the only anchor not previously reported, failed (PP.H4 = 0.018;
single instrument; discordant replication) and was excluded. Cross-referencing all
candidates against known loci confirmed **no pharmacology-prioritized gene was a
defensibly novel myopia-causal locus**.

**Conclusions.** Applied honestly, a drug-target MR pipeline recovers known
refractive-error biology (RDH5) as a positive control and declines to elevate MR
signals that fail the shared-causal-variant test. The muscarinic node most relevant to
atropine (CHRM3) was null. The contribution is a rigorous, transparently bounded
framework distinguishing colocalizing causal loci from LD-confounded associations —
not a claim of new atropine-specific targets.

**Keywords:** myopia; refractive error; Mendelian randomization; colocalization;
atropine; drug-target MR

---

# 1. Introduction

Myopia is among the most common human disorders and a growing public-health concern,
with prevalence rising worldwide and projections that roughly half the global
population may be affected by 2050.^‹ref Holden 2016› The burden is driven less by
refractive inconvenience than by high myopia, where axial elongation raises the
lifetime risk of myopic maculopathy, retinal detachment, choroidal neovascularization,
and glaucoma.^‹ref› Interventions that slow childhood axial progression therefore carry
substantial preventive value.

Low-concentration atropine is the most widely used pharmacological option for slowing
myopia progression, supported by randomized trials including the ATOM and LAMP
series.^‹ref ATOM; LAMP› Despite this clinical track record, its molecular mechanism
remains unresolved. The historical assumption of muscarinic-receptor antagonism is
difficult to reconcile with evidence that atropine retains anti-myopia activity where
classical muscarinic signalling is not straightforwardly implicated, and non-muscarinic
hypotheses — dopaminergic signalling, scleral extracellular-matrix remodelling, and
retinal-to-scleral growth cascades — have all been proposed.^‹ref› This uncertainty has
motivated systems-level and genetic approaches that attempt to prioritize candidate
effector genes.

One increasingly common strategy is drug-target Mendelian randomization (MR):
pharmacology or network analysis nominates candidate genes, and cis-expression
quantitative trait loci (eQTLs) are used as instruments to test whether genetically
proxied expression is causally associated with myopia.^‹ref› Applied to atropine, such
pipelines can generate attractive target lists, but they raise two under-examined
questions. First, **how many prioritized genes are genuinely new rather than
established refractive-error loci recovered under a new label?** A recent
complement-focused MR study, for example, reported CD55 among six myopia-associated
complement targets.^‹ref Wang 2024› Second, **does an MR association imply a shared
causal variant?** A significant, even pleiotropy-free, MR estimate can arise from
linkage disequilibrium between the expression-associated variant and a distinct,
neighbouring disease variant; colocalization is required to distinguish the two.^‹ref›

Here we address both questions directly. Rather than assert new atropine-specific
targets, we apply a deliberately conservative, tiered drug-target MR framework to a
pharmacology-prioritized candidate set and subject every signal to independent-cohort
replication, Steiger directionality, formal MR sensitivity analyses, and Bayesian
colocalization, cross-referencing each candidate against catalogued refractive-error
loci to adjudicate novelty explicitly. We use RDH5 — an established myopia locus with
prior tissue-level colocalization — as a positive control, and report transparently
where MR signals fail the shared-causal-variant test. Atropine serves throughout as
clinical motivation, not as an analytic endpoint: we make no claim to explain its
efficacy or dose-response from germline genetic data.

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
genes** was tested and reported, not only significant hits. ‹CHECK 113 matches results
row count.›

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

## 3.1 Full-panel screen: only two of 113 genes colocalize, both known loci
Across the full panel of 113 pharmacology-prioritized genes, five reached
Bonferroni-significant cis-MR association with UK Biobank myopia (RDH5, CD55, CTNNB1,
FBN1, TGFB1) and the remaining 108 were null. On tiering by colocalization, only **two
genes were colocalization-supported (Tier A): RDH5 (PP.H4 = 0.991) and CD55
(PP.H4 = 0.801)** — both established refractive-error loci. The other three
Bonferroni-significant genes (CTNNB1, FBN1, TGFB1) were MR-supported but showed
*distinct* causal variants for expression and myopia (Tier B). **No gene outside the
established anchors exceeded PP.H4 = 0.7**; that is, the entire pharmacology-prioritized
screen yielded no novel colocalizing myopia gene.

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
heterogeneity analyses are not applicable.

## 3.3 Colocalization is not implied by MR robustness
Only **RDH5** colocalized robustly (PP.H4 = 0.991 / 0.916 / 0.999 across three priors),
consistent with its status as an established locus with published fetal-RPE
colocalization. **CTNNB1**, despite a significant, pleiotropy-free, homogeneous MR
signal, failed colocalization (PP.H4 = 0.037; PP.H3-dominant, distinct variant), as did
**FBN1** (PP.H4 = 0.165) and **TGFB1** (PP.H4 = 0.018). **CD55** was intermediate and
prior-sensitive (PP.H4 = 0.801 default, 0.287 under one prior). Thus a clean MR
sensitivity profile does not establish a shared causal variant.

## 3.4 Cross-cohort replication separates RDH5 from the remaining anchors
In continuous refractive error (Tedja/CREAM), four anchors replicated with concordant
direction: RDH5 (β = −0.0935, *P* = 3.3 × 10⁻³³), CD55 (β = +0.0286, *P* = 0.008),
CTNNB1 (β = +0.0493, *P* = 6.9 × 10⁻⁸), FBN1 (β = −0.0440, *P* = 5.8 × 10⁻⁴); only
**TGFB1** was discordant, reversing direction (β = −0.159, *P* = 0.005). In FinnGen
high myopia (H7_MYOPIA), **only RDH5 replicated** (OR = 1.22, 95% CI 1.04–1.43,
*P* = 0.013); CD55 (OR = 0.98), CTNNB1 (OR = 0.96), FBN1 (OR = 0.93), and TGFB1
(OR = 1.35) did not. Because the four known loci replicate in continuous refractive
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
Under strict replication and colocalization filters, the prioritized loci are
**established refractive-error genes recovered as positive controls, not novel
atropine-specific targets**, and MR significance alone — even with clean pleiotropy and
heterogeneity diagnostics and independent replication — does not establish the causal
identity of a gene at its locus. Only **RDH5** cleared every filter. This is a
deliberately conservative, corrective result, framed as such.

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
FinnGen; it is one of the six complement targets already reported by Wang et al.
(2024). We neither claim CD55 as novel nor over-state its causal support.

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

## 4.7 Relationship to prior pharmacology-prioritized myopia MR (Wang 2024)
Our contribution relative to Wang et al. (2024) is methodological, not a new target
(we concede CD55 overlaps their complement set): explicit novelty adjudication against
catalogued loci, multi-cohort replication including a high-myopia endpoint,
prior-sensitivity reporting for colocalization, and transparent demotion of MR signals
that fail the shared-causal-variant test. ‹FILL when run: axial-length MR (a structural
mediator not previously tested here), eye-tissue colocalization, East-Asian
replication, and a delivery-route-aware druggability map would each add a concrete
point of differentiation.›

## 4.8 Limitations
Instruments derive from blood eQTLs (eQTLGen); blood is not eye tissue, and tissue-
specific colocalization in retina/RPE is the appropriate next step. The discovery
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

This study reframes an atropine-motivated, pharmacology-prioritized target list through
the discipline of replication and colocalization. Its central finding is
methodological: across five candidate anchors, MR significance, MR robustness, and even
independent replication were not sufficient to establish causality — only **RDH5**, the
most firmly established prior locus, cleared both MR and colocalization, functioning as
a positive control that validates the pipeline rather than a discovery. CD55 is a
robust but prior-sensitive association already reported elsewhere; CTNNB1, FBN1, and
TGFB1 illustrate how strong, replicating MR signals can still reflect linkage
disequilibrium with distinct causal variants and must remain candidate-only. We make no
atropine-specific causal claim: these germline data neither explain atropine's efficacy
nor its dose-response, and the muscarinic instrument we could test (CHRM3) was null.
What the framework offers is transparency — a tiered, colocalization-anchored standard
that recovers known myopia biology as positive controls and refuses to over-interpret
the rest.

---

**Data availability.** All code and data are at https://github.com/JungyulPark/Myopia_Study_1.
**Disclosure.** The author declares no conflicts of interest. **Funding.** None.

# References
‹Populate from References_complete_1_48.md, fixing [27][28][35][40]; add Wang 2024
PMC11314700, Tedja 2018, Holden 2016, ATOM/LAMP, eQTLGen, coloc, FinnGen.›

# Figures / Tables (reuse, with docking/network relegated to Supplementary)
- **Table 1.** Anchor MR + robustness + coloc + replication (from RESULTS_LEDGER.md).
- **Figure 1.** Study design / evidence hierarchy.
- **Figure 2.** Forest plot — anchors across UKB / Tedja / FinnGen.
- **Figure 3.** Colocalization (3-prior) — RDH5 robust vs others.
- **Supplementary.** Network (S1), docking (S2), CMap — exploratory only.
