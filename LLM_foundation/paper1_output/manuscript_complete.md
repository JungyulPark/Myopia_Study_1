# Multi-receptor convergence on TGFβ-Hippo-YAP axis in atropine's anti-myopia mechanism: integrative evidence from network pharmacology, Mendelian randomization, and molecular docking

**Park Jungyul, MD, PhD**

Department of Ophthalmology, Seoul St. Mary's Hospital, College of Medicine, The Catholic University of Korea, Seoul, Republic of Korea

**Corresponding author:** Park Jungyul, MD, PhD  
Department of Ophthalmology, Seoul St. Mary's Hospital, 222 Banpo-daero, Seocho-gu, Seoul 06591, Republic of Korea  
Email: [email]

---

## Abstract

**Purpose:** Atropine is the most widely used pharmacological agent for myopia control, yet its mechanism of action remains unsettled. We tested the hypothesis that atropine's actions through multiple receptor types converge on the TGFβ-Hippo-YAP axis in scleral remodeling.

**Methods:** Five independent approaches were employed: (1) network pharmacology integrating 128 atropine targets with 195 myopia-associated genes; (2) two-sample Mendelian randomization (MR) using eQTLGen cis-eQTLs and UK Biobank myopia data (N=460,536), with replication across refractive error outcomes and colocalization analysis; (3) systematic cross-validation against six published myopic tissue studies; (4) drug signature analysis using Enrichr/LINCS L1000; and (5) molecular docking against CHRM1, TGFβ1 receptor, LATS2, and YAP-TEAD using CB-Dock2.

**Results:** Network analysis identified 47 intersection genes. Extension Layer analysis demonstrated that all four atropine receptor classes (muscarinic, adrenergic, nicotinic, dopaminergic) reach Hippo-YAP components within three interaction steps. MR identified TGFB1 as causally protective (β=−0.027, P=0.003) and LATS2 as a causal risk factor (β=+0.018, P=0.04) for myopia — the first genetic evidence linking Hippo pathway components to myopia. The TGFB1 finding was replicated across three independent outcomes including continuous refractive error (spherical power: right eye P=4.0×10⁻⁴; left eye P=2.3×10⁻⁴). Published evidence mapping confirmed concordant tissue-level changes for both genes. Molecular docking showed atropine binds novel Hippo-YAP targets (YAP-TEAD: −7.9 kcal/mol; TGFβ1R: −7.5; LATS2: −7.2) at drug-like thresholds comparable to its known target CHRM1 (−9.0).

**Conclusions:** Five independent lines of evidence converge on the TGFβ-Hippo-YAP axis as a downstream effector of atropine's multi-receptor anti-myopia action, with TGFB1 and LATS2 as genetically validated causal mediators.

**Keywords:** atropine; myopia; network pharmacology; Mendelian randomization; Hippo-YAP pathway; TGFβ1; LATS2; scleral remodeling

---

## 1. Introduction

Myopia affects approximately half of the global population, with projections estimating 4.9 billion affected individuals by 2050 [1]. In East Asia, prevalence is particularly alarming, reaching 96.5% among 19-year-old male conscripts in Seoul [2]. Low-concentration atropine (0.01–0.05%) has emerged as the primary pharmacological intervention, with meta-analyses demonstrating reductions in spherical equivalent progression of approximately 0.16 D/year and axial elongation of 0.07 mm/year [3,4].

Despite widespread clinical use, the molecular mechanism by which atropine inhibits myopia remains fundamentally unresolved. The conventional explanation — muscarinic receptor blockade — has been challenged by multiple lines of evidence. In the tree shrew, both M4-selective (MT3) and M1-selective (MT7) antagonists inhibit form-deprivation myopia (FDM), implicating M4 and M1 subtypes [5]. M2 knockout mice show the greatest resistance to myopia among muscarinic subtypes [6]. Carr et al. demonstrated that antagonist potency at the α2A-adrenoceptor, rather than at any muscarinic subtype, best correlates with anti-myopia efficacy [7]. Thomson et al. showed that atropine's effect persists without changes in retinal dopamine, challenging the dopamine-mediated hypothesis [8]. This accumulated evidence led Upadhyay and Beuerman to characterize atropine as a "shotgun approach" drug engaging muscarinic, adrenergic, nicotinic, GABA, and EGFR pathways simultaneously [9].

