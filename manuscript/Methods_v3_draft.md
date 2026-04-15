# METHODS

## 2.1. Study Design

This study employed five independent analytical approaches to test the hypothesis that atropine's anti-myopia mechanism involves multi-receptor convergence on the TGFβ-Hippo-YAP signaling axis (Fig. 1). The five methods were: (1) network pharmacology with Extension Layer analysis, (2) two-sample Mendelian randomization with outcome replication and colocalization, (3) published transcriptomic evidence mapping, (4) drug signature reversal analysis, and (5) molecular docking. This triangulation design, where each method addresses limitations inherent in the others, follows established principles for strengthening causal inference in observational research.^30 This study used only publicly available summary-level data and did not involve human subjects; institutional review board approval was not required.

## 2.2. Network Pharmacology

### 2.2.1. Atropine Target Identification

Atropine-associated gene targets were retrieved from the Comparative Toxicogenomics Database (CTD; http://ctdbase.org) using compound ID D001285 (atropine), supplemented by DrugBank (https://go.drugbank.com) and SwissTargetPrediction (http://www.swisstargetprediction.ch) using the canonical SMILES string O=C(OC1CC2CCC1N2C)C(CO)c1ccccc1.^31 Gene lists were merged, and duplicates were removed, yielding 128 unique atropine-associated gene targets.

### 2.2.2. Myopia-Associated Gene Extraction

Myopia-associated genes were extracted from the CTD using disease ID D009216 (myopia). To minimize noise from inferred associations, only genes with "Direct Evidence" annotations (marker/mechanism categories) were retained. This curated set was supplemented with genes from the DisGeNET database (curated sources only) and the Online Mendelian Inheritance in Man (OMIM) catalog. After deduplication, 195 myopia-associated genes were included.

### 2.2.3. Protein–Protein Interaction Network Construction

The intersection of atropine targets and myopia-associated genes yielded 47 common genes. These were submitted to the Search Tool for the Retrieval of Interacting Genes/Proteins (STRING v12.0; https://string-db.org) with a minimum interaction confidence score of 0.700 (high confidence), restricted to Homo sapiens.^32 The resulting network comprised 47 nodes and 191 edges.

### 2.2.4. Hub Gene Identification and Topological Analysis

The PPI network was imported into Cytoscape (v3.10.2) for topological analysis.^33 Node centrality metrics — degree, betweenness centrality, and closeness centrality — were calculated using the NetworkAnalyzer plugin. Hub genes were defined as nodes ranking in the top 10 by degree centrality. CytoHubba was used for complementary hub ranking validation.

### 2.2.5. Extension Layer Analysis

To test whether atropine's receptor targets can reach the Hippo-YAP signaling machinery, we designed an Extension Layer analysis. Hippo-YAP pathway components (LATS1, LATS2, YAP1, TEAD1-4, WWTR1, NF2, SAV1, AMOT, MOB1A) were deliberately excluded from the initial intersection network to avoid circular reasoning, and were instead added as an adjacent layer connected through STRING-validated interactions (confidence ≥0.700). Shortest-path analysis (Dijkstra's algorithm) was performed from each of the four receptor classes — muscarinic (CHRM1, CHRM3, CHRM5), dopaminergic (DRD1, DRD2), adrenergic (ADRA2A, ADRA2C), and nicotinic (CHRNA3, CHRNA4, CHRNB2) — to each Hippo-YAP component, using intersection hub genes as intermediaries. The number of paths, representative shortest paths, and path distances were recorded for each receptor class.

### 2.2.6. Pathway Enrichment

Gene Ontology (GO) and Kyoto Encyclopedia of Genes and Genomes (KEGG) enrichment analyses were performed on the 47 intersection genes using g:Profiler (https://biit.cs.ut.ee/gprofiler). Statistical significance was defined as adjusted P < 0.05 (Benjamini-Hochberg correction). A total of 168 KEGG pathways were tested.

## 2.3. Mendelian Randomization

### 2.3.1. Study Design and Data Sources

Two-sample Mendelian randomization was conducted in accordance with the STROBE-MR guidelines.^30 Genetic instruments for gene expression were obtained from the eQTLGen Consortium (N = 31,684; blood-derived cis-eQTLs).^34 The primary outcome was self-reported myopia from the UK Biobank (dataset ukb-b-6353; N = 460,536; 37,362 cases, 423,174 controls).^35

### 2.3.2. Gene Selection and Instrument Extraction

Seven genes spanning five mechanistic modules were selected based on network pharmacology results, biological relevance, and instrument availability: TGFB1 and LOX (TGFβ/ECM module), LATS2 (Hippo-YAP module), COMT (dopamine module), CHRM3 (muscarinic module), ADRA2A (adrenergic module), and HIF1A (hypoxia module). An additional 15 genes (including TH, DRD1, DRD2, YAP1, LATS1, TEAD1, CHRM1, CHRM2, CHRM4, CHRM5) had insufficient instrumental variables at the selected threshold and are reported in Supplementary Table S2.

Cis-eQTLs reaching genome-wide significance (P < 5 × 10⁻⁶) were selected as instrumental variables. Linkage disequilibrium clumping was performed using a European reference panel (r² < 0.001, window = 10,000 kb). Instruments were harmonized with the outcome dataset; palindromic SNPs with intermediate allele frequencies were excluded.

### 2.3.3. Statistical Methods

For genes with a single instrumental variable, the Wald ratio was applied. For genes with two or more instruments, the inverse variance-weighted (IVW) method was used as the primary analysis. Sensitivity analyses included the weighted median method (for up to 50% invalid instruments), MR-Egger regression (for directional pleiotropy detection), and leave-one-out analysis. Instrument strength was evaluated using the F-statistic; all included instruments exceeded the conventional threshold of F > 10.

### 2.3.4. Directionality and Reverse Causality

Steiger directionality testing was performed for significant genes to confirm that genetic variants explain more variance in the exposure (gene expression) than in the outcome (myopia).^36 Reverse MR (outcome → exposure) was conducted as an additional check against reverse causation. PhenoScanner v2 (http://www.phenoscanner.medschl.cam.ac.uk) was queried to identify pleiotropic associations of lead instruments at genome-wide significance.^37

### 2.3.5. Outcome Replication

To assess robustness across phenotype definitions, causal estimates for TGFB1 were replicated using two continuous refractive error outcomes from the UK Biobank: right-eye spherical power (ukb-b-19994) and left-eye spherical power (ukb-b-7500). A positive beta for spherical power indicates a shift toward less myopic refraction, consistent with a protective effect against myopia.

### 2.3.6. Bayesian Colocalization

Colocalization analysis was performed using the coloc R package (coloc.abf method) to assess whether the eQTL signal for TGFB1 and the myopia GWAS signal share a common causal variant at the same genomic locus.^38 Full cis-eQTL summary statistics were obtained from the eQTLGen Consortium (release 2019-12-11), and UK Biobank GWAS summary statistics for myopia (ukb-b-6353) were downloaded in VCF format. Regional data (±500 kb from the transcription start site) were extracted for each gene. Prior probabilities were set to defaults (p1 = p2 = 10⁻⁴, p12 = 10⁻⁵). Posterior probabilities for five hypotheses were computed: H0 (no association with either trait), H1 (association with eQTL only), H2 (association with GWAS only), H3 (both associated, independent signals), and H4 (shared causal variant). PP.H4 > 0.80 was considered strong evidence for colocalization.

### 2.3.7. Tissue Specificity Limitation

We note that eQTLGen provides blood-derived eQTLs. Tissue-specific databases (GTEx v8 cultured fibroblasts, N ≈ 504) were investigated but yielded insufficient statistical power for instrument extraction at P < 5 × 10⁻⁶, owing to markedly smaller sample sizes compared with eQTLGen (N = 31,684).

All MR analyses were conducted in R (v4.3.3) using the TwoSampleMR (v0.6.4) and ieugwasr (v1.0.1) packages.

## 2.4. Published Transcriptomic Evidence Mapping

To validate network pharmacology predictions with independent tissue-level data, we systematically extracted molecular findings from six published myopic tissue studies spanning 2018–2026 (Supplementary Table S3).^21,22,23,27,39,40 These encompassed scleral and retinal tissues from mouse, guinea pig, and human models, using methods including single-cell RNA sequencing, Western blot, quantitative PCR, and immunofluorescence. For each of the 47 intersection genes and 11 Extension Layer genes, we catalogued reported expression changes (upregulated, downregulated, or not reported) across studies. Genes showing concordant changes across ≥2 independent studies were classified as "published-validated." Cross-referencing with MR results enabled three-way triangulation: network prediction × genetic causality × tissue-level expression.

## 2.5. Drug Signature Reversal Analysis

To identify pharmacological classes whose expression signatures most effectively reverse the 47-gene intersection profile, we queried the Enrichr platform (https://maayanlab.cloud/Enrichr) using the LINCS L1000 Chemical Perturbation Consensus Signatures library.^41 The 23 upregulated hub genes (top 10 hubs plus key signal transducers) were submitted as the input gene set. Reversal compounds were ranked by combined enrichment score. Drug classes were annotated using DrugBank and the IUPHAR Guide to Pharmacology.

## 2.6. Molecular Docking

### 2.6.1. Target Selection and Structure Preparation

Four protein targets were selected for molecular docking based on convergent evidence from network pharmacology and MR: (1) TGFβ1 receptor complex (PDB: 3KFD; TGFβ1–TβRII trimeric complex, resolution 3.00 Å),^42 (2) MOB1-LATS1 kinase complex (PDB: 5BRK; pMob1–Lats1 complex, resolution 2.35 Å)^43 as a proxy for LATS1/2 (LATS1 and LATS2 share >85% kinase domain sequence identity), (3) YAP-TEAD complex (PDB: 3KYS; YAP–TEAD1 complex, resolution 2.50 Å),^44 and (4) muscarinic acetylcholine receptor M1 (PDB: 5CXV; resolution 2.70 Å)^45 as a positive control, since atropine is a known muscarinic antagonist.

Protein structures were retrieved from the RCSB Protein Data Bank (https://www.rcsb.org). Water molecules, co-crystallized ligands, and non-essential heteroatoms were removed. The atropine ligand structure was obtained in SDF format from PubChem (CID 174174).

### 2.6.2. Blind Docking Protocol

Structure-based blind docking was performed using CB-Dock2 (https://cadd.labshare.cn/cb-dock2/),^46 which automatically identifies all potential binding cavities on the protein surface and docks the ligand into each cavity using AutoDock Vina. For each protein–ligand pair, up to five cavities were detected and ranked by Vina binding energy (kcal/mol). Binding energies below −7.0 kcal/mol were considered indicative of drug-like binding affinity.

For the positive control (5CXV, CHRM1), CB-Dock2 additionally performed template-based blind docking (FitDock), which identified template 6WJC (CHRM1 bound to a muscarinic antagonist, pocket identity = 1.00) as a reference, confirming that atropine docked into the canonical orthosteric binding site.

### 2.6.3. Binding Site Interpretation

Contact residues within 4 Å of the docked atropine pose were recorded for each cavity. For multi-chain complexes (3KFD, 5BRK), binding at the protein–protein interface was noted, as such binding may disrupt complex formation and modulate downstream signaling. Docking scores for novel targets were compared with the positive control to assess relative binding strength.

## 2.7. Data Availability

All data, code, and analytical scripts used in this study are publicly available at https://github.com/JungyulPark/Myopia_Study_1.

---

## METHODS REFERENCE LIST (continuing from Introduction [30])

[31] Daina A, Michielin O, Zoete V. SwissTargetPrediction: updated data and new features for efficient prediction of protein targets of small molecules. Nucleic Acids Res 2019;47:W357-64.

[32] Szklarczyk D, Kirsch R, Koutrouli M, et al. The STRING database in 2023: protein-protein association networks and functional enrichment analyses for any observed set of proteins. Nucleic Acids Res 2023;51:D483-9.

[33] Shannon P, Markiel A, Ozier O, et al. Cytoscape: a software environment for integrated models of biomolecular interaction networks. Genome Res 2003;13:2498-504.

[34] Võsa U, Claringbould A, Westra HJ, et al. Large-scale cis- and trans-eQTL analyses identify thousands of genetic loci and polygenic scores that regulate blood gene expression. Nat Genet 2021;53:1300-10.

[35] Elsworth B, Lyon M, Alexander T, et al. The MRC IEU OpenGWAS data infrastructure. bioRxiv 2020;2020.08.10.244293.

[36] Hemani G, Tilling K, Davey Smith G. Orienting the causal relationship between imprecisely measured traits using GWAS summary data. PLoS Genet 2017;13:e1007081.

[37] Staley JR, Blackshaw J, Kamat MA, et al. PhenoScanner: a database of human genotype-phenotype associations. Bioinformatics 2016;32:3207-9.

[38] Giambartolomei C, Vukcevic D, Schadt EE, et al. Bayesian test for colocalisation between pairs of genetic association studies using summary statistics. PLoS Genet 2014;10:e1004383.

[39] Yao M, Jiang F, Xu X, et al. Single-cell transcriptomic analysis of myopic retinal remodeling reveals ON/OFF signaling imbalance. MedComm 2023;4:e372.

[40] Scleral remodeling in myopia: comprehensive review. [NOTE: Insert exact citation for sclera review PMC 2025]

[41] Lachmann A, Torre D, Keenan AB, et al. Massive mining of publicly available RNA-seq data from human and mouse. Nat Commun 2018;9:1366.

[42] Groppe J, Hinck CS, Samavarchi-Tehrani P, et al. Cooperative assembly of TGF-β superfamily signaling complexes is mediated by two disparate mechanisms and distinct modes of receptor binding. Mol Cell 2008;29:157-68.

[43] Kim SY, Tachioka Y, Mori T, Bhatt DK. Crystal structure of the MOB1A–LATS1 complex. [NOTE: Confirm exact reference for 5BRK]

[44] Li Z, Zhao B, Wang P, et al. Structural insights into the YAP and TEAD complex. Genes Dev 2010;24:235-40.

[45] Thal DM, Sun B, Feng D, et al. Crystal structures of the M1 and M4 muscarinic acetylcholine receptors. Nature 2016;531:335-40.

[46] Liu Y, Yang X, Gan J, et al. CB-Dock2: improved protein-ligand blind docking by integrating cavity detection, docking and homologous template fitting. Nucleic Acids Res 2022;50:W159-64.

---

## NOTES

- References [31]–[46] are NEW, to be appended after Introduction [1]–[30]
- Total manuscript references so far: 46 (Introduction 30 + Methods 16)
- Results and Discussion will add ~4–8 more references
- [40] and [43] need exact citations confirmed before submission
- All statistical thresholds, sample sizes, and database versions match verified data
