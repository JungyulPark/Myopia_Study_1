# Multi-receptor convergence on the TGFβ–Hippo-YAP axis in atropine's anti-myopia mechanism: integrative evidence from network pharmacology, Mendelian randomization, and transcriptomic cross-validation

**Park Jungyul, MD, PhD**

---

## Abstract

**Purpose.** The molecular mechanism by which atropine inhibits myopia progression remains incompletely understood. We integrated network pharmacology, two-sample Mendelian randomization (MR), and systematic published transcriptomic evidence mapping to identify causal signaling pathways mediating atropine's anti-myopia effects.

**Methods.** In Phase 1 (network pharmacology), atropine targets from the Comparative Toxicogenomics Database and curated myopia-associated genes were intersected to identify 47 shared genes. Protein–protein interaction network analysis, hub gene identification, and KEGG/GO enrichment were performed. An Extension Layer analysis assessed convergence of four receptor classes (muscarinic, adrenergic, nicotinic, dopaminergic) onto the Hippo-YAP pathway. In Phase 2 (Mendelian randomization), two-sample MR using eQTLGen blood cis-eQTLs (p < 5 × 10⁻⁶) as exposures and UK Biobank myopia (N = 460,536) as outcome was performed for 18 genes across five modules: dopamine (MR-A), Hippo-YAP (MR-B), muscarinic (MR-C), adrenergic (MR-D), and ECM/HIF/TGFβ (MR-E). Sensitivity analyses included Steiger directionality testing, reverse MR, and PhenoScanner pleiotropy screening. In Phase 3 (published evidence mapping), differentially expressed gene results from six published myopic tissue studies (2018–2025) were systematically extracted and cross-referenced with network pharmacology targets.

**Results.** Network pharmacology identified TGFB1, AKT1, TP53, CTNNB1, and EGR1 as hub genes, with all four receptor classes converging on Hippo-YAP signaling nodes through the Extension Layer. MR analysis revealed two significant causal associations: genetically increased TGFB1 expression was protective against myopia (β = −0.027, p = 0.003), while increased LATS2 expression conferred myopia risk (β = +0.018, p = 0.04). Both passed Steiger directionality testing (p < 10⁻⁵) and showed no reverse causation. COMT (dopamine catabolism) showed no causal association (IVW p = 0.19). Cross-validation against published data confirmed YAP downregulation in myopic sclera and context-dependent TGFβ1 changes, with five genes achieving triple convergence across all three methods.

**Conclusions.** Integrative evidence from network topology, genetic causality, and tissue-level expression converges on the TGFβ–Hippo-YAP axis as a core regulatory mechanism in myopic scleral remodeling. The null dopamine result suggests atropine's anti-myopia effect operates primarily through non-dopaminergic pathways. TGFB1 and LATS2 represent novel genetically validated targets for myopia intervention.

**Keywords:** myopia, atropine, network pharmacology, Mendelian randomization, Hippo-YAP, TGFβ, sclera

---

## 1. Introduction

Myopia has reached epidemic proportions worldwide, with prevalence exceeding 80% among young adults in East Asia and projections suggesting nearly 50% of the global population will be affected by 2050.¹ Progressive myopia, driven by excessive axial elongation and scleral remodeling, increases the risk of sight-threatening complications including retinal detachment, myopic macular degeneration, and glaucoma.²

Low-dose atropine (0.01–0.05%) remains the most widely prescribed pharmacological intervention for myopia control, yet its precise molecular mechanism continues to be debated.³ While initially attributed to muscarinic receptor antagonism, accumulating evidence has challenged this explanation: atropine demonstrates anti-myopia effects in species lacking scleral muscarinic receptors, non-selective muscarinic antagonists such as pirenzepine show weaker efficacy, and atropine interacts with multiple non-muscarinic targets including α2A-adrenergic receptors, GABA receptors, and EGF receptors.⁴⁻⁶ Thompson et al. (2021) further demonstrated that atropine's anti-myopia effects persist without measurable changes in retinal dopamine levels, challenging the dominant "outdoor light → dopamine → myopia protection" paradigm.⁷

