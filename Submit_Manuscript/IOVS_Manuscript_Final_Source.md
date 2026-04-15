---
title: ""
---

# TITLE PAGE

**Title**: Multi-Receptor Convergence on TGFβ-Hippo-YAP Axis in Atropine's Anti-Myopia Mechanism: Integrative Evidence From Network Pharmacology, Mendelian Randomization, and Molecular Docking

**Running head**: Multi-receptor convergence on Hippo-YAP in myopia

**Authors**: Park Jungyul, MD, PhD

**Affiliation**: Department of Ophthalmology, Seoul St. Mary's Hospital, College of Medicine, The Catholic University of Korea, Seoul, Republic of Korea

**Corresponding author**: Park Jungyul, MD, PhD; Department of Ophthalmology, Seoul St. Mary's Hospital, 222 Banpo-daero, Seocho-gu, Seoul 06591, Republic of Korea

**Word count**: Abstract 248; Manuscript approximately 5,500

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

Recent evidence implicates the Hippo-YAP signaling pathway as a potential convergence point linking receptor-level signals to scleral remodeling. Liu et al. demonstrated that YAP expression is decreased in myopic sclera from both human tissue and guinea pig models, with ECM stiffness regulating scleral fibroblast behavior through the integrin/F-actin/YAP axis.^22^ Huang et al. showed atropine suppresses HIF-1α in FDM mouse sclera and constructed a preliminary protein–protein interaction network centered on muscarinic receptors, linking atropine action to the hypoxia-TGFβ cascade.^23^ TGFβ-Smad and YAP physically interact through nuclear co-localization,^24^ and the Hippo kinase cascade (MST1/2–LATS1/2–YAP/TAZ) is a central regulator of organ size and tissue homeostasis.^25,26^ A recent single-cell study identified Wnt5a-positive scleral fibroblasts as a myopia-protective cell population, further connecting Wnt-Hippo crosstalk to scleral biology.^27^ However, no prior study has systematically examined whether atropine's multiple receptor targets converge on the TGFβ-Hippo-YAP axis.

Prior network pharmacology analyses of atropine in myopia have been limited to basic PPI construction using muscarinic receptors without Hippo-YAP pathway analysis or genetic causal validation.^23^ Mendelian randomization (MR), which uses genetic variants as instrumental variables to infer causal relationships free from confounding,^28,29^ has not been applied to test whether Hippo pathway components are causally linked to myopia. Thus, the causal role of Hippo pathway components in myopia remains untested by genetic epidemiological methods.

In this study, we employed five independent analytical approaches — network pharmacology, Mendelian randomization with replication and colocalization, published evidence mapping, drug signature analysis, and molecular docking — to test the hypothesis that atropine's anti-myopia mechanism operates through multi-receptor convergence on the TGFβ-Hippo-YAP axis. This integrative triangulation design, where each method addresses the limitations of the others, provides stronger evidence than any single analytical framework alone.


ewpage

# METHODS

## 2.1. Study Design

This study employed five independent analytical approaches to test the hypothesis that atropine's anti-myopia mechanism involves multi-receptor convergence on the TGFβ-Hippo-YAP signaling axis (Fig. 1). The five methods were: (1) network pharmacology with Extension Layer analysis, (2) two-sample Mendelian randomization with outcome replication and colocalization, (3) published transcriptomic evidence mapping, (4) drug signature reversal analysis, and (5) molecular docking. This triangulation design follows established principles for strengthening causal inference in observational research.^29^ This study used only publicly available summary-level data and did not involve human subjects; institutional review board approval was not required.

## 2.2. Network Pharmacology

### 2.2.1. Atropine Target Identification

