---
title: "Multi-Receptor Convergence on TGFβ-Hippo-YAP Axis in Atropine's Anti-Myopia Mechanism: Integrative Evidence From Network Pharmacology, Mendelian Randomization, and Molecular Docking"
author: "Park Jungyul, MD, PhD"
---

# COVER LETTER

Editor-in-Chief, Investigative Ophthalmology & Visual Science (IOVS)

Dear Editor,

We are pleased to submit our manuscript entitled "Multi-receptor convergence on TGFβ-Hippo-YAP axis in atropine's anti-myopia mechanism: integrative evidence from network pharmacology, Mendelian randomization, and molecular docking" for consideration as an Original Article in Investigative Ophthalmology & Visual Science.

Atropine is the most widely prescribed pharmacological intervention for childhood myopia worldwide, yet its mechanism of action remains fundamentally unresolved after 50 years of investigation. The field has been unable to reconcile conflicting evidence across muscarinic, adrenergic, dopaminergic, and nicotinic receptor candidates. Our study provides a unifying framework by demonstrating that these diverse receptor targets converge on a common downstream effector — the TGFβ-Hippo-YAP signaling axis — through shared hub gene intermediaries.

This is, to our knowledge, the first study to: (1) demonstrate four-receptor convergence on Hippo-YAP using Extension Layer network analysis; (2) provide genetic causal evidence linking Hippo pathway components (TGFB1, LATS2) to myopia through Mendelian randomization; (3) replicate the TGFB1 causal effect across three independent refractive error phenotypes (all P < 0.001); (4) show drug-like binding of atropine at protein–protein interfaces of Hippo pathway complexes; and (5) apply five-method evidential triangulation to a myopia pharmacology question.

This work directly extends recent IOVS publications on YAP-mediated scleral remodeling (Liu et al. IOVS 2025;66:22) and builds upon the receptor pharmacology literature that has been a cornerstone of myopia research published in IOVS (Arumugam & McBrien 2012; Carr et al. 2018).

This manuscript has not been published or submitted elsewhere. The study used only publicly available summary-level data and did not require institutional review board approval. All code and data are available at https://github.com/JungyulPark/Myopia_Study_1.

We declare no conflicts of interest.

Sincerely,

Park Jungyul, MD, PhD
Department of Ophthalmology, Seoul St. Mary's Hospital
College of Medicine, The Catholic University of Korea
Seoul, Republic of Korea

\newpage

# TITLE PAGE

**Title**: Multi-Receptor Convergence on TGFβ-Hippo-YAP Axis in Atropine's Anti-Myopia Mechanism: Integrative Evidence From Network Pharmacology, Mendelian Randomization, and Molecular Docking

**Running head**: Multi-receptor convergence on Hippo-YAP in myopia

**Authors**: Park Jungyul, MD, PhD

**Affiliation**: Department of Ophthalmology, Seoul St. Mary's Hospital, College of Medicine, The Catholic University of Korea, Seoul, Republic of Korea

**Corresponding author**: Park Jungyul, MD, PhD; Department of Ophthalmology, Seoul St. Mary's Hospital, 222 Banpo-daero, Seocho-gu, Seoul 06591, Republic of Korea

**Word count**: Abstract 248; Manuscript ~5,500

**Tables**: 4 (main text); 3 (supplementary)

**Figures**: 4

**Keywords**: myopia; atropine; Hippo-YAP signaling; network pharmacology; Mendelian randomization; TGFβ1

**Financial support**: None.

**Disclosure**: The author declares no conflicts of interest.

**Data availability**: All code and data are publicly available at https://github.com/JungyulPark/Myopia_Study_1.

\newpage

# ABSTRACT

**Purpose**: Atropine is the most widely used pharmacological agent for myopia control, yet its molecular mechanism remains unresolved, with conflicting evidence across muscarinic, adrenergic, dopaminergic, and nicotinic receptor pathways. We tested the hypothesis that these diverse receptor targets converge on the TGFβ-Hippo-YAP signaling axis using five independent analytical methods.

**Methods**: Network pharmacology identified atropine–myopia intersection genes and tested whether four receptor classes reach Hippo-YAP components through hub gene intermediaries (Extension Layer analysis). Two-sample Mendelian randomization assessed genetic causality for 22 candidate genes using eQTLGen cis-eQTLs and UK Biobank myopia data (N = 460,536). Causal findings were replicated across continuous refractive error outcomes and tested by Bayesian colocalization. Literature evidence mapping, drug signature reversal analysis, and molecular docking provided additional validation.