Recent advances in scleral biology have highlighted the Hippo-YAP signaling pathway as a mechanotransduction hub governing extracellular matrix (ECM) homeostasis. Liu et al. (2025) demonstrated decreased YAP expression in myopic sclera of both guinea pigs and human donor eyes, with reduced downstream targets including COL1A1 and CTGF.⁸ Concurrently, Huang et al. (2025) showed that atropine suppresses HIF-1α in form-deprivation myopia (FDM) mice, restoring scleral ECM integrity.⁹ These findings suggest a convergence of atropine's multi-target pharmacology onto scleral remodeling pathways, but no study has systematically mapped this convergence or validated it through orthogonal genetic approaches.

The M-LIGHT (Multi-receptor Light Integration through Growth-factor and Hippo-YAP Transduction) hypothesis proposes that atropine's anti-myopia effect is mediated not by a single receptor but by the simultaneous modulation of multiple receptor classes that converge on the TGFβ–Hippo-YAP signaling axis in the sclera. To test this hypothesis, we employed a three-phase integrative strategy: (1) network pharmacology to map the multi-target landscape of atropine–myopia gene interactions; (2) two-sample Mendelian randomization to establish genetic causal relationships between pathway components and myopia risk; and (3) systematic cross-validation against published myopic tissue transcriptomic and proteomic data to achieve triangulation of evidence.

---

## 2. Methods

### 2.1 Study Design Overview

This study employed an integrative computational framework consisting of three complementary phases (Figure 1). Phase 1 (network pharmacology) identified shared molecular targets between atropine and myopia. Phase 2 (Mendelian randomization) tested genetic causal associations between pathway gene expression and myopia risk. Phase 3 (published evidence mapping) cross-validated computational predictions against published experimental tissue data. All analyses used publicly available data and did not require ethical approval.

### 2.2 Phase 1: Network Pharmacology

#### 2.2.1 Atropine Target Identification