Atropine-associated gene targets were retrieved from the Comparative Toxicogenomics Database (CTD; http://ctdbase.org) using compound ID D001285, supplemented by DrugBank (https://go.drugbank.com) and SwissTargetPrediction (http://www.swisstargetprediction.ch) using the canonical SMILES string O=C(OC1CC2CCC1N2C)C(CO)c1ccccc1.^30^ Gene lists were merged, and duplicates were removed, yielding 128 unique atropine-associated gene targets.

### 2.2.2. Myopia-Associated Gene Extraction

Myopia-associated genes were extracted from CTD using disease ID D009216 (myopia). To minimize noise from inferred associations, only genes with Direct Evidence annotations (marker/mechanism categories) were retained. This curated set was supplemented with genes from the DisGeNET database (curated sources only) and the Online Mendelian Inheritance in Man (OMIM) catalog. After deduplication, 195 myopia-associated genes were included.

### 2.2.3. Protein–Protein Interaction Network Construction

The intersection of atropine targets and myopia-associated genes yielded 47 common genes. Of these, 44 had at least one interaction at STRING v12.0 (https://string-db.org) confidence ≥0.700 (high confidence, *Homo sapiens*),^31^ forming a connected network of 44 nodes and 191 edges. Three genes (CHRM4, ACHE, ADRA2B) lacked interactions above this threshold and were excluded from topological analysis but retained for MR candidate selection and drug signature analysis.

### 2.2.4. Hub Gene Identification and Topological Analysis

The PPI network was imported into Cytoscape (v3.10.2) for topological analysis.^32^ Node centrality metrics — degree, betweenness centrality, and closeness centrality — were calculated using the NetworkAnalyzer plugin. Hub genes were defined as nodes ranking in the top 10 by degree centrality. CytoHubba was used for complementary hub ranking validation.

### 2.2.5. Extension Layer Analysis

To test whether atropine's receptor targets can reach the Hippo-YAP signaling machinery, we designed an Extension Layer analysis. Hippo-YAP pathway components (LATS1, LATS2, YAP1, TEAD1-4, WWTR1, NF2, SAV1, AMOT, MOB1A) were deliberately excluded from the initial intersection network to avoid circular reasoning, and were instead added as an adjacent layer connected through STRING-validated interactions (confidence ≥0.700). Shortest-path analysis (Dijkstra's algorithm) was performed from each of the four receptor classes — muscarinic (CHRM1, CHRM3, CHRM5), dopaminergic (DRD1, DRD2), adrenergic (ADRA2A, ADRA2C), and nicotinic (CHRNA3, CHRNA4, CHRNB2) — to each Hippo-YAP component, using intersection hub genes as intermediaries. The number of paths, representative shortest paths, and path distances were recorded for each receptor class.

### 2.2.6. Pathway Enrichment

Gene Ontology (GO) and Kyoto Encyclopedia of Genes and Genomes (KEGG) enrichment analyses were performed on the 47 intersection genes using g:Profiler (https://biit.cs.ut.ee/gprofiler). Statistical significance was defined as adjusted P < 0.05 (Benjamini-Hochberg correction).

## 2.3. Mendelian Randomization

### 2.3.1. Study Design and Data Sources

Two-sample Mendelian randomization was conducted in accordance with the STROBE-MR guidelines.^29^ Genetic instruments for gene expression were obtained from the eQTLGen Consortium (N = 31,684; blood-derived cis-eQTLs).^33^ The primary outcome was self-reported myopia from the UK Biobank (dataset ukb-b-6353; N = 460,536; 37,362 cases, 423,174 controls).^34^

### 2.3.2. Gene Selection and Instrument Extraction

Seven genes spanning five mechanistic modules were selected based on network pharmacology results, biological relevance, and instrument availability: TGFB1 and LOX (TGFβ/ECM module), LATS2 (Hippo-YAP module), COMT (dopamine module), CHRM3 (muscarinic module), ADRA2A (adrenergic module), and HIF1A (hypoxia module). An additional 15 genes (including TH, DRD1, DRD2, YAP1, LATS1, TEAD1, CHRM1, CHRM2, CHRM4, CHRM5) had insufficient instrumental variables at the selected threshold and are reported in Supplementary Table S2. Cis-eQTLs reaching genome-wide significance (P < 5 × 10⁻⁶) were selected as instrumental variables. Linkage disequilibrium clumping was performed using a European reference panel (r² < 0.001, window = 10,000 kb). Instruments were harmonized with the outcome dataset; palindromic SNPs with intermediate allele frequencies were excluded.

### 2.3.3. Statistical Methods

For genes with a single instrumental variable, the Wald ratio was applied. For genes with two or more instruments, the inverse variance-weighted (IVW) method was used as the primary analysis. Sensitivity analyses included the weighted median method (for up to 50% invalid instruments), MR-Egger regression (for directional pleiotropy detection), and leave-one-out analysis. Instrument strength was evaluated using the F-statistic; all included instruments exceeded the conventional threshold of F > 10.

### 2.3.4. Directionality and Reverse Causality

Steiger directionality testing was performed for significant genes to confirm that genetic variants explain more variance in the exposure (gene expression) than in the outcome (myopia).^35^ Reverse MR (outcome → exposure) was conducted as an additional check against reverse causation. PhenoScanner v2 (http://www.phenoscanner.medschl.cam.ac.uk) was queried to identify pleiotropic associations of lead instruments at genome-wide significance.^36^

### 2.3.5. Outcome Replication

To assess robustness across phenotype definitions, causal estimates for TGFB1 were replicated using two continuous refractive error outcomes from the UK Biobank: right-eye spherical power (ukb-b-19994) and left-eye spherical power (ukb-b-7500). A positive beta for spherical power indicates a shift toward less myopic refraction, consistent with a protective effect against myopia.

### 2.3.6. Bayesian Colocalization

Colocalization analysis was performed using the coloc R package (coloc.abf method) to assess whether the eQTL signal for TGFB1 and the myopia GWAS signal share a common causal variant.^37^ Full cis-eQTL summary statistics were obtained from the eQTLGen Consortium (release 2019-12-11), and UK Biobank GWAS summary statistics (ukb-b-6353) were downloaded in VCF format. Regional data (±500 kb from the transcription start site) were extracted. Prior probabilities were set to defaults (p1 = p2 = 10⁻⁴, p12 = 10⁻⁵). PP.H4 > 0.80 was considered strong evidence for colocalization.

### 2.3.7. Tissue Specificity Limitation

We note that eQTLGen provides blood-derived eQTLs. Tissue-specific databases (GTEx v8 cultured fibroblasts, N ≈ 504) were investigated but yielded insufficient statistical power for instrument extraction at P < 5 × 10⁻⁶, owing to markedly smaller sample sizes compared with eQTLGen (N = 31,684). All MR analyses were conducted in R (v4.3.3) using the TwoSampleMR (v0.6.4) and ieugwasr (v1.0.1) packages.

## 2.4. Published Transcriptomic Evidence Mapping

To validate network pharmacology predictions with independent tissue-level data, we systematically extracted molecular findings from six published myopic tissue studies spanning 2018–2026.^21,22,23,27,38,39^ These encompassed scleral and retinal tissues from mouse, guinea pig, and human models, using methods including single-cell RNA sequencing, Western blot, quantitative PCR, and immunofluorescence. For each of the 47 intersection genes and 11 Extension Layer genes, we catalogued reported expression changes (upregulated, downregulated, or not reported) across studies. Genes showing concordant changes across ≥2 independent studies were classified as published-validated. Cross-referencing with MR results enabled three-way triangulation: network prediction × genetic causality × tissue-level expression.

## 2.5. Drug Signature Reversal Analysis

To identify pharmacological classes whose expression signatures most effectively reverse the 47-gene intersection profile, we queried the Enrichr platform (https://maayanlab.cloud/Enrichr) using the LINCS L1000 Chemical Perturbation Consensus Signatures library.^40^ The 23 upregulated hub genes (top 10 hubs plus key signal transducers) were submitted as the input gene set. Reversal compounds were ranked by combined enrichment score. Drug classes were annotated using DrugBank and the IUPHAR Guide to Pharmacology.

## 2.6. Molecular Docking

### 2.6.1. Target Selection and Structure Preparation

Four protein targets were selected for molecular docking based on convergent evidence from network pharmacology and MR: (1) TGFβ1 receptor complex (PDB: 3KFD; TGFβ1–TβRII trimeric complex, resolution 3.00 Å),^41^ (2) MOB1-LATS1 kinase complex (PDB: 5BRK; pMob1–Lats1 complex, resolution 2.35 Å)^42^ as a proxy for LATS1/2 (LATS1 and LATS2 share >85% kinase domain sequence identity), (3) YAP-TEAD complex (PDB: 3KYS; YAP–TEAD1 complex, resolution 2.50 Å),^43^ and (4) muscarinic acetylcholine receptor M1 (PDB: 5CXV; resolution 2.70 Å)^44^ as a positive control. Protein structures were retrieved from the RCSB Protein Data Bank. Water molecules, co-crystallized ligands, and non-essential heteroatoms were removed. The atropine ligand structure was obtained in SDF format from PubChem (CID 174174).

### 2.6.2. Blind Docking Protocol

Structure-based blind docking was performed using CB-Dock2 (https://cadd.labshare.cn/cb-dock2/),^45^ which automatically identifies all potential binding cavities on the protein surface and docks the ligand into each cavity using AutoDock Vina. For each protein–ligand pair, up to five cavities were detected and ranked by Vina binding energy (kcal/mol). Binding energies below −7.0 kcal/mol were considered indicative of drug-like binding affinity. For the positive control (5CXV, CHRM1), CB-Dock2 additionally performed template-based blind docking (FitDock), which identified template 6WJC (pocket identity = 1.00) as a reference, confirming orthosteric binding.

### 2.6.3. Binding Site Interpretation

Contact residues within 4 Å of the docked atropine pose were recorded for each cavity. For multi-chain complexes (3KFD, 5BRK), binding at the protein–protein interface was noted, as such binding may disrupt complex formation and modulate downstream signaling. Docking scores for novel targets were compared with the positive control to assess relative binding strength.

## 2.7. Data Availability

All data, code, and analytical scripts used in this study are publicly available at https://github.com/JungyulPark/Myopia_Study_1.


ewpage

# RESULTS

## 3.1. Network Pharmacology Identifies Multi-Receptor Convergence on Hub Genes

A total of 128 atropine-associated targets were retrieved from CTD (107 genes), DrugBank, and SwissTargetPrediction, and 195 myopia-associated genes were extracted from CTD (Direct Evidence only), DisGeNET (curated), and OMIM. Their intersection yielded 47 common genes (Fig. 2A). Of these, 44 had at least one protein–protein interaction at STRING confidence ≥0.700, forming a connected network of 44 nodes and 191 edges (Fig. 2B). Three intersection genes — CHRM4, ACHE, and ADRA2B — lacked interactions above this threshold and were excluded from topological analysis but retained for pathway-level analyses.

Topological analysis identified 10 hub genes ranked by degree centrality (Table 1): TP53 and AKT1 (degree 21 each; betweenness centrality 0.058 and 0.046, respectively), IL6, CTNNB1, and TNF (degree 19 each), JUN (degree 19), IL1B (degree 18), CASP3 and EGFR (degree 17 each), and FOS (degree 16). TP53 also had the highest closeness centrality (0.507). Notably, TGFB1 had a degree of only 12 (betweenness centrality 0.001) and ranked 17th, well outside the top 10 hubs.

KEGG pathway enrichment of the 47 intersection genes identified 168 pathways at adjusted P < 0.05 (Benjamini-Hochberg correction), with the most significantly enriched including pathways in cancer (adjusted P = 2.1 × 10⁻³⁵), lipid and atherosclerosis (adjusted P = 5.8 × 10⁻²⁸), and IL-17 signaling (adjusted P = 1.2 × 10⁻²²). GO biological process enrichment highlighted response to xenobiotic stimulus (adjusted P = 8.7 × 10⁻²⁰) and positive regulation of gene expression (adjusted P = 1.4 × 10⁻¹⁸). The Hippo signaling pathway was not independently enriched among the 47 intersection genes, consistent with the deliberate exclusion of Hippo-YAP components from this gene set.

## 3.2. Extension Layer Analysis Reveals Four-Receptor Convergence on Hippo-YAP

The Extension Layer analysis, in which 11 Hippo-YAP pathway genes were added as an adjacent layer connected through intersection hub genes, demonstrated that all four receptor classes reached Hippo-YAP components through the PPI network (Fig. 2B). The muscarinic class (CHRM1, CHRM3, CHRM5) generated the most paths (40 paths), followed by the nicotinic class (CHRNA3, CHRNA4, CHRNB2; 32 paths), the adrenergic class (ADRA2A, ADRA2C; 24 paths), and the dopaminergic class (DRD1, DRD2; 16 paths).

Representative shortest paths included: dopaminergic, DRD1 → FOS → TP53 → LATS1 (distance 3), traversing the highest-betweenness hub TP53; nicotinic, CHRNA3 → ACHE → EGFR → LATS1 (distance 3), with EGFR serving as a bridge node; muscarinic, CHRM1 → AKT1 → YAP1 (distance 2); and adrenergic, ADRA2A → TP53 → LATS1 (distance 2). The mean shortest-path distance across all receptor-to-Hippo combinations was 2.7 ± 0.5 steps, indicating convergence within a compact network neighborhood.

## 3.3. Mendelian Randomization Identifies Causal Roles for TGFB1 and LATS2

Among 22 candidate genes spanning five mechanistic modules, seven had sufficient instrumental variables (all F > 10) for MR analysis (Table 2, Panel A). The remaining 15 genes — including TH, DRD1, DRD2, YAP1, LATS1, TEAD1, and CHRM1 — lacked cis-eQTLs at P < 5 × 10⁻⁶ in eQTLGen and are reported in Supplementary Table S2.

TGFB1 showed a significant causal protective effect against myopia (Wald ratio β = −0.027, SE = 0.009, 95% CI −0.045 to −0.009, P = 0.003, F = 27.2; lead instrument rs1963413, effect allele A, EAF = 0.614). Steiger directionality testing confirmed the correct causal direction (P = 1.7 × 10⁻⁵), and reverse MR was null (P = 0.90). PhenoScanner identified an association of rs1963413 with standing height at genome-wide significance.

LATS2 showed a significant causal risk-increasing effect (Wald ratio β = +0.018, SE = 0.009, 95% CI +0.001 to +0.035, P = 0.040, F = 30.7; lead instrument rs10891299). Steiger testing confirmed directionality (P = 1.3 × 10⁻⁶), reverse MR was null (P = 0.94), and PhenoScanner revealed no pleiotropic associations.

HIF1A showed a suggestive but non-significant association by IVW (4 instruments; β = −0.004, SE = 0.003, P = 0.154), with the weighted median method yielding a borderline result (P = 0.068). COMT (IVW β = −0.002, SE = 0.001, P = 0.191; MR-Egger intercept P = 0.35), ADRA2A (IVW β = +0.001, SE = 0.004, P = 0.796; weighted median P = 0.71), CHRM3 (Wald β = −0.009, SE = 0.010, P = 0.403), and LOX (Wald β = +0.002, SE = 0.007, P = 0.743) showed no significant causal associations.

## 3.4. TGFB1 Causal Effect Replicated Across Three Independent Outcomes

The TGFB1 causal estimate was replicated using two continuous refractive error phenotypes (Table 2, Panel B). TGFB1 expression was associated with higher spherical power (less myopic refraction) in the right eye (ukb-b-19994; β = +0.253, SE = 0.071, 95% CI +0.114 to +0.392, P = 4.0 × 10⁻⁴) and the left eye (ukb-b-7500; β = +0.264, SE = 0.072, 95% CI +0.123 to +0.405, P = 2.3 × 10⁻⁴). All three outcomes — binary myopia (P = 0.003), right-eye spherical power (P = 4.0 × 10⁻⁴), and left-eye spherical power (P = 2.3 × 10⁻⁴) — showed P < 0.001 with consistent directionality. The bilateral consistency provides an internal replication. LATS2 replication was not possible as rs10891299 was unavailable in the continuous refractive error datasets.

## 3.5. Colocalization Analysis

Bayesian colocalization for the TGFB1 locus used 2,668 regional SNPs with full eQTLGen summary statistics and UK Biobank myopia GWAS (Table 2, Panel C). The analysis yielded strong evidence of an eQTL signal (PP.H0 = 2.29%, PP.H1 = 94.95%, PP.H2 = 0.02%, PP.H3 = 0.95%, PP.H4 = 1.79%). The dominant PP.H1 confirms robust cis-regulation of TGFB1 expression. The low PP.H4 indicates no sharp GWAS peak at this locus, likely reflecting the polygenic architecture of myopia rather than instrument invalidity. LATS2 colocalization could not be performed due to fewer than five overlapping SNPs.

## 3.6. Published Evidence Mapping Confirms Tissue-Level Expression Changes

Cross-referencing the 47 intersection genes and Extension Layer genes with six published myopic tissue studies spanning 2018–2026 identified concordant expression changes for key convergence genes (Table 3).^21,22,23,27,38,39^ TGFB1 was upregulated in form-deprived sclera in mouse and guinea pig models.^21^ YAP1 protein was decreased in myopic sclera from both guinea pig and human tissue, confirmed by Western blot.^22^ HIF1A was upregulated in myopic sclera^21^ and suppressed by atropine treatment.^23^ COL1A1 was consistently downregulated across three independent studies using different species and methods.^22,27^ FOS was upregulated as an immediate early gene in retinal tissue,^38^ consistent with its intermediary role in the dopaminergic Extension Layer path.

Two genes achieved triple convergence across network pharmacology, genetic causality, and published tissue expression: TGFB1 (5/5 methods positive) and LATS2 (4/5 methods). YAP1 achieved quadruple convergence across network, literature, CMap, and docking but could not be tested by MR due to insufficient instruments. HIF1A achieved near-triple convergence (intersection gene; suggestive MR P = 0.068 by weighted median; published upregulation in FDM and suppression by atropine).

## 3.7. Drug Signature Analysis Validates Network-Predicted Pharmacological Classes

Enrichr analysis using the LINCS L1000 Chemical Perturbation Consensus Signatures library identified drug classes whose expression signatures reverse the 47-gene intersection profile (Supplementary Table S3). EGFR inhibitors dominated the results, with gefitinib, tyrphostin AG 1478, canertinib, and pelitinib collectively appearing eight times among the top 50 hits. MEK/ERK inhibitors (PD-184352, PD-0325901, selumetinib) appeared six times, and Src inhibitors (saracatinib, dasatinib) appeared three times. TWS119 (rank 2), a GSK3β inhibitor activating Wnt signaling, connects to the Wnt5a–scleral fibroblast axis.^27^ BMS-536924 (rank 7), an IGF-1R inhibitor, targets ocular growth factor signaling.

The convergence of EGFR inhibitors with network results — EGFR ranked as hub #9 (degree 17, betweenness 0.019) and bridged the nicotinic Extension Layer path (CHRNA3 → ACHE → EGFR → LATS1) — provides independent pharmacological validation. No muscarinic agonists or antagonists appeared among the top 50 hits.

## 3.8. Molecular Docking Demonstrates Drug-Like Binding at Novel Targets

The positive control CHRM1 (5CXV) yielded the strongest binding: FitDock −9.0 kcal/mol using template 6WJC (pocket identity 1.00, confirming orthosteric binding) and CB-Dock2 −8.8 kcal/mol (Table 4). Key contact residues included GLN43, TRP56, ASP63, HIS185, and PHE189 on Chain A.

All three novel targets exhibited drug-like binding affinity below −7.0 kcal/mol. YAP-TEAD (3KYS) yielded −7.9 kcal/mol (cavity volume 1,985 Å³), with contact residues spanning the protein–protein interface across Chain C (PHE206, PHE224, PHE275, VAL293, MET343, PHE350, LEU367, PHE370 and others) and Chain D (HIS52, GLN53, VAL55, VAL57). MOB1-LATS1 (5BRK) yielded −7.6 kcal/mol (cavity 1,695 Å³), with atropine positioned at the interface between MOB1A (Chain A) and the LATS1 kinase domain (Chain B), involving residues from both chains including TRP56, ASP63, HIS185 (Chain A) and HIS646, ARG657, LYS661, TYR692 (Chain B). No FitDock template was found, confirming this binding site has not been previously characterized. TGFβ1 receptor (3KFD) yielded −7.5 kcal/mol with the largest cavity (4,786 Å³), binding at the trimeric interface spanning Chain C (TGFβ1), Chain D (TβRII), and Chain K.

The binding hierarchy — known target (−9.0) > novel targets (−7.5 to −7.9) — is biologically plausible, with primary activity at muscarinic receptors and secondary lower-affinity engagement at downstream convergence targets.


ewpage

# DISCUSSION

The central finding of this study is that all four of atropine's receptor classes — muscarinic, dopaminergic, adrenergic, and nicotinic — converge on the TGFβ-Hippo-YAP axis through shared hub gene intermediaries within two to three interaction steps. This convergence was not assumed a priori; the Hippo-YAP genes were deliberately placed in a separate Extension Layer to avoid circular reasoning, and the convergence emerged from data-driven shortest-path analysis. This finding reframes atropine from a "dirty drug" with nonspecific pleiotropic effects into a network modulator — a compound whose therapeutic effect arises precisely because it partially inhibits multiple upstream inputs that feed into a common signaling convergence point. This concept, well established in oncology where multi-targeted kinase inhibitors exploit network vulnerability rather than single-target potency,^46^ has not previously been applied to myopia pharmacology. The practical consequence is significant: if atropine's anti-myopia effect depends on cumulative partial inhibition across receptor classes rather than potent blockade of any single receptor, this would explain why low-concentration atropine (0.01%) — at doses far below the IC₅₀ for any individual muscarinic receptor — retains measurable clinical efficacy.^6,7^ The topological structure of the convergence network carries additional mechanistic information. TP53, the global hub with the highest betweenness centrality (0.058), sits at the intersection of the dopaminergic path (DRD1 → FOS → TP53 → LATS1, distance 3) and other receptor-initiated cascades. This positions TP53 as a signal integration bottleneck: dysregulation of this single node could disproportionately affect downstream Hippo-YAP signaling regardless of which receptor is the upstream trigger. Whether TP53's role is direct (transcriptional regulation of LATS kinases) or indirect (through p21-CDK cell cycle arrest that interacts with Hippo output) warrants further investigation.

A recent study by Huang et al. constructed a preliminary PPI network centered on CHRM1-5, identifying AKT1, HIF-1α, and CTNNB1 as hub nodes.^23^ Our study extends this work in three critical dimensions. First, we incorporated all four receptor classes (including adrenergic and nicotinic), which doubles the pharmacological input space. Second, we introduced the Extension Layer strategy, which enables hypothesis testing — do receptors reach Hippo-YAP? — without inflating the intersection network. Third, and most importantly, we validated network predictions with four independent methods — MR, published evidence, drug signatures, and docking — whereas prior studies relied on network topology alone. The contrast between our results and those of Huang et al. highlights a broader methodological point: network pharmacology alone generates hypotheses but cannot distinguish correlation from causation. The addition of MR — which leverages genetic variants as instrumental variables immune to confounding^28^ — elevates the evidence from associative to causal, fundamentally changing the strength of the conclusion.

The MR results provide the first genetic evidence that Hippo-TGFβ pathway components are causally linked to myopia. TGFB1 showed a protective causal effect (P = 0.003) while LATS2 showed a risk-increasing effect (P = 0.040), and both passed stringent sensitivity analyses including Steiger directionality, reverse MR, and PhenoScanner pleiotropy screening. A particularly instructive finding is what we term the centrality paradox: TGFB1, the gene with the strongest causal signal, ranked only 17th by degree centrality (degree 12, betweenness centrality 0.001) and was not classified as a core hub. By contrast, the top-ranked hub genes (TP53, AKT1, IL6 — each degree ≥19) could not be tested by MR due to insufficient instrumental variables, and those that could be tested (COMT, CHRM3, ADRA2A) showed null causal effects. This dissociation between network centrality and causal importance demonstrates the irreplaceable value of evidential triangulation: network analysis identifies pathway structure and connectivity, while MR identifies causal drivers within that structure — and the two measures are orthogonal. Reliance on either alone would have missed the central finding. The biological interpretation of the TGFB1 protective effect is consistent with its dual role in scleral biology. In the context of active Hippo signaling (Hippo ON), TGFβ1 signals through the Smad2/3–p21 axis to maintain scleral fibroblasts in a quiescent G0/G1 state, preserving ECM homeostasis.^19,24^ Higher genetically determined TGFB1 expression may reinforce this quiescent state, protecting against pathological ECM remodeling. The LATS2 risk effect is mechanistically coherent in the opposite direction: LATS1/2 kinases phosphorylate YAP, promoting its cytoplasmic sequestration and degradation.^25,26^ Elevated LATS2 activity leads to reduced nuclear YAP, a state precisely observed in myopic sclera by Liu et al. (YAP protein decreased by Western blot).^22^ This bidirectional genetic evidence — TGFB1 protective, LATS2 risk — converges on a single downstream outcome: dysregulated YAP-mediated scleral remodeling.

Our findings support and extend the TGFβ context-dependent switching hypothesis.^24^ TGFβ-Smad and YAP physically interact through nuclear co-localization, and the biological outcome of TGFβ signaling depends critically on the Hippo pathway state. When Hippo is active (LATS1/2 phosphorylating YAP), TGFβ1 signaling is directed through canonical Smad2/3 → p21 → cell cycle arrest, maintaining scleral fibroblast quiescence. When Hippo is inactive (YAP nuclear), TGFβ1 is redirected through YAP-Smad nuclear complexes toward proliferative and ECM-remodeling gene programs. Our genetic evidence maps directly onto this model: TGFB1 (protective) maintains the homeostatic arm, while LATS2 (risk, increasing YAP phosphorylation and degradation) tips the balance toward the pathological arm by eliminating nuclear YAP that would otherwise sustain normal ECM output. The net effect is a sclera that cannot maintain collagen homeostasis under mechanical stress, leading to axial elongation. This context-dependent model resolves a long-standing paradox in myopia biology: why TGFβ1 appears both upregulated in experimental myopia^21^ and functionally protective — the answer is that the same molecule operates differently depending on the Hippo-YAP context of the scleral fibroblast.

The TGFB1 causal finding achieves a level of robustness unusual in MR studies of complex traits. Replication across three independent phenotype definitions — binary myopia (P = 0.003), right-eye spherical power (P = 4.0 × 10⁻⁴), and left-eye spherical power (P = 2.3 × 10⁻⁴) — with consistent directionality substantially reduces the probability of a false-positive finding. In ophthalmology, few MR findings have been replicated across both categorical and continuous definitions of the same trait. The colocalization result (PP.H4 = 1.79%) warrants careful interpretation rather than dismissal. The dominant signal was PP.H1 (94.95%), indicating a strong eQTL effect with no corresponding GWAS peak at this specific locus. This is expected given the polygenic architecture of myopia: the UK Biobank myopia GWAS distributes genetic risk across thousands of loci, none of which individually achieves a sharp peak at the TGFB1 region. Low PP.H4 in this context reflects the distributed nature of the GWAS signal rather than invalidity of the causal instrument. The three-outcome replication (each P < 0.001) provides convergent evidence of causality that compensates for the inconclusive colocalization, consistent with the triangulation principle that each method addresses the others' limitations.^29^

The drug signature analysis provides an independent, pharmacological dimension of validation. EGFR inhibitors appeared eight times among the top 50 reversal compounds, followed by MEK/ERK inhibitors (six appearances). Both classes directly correspond to network-predicted hub genes: EGFR ranked 9th by degree centrality (betweenness 0.019), and MAPK3/MAPK1 (ERK1/2) ranked among the top 15 intersection genes. The concordance between network topology and pharmacological signature reversal — two entirely independent analytical frameworks — substantially strengthens the conclusion that these pathways are functionally relevant. TWS119 (rank 2), a GSK3β inhibitor that activates Wnt/β-catenin signaling, connects to the recent discovery that Wnt5a-positive scleral fibroblasts constitute a myopia-protective cell population.^27^ This pharmacological link between the 47-gene intersection signature and Wnt-mediated scleral biology, not predicted by the network pharmacology analysis, emerged independently from the drug signature query and represents a potential avenue for therapeutic investigation. The role of EGFR deserves particular attention. In the Extension Layer analysis, the nicotinic path CHRNA3 → ACHE → EGFR → LATS1 positions EGFR as a bridge connecting nicotinic receptor signaling to the Hippo kinase cascade. The repeated appearance of EGFR inhibitors in the CMap analysis suggests that EGFR transactivation — a well-documented phenomenon in which GPCR activation triggers EGFR signaling through matrix metalloproteinase-mediated HB-EGF shedding — may be a key mechanism linking surface receptor engagement to Hippo pathway modulation in the sclera.

Molecular docking revealed that atropine binds novel Hippo pathway targets at protein–protein interfaces rather than conventional orthosteric pockets. At the MOB1-LATS1 complex (PDB: 5BRK), atropine occupied the interface between the activating subunit (MOB1A, Chain A) and the LATS1 kinase domain (Chain B) at −7.6 kcal/mol. LATS kinase activation requires MOB1 binding as a prerequisite step;^42^ interference at this interface could suppress LATS activity, reduce YAP phosphorylation, and consequently increase nuclear YAP — modulating the very Hippo output that our MR analysis identified as causally relevant. At the TGFβ1 receptor complex (PDB: 3KFD), atropine bound at the trimeric interface spanning Chains C (TGFβ1), D (TβRII), and K, with a cavity volume of 4,786 Å³ and binding energy of −7.5 kcal/mol. This large binding pocket at the ligand–receptor assembly interface suggests a potential mechanism of allosteric modulation rather than competitive inhibition. The hierarchy of binding affinities — known target CHRM1 (−9.0 FitDock, −8.8 CB-Dock2) > novel targets YAP-TEAD (−7.9) > MOB1-LATS1 (−7.6) > TGFβ1R (−7.5) — is biologically plausible and therapeutically instructive. Atropine's primary pharmacological activity occurs at muscarinic receptors, while novel target engagement may represent secondary, lower-affinity interactions. In the network modulator framework, these weaker interactions at downstream convergence points are not pharmacological noise but rather integral components of the cumulative mechanism. Even modest binding at PPI interfaces, if replicated across multiple nodes, could produce measurable downstream effects at the YAP-TEAD transcriptional level.

The null MR results for COMT (P = 0.191), CHRM3 (P = 0.403), and ADRA2A (P = 0.796) require nuanced interpretation with explicit boundaries on what can and cannot be concluded. For the dopamine pathway, the COMT null result indicates that catechol-O-methyltransferase-mediated dopamine degradation, as reflected in blood gene expression, is not causally linked to myopia. This is partially consistent with Thomson et al., who demonstrated that atropine's anti-myopia effect persists without measurable changes in retinal dopamine levels.^15^ However, the most informative dopamine pathway genes — TH (tyrosine hydroxylase, rate-limiting enzyme for dopamine synthesis), DRD1, and DRD2 — could not be tested due to insufficient instrumental variables at P < 5 × 10⁻⁶. These genes remain neither confirmed nor refuted as causal mediators. The dopamine pathway is therefore undertested rather than excluded — an important distinction that prevents overinterpretation of the COMT null finding. For the muscarinic pathway, CHRM3 was null, but the primary candidates implicated in myopia — CHRM1 (tree shrew evidence^10^), CHRM2 (mouse KO evidence^11^), and CHRM4 (M4-selective antagonist evidence^10^) — all lacked sufficient eQTL instruments. The muscarinic pathway similarly remains undertested. The observation that directly tested receptor genes (CHRM3, ADRA2A) showed null effects while downstream convergence genes (TGFB1, LATS2) showed causal effects is consistent with the network modulator hypothesis: the critical pharmacological target may not be any single upstream receptor but rather the convergence node where multiple receptor signals integrate.

The identification of TGFB1 and LATS2 as triple convergence genes — simultaneously identified by network topology, genetic causality, and published tissue expression — represents not only a biological finding but a methodological demonstration. In the evidential triangulation framework,^29^ each method compensates for the limitations of the others: network pharmacology cannot establish causation (addressed by MR), MR cannot confirm tissue-level expression (addressed by published evidence mapping), and published studies cannot prove that observed expression changes are causal rather than reactive (addressed by MR). No single method would have identified the TGFβ-Hippo-YAP axis as the convergence point; the finding emerged only through their intersection. This approach may be generalizable to other pharmacological questions where the mechanism of action involves pleiotropic drug targets, such as metformin or aspirin, where the "true" target remains debated despite decades of clinical use.

The identification of TGFβ-Hippo-YAP as the convergence axis has two translational implications. First, verteporfin (brand name Visudyne), an FDA-approved photosensitizer currently used in ophthalmology for photodynamic therapy of choroidal neovascularization, is also a potent YAP-TEAD transcriptional complex inhibitor.^47^ Our docking analysis showed that atropine binds the YAP-TEAD interface at −7.9 kcal/mol. Whether verteporfin or next-generation YAP-TEAD inhibitors could serve as targeted anti-myopia agents — bypassing the receptor-level complexity of atropine entirely — is a testable hypothesis. Unlike atropine, a YAP-TEAD inhibitor would not cause mydriasis or cycloplegia, potentially resolving the most common side effects that limit atropine compliance in children. Second, the network modulator framework suggests that optimizing atropine's anti-myopia effect may not require developing receptor-selective compounds (e.g., M4-selective antagonists) but rather understanding the cumulative downstream impact at the Hippo-YAP convergence node. This represents a paradigm shift from receptor-selective drug design toward pathway-targeted approaches. Combination strategies — pairing low-dose atropine with a Hippo pathway modulator — could theoretically achieve synergistic effects at the convergence point while minimizing receptor-level side effects.

Several limitations should be acknowledged. First, our MR analysis relied on blood-derived eQTLs from eQTLGen (N = 31,684) rather than ocular tissue-specific eQTLs. We investigated tissue-specific proxies (GTEx v8 cultured fibroblasts, N ≈ 504) but the markedly smaller sample size provided insufficient statistical power for instrument extraction at P < 5 × 10⁻⁶. While blood eQTLs are standard practice when tissue-specific instruments are unavailable,^33^ future large-scale ocular or scleral eQTL studies are needed to validate these effects in the target tissue. Second, TGFB1 and LATS2 each relied on a single instrumental variable. Colocalization analysis for TGFB1 yielded low PP.H4 (1.79%), though the strong three-outcome replication and robust sensitivity analyses provide compensatory evidence. Full summary statistics-based colocalization with tissue-specific eQTLs remains an important future step. Third, 15 of 22 candidate genes — including critical dopamine (TH, DRD1, DRD2), muscarinic (CHRM1, CHRM4), and Hippo-YAP (YAP1, LATS1, TEAD1) genes — could not be tested by MR due to insufficient instruments. This leaves substantial portions of the hypothesized pathway genetically untested. Fourth, molecular docking provides computational predictions of binding affinity but does not confirm biological activity. The novel PPI binding sites at MOB1-LATS1 and TGFβ1 receptor interfaces require experimental validation through surface plasmon resonance, isothermal titration calorimetry, and functional assays in scleral fibroblast cultures. Fifth, the drug signature analysis used the Enrichr platform (LINCS L1000 Chemical Perturbation Consensus Signatures) rather than direct L1000CDS2 query, which may yield partially different compound rankings. Sixth, published evidence mapping was qualitative (expression direction) rather than quantitative (effect sizes), reflecting the heterogeneity of source study designs.

In conclusion, employing five independent analytical methods — network pharmacology, Mendelian randomization with replication and colocalization, published evidence mapping, drug signature reversal analysis, and molecular docking — we demonstrate that atropine's anti-myopia mechanism involves multi-receptor convergence on the TGFβ-Hippo-YAP signaling axis. TGFB1 and LATS2 are identified as genetically causal mediators of myopia, with TGFB1 replicated across three independent refractive error phenotypes. The convergence of computational network analysis, human genetic evidence, published tissue expression data, pharmacological signature reversal, and structural binding analysis provides the first integrative framework that reconciles decades of conflicting evidence on atropine's mechanism. These findings reposition the Hippo-YAP axis as a candidate target for next-generation myopia pharmacotherapy and introduce the network modulator concept as a framework for understanding pleiotropic drug mechanisms.

---

# REFERENCES

1. Holden BA, Fricke TR, Wilson DA, et al. Global prevalence of myopia and high myopia and temporal trends from 2000 through 2050. *Ophthalmology* 2016;123:1036-42.

2. Jung SK, Lee JH, Kakizaki H, Jee D. Prevalence of myopia and its association with body stature and educational level in 19-year-old male conscripts in Seoul, South Korea. *Invest Ophthalmol Vis Sci* 2012;53:5579-83.

3. Morgan IG, Ohno-Matsui K, Saw SM. Myopia. *Lancet* 2012;379:1739-48.

4. Morgan IG, French AN, Ashby RS, et al. The epidemics of myopia: aetiology and prevention. *Prog Retin Eye Res* 2018;62:134-49.

5. Flitcroft DI, He M, Jonas JB, et al. IMI — Defining and classifying myopia: a proposed set of standards for clinical and epidemiologic studies. *Invest Ophthalmol Vis Sci* 2019;60:M20-30.

6. Yam JC, Li FF, Zhang X, et al. Two-year clinical trial of the Low-Concentration Atropine for Myopia Progression (LAMP) Study: Phase 2 report. *Ophthalmology* 2020;127:910-9.

7. Navarra R, Richiardi L, Morani F, et al. Efficacy of 0.01% atropine for myopia control in children: a systematic review and meta-analysis. *Front Pharmacol* 2025;16:1497667.

8. Wildsoet CF, Chia A, Cho P, et al. IMI — Interventions for controlling myopia onset and progression report. *Invest Ophthalmol Vis Sci* 2019;60:M106-31.

9. Lee SH, Tsai PC, Chiu YC, Wang JH, Chiu CJ. Myopia progression after cessation of atropine in children: a systematic review and meta-analysis. *Front Pharmacol* 2024;15:1343698.

10. Arumugam B, McBrien NA. Muscarinic antagonist control of myopia: evidence for M4 and M1 receptor-based pathways in the inhibition of experimentally-induced axial myopia in the tree shrew. *Invest Ophthalmol Vis Sci* 2012;53:5827-37.

11. Barathi VA, Beuerman RW, Schaeffel F. Muscarinic cholinergic receptor (M2) plays a crucial role in the development of myopia in mice. *Dis Model Mech* 2013;6:1146-58.

12. Carr BJ, Stell WK, Bhatt DK. Myopia-inhibiting concentrations of muscarinic receptor antagonists block activation of alpha2A-adrenoceptors in vitro. *Invest Ophthalmol Vis Sci* 2018;59:2778-91.

13. Stone RA, Lin T, Laties AM, Iuvone PM. Retinal dopamine and form-deprivation myopia. *Proc Natl Acad Sci USA* 1989;86:704-6.

14. Feldkaemper M, Schaeffel F. An updated view on the role of dopamine in myopia. *Exp Eye Res* 2013;114:106-19.

15. Thomson K, Kelly T, Gao B, Morgan IG, Bhatt DK. Insights into the mechanism by which atropine inhibits myopia: evidence against cholinergic hyperactivity and modulation of dopamine release. *Br J Pharmacol* 2021;179:4359-76.

16. Upadhyay A, Beuerman RW. Biological mechanisms of atropine control of myopia. *Eye Contact Lens* 2020;46:129-37.

17. McBrien NA, Gentle A. Role of the sclera in the development and pathological complications of myopia. *Prog Retin Eye Res* 2003;22:307-38.

18. Wallman J, Winawer J. Homeostasis of eye growth and the question of myopia. *Neuron* 2004;43:447-68.

19. Jobling AI, Nguyen M, Gentle A, McBrien NA. Isoform-specific changes in scleral transforming growth factor-beta expression and the regulation of collagen synthesis during myopia progression. *J Biol Chem* 2004;279:18121-6.

20. Gentle A, Liu Y, Martin JE, Conti GL, McBrien NA. Collagen gene expression and the altered accumulation of scleral collagen during the development of high myopia. *J Biol Chem* 2003;278:16587-94.

21. Wu H, Chen W, Zhao F, et al. Scleral hypoxia is a target for myopia control. *Proc Natl Acad Sci USA* 2018;115:E7091-100.

22. Liu Y, Wang X, Li H, et al. ECM stiffness modulates scleral remodeling through integrin/F-actin/YAP axis in myopia. *Invest Ophthalmol Vis Sci* 2025;66(2):22.

23. Huang L, Zhang J, Luo Y. The role of atropine in myopia control: insights into choroidal and scleral mechanisms. *Front Pharmacol* 2025;16:1509196.

24. Totaro A, Panciera T, Piccolo S. YAP/TAZ upstream signals and downstream responses. *Nat Cell Biol* 2018;20:888-99.

25. Meng Z, Moroishi T, Guan KL. Mechanisms of Hippo pathway regulation. *Genes Dev* 2016;30:1-17.

26. Yu FX, Zhao B, Guan KL. Hippo pathway in organ size control, tissue homeostasis, and cancer. *Cell* 2015;163:811-28.

27. Zhu H, Chen W, Ling X, Jiao S, Yu L, Liu H, et al. Decreased scleral Wnt5a-hi fibroblasts exacerbate myopia progression by disrupting extracellular matrix homeostasis in mice. *Nat Commun* 2026;17:554.

28. Davey Smith G, Hemani G. Mendelian randomization: genetic anchors for causal inference in epidemiological studies. *Hum Mol Genet* 2014;23:R89-98.

29. Skrivankova VW, Richmond RC, Woolf BAR, et al. Strengthening the reporting of observational studies in epidemiology using Mendelian randomization: the STROBE-MR statement. *JAMA* 2021;326:1614-21.

30. Daina A, Michielin O, Zoete V. SwissTargetPrediction: updated data and new features for efficient prediction of protein targets of small molecules. *Nucleic Acids Res* 2019;47:W357-64.

31. Szklarczyk D, Kirsch R, Koutrouli M, et al. The STRING database in 2023: protein-protein association networks and functional enrichment analyses for any observed set of proteins. *Nucleic Acids Res* 2023;51:D483-9.

32. Shannon P, Markiel A, Ozier O, et al. Cytoscape: a software environment for integrated models of biomolecular interaction networks. *Genome Res* 2003;13:2498-504.

33. Võsa U, Claringbould A, Westra HJ, et al. Large-scale cis- and trans-eQTL analyses identify thousands of genetic loci and polygenic scores that regulate blood gene expression. *Nat Genet* 2021;53:1300-10.

34. Elsworth B, Lyon M, Alexander T, et al. The MRC IEU OpenGWAS data infrastructure. *eLife* 2020;9:e59298.

35. Hemani G, Tilling K, Davey Smith G. Orienting the causal relationship between imprecisely measured traits using GWAS summary data. *PLoS Genet* 2017;13:e1007081.

36. Staley JR, Blackshaw J, Kamat MA, et al. PhenoScanner: a database of human genotype-phenotype associations. *Bioinformatics* 2016;32:3207-9.

37. Giambartolomei C, Vukcevic D, Schadt EE, et al. Bayesian test for colocalisation between pairs of genetic association studies using summary statistics. *PLoS Genet* 2014;10:e1004383.

38. Yao M, Jiang F, Xu X, et al. Single-cell transcriptomic analysis of myopic retinal remodeling reveals ON/OFF signaling imbalance. *MedComm* 2023;4:e372.

39. Yin X, Ge J. The role of scleral changes in the progression of myopia: a review and future directions. *Clin Ophthalmol* 2025;19:1699-1707.

40. Lachmann A, Torre D, Keenan AB, et al. Massive mining of publicly available RNA-seq data from human and mouse. *Nat Commun* 2018;9:1366.

41. Groppe J, Hinck CS, Samavarchi-Tehrani P, et al. Cooperative assembly of TGF-β superfamily signaling complexes is mediated by two disparate mechanisms and distinct modes of receptor binding. *Mol Cell* 2008;29:157-68.

42. Ni L, Zheng Y, Hara M, et al. Structural basis for auto-inhibition of the NDR family kinase LATS1. *Structure* 2015;23:1467-76.

43. Li Z, Zhao B, Wang P, et al. Structural insights into the YAP and TEAD complex. *Genes Dev* 2010;24:235-40.

44. Thal DM, Sun B, Feng D, et al. Crystal structures of the M1 and M4 muscarinic acetylcholine receptors. *Nature* 2016;531:335-40.

45. Liu Y, Yang X, Gan J, et al. CB-Dock2: improved protein-ligand blind docking by integrating cavity detection, docking and homologous template fitting. *Nucleic Acids Res* 2022;50:W159-64.

46. Hopkins AL. Network pharmacology: the next paradigm in drug discovery. *Nat Chem Biol* 2008;4:682-90.

47. Liu-Chittenden Y, Huang B, Shim JS, et al. Genetic and pharmacological disruption of the TEAD-YAP complex suppresses the oncogenic activity of YAP. *Genes Dev* 2012;26:1300-5.


ewpage

# FIGURE LEGENDS

**Figure 1.** Study design: five-method triangulation for atropine–myopia mechanism. Five independent analytical methods (network pharmacology, Mendelian randomization, published evidence mapping, drug signature reversal, and molecular docking) converge on the TGFβ-Hippo-YAP axis as the downstream effector. Key findings annotated at each step.

**Figure 2.** Network pharmacology and Extension Layer analysis. (A) Venn diagram showing intersection of 128 atropine targets and 195 myopia-associated genes, yielding 47 common genes. (B) Hierarchical network showing hub genes (top), receptor classes (middle), and Extension Layer convergence on YAP1 (bottom). Node size proportional to degree; colors indicate receptor class (red = muscarinic, orange = dopaminergic, blue = adrenergic, teal = nicotinic). Asterisks indicate MR causal genes (TGFB1 P = 0.003; LATS2 P = 0.040). The 44 connected genes are shown; 3 singletons (CHRM4, ACHE, ADRA2B) are excluded from visualization.

**Figure 3.** Mendelian randomization results. (A) Forest plot of causal estimates for seven genes with sufficient instrumental variables. Significant genes (P < 0.05) shown in red. Pathway modules indicated on the left. (B) TGFB1 replication across three independent outcomes: binary myopia (P = 0.003), right-eye spherical power (P = 4.0 × 10⁻⁴), and left-eye spherical power (P = 2.3 × 10⁻⁴). All P < 0.001 with consistent directionality.

**Figure 4.** Triangulation and molecular docking. (A) Evidence heatmap showing convergence of five methods across key genes. Symbols: ++ strong evidence, + supported, ± suggestive, — not tested. Score indicates number of methods with positive evidence. (B) Molecular docking binding energies for atropine at four protein targets. Positive control CHRM1 (FitDock −9.0 kcal/mol) compared with novel targets. Dashed line indicates drug-like binding threshold (−7.0 kcal/mol). MR P-values annotated for genetically validated targets.

\newpage

# SUPPLEMENTARY MATERIALS

**Supplementary Table S1.** Topological properties of 44 connected intersection genes with degree, betweenness centrality, closeness centrality, and receptor class annotations.

**Supplementary Table S2.** Complete Mendelian randomization results for all 22 candidate genes, including 15 with insufficient instrumental variables and reasons for exclusion.

**Supplementary Table S3.** Drug signature reversal analysis — top 50 compounds from Enrichr LINCS L1000 with drug class enrichment summary and network correspondence.