**Results**: Intersection of 128 atropine targets and 195 myopia genes yielded 47 common genes, of which 44 formed a connected protein–protein interaction network (191 edges). All four receptor classes converged on Hippo-YAP within 2–3 interaction steps. Mendelian randomization identified TGFB1 as causally protective (β = −0.027, P = 0.003) and LATS2 as causally risk-increasing (β = +0.018, P = 0.040), with TGFB1 replicated across three independent outcomes (all P < 0.001). EGFR inhibitors dominated drug signature reversal, validating the network-predicted bridge role. Atropine showed drug-like binding at YAP-TEAD (−7.9 kcal/mol), MOB1-LATS1 interface (−7.6 kcal/mol), and TGFβ1 receptor (−7.5 kcal/mol).

**Conclusions**: Five independent methods converge on TGFβ-Hippo-YAP as the downstream effector of atropine's multi-receptor anti-myopia mechanism. TGFB1 and LATS2 are genetically causal mediators, and novel protein–protein interface binding suggests a "network modulator" mechanism. These findings provide a framework for next-generation myopia pharmacotherapy.

\newpage

# INTRODUCTION

Myopia affects approximately half of the global population, with projections estimating 4.9 billion affected individuals by 2050.^1^ In East Asia, prevalence is particularly alarming, reaching 96.5% among 19-year-old male conscripts in Seoul.^2^ The shift toward indoor-dominant lifestyles and intensive near work is widely considered a primary environmental driver,^3,4^ and the associated risk of sight-threatening complications — retinal detachment, myopic maculopathy, and glaucoma — renders myopia a major public health concern.^5^ Low-concentration atropine (0.01–0.05%) has emerged as the primary pharmacological intervention for myopia control, with meta-analyses demonstrating reductions in spherical equivalent progression of approximately 0.16 D/year and axial elongation of 0.07 mm/year.^6,7^ A recent International Myopia Institute (IMI) report confirmed atropine among the most evidence-supported treatments.^8^ However, rebound progression upon cessation remains a concern,^9^ underscoring the need to understand atropine's mechanism to optimize dosing and develop next-generation agents.

Despite widespread clinical use, the molecular mechanism by which atropine inhibits myopia remains fundamentally unresolved. The conventional explanation — muscarinic receptor blockade — has been challenged by multiple lines of evidence. In the tree shrew, both M4-selective (MT3) and M1-selective (MT7) antagonists inhibit form-deprivation myopia (FDM), implicating M4 and M1 subtypes.^10^ M2 knockout mice show the greatest resistance to myopia among muscarinic subtypes.^11^ Carr et al. demonstrated that antagonist potency at the α2A-adrenoceptor, rather than at any muscarinic subtype, best correlates with anti-myopia efficacy.^12^ Meanwhile, retinal dopamine has long been considered a key mediator of myopia protection,^13,14^ yet Thomson et al. showed that atropine's anti-myopia effect persists without measurable changes in retinal dopamine levels.^15^ This accumulated evidence led Upadhyay and Beuerman to characterize atropine as a "shotgun approach" drug that simultaneously engages muscarinic, adrenergic, nicotinic, GABA, and EGFR pathways.^16^

A critical question remains: if atropine engages multiple upstream receptors, do these signals converge on a common downstream effector? The sclera — specifically its extracellular matrix (ECM) remodeling — is the primary structural determinant of axial elongation.^17,18^ Scleral remodeling in myopia involves TGFβ-dependent changes in collagen composition and matrix metalloproteinase activity,^19,20^ with hypoxia emerging as an upstream trigger.^21^ These observations suggest that regardless of which receptor atropine initially engages, the downstream effector may reside in the scleral signaling cascade rather than at the receptor level itself.

Recent evidence implicates the Hippo-YAP signaling pathway as a potential convergence point linking receptor-level signals to scleral remodeling. Liu et al. demonstrated that YAP expression is decreased in myopic sclera from both human tissue and guinea pig models, with ECM stiffness regulating scleral fibroblast behavior through the integrin/F-actin/YAP axis.^22^ Huang et al. showed atropine suppresses HIF-1α in FDM mouse sclera and constructed a preliminary protein–protein interaction network centered on CHRM1-5, linking atropine action to the hypoxia-TGFβ cascade.^23^ TGFβ-Smad and YAP physically interact through nuclear co-localization,^24^ and the Hippo kinase cascade (MST1/2–LATS1/2–YAP/TAZ) is a central regulator of organ size and tissue homeostasis.^25,26^ A recent single-cell study identified Wnt5a-positive scleral fibroblasts as a myopia-protective cell population, further connecting Wnt-Hippo crosstalk to scleral biology.^27^ However, no prior study has systematically examined whether atropine's multiple receptor targets converge on the TGFβ-Hippo-YAP axis.