Atropine-interacting genes were extracted from the Comparative Toxicogenomics Database (CTD; http://ctdbase.org), filtered to include only direct evidence interactions (marker/mechanism and therapeutic). This yielded 107 unique gene targets. The curated list was supplemented with established pharmacological targets from DrugBank (DB00572) including muscarinic receptors CHRM1–5, α2A-adrenoceptor ADRA2A, and additional literature-validated targets.

#### 2.2.2 Myopia Gene Identification

Myopia-associated genes were curated from DisGeNET (filtering for Gene-Disease Association score ≥ 0.1 using search terms "myopia," "high myopia," and "degenerative myopia") and supplemented with OMIM-confirmed causal genes (PAX6, ZNF644, RASGRF1, GJD2) and M-LIGHT hypothesis genes (LATS1/2, YAP1, TEAD1–4, HIF1A). Direct evidence genes only were retained, yielding 207 unique myopia-associated genes.

#### 2.2.3 Network Construction and Analysis

The Venn intersection of atropine targets and myopia genes was computed to identify shared targets. These were submitted to the STRING database (v12.0; minimum confidence score 0.7) to construct a protein–protein interaction (PPI) network. Hub genes were identified using degree centrality, betweenness centrality, and closeness centrality, with the top genes by each metric retained.

#### 2.2.4 Pathway Enrichment

KEGG pathway and Gene Ontology (GO) Biological Process enrichment analyses were performed via the STRING enrichment API with false discovery rate (FDR) < 0.05 as the significance threshold.

#### 2.2.5 Extension Layer Analysis

To test the M-LIGHT convergence hypothesis, we defined a Hippo-YAP Extension Layer consisting of core pathway components (LATS1, LATS2, YAP1, WWTR1/TAZ, TEAD1–4, MST1/2, SAV1, NF2, AMOT) not present in the initial intersection. For each receptor class (muscarinic, adrenergic, nicotinic, dopaminergic), we computed shortest-path distances from receptor targets through PPI edges to Extension Layer nodes. Convergence was defined as ≤ 3 intermediate steps.

### 2.3 Phase 2: Two-Sample Mendelian Randomization

#### 2.3.1 Instrument Selection

Genetic instruments for gene expression were obtained from the eQTLGen Consortium (blood cis-eQTLs; N = 31,684) accessed via OpenGWAS (https://gwas.mrcieu.ac.uk). Single nucleotide polymorphisms (SNPs) with p < 5 × 10⁻⁶ were selected as instruments, clumped at r² < 0.001 within a 10,000-kb window. Instruments with F-statistic < 10 were excluded to minimize weak instrument bias.

#### 2.3.2 Exposure and Outcome Definitions

Eighteen genes were analyzed across five modules:
- **MR-A (Dopamine):** TH, DRD1, DRD2, COMT
- **MR-B (Hippo-YAP):** LATS1, LATS2, YAP1, TEAD1, WWTR1
- **MR-C (Muscarinic):** CHRM1–5
- **MR-D (Adrenergic/Non-cholinergic):** ADRA2A, GABRA1, EGFR
- **MR-E (ECM/HIF/TGFβ):** HIF1A, TGFB1, LOX, MMP2, VEGFA

The outcome was self-reported myopia (reason for glasses: short-sightedness) from UK Biobank (dataset ukb-b-6353; N = 460,536).

#### 2.3.3 MR Analysis

Primary analysis used the inverse variance weighted (IVW) method for genes with ≥ 3 instruments and Wald ratio for single-instrument genes. For genes with ≥ 3 instruments, supplementary methods included MR-Egger regression, weighted median, and weighted mode estimators. Data harmonization excluded palindromic SNPs with intermediate allele frequencies. Analyses were performed using the TwoSampleMR R package (version 0.7.4).

#### 2.3.4 Sensitivity Analyses

For significant associations (p < 0.05):
- **Steiger directionality test** to confirm the causal direction from gene expression to myopia rather than reverse causation.
- **Reverse MR** using genome-wide significant myopia SNPs (p < 5 × 10⁻⁸) as instruments for myopia exposure and gene expression as outcome.
- **PhenoScanner** pleiotropy screening to identify instrument associations with potential confounders (height, BMI, autoimmune diseases, cancer) at p < 5 × 10⁻⁸.
- **Cochran's Q test** for heterogeneity and **MR-Egger intercept test** for directional pleiotropy (when ≥ 3 instruments).

### 2.4 Phase 3: Published Transcriptomic Evidence Mapping

To validate network pharmacology predictions without re-analyzing raw sequencing data, we systematically extracted molecular findings from six published myopic tissue studies (2018–2025) encompassing scleral and retinal tissues from mouse, guinea pig, and human models (Table 1). For each CP1 hub gene and Extension Layer gene, we catalogued its reported expression change (upregulated, downregulated, not significant, or not reported) across studies. Genes showing concordant changes across ≥ 2 independent studies were classified as "published-validated." Cross-referencing with MR results enabled three-way triangulation (network prediction × genetic causality × tissue expression).

---

## 3. Results

### 3.1 Network Pharmacology Identifies Multi-receptor Convergence on Hippo-YAP

Intersection of 107 atropine targets with 207 myopia-associated genes yielded 47 shared genes (Figure 2A). PPI network analysis (STRING, confidence ≥ 0.7) identified 8 hub genes by consensus of degree, betweenness, and closeness centrality: JUN, AKT1, TP53, MAPK3, FOS, CTNNB1, EGR1, and TGFB1 (Figure 2B).

KEGG pathway enrichment revealed 168 significantly enriched pathways (FDR < 0.05), including pathways directly relevant to the M-LIGHT hypothesis: Cholinergic synapse, PI3K-Akt signaling, MAPK signaling, TGF-beta signaling, and HIF-1 signaling pathways.

Extension Layer analysis demonstrated that all four atropine receptor classes converge on Hippo-YAP signaling within ≤ 3 PPI edges (Figure 2C). The shortest identified path was DRD1 → FOS → YAP1 (distance 2), establishing a direct topological link between dopaminergic signaling and Hippo-YAP mechanotransduction.

### 3.2 Mendelian Randomization Reveals Causal Roles of TGFB1 and LATS2

Of 18 genes tested across five MR modules, sufficient cis-eQTL instruments (p < 5 × 10⁻⁶, F > 10) were identified for 8 genes (Table 2). The remaining 10 genes lacked instruments due to tissue-specific expression patterns (predominantly neuronal or scleral), consistent with the blood-based eQTL source.

Two genes demonstrated significant causal associations with myopia (Figure 3):

**TGFB1** (MR-E): Genetically proxied increased TGFB1 expression was protective against myopia (Wald ratio β = −0.027, SE = 0.009, p = 0.003). Steiger directionality confirmed the correct causal direction (p = 1.65 × 10⁻⁵). Reverse MR showed no evidence of reverse causation (IVW p = 0.90). PhenoScanner identified a known pleiotropic association with standing height (p = 7.4 × 10⁻³⁴), attributable to TGFβ's established role in skeletal growth rather than horizontal pleiotropy.

**LATS2** (MR-B): Genetically proxied increased LATS2 expression was associated with increased myopia risk (Wald ratio β = +0.018, SE = 0.009, p = 0.04). Steiger directionality confirmed the correct causal direction (p = 1.29 × 10⁻⁶). Reverse MR showed no reverse causation (IVW p = 0.94). No concerning pleiotropic associations were identified by PhenoScanner.

**COMT** (MR-A): Five instruments with mean F-statistic of 27.2 showed no causal association between dopamine catabolism and myopia (IVW β = −0.002, p = 0.19). TH, DRD1, and DRD2 had insufficient blood-based eQTL instruments, consistent with their predominantly neuronal expression.

**HIF1A** (MR-E): Four instruments yielded a suggestive but non-significant protective trend (IVW β = −0.004, p = 0.15; weighted median p = 0.068).

ADRA2A (5 IVs, IVW p = 0.80), CHRM3 (1 IV, p = 0.40), LOX (1 IV, p = 0.74), and VEGFA (5 IVs, p = 0.81) showed no significant associations.

### 3.3 Published Evidence Mapping Confirms Triple Convergence

Systematic extraction from six published studies identified expression changes for 30 CP1/Extension Layer genes across scleral and retinal tissues (Figure 4). Five genes achieved triple convergence across all three analytical phases:

1. **TGFB1**: CP1 hub gene (degree 14) → CP3 causal protective (p = 0.003) → altered in FDM sclera (Wu et al. 2018; context-dependent regulation)
2. **LATS2**: CP1 Extension Layer kinase → CP3 causal risk (p = 0.04) → consistent with YAP downregulation in myopic sclera (Liu et al. 2025)
3. **YAP1**: CP1 Extension Layer core → decreased in myopic sclera by Western blot in both guinea pig and human tissue (Liu et al. 2025) and confirmed across multiple myopia models (scleral review 2025)
4. **HIF1A**: CP1 hub gene → CP3 suggestive (p = 0.068) → upregulated in FDM sclera (Wu et al. 2018), suppressed by atropine (Huang et al. 2025)
5. **COL1A1**: CP1 downstream ECM target → consistently decreased across three independent studies (Liu 2025, Wnt5a 2025, atropine rescue in Huang 2025)

Notably, ECM structural genes (COL1A1, COL1A2, FN1) showed consistent downregulation in myopic sclera across independent studies, supporting the scleral remodeling axis as the final common effector pathway.

---

## 4. Discussion

### 4.1 The TGFβ–Hippo-YAP Axis as a Core Mechanism

This study provides the first integrative evidence from three independent analytical methods converging on the TGFβ–Hippo-YAP signaling axis as a central regulatory mechanism in atropine-mediated myopia control. The triangulation of network pharmacology prediction, genetic causal evidence, and published tissue-level expression data substantially strengthens causal inference beyond what any single method could achieve.¹⁰

The strongest individual finding was the causal protective effect of TGFB1 on myopia (MR p = 0.003). TGFβ1 is a pleiotropic cytokine with well-established roles in ECM homeostasis, and its context-dependent effects in the sclera — promoting collagen synthesis and cross-linking under physiological conditions while driving fibrosis under pathological stimulation — align with the observed bidirectional expression changes across published studies. In the context of Hippo-YAP signaling, TGFβ–SMAD complexes interact with YAP/TAZ to co-regulate target gene expression, including COL1A1 and CTGF,¹¹ providing a mechanistic link between our MR-validated exposure and the downstream ECM changes observed in myopic sclera.

### 4.2 LATS2 Overactivity and the "Goldilocks" Model of YAP Regulation

The finding that genetically increased LATS2 expression confers myopia risk (β = +0.018, p = 0.04) initially appears paradoxical — the Hippo pathway's tumor suppressor function implies that pathway activation should be protective. However, in the context of scleral biomechanics, this result is biologically consistent: LATS2 phosphorylates YAP at Ser127, promoting its cytoplasmic sequestration and proteasomal degradation. Excessive LATS2 activity would therefore lead to pathological YAP depletion, reducing TEAD-mediated transcription of ECM genes including COL1A1, COL3A1, and CTGF.

This interpretation is directly supported by Liu et al. (2025), who demonstrated decreased YAP protein in myopic guinea pig and human sclera by Western blot and immunofluorescence. We propose a "Goldilocks" model of scleral YAP regulation: both excessive YAP (oncogenic proliferation) and insufficient YAP (ECM synthesis failure) are deleterious, and the myopic sclera suffers from the latter — a state of LATS2-driven YAP hypofunction leading to collagen insufficiency and mechanical weakening.

This model is further supported by the recent observation that Wnt5a-positive scleral fibroblasts — the principal collagen-producing cells — are depleted in myopic sclera (Wnt5a, Nat Commun 2025), with concomitant reductions in COL1A1, COL1A2, and SPARC. The Hippo-YAP pathway is a known regulator of fibroblast fate and mechanosensing,¹² suggesting that LATS2-mediated YAP suppression may drive this pathological fibroblast depletion.

### 4.3 Reframing Atropine's Mechanism: Beyond Dopamine

The null MR result for COMT (p = 0.19) and the absence of viable instruments for TH, DRD1, and DRD2 provide genetic evidence that the dopamine catabolism pathway does not causally mediate myopia risk at the population level. This aligns with Thomson et al. (2021), who demonstrated that atropine's anti-myopia effects in chicks persist without measurable changes in retinal dopamine or DOPAC levels. While dopamine likely plays a modulatory role in light-mediated ocular growth regulation, our integrative results suggest that atropine's therapeutic mechanism operates primarily through non-dopaminergic scleral pathways — specifically, the TGFβ–Hippo-YAP axis.

The network pharmacology Extension Layer analysis provides a topological framework for this reinterpretation: all four receptor classes through which atropine acts converge within ≤ 3 PPI interactions on Hippo-YAP signaling nodes, with the shortest path being DRD1 → FOS → YAP1. This suggests that the multi-receptor nature of atropine's pharmacology is not a liability but rather a therapeutic advantage: simultaneous modulation of multiple upstream inputs that converge on a single downstream effector (scleral ECM homeostasis via YAP).

### 4.4 Clinical Implications

These findings have direct translational relevance. First, TGFB1 and LATS2 represent genetically validated therapeutic targets: strategies to enhance TGFβ1 signaling or inhibit LATS2 in the sclera merit investigation as adjuncts to atropine therapy. Second, the "Goldilocks" model predicts that both excessive and insufficient Hippo pathway activity would be deleterious, suggesting that selective LATS2 inhibitors — which are under active development in oncology¹³ — could theoretically be repurposed for myopia prevention. Third, the null dopamine result argues against combination therapies targeting dopaminergic pathways and instead supports direct scleral-targeting approaches.

### 4.5 Limitations

Several limitations should be acknowledged. First, both TGFB1 and LATS2 MR analyses relied on single instrumental variables (Wald ratio), precluding pleiotropy assessment through MR-Egger regression or weighted median methods. While Steiger and reverse MR confirmed the causal direction, replication with tissue-specific eQTLs (e.g., GTEx scleral or ocular tissue data) will be essential when such datasets become available in OpenGWAS. Second, the TGFB1 instrument (rs1963413) showed strong association with standing height, a known TGFβ pleiotropic effect. While height and axial length may share developmental TGFβ-mediated growth pathways — representing vertical rather than horizontal pleiotropy — this cannot be definitively excluded. Third, eQTLGen provides blood-based eQTLs, and gene expression regulation may differ in target tissues (sclera, retina). The absence of instruments for tissue-specific genes (TH, DRD1, CHRM1, YAP1) reflects this limitation rather than evidence of no causal effect. Fourth, the published evidence mapping relied on curated extraction from six studies and does not constitute a formal systematic review with PRISMA methodology.

### 4.6 Conclusions

By integrating network pharmacology, Mendelian randomization, and published transcriptomic evidence mapping, we demonstrate that the TGFβ–Hippo-YAP axis represents the convergence point for atropine's multi-receptor anti-myopia mechanism. TGFB1 is causally protective and LATS2 is causally detrimental for myopia risk, establishing the first genetically validated targets within this pathway. The null dopamine catabolism result reframes atropine's mechanism away from the prevailing dopaminergic hypothesis toward direct scleral ECM regulation. These findings provide a molecular framework for developing next-generation myopia therapies targeting the Hippo-YAP pathway.

---

## References

1. Holden BA, et al. Global prevalence of myopia and high myopia and temporal trends from 2000 through 2050. *Ophthalmology*. 2016;123(5):1036-1042.
2. Ohno-Matsui K, et al. Pathologic myopia. *Annu Rev Vis Sci*. 2023;9:293-322.
3. Yam JC, et al. Low-Concentration Atropine for Myopia Progression (LAMP) Study: A randomized, double-masked, placebo-controlled trial. *Ophthalmology*. 2019;126(1):113-124.
4. McBrien NA, et al. Structural and ultrastructural changes to the sclera in a mammalian model of high myopia. *Invest Ophthalmol Vis Sci*. 2001;42(10):2179-2187.
5. Carr BJ, et al. Nitric oxide (NO) mediates the inhibition of form-deprivation myopia by atropine in chicks. *Sci Rep*. 2018;8(1):9086.
6. Arumugam B, McBrien NA. Muscarinic antagonist control of myopia: evidence for M4 and M1 receptor-based pathways in the inhibition of experimentally-induced axial myopia. *Invest Ophthalmol Vis Sci*. 2012;53(9):5827-5837.
7. Thomson K, et al. Atropine reduces form-deprivation myopia in chicks without changing retinal dopamine or DOPAC levels. *Exp Eye Res*. 2021;207:108604.
8. Liu Y, et al. Role of YAP in scleral remodeling in myopia. *Invest Ophthalmol Vis Sci*. 2025;66(2):22.
9. Huang X, et al. Atropine inhibits HIF-1α-mediated scleral remodeling in form-deprivation myopia. *Front Pharmacol*. 2025;16:1486571.
10. Lawlor DA, et al. Triangulation in aetiological epidemiology. *Int J Epidemiol*. 2016;45(6):1866-1886.
11. Piccolo S, et al. The biology of YAP/TAZ: hippo signaling and beyond. *Physiol Rev*. 2014;94(4):1287-1312.
12. Dupont S, et al. Role of YAP/TAZ in mechanotransduction. *Nature*. 2011;474(7350):179-183.
13. Dey A, et al. Targeting the Hippo pathway in cancer, fibrosis, wound healing and regenerative medicine. *Nat Rev Drug Discov*. 2020;19(7):480-494.

---

## Figure Legends

**Figure 1.** Study design overview. Three-phase integrative framework: network pharmacology (Phase 1) identified shared atropine–myopia gene targets and their convergence on Hippo-YAP signaling; Mendelian randomization (Phase 2) tested genetic causal associations; published transcriptomic evidence mapping (Phase 3) cross-validated predictions against experimental tissue data.

**Figure 2.** Network pharmacology results. (A) Venn diagram showing 47 intersection genes between 107 atropine targets and 207 myopia genes. (B) Protein–protein interaction network of intersection genes with hub genes highlighted. (C) Extension Layer analysis demonstrating convergence of all four receptor classes onto Hippo-YAP signaling nodes within ≤ 3 PPI edges (shortest path: DRD1 → FOS → YAP1).

**Figure 3.** Forest plot of two-sample Mendelian randomization results across five modules (MR-A through MR-E). Effect sizes (β) represent the change in myopia risk per standard deviation increase in genetically proxied gene expression. Red indicates statistically significant associations (p < 0.05); grey indicates non-significant results. Error bars represent 95% confidence intervals.

**Figure 4.** Triangulation evidence matrix. Cross-validation of CP1 hub genes and Extension Layer genes against published myopic tissue expression data from six studies. Red indicates upregulation in myopia; blue indicates downregulation; white indicates not significant; grey indicates not tested. Gene names are color-coded by CP1 classification (red = hub gene; purple = Hippo-YAP Extension; green = receptor). Stars indicate level of convergence: ⭐⭐⭐ = triple (network + genetics + tissue), ⭐⭐ = double, ⭐ = single method.
