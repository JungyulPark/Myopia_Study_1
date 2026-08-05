# FIGURE AND TABLE LEGENDS — audit-framed manuscript

> Written fresh for the new Figures 1–5 (+ planned Figure 6). The legends in
> `Submit_Manuscript/IOVS_Manuscript_Final_Source.md` describe the *old* figures
> (Venn / network / docking) and are **not** reusable — only their house style is.
> All numbers below are from `value_add/outputs/`. Attribution uses **Qin et al. (2024)**,
> not the incorrect "Wang et al. (2024)".

---

## Figure 1. Study pipeline and tier assignment.
Flow of the pharmacology-prioritized screen. All 113 candidate genes were tested by
two-sample cis-eQTL Mendelian randomization (eQTLGen blood cis-eQTL → UK Biobank myopia,
ukb-b-6353), and the complete testing denominator is reported rather than significant hits
only. Genes passing Bonferroni correction with a concordant Steiger direction (n = 5) were
carried into replication (CREAM, Tedja et al. 2018, FinnGen H7_MYOPIA) and three-prior
Bayesian colocalization. Genes were then assigned to **Tier A** (colocalization-supported;
PP.H4 > 0.8 with replication; n = 2: RDH5, CD55), **Tier B** (MR-supported but with distinct
causal variants for expression and myopia; n = 3: CTNNB1, FBN1, TGFB1), or **Null**
(MR non-significant; n = 108).

## Figure 2. Multi-cohort Mendelian randomization estimates for the five anchor genes.
Causal estimates (point estimate ± 95% CI) for RDH5, CD55, CTNNB1, FBN1 and TGFB1 in four
datasets: UK Biobank self-reported myopia (ukb-b-6353), CREAM spherical equivalent, Tedja
et al. 2018 spherical equivalent, and FinnGen high myopia (H7_MYOPIA, release R10). All
effects are sign-aligned to **increasing myopia risk**; because the outcome scales differ,
UK Biobank and FinnGen are on the log-odds scale while CREAM and Tedja are in dioptres and
therefore sign-inverted. RDH5 replicates in every cohort. CD55, CTNNB1 and FBN1 replicate in
the continuous refractive-error datasets but are non-significant in the smaller, more
severely ascertained FinnGen endpoint. **TGFB1 reverses direction between discovery and
replication** and is excluded as a positive result. Note that TGFB1 was instrumented by a
single protein-QTL variant (rs1963413) rather than an eQTLGen cis-eQTL.

## Figure 3. Bayesian colocalization and prior sensitivity for the anchor genes.
Stacked bars give the posterior probabilities from `coloc.abf` under the default prior
(p₁ = p₂ = 1 × 10⁻⁴, p₁₂ = 1 × 10⁻⁵): **PP.H1** (association with expression only),
**PP.H3** (distinct causal variants), and **PP.H4** (a shared causal variant). Points with
ranges show PP.H4 across the three-prior sensitivity analysis (p₁₂ = 1 × 10⁻⁶, 1 × 10⁻⁵,
5 × 10⁻⁶). RDH5 colocalizes robustly (PP.H4 = 0.991, stable across priors). CD55 exceeds the
threshold under the default prior (PP.H4 = 0.801) **but falls to 0.287 under the most
conservative prior**, so its colocalization is prior-dependent. CTNNB1 is PP.H3-dominant
(0.767) and FBN1 and TGFB1 are PP.H1-dominant (0.702 and 0.950), each indicating distinct
causal variants rather than shared causality.

## Figure 4. Screen-wide comparison of MR significance and colocalization evidence.
Each point is one of the 113 pharmacology-prioritized genes, plotted by MR significance
(−log₁₀ P, x-axis) against colocalization posterior PP.H4 (y-axis). Dashed lines mark the
Bonferroni significance threshold and PP.H4 = 0.8. Only two genes occupy the
colocalization-supported quadrant — **RDH5** and **CD55**, both previously reported — while
the three remaining Bonferroni-significant genes (CTNNB1, FBN1, TGFB1) have high MR
significance but near-zero PP.H4. The 108 null genes are shown in grey and are not omitted.
The figure makes the study's central point visible in one panel: **MR significance and
colocalization are largely decoupled**, and no novel colocalizing target emerged from the
full screen.