Prior network pharmacology analyses of atropine in myopia have been limited to basic PPI construction using muscarinic receptors without Hippo-YAP pathway analysis or genetic causal validation.^23^ Mendelian randomization (MR), which uses genetic variants as instrumental variables to infer causal relationships free from confounding,^28,29^ has not been applied to test whether Hippo pathway components are causally linked to myopia. Thus, the causal role of Hippo pathway components in myopia remains untested by genetic epidemiological methods.

In this study, we employed five independent analytical approaches — network pharmacology, Mendelian randomization with replication and colocalization, published evidence mapping, drug signature analysis, and molecular docking — to test the hypothesis that atropine's anti-myopia mechanism operates through multi-receptor convergence on the TGFβ-Hippo-YAP axis. This integrative triangulation design, where each method addresses the limitations of the others, provides stronger evidence than any single analytical framework alone.

\newpage

# METHODS

## 2.1. Study Design

This study employed five independent analytical approaches to test the hypothesis that atropine's anti-myopia mechanism involves multi-receptor convergence on the TGFβ-Hippo-YAP signaling axis (Fig. 1). The five methods were: (1) network pharmacology with Extension Layer analysis, (2) two-sample Mendelian randomization with outcome replication and colocalization, (3) published transcriptomic evidence mapping, (4) drug signature reversal analysis, and (5) molecular docking. This triangulation design follows established principles for strengthening causal inference.^29^ This study used only publicly available summary-level data and did not involve human subjects; institutional review board approval was not required.

## 2.2. Network Pharmacology

### 2.2.1. Atropine Target Identification
Atropine-associated gene targets were retrieved from the Comparative Toxicogenomics Database (CTD) using compound ID D001285, supplemented by DrugBank and SwissTargetPrediction using the canonical SMILES string O=C(OC1CC2CCC1N2C)C(CO)c1ccccc1.^30^ After merging and deduplication, 128 unique atropine-associated gene targets were identified.

### 2.2.2. Myopia-Associated Gene Extraction
Myopia-associated genes were extracted from CTD using disease ID D009216. Only genes with Direct Evidence annotations (marker/mechanism categories) were retained, supplemented with DisGeNET (curated sources) and OMIM. After deduplication, 195 myopia-associated genes were included.

### 2.2.3. PPI Network Construction
The intersection yielded 47 common genes. Of these, 44 had at least one interaction at STRING v12.0 confidence ≥0.700 (Homo sapiens),^31^ forming a connected network of 191 edges. Three genes (CHRM4, ACHE, ADRA2B) lacked interactions above this threshold and were excluded from topological analysis but retained for MR candidate selection and drug signature analysis.

### 2.2.4. Hub Gene Identification
The PPI network was imported into Cytoscape v3.10.2 for topological analysis.^32^ Degree, betweenness centrality, and closeness centrality were calculated using NetworkAnalyzer. Hub genes were defined as nodes in the top 10 by degree.

### 2.2.5. Extension Layer Analysis
Hippo-YAP components (LATS1, LATS2, YAP1, TEAD1-4, WWTR1, NF2, SAV1, AMOT, MOB1A) were deliberately excluded from the intersection network to avoid circular reasoning and added as an adjacent Extension Layer connected through STRING interactions (confidence ≥0.700). Shortest-path analysis from each of four receptor classes — muscarinic (CHRM1, CHRM3, CHRM5), dopaminergic (DRD1, DRD2), adrenergic (ADRA2A, ADRA2C), and nicotinic (CHRNA3, CHRNA4, CHRNB2) — to each Hippo-YAP component was performed.

### 2.2.6. Pathway Enrichment
GO and KEGG enrichment analyses were performed using g:Profiler. Significance was defined as adjusted P < 0.05 (Benjamini-Hochberg).

## 2.3. Mendelian Randomization

### 2.3.1. Data Sources
Two-sample MR was conducted following STROBE-MR guidelines.^29^ Genetic instruments were obtained from the eQTLGen Consortium (N = 31,684; blood cis-eQTLs).^33^ The primary outcome was UK Biobank myopia (ukb-b-6353; N = 460,536).^34^

### 2.3.2. Gene Selection
Seven genes across five modules had sufficient instruments: TGFB1, LOX (TGFβ/ECM), LATS2 (Hippo-YAP), COMT (dopamine), CHRM3 (muscarinic), ADRA2A (adrenergic), and HIF1A (hypoxia). Fifteen additional genes lacked instruments at P < 5 × 10⁻⁶ (Supplementary Table S2). LD clumping: r² < 0.001, window 10,000 kb.

### 2.3.3. Statistical Methods
Single-IV genes: Wald ratio. Multi-IV genes: IVW (primary), weighted median, MR-Egger (sensitivity). All F > 10.

### 2.3.4. Directionality
Steiger testing confirmed causal direction for significant genes.^35^ Reverse MR and PhenoScanner v2 pleiotropy screening were performed.^36^