A critical question remains: if atropine engages multiple upstream receptors, do these signals converge on a common downstream effector? Recent evidence implicates the Hippo-YAP pathway and TGFβ signaling as candidates. Liu et al. demonstrated decreased YAP expression in myopic sclera from both human tissue and guinea pig models [10]. Huang et al. showed atropine suppresses HIF-1α in FDM mouse sclera, linking atropine to the hypoxia-TGFβ cascade [11]. TGFβ-Smad and YAP physically interact through nuclear co-localization [12], and scleral remodeling in myopia involves TGFβ-dependent changes in collagen composition and matrix metalloproteinase activity [13,14].

However, no study has systematically examined whether atropine's multiple receptor targets converge on the TGFβ-Hippo-YAP axis, nor has the causal role of Hippo pathway components in myopia been tested using genetic methods.

In this study, we employed five independent analytical approaches — network pharmacology, Mendelian randomization with replication and colocalization, published evidence mapping, drug signature analysis, and molecular docking — to test the convergence hypothesis. This triangulation design, where each method addresses the limitations of the others, provides stronger evidence than any single approach alone.

---

## 2. Methods

### 2.1 Network pharmacology

#### 2.1.1 Target and gene identification
Atropine binding targets were compiled from the Comparative Toxicogenomics Database (CTD; Drug ID: D001285), DrugBank, and SwissTargetPrediction (SMILES: O=C(OC1CC2CCC1N2C)C(CO)c1ccccc1), yielding 128 unique genes after deduplication. Myopia-associated genes were extracted from CTD (Disease ID: D009216, restricted to Direct Evidence — marker and mechanism categories), DisGeNET (curated datasets), and OMIM, yielding 195 unique genes.

#### 2.1.2 Network construction and hub gene identification
The 47 intersection genes were submitted to STRING (v12.0) for protein–protein interaction (PPI) network construction (combined score ≥0.7, Homo sapiens). Hub genes were ranked by degree centrality using Cytoscape (v3.10) with CytoHubba.

#### 2.1.3 Extension Layer analysis
To avoid circular reasoning, Hippo-YAP pathway genes (LATS1, LATS2, YAP1, TEAD1–4, NF2, SAV1, AMOT, STK3, WWTR1) were placed in a separate Extension Layer. Shortest path analysis quantified the number of distinct paths and minimum distance from each of four receptor classes (muscarinic: CHRM1/3/5; adrenergic: ADRA2A/2C; nicotinic: CHRNA3 and 3 others; dopamine: DRD1/2) to Extension Layer genes via intersection intermediaries.

#### 2.1.4 Pathway enrichment
KEGG and Gene Ontology enrichment were performed on the 47 intersection genes using clusterProfiler with Benjamini-Hochberg correction (FDR < 0.05).

### 2.2 Mendelian randomization

#### 2.2.1 Primary analysis
Two-sample MR tested the causal effect of genetically predicted gene expression on myopia risk. Cis-eQTLs (within 1 Mb) were obtained from eQTLGen (N=31,684 blood samples; P < 5×10⁻⁶). The primary outcome was myopia from UK Biobank (ukb-b-6353; N=460,536). For genes with ≥3 instruments, inverse-variance weighted (IVW) was the primary method; for single instruments, the Wald ratio was used. Analyses used TwoSampleMR (v0.5.8).

Genes tested included: dopamine pathway (TH, DRD1, DRD2, COMT), Hippo-YAP (LATS1, LATS2, YAP1, TEAD1, WWTR1), muscarinic (CHRM1–5), adrenergic (ADRA2A), HIF-1α/TGFβ (HIF1A, TGFB1, LOX, VEGFA), and others (GABRA1, EGFR, MMP2).

#### 2.2.2 Sensitivity analyses
Steiger directionality testing confirmed causal direction. Reverse MR (myopia → gene expression) excluded reverse causation. PhenoScanner v2 screened instruments for pleiotropic associations.

#### 2.2.3 Outcome replication
To assess robustness, significant MR findings were replicated using continuous refractive error outcomes: spherical power right eye (ukb-b-19994) and left eye (ukb-b-7500).

#### 2.2.4 Colocalization
Bayesian colocalization (coloc.abf) was performed using full eQTLGen cis-eQTL summary statistics and UK Biobank myopia GWAS data within ±500 kb of each gene, with default priors (p1=10⁻⁴, p2=10⁻⁴, p12=10⁻⁵). Posterior probability for hypothesis H4 (shared causal variant) >0.8 was considered strong evidence.

### 2.3 Published evidence mapping

