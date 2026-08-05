# DRAFT — Honest Introduction (replaces the discovery/atropine-mechanism framing)

> Atropine is MOTIVATION only (do-not-regress rule 4). No "we discovered", no "novel
> targets", no "TGFβ-Hippo-YAP is atropine's mechanism", no "N methods converge".
> `‹ref›` = citation to slot from References. Sets up the honest thesis: a
> replication- and colocalization-filtered drug-target MR reappraisal that recovers
> known biology and separates causal loci from LD-confounded associations.

---

## 1. Introduction

Myopia is among the most common human disorders and a growing public-health concern,
with prevalence rising worldwide and projections that roughly half the global
population may be affected by 2050 ‹ref Holden 2016›. The burden is driven less by
refractive inconvenience than by high myopia, where axial elongation raises the
lifetime risk of myopic maculopathy, retinal detachment, choroidal neovascularization,
and glaucoma ‹ref›. Interventions that slow childhood axial progression therefore
carry substantial preventive value.

Low-concentration atropine is the most widely used pharmacological option for slowing
myopia progression, supported by randomized trials including the ATOM and LAMP series
‹ref ATOM; LAMP›. Despite this clinical track record, its molecular mechanism remains
unresolved. The historical assumption of muscarinic-receptor antagonism is difficult
to reconcile with evidence that atropine retains anti-myopia activity in settings
where classical muscarinic signalling is not straightforwardly implicated, and
non-muscarinic hypotheses — dopaminergic signalling, scleral extracellular-matrix
remodelling, and retinal-to-scleral growth cascades — have all been proposed
‹ref McBrien; dopamine hypothesis›. This mechanistic uncertainty has motivated
systems-level and genetic approaches that attempt to prioritize candidate effector
genes.

One increasingly common strategy is drug-target Mendelian randomization (MR):
pharmacology or network analysis nominates candidate genes, and cis-expression
quantitative trait loci (eQTLs) are used as instruments to test whether genetically
proxied expression is causally associated with myopia ‹ref›. Applied to atropine, such
pipelines can generate attractive target lists — but they raise two questions that are
frequently under-examined. First, **how many prioritized genes are genuinely new,
rather than established refractive-error loci recovered under a new label?** A recent
complement-focused MR study, for example, reported CD55 among six myopia-associated
complement targets ‹ref Qin et al. 2024›. Second, and more fundamentally, **does an MR
association imply a shared causal variant?** A significant, even pleiotropy-free, MR
estimate at a locus can still arise from linkage disequilibrium between the
expression-associated variant and a distinct, neighbouring disease-causing variant;
colocalization analysis is required to distinguish the two ‹ref coloc›.

Here we address both questions directly. Rather than assert new atropine-specific
targets, we apply a deliberately conservative, tiered drug-target MR framework to a
pharmacology-prioritized candidate set and subject every signal to independent-cohort
replication, Steiger directionality, formal MR sensitivity analyses, and Bayesian
colocalization, and we cross-reference each candidate against catalogued refractive-
error loci to adjudicate novelty explicitly. We use RDH5 — an established myopia locus
with prior tissue-level colocalization — as a positive control to demonstrate that the
pipeline recovers known biology, and we report transparently where MR signals fail the
shared-causal-variant test. Atropine serves throughout as clinical motivation, not as
an analytic endpoint: we make no claim to explain its efficacy or dose-response from
germline genetic data. The contribution we aim for is methodological rigor and honest
bounding of novelty, providing a template for distinguishing colocalizing causal loci
from LD-confounded associations in pharmacology-prioritized myopia genetics.

---

## Do-not-regress self-check
- [x] Atropine framed as motivation only; no atropine-specific causal/mechanistic claim.
- [x] No "discovery"/"novel target"/"converge"/"TGFβ-Hippo-YAP mechanism" language.
- [x] CD55 = Qin-2024 prior conceded; novelty question posed openly.
- [x] MR-vs-colocalization distinction set up as a central aim.
- [x] RDH5 introduced as positive control, not discovery.
- [x] No fabricated results; citation slots marked ‹ref›.