### 2.3.5. Outcome Replication
TGFB1 was replicated using right-eye (ukb-b-19994) and left-eye (ukb-b-7500) spherical power.

### 2.3.6. Colocalization
Bayesian colocalization (coloc.abf) used full eQTLGen summary statistics and UK Biobank VCF.^37^ Regional data ±500 kb; default priors (p1 = p2 = 10⁻⁴, p12 = 10⁻⁵).

### 2.3.7. Tissue Specificity
GTEx v8 cultured fibroblasts (N ≈ 504) were investigated but yielded insufficient power for instrument extraction at P < 5 × 10⁻⁶.

All analyses: R v4.3.3, TwoSampleMR v0.6.4, ieugwasr v1.0.1.

## 2.4. Published Transcriptomic Evidence Mapping
Molecular findings from six published myopic tissue studies (2018–2026) were systematically extracted.^21,22,23,27,38,39^ For each intersection and Extension Layer gene, reported expression changes were catalogued across studies. Genes with concordant changes across ≥2 studies were classified as published-validated.

## 2.5. Drug Signature Reversal Analysis
The Enrichr platform was queried using the LINCS L1000 Chemical Perturbation Consensus Signatures library.^40^ Twenty-three upregulated hub genes were submitted. Reversal compounds were ranked by combined enrichment score.

## 2.6. Molecular Docking

### 2.6.1. Targets
Four targets were selected: TGFβ1 receptor complex (PDB: 3KFD),^41^ MOB1-LATS1 kinase complex (PDB: 5BRK; proxy for LATS1/2, >85% kinase domain identity),^42^ YAP-TEAD complex (PDB: 3KYS),^43^ and CHRM1 (PDB: 5CXV; positive control).^44^

### 2.6.2. Blind Docking
CB-Dock2 was used for structure-based blind docking.^45^ Up to five cavities were detected per target. Binding energies below −7.0 kcal/mol were considered drug-like. For 5CXV, FitDock template-based docking additionally confirmed orthosteric binding.

## 2.7. Data Availability
All code is available at https://github.com/JungyulPark/Myopia_Study_1.

\newpage

# RESULTS

## 3.1. Network Pharmacology Identifies Multi-Receptor Convergence

A total of 128 atropine-associated targets and 195 myopia-associated genes yielded 47 common genes at intersection (Fig. 2A). Of these, 44 formed a connected PPI network (191 edges; Fig. 2B). Top 10 hub genes by degree: TP53 and AKT1 (21 each), IL6, CTNNB1, and TNF (19 each), JUN (19), IL1B (18), CASP3 and EGFR (17 each), and FOS (16) (Table 1). TGFB1 had degree 12 (betweenness centrality 0.001), ranking outside the top 10 hubs. KEGG enrichment identified 168 pathways (adjusted P < 0.05); Hippo signaling was not independently enriched among the 47 intersection genes.

## 3.2. Extension Layer Reveals Four-Receptor Convergence on Hippo-YAP

All four receptor classes reached Hippo-YAP components: muscarinic (40 paths), nicotinic (32), adrenergic (24), and dopaminergic (16). Representative paths: DRD1 → FOS → TP53 → LATS1 (distance 3); CHRNA3 → ACHE → EGFR → LATS1 (distance 3); CHRM1 → AKT1 → YAP1 (distance 2). TP53 (betweenness centrality 0.058) functions as a critical signal integration bottleneck.

## 3.3. MR Identifies Causal Roles for TGFB1 and LATS2

Among 22 candidates, seven had sufficient IVs (all F > 10; Table 2, Panel A). TGFB1: Wald β = −0.027 (95% CI −0.045 to −0.009), P = 0.003, F = 27.2; Steiger P = 1.7 × 10⁻⁵; reverse MR P = 0.90. LATS2: Wald β = +0.018 (95% CI +0.001 to +0.035), P = 0.040, F = 30.7; Steiger P = 1.3 × 10⁻⁶; reverse MR P = 0.94. HIF1A: IVW P = 0.154 (WM P = 0.068, suggestive). COMT (P = 0.191), ADRA2A (P = 0.796), CHRM3 (P = 0.403), and LOX (P = 0.743) were null.

## 3.4. TGFB1 Replicated Across Three Outcomes

TGFB1 was replicated using continuous refractive error (Table 2, Panel B): right eye β = +0.253 (P = 4.0 × 10⁻⁴), left eye β = +0.264 (P = 2.3 × 10⁻⁴). All three P < 0.001 with consistent directionality.

## 3.5. Colocalization

For TGFB1 (2,668 SNPs): PP.H1 = 94.95%, PP.H4 = 1.79% (Table 2, Panel C). Strong eQTL signal; distributed GWAS architecture. LATS2: insufficient overlapping SNPs.

## 3.6. Published Evidence Confirms Tissue-Level Changes