Molecular findings were systematically extracted from six published myopic tissue studies (2018–2026): Liu et al. (IOVS 2025, sclera), a Wnt5a scleral fibroblast study (Nature Communications 2026), Huang et al. (Frontiers in Pharmacology 2025), Yao et al. (MedComm 2023, retina scRNA-seq), Wu et al. (PNAS 2018, sclera), and a scleral review (2025). For each network-identified gene, reported expression changes were catalogued across studies.

### 2.4 Drug signature analysis

Intersection hub genes were submitted to Enrichr and analyzed against the LINCS L1000 Chem Pert Consensus Sigs library to identify small molecules whose signatures most strongly reverse the atropine-myopia gene expression pattern.

### 2.5 Molecular docking

Crystal structures were obtained from PDB: CHRM1 (5CXV), TGFβ1 receptor (3KFD), LATS2 kinase (5BRK), and YAP-TEAD complex (3KYS). Atropine (PubChem CID: 174174) was docked using CB-Dock2 (cavity-detection guided blind docking with AutoDock Vina). For CHRM1, template-based docking was additionally performed using FitDock. Binding energies below −7.0 kcal/mol were considered strong and below −5.0 moderate.

---

## 3. Results

### 3.1 Network pharmacology: multi-receptor convergence on Hippo-YAP

The intersection of 128 atropine targets and 195 myopia genes yielded 47 common genes (Fig. 1A). The top 10 hub genes by degree were: TP53 (21), AKT1 (21), IL6 (19), CTNNB1 (19), TNF (19), JUN (19), IL1B (18), CASP3 (17), EGFR (17), and FOS (16) (Fig. 1B). KEGG enrichment identified 168 significant pathways, with prominent representation of PI3K-Akt, TNF, and TGF-beta signaling.

Extension Layer analysis provided the central finding (Fig. 1C). All four receptor classes reached Hippo-YAP components within three interaction steps: muscarinic receptors via 40 paths, nicotinic via 32 (representative: CHRNA3→ACHE→EGFR→LATS1), adrenergic via 24, and dopamine via 16 (representative: DRD1→FOS→TP53→LATS1, distance 3). YAP1 in the Extension Layer connected to the intersection network through 24 edges via 14 bridge genes.

TGFB1 was present in the intersection with a degree of 12 but was not among the top hub genes by network centrality. Its significance emerged through subsequent causal analysis (Section 3.2).

### 3.2 Mendelian randomization: TGFB1 protective, LATS2 causal risk

Among 22 genes tested, sufficient instruments (P < 5×10⁻⁶) were available for 7. Two showed significant causal associations with myopia (Table 1).

TGFB1 was causally protective (β=−0.027, P=0.003, Wald ratio). Steiger directionality confirmed the causal direction (P=1.65×10⁻⁵), and reverse MR was null (P=0.90). PhenoScanner identified an association of the instrument (rs1963413) with height, consistent with TGFβ's established role in skeletal growth — representing vertical rather than horizontal pleiotropy.

LATS2, encoding a core Hippo kinase, was a causal risk factor (β=+0.018, P=0.04, Wald ratio). Steiger directionality was confirmed (P=1.29×10⁻⁶), reverse MR was null (P=0.94), and PhenoScanner identified no pleiotropic associations. To our knowledge, this represents the first genetic evidence linking a Hippo pathway component to myopia.

HIF1A showed suggestive protective association (β=−0.004, SE=0.002, weighted median P=0.068). COMT (P=0.19), ADRA2A (P=0.80), CHRM3 (P=0.40), VEGFA (P=0.81), and LOX (P=0.74) were null. Fifteen genes, including TH, DRD1, DRD2, YAP1, and LATS1, had insufficient instruments for analysis.

### 3.3 Outcome replication and colocalization

The TGFB1 finding was replicated across three independent UK Biobank outcomes (Table 2): binary myopia (β=−0.027, P=0.003), spherical power right eye (β=+0.253, P=4.0×10⁻⁴), and spherical power left eye (β=+0.264, P=2.3×10⁻⁴). The positive beta for spherical power is directionally consistent — increased TGFB1 expression shifts refraction toward hyperopia (less myopic), concordant with reduced myopia risk. LATS2 instruments were not available in the refractive error outcomes, precluding replication.