## Figure 5. Independent reproducibility audit of published myopia MR/eQTL targets.
Colocalization posterior (PP.H4) for each gene nominated by prior myopia Mendelian
randomization / eQTL studies, re-tested here under a single uniform standard: **Qin et al.
(2024)** (CD34, CD55, WNT3, LCAT, BTN3A1, TSSK6) and the 2024 multi-omics SMR study (PRMT6,
SH3YL1, ZKSCAN4, GATS, NPAT, UBE2I). Colocalization was computed locally from eQTLGen and UK
Biobank; the dashed line marks PP.H4 = 0.8. Symbols denote the audit verdict: reproduced
(colocalization plus independent replication), intermediate colocalization without
replication, distinct causal variants, or not evaluable because the gene has no blood
cis-eQTL. Only **CD55** reproduced. **These results are scoped to a uniform blood-eQTL
standard: the original nominations additionally used retinal eQTL (Qin et al.) or
SMR with methylation QTLs (multi-omics study), so a failure to colocalize in blood does not
establish that a target is false.** Genes without a blood cis-eQTL are unassessable here
rather than negative.

## Figure 6 (to be generated). Positive-control calibration of the audit pipeline.
PP.H4 for a panel of established myopia GWAS loci (e.g. GJD2, LAMA2, KCNQ5, ZMAT4, RBFOX1,
BMP3, with RDH5 as an internal benchmark) passed through the identical MR-plus-colocalization
pipeline. This panel quantifies the pipeline's sensitivity to genuine myopia signal and
therefore the false-negative rate against which the audit's negative findings must be read.
*Required before submission: if established loci are not recovered, the audit's negative
results are uninterpretable.*

---

## Table 1. Anchor genes: instrument strength, MR, sensitivity, replication, colocalization and tier.
For each of the five Bonferroni-significant anchor genes: number of instruments, F-statistic,
UK Biobank causal estimate, MR sensitivity analyses where instrument count permits
(MR-Egger intercept, weighted median, Cochran's Q), replication in CREAM, Tedja et al. 2018
and FinnGen, colocalization posteriors (PP.H4 / PP.H3 / PP.H1), Steiger direction, and final
tier. Sensitivity analyses are not applicable to single-instrument genes (TGFB1, FBN1) by
construction. Reverse MR was null for all anchors.

## Table 2. Reproducibility audit of published myopia MR/eQTL targets.
The 12 genes nominated by Qin et al. (2024) and the 2024 multi-omics SMR study, each
re-tested with the same pipeline: source study, original tissue and method, instrument count
and strength, MR estimate, colocalization posteriors, replication statistics, known-locus
status, and reproduction verdict. Colocalization was evaluable for 9 of 12 genes. Footnotes
must state the tissue caveat (blood-only versus the originals' retinal eQTL) and the method
caveat (coloc.abf versus SMR with methylation QTLs).

## Supplementary Table S1. Full 113-gene screen.
Complete testing denominator with per-gene instrument details, MR estimates, Steiger and
reverse-MR results, replication statistics, colocalization posteriors and tier assignment —
reported in full to avoid selective reporting.

## Supplementary Table S2. MR sensitivity analyses.
MR-Egger intercepts, weighted-median estimates and Cochran's Q statistics for all
multi-instrument genes.

## Supplementary Figure S1. Atropine–myopia intersection network (exploratory).
Protein–protein interaction network used only to motivate candidate selection. **No causal
or mechanistic claim is drawn from network topology.**

## Supplementary Figure S2. Molecular docking (exploratory).
Predicted binding energies for atropine at candidate interfaces, with scopolamine,
tropicamide and caffeine as comparators. **Because the non-atropine tropane scopolamine
bound comparably, these results are interpreted as tropane-scaffold-dependent rather than
atropine-specific and support no mechanistic or therapeutic claim.**