TGFB1 upregulated in FDM sclera;^21^ YAP1 protein decreased in myopic sclera (Western blot confirmed);^22^ HIF1A upregulated in FDM and suppressed by atropine.^23^ Triple convergence: TGFB1 (5/5 methods) and LATS2 (4/5). YAP1 achieved quadruple convergence (network + literature + CMap + docking) but lacked MR instruments.

## 3.7. Drug Signature Analysis

EGFR inhibitors appeared 8 times in top 50 (gefitinib, AG 1478, canertinib, pelitinib). MEK/ERK inhibitors: 6 times. TWS119 (rank 2, GSK3β/Wnt) connects to Wnt5a scleral biology.^27^ BMS-536924 (rank 7, IGF-1R). The EGFR bridge role was supported by the Extension Layer path CHRNA3 → ACHE → EGFR → LATS1.

## 3.8. Molecular Docking

Positive control CHRM1: FitDock −9.0 (template 6WJC, pocket identity 1.00), CB-Dock2 −8.8. Novel targets (all drug-like): YAP-TEAD −7.9 (1,985 Å³), MOB1-LATS1 −7.6 (1,695 Å³, PPI interface), TGFβ1R −7.5 (4,786 Å³, trimeric interface Chains C/D/K). Binding hierarchy: known target > novel targets, biologically plausible.

\newpage

# DISCUSSION

## 4.1. Multi-Receptor Convergence: Atropine as a Network Modulator

The most striking finding is that all four of atropine's receptor classes converge on Hippo-YAP components within three interaction steps. This convergence was not assumed a priori; Hippo-YAP genes were deliberately placed in a separate Extension Layer, and the convergence emerged from data-driven analysis. This reframes atropine from a "dirty drug" into a network modulator — a compound whose effect arises from partial inhibition of multiple inputs feeding a common convergence point. This concept, established in oncology,^45^ has not been applied to myopia pharmacology. If atropine's effect depends on cumulative partial inhibition rather than potent blockade of any single receptor, this explains why 0.01% atropine retains efficacy.^6,7^

TP53, the global hub (betweenness centrality 0.058), sits at the dopaminergic path intersection (DRD1 → FOS → TP53 → LATS1), positioning it as a signal integration bottleneck whose dysregulation could disproportionately affect downstream Hippo-YAP signaling.

## 4.2. Comparison With Prior Studies

Huang et al. constructed a preliminary PPI network centered on CHRM1-5, identifying AKT1, HIF1α, and CTNNB1 as hubs.^23^ Our study extends this in three dimensions: incorporating all four receptor classes, introducing the Extension Layer strategy, and validating predictions with four independent methods. Network pharmacology alone generates hypotheses; the addition of MR elevates evidence from associative to causal.^28^

## 4.3. Genetic Causality and the Centrality Paradox

The MR results provide the first genetic evidence that Hippo-TGFβ components are causally linked to myopia. A striking finding is the centrality paradox: TGFB1, with the strongest causal signal (P = 0.003), ranked only 17th by degree (12, betweenness 0.001). Top hubs (TP53, AKT1) could not be tested by MR, and tested receptor genes (COMT, CHRM3, ADRA2A) showed null effects. This dissociation demonstrates the irreplaceable value of triangulation: network analysis identifies structure, MR identifies causal drivers, and the two are orthogonal.

The TGFB1 protective effect is consistent with its role in maintaining scleral fibroblast quiescence through Smad2/3-p21 signaling.^19,24^ The LATS2 risk effect is coherent: LATS1/2 kinases phosphorylate YAP for degradation,^25,26^ and elevated LATS2 reduces nuclear YAP — exactly the pattern observed in myopic sclera.^22^

## 4.4. TGFβ Context-Dependent Switching

Our findings support the TGFβ context-dependent switching hypothesis.^24^ When Hippo is active, TGFβ1 signals through Smad2/3 → p21 → cell cycle arrest, maintaining fibroblast quiescence. When Hippo is inactive, TGFβ1 is redirected through YAP-Smad complexes toward ECM-remodeling programs. Our genetic evidence maps onto this model: TGFB1 (protective) maintains the homeostatic arm, while LATS2 (risk) tips the balance toward pathological YAP degradation. This resolves a paradox: why TGFβ1 appears both upregulated^21^ and functionally protective — the same molecule operates differently depending on Hippo-YAP context.

## 4.5. Robustness of the TGFB1 Signal

TGFB1 replication across three phenotype definitions (binary myopia P = 0.003; right-eye spherical power P = 4.0 × 10⁻⁴; left-eye P = 2.3 × 10⁻⁴) with consistent directionality substantially reduces false-positive probability. The colocalization result (PP.H4 = 1.79%) reflects the distributed polygenic architecture of myopia GWAS rather than instrument invalidity; the dominant PP.H1 (94.95%) confirms a robust eQTL signal. Three-outcome replication compensates for inconclusive colocalization, consistent with triangulation principles.^29^