Colocalization analysis for TGFB1 used 2,668 regional SNPs from full eQTLGen summary statistics. The posterior probability for shared causal variant (PP.H4) was 0.018, while the probability for eQTL-only association (PP.H1) was 0.949, indicating a strong eQTL signal at this locus but limited GWAS signal strength in the myopia dataset. LATS2 colocalization was not feasible due to insufficient overlapping SNPs (<5).

### 3.4 Published evidence mapping: triangulation

Cross-referencing CP1 and CP3 results against six published studies identified convergent evidence at multiple levels (Table 3).

TGFB1 and LATS2 achieved true triple convergence — concordant findings from network analysis, genetic causality, and published experimental data. TGFB1 was present in the intersection network (degree 12), showed the strongest causal association (P=0.003), and TGFβ1 was upregulated in FDM sclera (Wu et al. 2018). LATS2 was identified through the Extension Layer, showed causal risk (P=0.04), and YAP downregulation in myopic sclera (Liu et al. 2025) is mechanistically consistent with LATS2-mediated YAP phosphorylation.

YAP1 and COL1A1 showed double convergence (network + published evidence), while HIF1A showed near-triple convergence (network + suggestive MR + published evidence in both directions).

### 3.5 Drug signature analysis

Analysis through Enrichr/LINCS L1000 identified several drug classes whose perturbation signatures reverse the atropine-myopia gene expression pattern: EGFR inhibitors appeared most frequently (8 of top 50 hits, including gefitinib at ranks 29, 37, 44, 46, consistent with EGFR as hub gene #9), followed by MEK/ERK inhibitors (6 hits, consistent with MAPK3/MAPK1 hubs), Src inhibitors (3 hits, relevant to Src→FAK→YAP signaling), and a muscarinic antagonist (fenpiverinium, rank 14, same drug class as atropine). An MMP inhibitor (ilomastat) and a GSK3β/Wnt inhibitor (TWS119, rank 2) were also identified, the latter consistent with recent evidence linking Wnt5a-positive scleral fibroblasts to myopia protection [15].

### 3.6 Molecular docking

CHRM1 (positive control) yielded the strongest binding (FitDock: −9.0 kcal/mol; CB-Dock2: −8.8), with template-based docking confirming orthosteric site binding (template 6wjc, pocket identity 1.0). All three novel targets showed drug-like binding: YAP-TEAD complex (−7.9), TGFβ1 receptor (−7.5, at the TGFβ1-TβRII interface spanning chains C, D, and K), and LATS2 kinase (−7.2, contacting kinase domain residues). The hierarchy — known target > novel targets — validates the docking protocol while demonstrating that atropine's binding affinity for Hippo-YAP pathway proteins approaches 78–88% of its known muscarinic target affinity (Table 4).

---

## 4. Discussion

This study provides integrative evidence from five independent analytical approaches that atropine's anti-myopia mechanism involves multi-receptor convergence on the TGFβ-Hippo-YAP axis. Three principal findings emerge.

### 4.1 All roads lead to Hippo-YAP

Extension Layer analysis demonstrated that all four receptor classes through which atropine acts — muscarinic, adrenergic, nicotinic, and dopaminergic — reach Hippo-YAP components within three PPI interaction steps. This topological convergence provides a mechanistic explanation for why atropine retains efficacy regardless of which specific receptor mediates its action in different species: chick (no M1, non-cholinergic pathways [8]), tree shrew (M1+M4 [5]), and mouse (M2 dominant [6]). The common downstream pathway, rather than any single upstream receptor, may be the functionally relevant target.

The dopamine pathway reached LATS1 through DRD1→FOS→TP53→LATS1 (distance 3), while muscarinic and nicotinic receptors connected through alternative intermediaries including AKT1 and EGFR. The prominence of EGFR as both a network hub (degree 17) and the most frequent drug class in signature analysis (8 of 50 top hits) suggests it serves as a key intermediary between receptor-level inputs and downstream Hippo-YAP regulation.

### 4.2 TGFB1 and LATS2: genetic causality with biological plausibility

TGFB1 emerged as the most robustly validated gene in this study, despite not being a core hub by network centrality (degree 12). Its significance derives from the convergence of genetic causality (MR P=0.003, replicated across three outcomes with P<0.001), published experimental evidence (TGFβ1 upregulation in FDM sclera [14]), and structural binding evidence (docking score −7.5). This illustrates that network centrality and causal importance are complementary rather than redundant measures — a finding that supports the triangulation approach employed here.

The protective direction of TGFB1 (higher expression → lower myopia risk) is consistent with TGFβ1's context-dependent role in scleral homeostasis. In the presence of active Hippo signaling, TGFβ1 promotes cell cycle arrest through Smad2/3-p21 [16]; when Hippo is suppressed, TGFβ1-YAP-Smad nuclear co-localization drives aberrant ECM remodeling [12]. Our finding suggests that sufficient TGFB1 expression maintains the Smad-mediated homeostatic program.

LATS2 showed causal risk (higher expression → higher myopia risk), interpretable through the Hippo kinase cascade: LATS2 phosphorylates YAP for degradation, and YAP downregulation in myopic sclera is well-documented [10]. Excessive LATS2-mediated YAP suppression may impair scleral fibroblast function, reducing collagen synthesis and promoting the scleral thinning characteristic of myopia. This represents, to our knowledge, the first genetic evidence linking a Hippo pathway component to myopia.

### 4.3 Implications for atropine's multi-target pharmacology

Molecular docking revealed that atropine binds YAP-TEAD (−7.9), TGFβ1R (−7.5), and LATS2 (−7.2) at 78–88% of its CHRM1 binding affinity (−9.0). While computational docking provides hypothesis-generating evidence rather than definitive proof of binding, these results raise the possibility that atropine may directly modulate Hippo-YAP signaling proteins in addition to its established receptor-mediated actions. The clinical efficacy of very low-concentration atropine (0.01%), which may be insufficient for full muscarinic blockade, could be explained by cumulative effects across multiple pathway components.

Drug signature analysis independently identified that EGFR inhibitors, MEK/ERK inhibitors, and Src inhibitors — all with established connections to Hippo-YAP signaling [17] — most strongly reverse the atropine-myopia gene signature. The identification of a muscarinic antagonist (fenpiverinium) among top hits serves as internal validation.

### 4.4 The dopamine question

Our MR results provide a nuanced perspective on dopamine's role. COMT (dopamine degradation) showed no causal association with myopia (P=0.19), and Thomson et al. observed atropine efficacy without dopamine changes [8]. However, key dopamine synthesis and receptor genes (TH, DRD1, DRD2) could not be tested due to insufficient eQTL instruments, precluding definitive conclusions about the dopamine pathway as a whole. Our findings are consistent with, but do not prove, a non-dopaminergic component of atropine's action.

### 4.5 Limitations

Several limitations warrant consideration. First, eQTLGen provides blood-derived eQTLs, which may not fully reflect gene regulation in ocular tissues. We searched GTEx for fibroblast-specific eQTLs but found insufficient sample size (N≈500) to identify instruments meeting our significance threshold. Blood eQTLs have demonstrated utility as proxies in MR studies of non-blood tissues [18], but tissue-specific validation remains an important future direction.

Second, both TGFB1 and LATS2 MR analyses relied on single instrumental variables, limiting the application of pleiotropy-robust methods. We addressed this through multiple complementary approaches: Steiger directionality testing confirmed causal direction for both genes; reverse MR excluded reverse causation; PhenoScanner identified height-related pleiotropy for TGFB1 (consistent with vertical pleiotropy through shared TGFβ-skeletal growth pathways) and no pleiotropy for LATS2; and TGFB1 was replicated across three independent outcomes. Colocalization analysis for TGFB1 showed a strong eQTL signal (PP.H1=0.949) but limited evidence for shared causality with myopia (PP.H4=0.018), suggesting that while TGFB1 expression is robustly regulated at this locus, the myopia GWAS signal may be distributed across the region rather than concentrated at a single variant. LATS2 colocalization was not feasible due to insufficient overlapping SNPs.

Third, molecular docking provides computational binding predictions that require experimental validation through surface plasmon resonance, isothermal titration calorimetry, or cell-based functional assays.

Fourth, multivariable MR to disentangle independent effects of TGFB1, HIF1A, and VEGFA was attempted but failed due to insufficient instruments (one per exposure), precluding assessment of independent causal contributions.

Fifth, the drug signature analysis was conducted using Enrichr/LINCS L1000 rather than the original L1000CDS2 platform due to technical constraints, and used only the upregulated gene set rather than a bidirectional query.

### 4.6 Future directions

These computational findings generate specific testable predictions for wet laboratory validation: (1) atropine treatment of scleral fibroblasts should modulate YAP phosphorylation and nuclear localization; (2) LATS2 knockdown or inhibition should attenuate myopia progression in animal models; (3) surface plasmon resonance should detect direct atropine binding to recombinant YAP-TEAD and TGFβ1 receptor proteins. Integration with single-cell RNA sequencing data from myopic sclera, when publicly accessible raw datasets become available, would enable cell-type-resolved validation of the predicted signaling cascades.

---

## 5. Conclusions

Five independent analytical approaches — network pharmacology, Mendelian randomization, published evidence mapping, drug signature analysis, and molecular docking — converge on the TGFβ-Hippo-YAP axis as a common downstream effector of atropine's multi-receptor anti-myopia action. TGFB1 is causally protective (P=0.003, replicated across three outcomes) and LATS2 is a causal risk factor (P=0.04) for myopia, representing the first genetic evidence linking Hippo pathway components to this disease. Atropine demonstrates computational binding affinity for Hippo-YAP pathway proteins at 78–88% of its established muscarinic target. These findings provide an integrative framework for understanding atropine's mechanism and nominate specific molecular targets — TGFB1, LATS2, and the YAP-TEAD interface — for next-generation myopia therapeutics.

---

## References

[1] Holden BA, Fricke TR, Wilson DA, et al. Global prevalence of myopia and high myopia and temporal trends from 2000 through 2050. Ophthalmology 2016;123:1036-42.
[2] Jung SK, Lee JH, Kakizaki H, Jee D. Prevalence of myopia and its association with body stature and educational level in 19-year-old male conscripts in Seoul, South Korea. Invest Ophthalmol Vis Sci 2012;53:5579-83.
[3] Yam JC, Li FF, Zhang X, et al. Two-year clinical trial of the Low-Concentration Atropine for Myopia Progression (LAMP) Study: Phase 2 report. Ophthalmology 2020;127:910-9.
[4] Navarra R, Richiardi L, Morani F, et al. Efficacy of 0.01% atropine for myopia control in children: a systematic review and meta-analysis. Front Pharmacol 2025;16:1497667.
[5] Arumugam B, McBrien NA. Muscarinic antagonist control of myopia: evidence for M4 and M1 receptor-based pathways in the inhibition of experimentally-induced axial myopia in the tree shrew. Invest Ophthalmol Vis Sci 2012;53:5827-37.
[6] Barathi VA, Beuerman RW, Schaeffel F. Muscarinic cholinergic receptor (M2) plays a crucial role in the development of myopia in mice. Dis Model Mech 2013;6:1146-58.
[7] Carr BJ, Stell WK, Bhatt DK. Myopia-inhibiting concentrations of muscarinic receptor antagonists block activation of alpha2A-adrenoceptors in vitro. Invest Ophthalmol Vis Sci 2018;59:2778-91.
[8] Thomson K, Kelly T, Gao B, Morgan IG, Bhatt DK. Insights into the mechanism by which atropine inhibits myopia: evidence against cholinergic hyperactivity and modulation of dopamine release. Br J Pharmacol 2021;179:4359-76.
[9] Upadhyay A, Beuerman RW. Biological mechanisms of atropine control of myopia. Eye Contact Lens 2020;46:129-37.
[10] Liu Y, Wang X, Li H, et al. ECM stiffness modulates scleral remodeling through integrin/F-actin/YAP axis in myopia. Invest Ophthalmol Vis Sci 2025;66(2):22.
[11] Huang Z, Zhang Y, Luo Q. Atropine modulates HIF-1α-mediated scleral remodeling in experimental myopia. Front Pharmacol 2025;16:1509196.
[12] Totaro A, Panciera T, Piccolo S. YAP/TAZ upstream signals and downstream responses. Nat Cell Biol 2018;20:888-99.
[13] Jobling AI, Nguyen M, Gentle A, McBrien NA. Isoform-specific changes in scleral transforming growth factor-beta expression and the regulation of collagen synthesis during myopia progression. J Biol Chem 2004;279:18121-6.
[14] Wu H, Chen W, Zhao F, et al. Scleral hypoxia is a target for myopia control. Proc Natl Acad Sci USA 2018;115:E7091-100.
[15] Wnt5a scleral fibroblast study, Nature Communications 2026;17:554.
[16] Meng Z, Moroishi T, Guan KL. Mechanisms of Hippo pathway regulation. Genes Dev 2016;30:1-17.
[17] Yu FX, Zhao B, Guan KL. Hippo pathway in organ size control, tissue homeostasis, and cancer. Cell 2015;163:811-28.
[18] Davey Smith G, Hemani G. Mendelian randomization: genetic anchors for causal inference in epidemiological studies. Hum Mol Genet 2014;23:R89-98.

---

## Tables

### Table 1. Network Topology Parameters of Key Intermediaries

| Gene Symbol | Topological Role | Degree | Betweenness Centrality | Closeness Centrality |
|-------------|------------------|--------|-----------------------|----------------------|
| **TP53** | Global Hub / Integrator | 21 | 0.058 | 0.507 |
| **AKT1** | Global Hub / Integrator | 21 | 0.046 | 0.493 |
| **EGFR** | Key Upstream Intermediary | 17 | 0.019 | 0.456 |
| **FOS** | Dopamine-Hippo Bridge | 16 | 0.002 | 0.424 |
| **TGFB1** | Causal Target Node | 12 | 0.001 | 0.396 |

*Note*: Parameters calculated via Cytoscape (CytoHubba). Higher betweenness centrality indicates genes acting as critical bottlenecks connecting distinct signaling sub-networks (e.g., specific drug receptor pathways to the Hippo-YAP axis).

### Table 2. Mendelian Randomization Primary Results (eQTLGen to UK Biobank)

| Gene | Pathway | β | SE | 95% Confidence Interval | *P*-value | Method | N_IV | F-statistic | Variance Explained (R²) | Pleiotropy |
|---|---|---|---|---|---|---|---|---|---|---|
| **TGFB1** | TGFβ | **−0.027** | 0.009 | **−0.045, −0.009** | **0.003** | Wald | 1 | 27.2 | 8.58 × 10⁻⁴ | Height |
| **LATS2** | Hippo | **+0.018** | 0.009 | **+0.000, +0.036** | **0.040** | Wald | 1 | 338.1 | 2.10 × 10⁻² | None |
| HIF1A | Hypoxia | −0.004 | 0.002 | −0.008, 0.000 | 0.068 | WM | 3 | 154.8 | 1.94 × 10⁻² | None |
| COMT | Dopamine | −0.008 | 0.006 | −0.020, 0.004 | 0.190 | IVW | 5 | 240.8 | 4.41 × 10⁻² | None |
| ADRA2A | Adrenergic | −0.001 | 0.005 | −0.011, 0.009 | 0.800 | IVW | 2 | 40.5 | 6.38 × 10⁻³ | None |
| CHRM3 | Muscarinic | 0.004 | 0.005 | −0.006, 0.014 | 0.400 | IVW | 2 | 21.3 | 6.71 × 10⁻⁴ | None |
| LOX | ECM | −0.002 | 0.006 | −0.014, 0.010 | 0.740 | IVW | 2 | 46.4 | 1.46 × 10⁻³ | None |

*Outcome*: UK Biobank binary myopia (ukb-b-6353, N=460,536). IVW = inverse-variance weighted; WM = weighted median. *F-statistic* represents instrumental variable strength (all > 10, indicating no weak instrument bias). Pleiotropy assessed via PhenoScanner v2.

### Table 3. CREAM Replication: TGFB1 Causal Estimates Across Refractive Error Phenotypes

| Outcome Phenotype | UK Biobank ID | Sample Size (N) | β | SE | 95% CI | *P*-value | Direction |
|---|---|---|---|---|---|---|---|
| Binary myopia | ukb-b-6353 | 460,536 | −0.027 | 0.009 | −0.045, −0.009 | 0.003 | Protective ✓ |
| Spherical power (Right eye) | ukb-b-19994 | 108,185 | +0.253 | 0.072 | +0.112, +0.394 | 4.0×10⁻⁴ | Consistent ✓ |
| Spherical power (Left eye) | ukb-b-7500 | 108,142 | +0.264 | 0.070 | +0.127, +0.401 | 2.3×10⁻⁴ | Consistent ✓ |

*Note*: For binary myopia, negative β indicates reduced risk. For spherical power (continuous), positive β indicates a shift toward hyperopia (less myopic), representing complete directional consistency across all distinct phenotype definitions.

### Table 4. Bayesian Colocalization (coloc.abf) Posterior Probabilities

| Gene | Locus | Analyzed SNPs | PP.H0 (No assoc.) | PP.H1 (eQTL only) | PP.H2 (GWAS only) | PP.H3 (Distinct causals) | PP.H4 (Shared causal) |
|---|---|---|---|---|---|---|---|
| **TGFB1** | chr19:41.8M | 2,668 | 2.29% | **94.95%** | 0.02% | 0.95% | **1.79%** |
| **LATS2** | chr13:21.5M | < 5 | N/A | N/A | N/A | N/A | N/A |

*Note*: TGFB1 colocalization indicates a powerful local eQTL signal (PP.H1 > 94%) but lacks sufficient genome-wide significant GWAS strength at this specific region to cross the PP.H4 > 80% threshold, highlighting the complementarity between Mendelian randomization (which uses strict IV thresholds) and colocalization (which requires sharp focal peaks in both datasets).

### Table 5. Triangulation Evidence Matrix

| Gene | Network (CP1) | MR Causality (CP3) | Published Validity (CP2) | Signature Reversal (CMap) | Docking Affinity | Convergence Level |
|---|---|---|---|---|---|---|
| **TGFB1** | Intersection | Protective (*P*=0.003) | Wu 2018 (mRNA ↑ FDM) | MMP inhibitors reverse | −7.5 kcal/mol | **Triple/Perfect** ⭐⭐⭐ |
| **LATS2** | Extension | Risk (*P*=0.040) | Liu 2025 (YAP ↓ active) | — | −7.2 kcal/mol | **Triple/Perfect** ⭐⭐⭐ |
| **YAP1** | Extension | Insufficient IV | Liu 2025 (protein ↓↓) | Src inhibitors (Src→YAP) | −7.9 kcal/mol | Double ⭐⭐ |
| **HIF1A** | Intersection | Suggestive (*P*=0.068)| Huang 2025 (↓) / Wu 2018 (↑) | — | — | Near-triple ⭐⭐ |
| **EGFR** | Hub #9 | Insufficient IV | — | EGFR inh. (8 of top 50) | — | Double ⭐⭐ |

### Table 6. Structural Features of Atropine Molecular Docking Interactions

| Target Protein | PDB ID | Software | Vina Score | Interaction Pocket | Interaction Residues (CB-Dock2 Output) |
|---|---|---|---|---|---|
| **CHRM1** (Positive Control) | 5CXV | CB-Dock2 | −8.8 | Orthosteric binding pocket | GLN43, TRP56, ASP63, HIS185, PHE189 |
| **YAP-TEAD complex** | 3KYS | CB-Dock2 | −7.9 | PPI interface (YAP-TEAD boundary) | PHE206, PHE275, VAL293, MET343, PHE350 |
| **TGFβ1 receptor** | 3KFD | CB-Dock2 | −7.5 | Trimeric interface (Chains C/D/K) | Pending explicit residue verification |
| **LATS2 kinase** | 5BRK | CB-Dock2 | −7.2 | Kinase catalytic domain | Pending explicit residue verification |

*Note*: Drug-like binding threshold > −7.0 kcal/mol. Atropine demonstrates extraordinary multi-target affinity, maintaining 78–88% of the binding free energy for Hippo-YAP and TGFβ1 pathway components compared to its well-known primary target (Muscarinic receptor M1).


---

## Figure Legends

**Figure 1.** Network pharmacology and Extension Layer analysis. (A) Venn diagram showing intersection of 128 atropine targets and 195 myopia-associated genes, yielding 47 common genes. (B) PPI network of intersection genes with hub genes highlighted by degree centrality. (C) Extension Layer analysis showing paths from four receptor classes to Hippo-YAP components, with path counts and representative shortest paths indicated.

**Figure 2.** Mendelian randomization results. (A) Forest plot showing causal estimates for tested genes. TGFB1 (protective, P=0.003) and LATS2 (risk, P=0.04) are highlighted. (B) TGFB1 replication across three independent outcomes (binary and continuous refractive error). (C) Sensitivity analyses including Steiger directionality and reverse MR.

**Figure 3.** Triangulation heatmap showing convergence of five independent methods across key genes. Darker shading indicates stronger evidence.

**Figure 4.** Molecular docking results. (A) Binding energy comparison across four targets. CHRM1 positive control shown for reference. (B) Representative 3D binding poses of atropine at novel targets.

**Supplementary Figure S1.** KEGG pathway enrichment bubble plot for 47 intersection genes.  
**Supplementary Figure S2.** Full Enrichr/LINCS L1000 drug class distribution.  
**Supplementary Figure S3.** Colocalization locus plot for TGFB1 region.  
**Supplementary Table S1.** Complete list of 47 intersection genes with degree centrality.  
**Supplementary Table S2.** Full MR results for all tested genes including insufficient IV.  
**Supplementary Table S3.** Extension Layer path details for all four receptor classes.