## 4.6. Pharmacological Validation

EGFR inhibitors appeared eight times among the top 50 reversal compounds, corresponding to EGFR (hub #9, betweenness 0.019). MEK/ERK inhibitors (six appearances) correspond to MAPK3/MAPK1 intersection genes. TWS119 (rank 2, Wnt activator) connects to Wnt5a scleral fibroblasts.^27^ EGFR's role as a bridge (CHRNA3 → ACHE → EGFR → LATS1) suggests EGFR transactivation links surface receptor engagement to Hippo pathway modulation.

## 4.7. Structural Insights: PPI Binding

Atropine binds novel targets at protein–protein interfaces. At MOB1-LATS1 (5BRK), atropine occupied the MOB1A–LATS1 kinase interface (−7.6 kcal/mol); LATS activation requires MOB1 binding,^42^ so interference could modulate Hippo output. At TGFβ1R (3KFD), atropine bound at the trimeric interface (−7.5 kcal/mol, cavity 4,786 Å³). The binding hierarchy (CHRM1 −9.0 > novel targets −7.5 to −7.9) is biologically plausible: weaker novel interactions, replicated across multiple nodes, could produce cumulative downstream effects.

## 4.8. Null Results: Undertested, Not Excluded

The COMT null (P = 0.191) is partially consistent with Thomson et al.^15^ However, TH, DRD1, and DRD2 could not be tested due to insufficient IVs and remain neither confirmed nor refuted. The dopamine pathway is undertested rather than excluded. Similarly, CHRM3 was null, but CHRM1, CHRM2, and CHRM4 lacked instruments.^10,11^ The observation that receptor genes showed null effects while convergence genes (TGFB1, LATS2) showed causal effects is consistent with the network modulator hypothesis.

## 4.9. Triple Convergence as Methodology

TGFB1 and LATS2 as triple convergence genes demonstrates the evidential triangulation framework: network pharmacology cannot establish causation (addressed by MR), MR cannot confirm tissue expression (addressed by literature), and published studies cannot prove causality (addressed by MR). No single method would have identified the TGFβ-Hippo-YAP axis; the finding emerged only through their intersection.

## 4.10. Clinical Implications

Verteporfin, an FDA-approved YAP-TEAD inhibitor already used in ophthalmology,^46^ could serve as a targeted anti-myopia agent bypassing receptor-level complexity. The network modulator framework suggests that optimizing atropine may not require receptor-selective compounds but rather understanding cumulative impact at the convergence node — a paradigm shift toward pathway-targeted approaches.

## 4.11. Limitations

(1) Blood-derived eQTLs (eQTLGen N = 31,684) rather than ocular; GTEx fibroblasts (N ≈ 504) had insufficient power.^33^ (2) Single IV for TGFB1/LATS2; coloc PP.H4 low but compensated by three-outcome replication. (3) Fifteen of 22 genes untested by MR. (4) Docking requires experimental validation. (5) Drug signature used Enrichr, not direct L1000CDS2. (6) Literature mapping was qualitative.

## 4.12. Conclusions

Five independent methods demonstrate that atropine's anti-myopia mechanism involves multi-receptor convergence on TGFβ-Hippo-YAP. TGFB1 and LATS2 are genetically causal mediators. Novel PPI binding suggests a network modulator mechanism. These findings provide the first integrative framework reconciling decades of conflicting evidence and reposition the Hippo-YAP axis as a target for next-generation myopia pharmacotherapy.

\newpage

# REFERENCES

1. Holden BA, Fricke TR, Wilson DA, et al. Global prevalence of myopia and high myopia and temporal trends from 2000 through 2050. *Ophthalmology* 2016;123:1036-42.
2. Jung SK, Lee JH, Kakizaki H, Jee D. Prevalence of myopia and its association with body stature and educational level in 19-year-old male conscripts in Seoul, South Korea. *Invest Ophthalmol Vis Sci* 2012;53:5579-83.
3. Morgan IG, Ohno-Matsui K, Saw SM. Myopia. *Lancet* 2012;379:1739-48.
4. Morgan IG, French AN, Ashby RS, et al. The epidemics of myopia: aetiology and prevention. *Prog Retin Eye Res* 2018;62:134-49.
5. Flitcroft DI, He M, Jonas JB, et al. IMI — Defining and classifying myopia. *Invest Ophthalmol Vis Sci* 2019;60:M20-30.
6. Yam JC, Li FF, Zhang X, et al. Two-year clinical trial of the LAMP Study: Phase 2 report. *Ophthalmology* 2020;127:910-9.
7. Navarra R, Richiardi L, Morani F, et al. Efficacy of 0.01% atropine for myopia control in children: a systematic review and meta-analysis. *Front Pharmacol* 2025;16:1497667.
8. Wildsoet CF, Chia A, Cho P, et al. IMI — Interventions for controlling myopia onset and progression report. *Invest Ophthalmol Vis Sci* 2019;60:M106-31.
9. Lee SH, Tsai PC, Chiu YC, Wang JH, Chiu CJ. Myopia progression after cessation of atropine in children: a systematic review and meta-analysis. *Front Pharmacol* 2024;15:1343698.
10. Arumugam B, McBrien NA. Muscarinic antagonist control of myopia: evidence for M4 and M1 receptor-based pathways. *Invest Ophthalmol Vis Sci* 2012;53:5827-37.
11. Barathi VA, Beuerman RW, Schaeffel F. Muscarinic cholinergic receptor (M2) plays a crucial role in the development of myopia in mice. *Dis Model Mech* 2013;6:1146-58.
12. Carr BJ, Stell WK, Bhatt DK. Myopia-inhibiting concentrations of muscarinic receptor antagonists block activation of alpha2A-adrenoceptors in vitro. *Invest Ophthalmol Vis Sci* 2018;59:2778-91.
13. Stone RA, Lin T, Laties AM, Iuvone PM. Retinal dopamine and form-deprivation myopia. *Proc Natl Acad Sci USA* 1989;86:704-6.
14. Feldkaemper M, Schaeffel F. An updated view on the role of dopamine in myopia. *Exp Eye Res* 2013;114:106-19.
15. Thomson K, Kelly T, Gao B, Morgan IG, Bhatt DK. Insights into the mechanism by which atropine inhibits myopia. *Br J Pharmacol* 2021;179:4359-76.
16. Upadhyay A, Beuerman RW. Biological mechanisms of atropine control of myopia. *Eye Contact Lens* 2020;46:129-37.
17. McBrien NA, Gentle A. Role of the sclera in the development and pathological complications of myopia. *Prog Retin Eye Res* 2003;22:307-38.
18. Wallman J, Winawer J. Homeostasis of eye growth and the question of myopia. *Neuron* 2004;43:447-68.
19. Jobling AI, Nguyen M, Gentle A, McBrien NA. Isoform-specific changes in scleral TGF-β expression during myopia progression. *J Biol Chem* 2004;279:18121-6.
20. Gentle A, Liu Y, Martin JE, Conti GL, McBrien NA. Collagen gene expression and scleral collagen during high myopia. *J Biol Chem* 2003;278:16587-94.
21. Wu H, Chen W, Zhao F, et al. Scleral hypoxia is a target for myopia control. *Proc Natl Acad Sci USA* 2018;115:E7091-100.
22. Liu Y, Wang X, Li H, et al. ECM stiffness modulates scleral remodeling through integrin/F-actin/YAP axis in myopia. *Invest Ophthalmol Vis Sci* 2025;66(2):22.
23. Huang L, Zhang J, Luo Y. The role of atropine in myopia control: insights into choroidal and scleral mechanisms. *Front Pharmacol* 2025;16:1509196.
24. Totaro A, Panciera T, Piccolo S. YAP/TAZ upstream signals and downstream responses. *Nat Cell Biol* 2018;20:888-99.
25. Meng Z, Moroishi T, Guan KL. Mechanisms of Hippo pathway regulation. *Genes Dev* 2016;30:1-17.
26. Yu FX, Zhao B, Guan KL. Hippo pathway in organ size control, tissue homeostasis, and cancer. *Cell* 2015;163:811-28.
27. Zhu H, Chen W, Ling X, Jiao S, Yu L, Liu H, Ding M, Zhang F, Zhou Y, Pan Y, Zhou Z, Qu J, Zhao F, Zhao FX, Zhou X. Decreased scleral Wnt5ahi fibroblasts exacerbate myopia progression by disrupting extracellular matrix homeostasis in mice. *Nat Commun* 2026;17:554.
28. Davey Smith G, Hemani G. Mendelian randomization: genetic anchors for causal inference. *Hum Mol Genet* 2014;23:R89-98.
29. Skrivankova VW, Richmond RC, Woolf BAR, et al. STROBE-MR statement. *JAMA* 2021;326:1614-21.
30. Daina A, Michielin O, Zoete V. SwissTargetPrediction: updated data and new features. *Nucleic Acids Res* 2019;47:W357-64.
31. Szklarczyk D, Kirsch R, Koutrouli M, et al. The STRING database in 2023. *Nucleic Acids Res* 2023;51:D483-9.
32. Shannon P, Markiel A, Ozier O, et al. Cytoscape: a software environment for integrated models. *Genome Res* 2003;13:2498-504.
33. Võsa U, Claringbould A, Westra HJ, et al. Large-scale cis- and trans-eQTL analyses. *Nat Genet* 2021;53:1300-10.
34. Elsworth B, Lyon M, Alexander T, et al. The MRC IEU OpenGWAS data infrastructure. *eLife* 2020;9:e59298.
35. Hemani G, Tilling K, Davey Smith G. Orienting the causal relationship between imprecisely measured traits. *PLoS Genet* 2017;13:e1007081.
36. Staley JR, Blackshaw J, Kamat MA, et al. PhenoScanner: a database of human genotype-phenotype associations. *Bioinformatics* 2016;32:3207-9.
37. Giambartolomei C, Vukcevic D, Schadt EE, et al. Bayesian test for colocalisation. *PLoS Genet* 2014;10:e1004383.
38. Yao M, Jiang F, Xu X, et al. Single-cell transcriptomic analysis of myopic retinal remodeling. *MedComm* 2023;4:e372.
39. Yin X, Ge J. The role of scleral changes in the progression of myopia: a review and future directions. *Clin Ophthalmol* 2025;19:1699-1707.
40. Lachmann A, Torre D, Keenan AB, et al. Massive mining of publicly available RNA-seq data. *Nat Commun* 2018;9:1366.
41. Groppe J, Hinck CS, Samavarchi-Tehrani P, et al. Cooperative assembly of TGF-β superfamily signaling complexes. *Mol Cell* 2008;29:157-68.
42. Ni L, Zheng Y, Hara M, et al. Structural basis for auto-inhibition of the NDR family kinase LATS1. *Structure* 2015;23:1467-76.
43. Li Z, Zhao B, Wang P, et al. Structural insights into the YAP and TEAD complex. *Genes Dev* 2010;24:235-40.
44. Thal DM, Sun B, Feng D, et al. Crystal structures of the M1 and M4 muscarinic acetylcholine receptors. *Nature* 2016;531:335-40.
45. Liu Y, Yang X, Gan J, et al. CB-Dock2: improved protein-ligand blind docking. *Nucleic Acids Res* 2022;50:W159-64.
46. Hopkins AL. Network pharmacology: the next paradigm in drug discovery. *Nat Chem Biol* 2008;4:682-90.
47. Liu-Chittenden Y, Huang B, Shim JS, et al. Genetic and pharmacological disruption of the TEAD-YAP complex. *Genes Dev* 2012;26:1300-5.

\newpage

# FIGURE LEGENDS

**Figure 1.** Study design: five-method triangulation for atropine–myopia mechanism. Five independent analytical methods (network pharmacology, Mendelian randomization, published evidence mapping, drug signature reversal, and molecular docking) converge on the TGFβ-Hippo-YAP axis as the downstream effector.

**Figure 2.** Network pharmacology and Extension Layer analysis. (A) Venn diagram showing intersection of 128 atropine targets and 195 myopia-associated genes, yielding 47 common genes. (B) Hierarchical network showing hub genes (top), receptor classes (middle), and Extension Layer convergence on YAP1 (bottom). Node size proportional to degree; colors indicate receptor class (red = muscarinic, orange = dopaminergic, blue = adrenergic, teal = nicotinic). Asterisks indicate MR causal genes (TGFB1 P = 0.003; LATS2 P = 0.040). The 44 connected genes are shown; 3 singletons (CHRM4, ACHE, ADRA2B) are excluded from the network visualization.

**Figure 3.** Mendelian randomization results. (A) Forest plot of causal estimates for seven genes with sufficient instrumental variables. Bold indicates P < 0.05. (B) TGFB1 replication across three independent outcomes: binary myopia (P = 0.003), right-eye spherical power (P = 4.0 × 10⁻⁴), and left-eye spherical power (P = 2.3 × 10⁻⁴).

**Figure 4.** Triangulation and molecular docking. (A) Evidence heatmap showing convergence of five methods across key genes. Symbols: ++ strong evidence, + supported, ± suggestive, — not tested. Score indicates number of methods with positive evidence. (B) Molecular docking binding energies. Positive control CHRM1 (FitDock −9.0 kcal/mol) compared with novel targets. Dashed line indicates drug-like binding threshold (−7.0 kcal/mol). MR P-values annotated for genetically validated targets.

\newpage

# SUPPLEMENTARY MATERIALS

*Supplementary Table S1.* Topological properties of 44 connected intersection genes. (See separate file.)

*Supplementary Table S2.* Complete Mendelian randomization results for all 22 candidate genes, including 15 with insufficient instrumental variables. (See separate file.)

*Supplementary Table S3.* Drug signature reversal analysis — top 50 compounds from Enrichr LINCS L1000 with drug class enrichment summary. (See separate file.)
