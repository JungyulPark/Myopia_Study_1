# Multi-Receptor Convergence on TGFβ-Hippo-YAP in Atropine's Anti-Myopia Mechanism

Park Jungyul

Department of Ophthalmology, Seoul St. Mary's Hospital, College of Medicine, The Catholic University of Korea, Seoul, Republic of Korea

Corresponding author: Park Jungyul, MD, PhD; Department of Ophthalmology, Seoul St. Mary's Hospital, 222 Banpo-daero, Seocho-gu, Seoul 06591, Republic of Korea. E-mail: ophjyp@naver.com

## Abstract

Atropine is the most widely used pharmacological agent for myopia control, yet its mechanism remains unresolved, with conflicting evidence across muscarinic, adrenergic, dopaminergic, and nicotinic receptor pathways. We investigated whether these diverse receptor targets converge on the TGFβ-Hippo-YAP signaling axis using network pharmacology and Mendelian randomization as complementary approaches, supported by molecular docking and drug signature analysis. Intersection of 128 atropine targets and 195 myopia-associated genes yielded 47 common genes, of which 44 formed a connected protein–protein interaction network (191 edges). All four receptor classes converged on Hippo-YAP components within 2–3 interaction steps, with pathway-specific significance confirmed by permutation testing against 1,000 random KEGG pathways (P = 0.010). Two-sample Mendelian randomization using eQTLGen cis-eQTLs and UK Biobank myopia data (N = 460,536) implicated TGFB1 as causally protective (β = −0.027, P = 0.003, Bonferroni-significant), with the direct effect retaining 93.8% after multivariable conditioning on height. LATS2 showed a nominal association (β = +0.018, P = 0.040). TGFB1 was replicated across three refractive error phenotypes (all P < 0.001). Atropine exhibited scaffold-specific binding at Hippo pathway protein–protein interfaces (−7.5 to −7.9 kcal/mol vs caffeine control −5.2 to −5.8 kcal/mol). These findings suggest that atropine's anti-myopia mechanism may involve multi-receptor convergence on TGFβ-Hippo-YAP, with TGFB1 implicated as a putatively causal mediator, providing a hypothesis-generating framework for pathway-targeted myopia pharmacotherapy.

**Keywords**: myopia; atropine; Hippo-YAP signaling; network pharmacology; Mendelian randomization; TGFβ1

---

## 1. Introduction

Myopia affects approximately half of the global population, with projections estimating 4.9 billion affected individuals by 2050 (Holden et al., 2016). In East Asia, prevalence is particularly alarming, reaching 96.5% among 19-year-old male conscripts in Seoul (Jung et al., 2012). The shift toward indoor-dominant lifestyles and intensive near work is widely considered a primary environmental driver (Morgan et al., 2012, 2018), and the associated risk of sight-threatening complications — retinal detachment, myopic maculopathy, and glaucoma — renders myopia a major public health concern (Flitcroft et al., 2019). Low-concentration atropine (0.01–0.05%) has emerged as the primary pharmacological intervention for myopia control, with meta-analyses demonstrating reductions in spherical equivalent progression of approximately 0.16 D/year and axial elongation of 0.07 mm/year (Yam et al., 2020; Navarra et al., 2025). However, rebound progression upon cessation remains a concern (Lee et al., 2024), underscoring the need to understand atropine's mechanism to optimize dosing and develop next-generation agents.

Despite widespread clinical use, the molecular mechanism by which atropine inhibits myopia remains fundamentally unresolved. The conventional explanation — muscarinic receptor blockade — has been challenged by multiple lines of evidence. In the tree shrew, both M4-selective (MT3) and M1-selective (MT7) antagonists inhibit form-deprivation myopia, implicating M4 and M1 subtypes (Arumugam and McBrien, 2012). M2 knockout mice show the greatest resistance to myopia among muscarinic subtypes (Barathi et al., 2013). Carr et al. (2018) demonstrated that antagonist potency at the α2A-adrenoceptor, rather than at any muscarinic subtype, best correlates with anti-myopia efficacy. Meanwhile, retinal dopamine has long been considered a key mediator of myopia protection (Stone et al., 1989; Feldkaemper and Schaeffel, 2013), yet Thomson et al. (2021) showed that atropine's anti-myopia effect persists without measurable changes in retinal dopamine levels. This accumulated evidence led Upadhyay and Beuerman (2020) to characterize atropine as a "shotgun approach" drug that simultaneously engages muscarinic, adrenergic, nicotinic, GABA, and EGFR pathways.

A critical question remains: if atropine engages multiple upstream receptors, do these signals converge on a common downstream effector? The sclera — specifically its extracellular matrix (ECM) remodeling — is the primary structural determinant of axial elongation (McBrien and Gentle, 2003; Wallman and Winawer, 2004). Scleral remodeling in myopia involves TGFβ-dependent changes in collagen composition and matrix metalloproteinase activity (Jobling et al., 2004; Gentle et al., 2003), with hypoxia emerging as an upstream trigger (Wu et al., 2018). These observations suggest that regardless of which receptor atropine initially engages, the downstream effector may reside in the scleral signaling cascade rather than at the receptor level itself.

Recent evidence implicates the Hippo-YAP signaling pathway as a potential convergence point linking receptor-level signals to scleral remodeling. Liu et al. (2025) demonstrated that YAP expression is decreased in myopic sclera from both human tissue and guinea pig models, with ECM stiffness regulating scleral fibroblast behavior through the integrin/F-actin/YAP axis. Huang et al. (2025) showed atropine suppresses HIF-1α in form-deprived mouse sclera and constructed a preliminary PPI network centered on muscarinic receptors, linking atropine action to the hypoxia-TGFβ cascade. TGFβ-Smad and YAP physically interact through nuclear co-localization (Totaro et al., 2018), and the Hippo kinase cascade (MST1/2–LATS1/2–YAP/TAZ) is a central regulator of organ size and tissue homeostasis (Meng et al., 2016; Yu et al., 2015). A recent single-cell study identified Wnt5a-positive scleral fibroblasts as a myopia-protective cell population, further connecting Wnt-Hippo crosstalk to scleral biology (Zhu et al., 2026). However, no prior study has systematically examined whether atropine's multiple receptor targets converge on the TGFβ-Hippo-YAP axis.

Prior network pharmacology analyses of atropine in myopia have been limited to basic PPI construction without Hippo-YAP pathway analysis or genetic causal validation (Huang et al., 2025). Mendelian randomization (MR), which uses genetic variants as instrumental variables to infer causal relationships free from confounding (Davey Smith and Hemani, 2014; Skrivankova et al., 2021), has not been applied to test whether Hippo pathway components are causally linked to myopia. In this study, we employed network pharmacology and MR as complementary analytical approaches — supported by molecular docking and drug signature analysis — to investigate the hypothesis that atropine's anti-myopia mechanism operates through multi-receptor convergence on the TGFβ-Hippo-YAP axis.

## 2. Materials and methods

### 2.1. Study design

This study employed network pharmacology with Extension Layer analysis and two-sample MR as complementary core approaches, supported by drug signature reversal analysis and molecular docking (Fig. 1). This design follows established principles for strengthening causal inference through evidential triangulation (Skrivankova et al., 2021). This study used only publicly available summary-level data and did not involve human subjects; institutional review board approval was not required.

### 2.2. Network pharmacology

#### 2.2.1. Atropine target identification

Atropine-associated gene targets were retrieved from the Comparative Toxicogenomics Database (CTD) using compound ID D001285, supplemented by DrugBank and SwissTargetPrediction using the canonical SMILES (Daina et al., 2019). After merging and deduplication, 128 unique targets were identified.

#### 2.2.2. Myopia-associated gene extraction

Myopia-associated genes were extracted from CTD using disease ID D009216. Only genes with Direct Evidence annotations (marker/mechanism categories) were retained, supplemented with DisGeNET (curated sources) and OMIM. After deduplication, 195 genes were included.

#### 2.2.3. PPI network construction

The intersection yielded 47 common genes. Of these, 44 had at least one interaction at STRING v12.0 confidence ≥0.700 (Homo sapiens) (Szklarczyk et al., 2023), forming a connected network of 191 edges. Three genes (CHRM4, ACHE, ADRA2B) lacked interactions above this threshold and were excluded from topological analysis but retained for MR candidate selection. The network was imported into Cytoscape v3.10.2 for hub gene identification (Shannon et al., 2003).

#### 2.2.4. Extension Layer analysis

Hippo-YAP pathway components (LATS1, LATS2, YAP1, TEAD1-4, WWTR1, NF2, SAV1, AMOT, MOB1A) were deliberately excluded from the intersection network to avoid circular reasoning and added as an adjacent Extension Layer connected through STRING interactions (confidence ≥0.700). Shortest-path analysis was performed from each of four receptor classes — muscarinic (CHRM1, CHRM3, CHRM5), dopaminergic (DRD1, DRD2), adrenergic (ADRA2A, ADRA2C), and nicotinic (CHRNA3, CHRNA4, CHRNB2) — to each Hippo-YAP component.

#### 2.2.5. Permutation testing

To test whether Hippo-YAP convergence was specific rather than a trivial network property, we conducted an empirical permutation test. One thousand KEGG pathways (≥5 genes each, excluding the Hippo signaling pathway itself) were randomly sampled as alternative Extension Layers. For each, the same shortest-path analysis was performed. Empirical P-values were calculated as the proportion of random pathways achieving equal or greater convergence than Hippo-YAP.

#### 2.2.6. Pathway enrichment

GO and KEGG enrichment analyses were performed using g:Profiler with Benjamini-Hochberg correction (adjusted P < 0.05).

### 2.3. Mendelian randomization

#### 2.3.1. Data sources

Two-sample MR was conducted following STROBE-MR guidelines (Skrivankova et al., 2021). Genetic instruments were obtained from eQTLGen (N = 31,684; blood cis-eQTLs) (Võsa et al., 2021). The primary outcome was UK Biobank myopia (ukb-b-6353; N = 460,536) (Elsworth et al., 2020).

#### 2.3.2. Instrument selection

Seven genes across five modules had sufficient instruments (all F > 10): TGFB1, LOX (TGFβ/ECM), LATS2 (Hippo-YAP), COMT (dopamine), CHRM3 (muscarinic), ADRA2A (adrenergic), and HIF1A (hypoxia). Fifteen additional genes lacked instruments at P < 5 × 10⁻⁶ (Supplementary Table S2). LD clumping: r² < 0.001, window 10,000 kb.

#### 2.3.3. Statistical methods

Single-instrument genes: Wald ratio. Multi-instrument genes: IVW (primary), weighted median, MR-Egger (sensitivity). Bonferroni correction was applied for 7 tests (threshold P < 0.0071).

#### 2.3.4. Sensitivity analyses

Steiger directionality testing confirmed causal direction for significant genes (Hemani et al., 2017). Reverse MR and PhenoScanner v2 pleiotropy screening were performed (Staley et al., 2016). For TGFB1, whose lead instrument (rs1963413) showed genome-wide significant association with standing height, multivariable MR decomposition conditioning on height (ukb-b-10787) was performed to quantify the proportion of effect mediated through the height pathway.

#### 2.3.5. Replication and colocalization

TGFB1 was replicated using right-eye (ukb-b-19994) and left-eye (ukb-b-7500) spherical power. Bayesian colocalization (coloc.abf) used full eQTLGen and UK Biobank summary statistics (±500 kb; default priors) (Giambartolomei et al., 2014).

### 2.4. Drug signature reversal analysis

The Enrichr platform was queried using the LINCS L1000 Chemical Perturbation Consensus Signatures library (Lachmann et al., 2018). The 23 most highly connected hub genes from the intersection network were submitted as the input gene set.

### 2.5. Molecular docking

Structure-based blind docking was performed using CB-Dock2 (Liu et al., 2022) for four targets: TGFβ1 receptor (PDB: 3KFD) (Groppe et al., 2008), MOB1-LATS1 complex (PDB: 5BRK) (Ni et al., 2015), YAP-TEAD complex (PDB: 3KYS) (Li et al., 2010), and CHRM1 (PDB: 5CXV, positive control) (Thal et al., 2016). Binding energies below −7.0 kcal/mol were considered drug-like (Pagadala et al., 2017). To assess specificity, two structural controls — scopolamine (tropane alkaloid) and caffeine (xanthine derivative) — were docked against the same targets under identical conditions.

### 2.6. Data availability and AI disclosure

All code is available at https://github.com/JungyulPark/Myopia_Study_1. Generative AI tools (Claude, Anthropic) were used for literature search assistance, code debugging, and manuscript drafting. All outputs were critically reviewed, verified against primary data sources, and edited by the author, who assumes full responsibility for the content.

## 3. Results

### 3.1. Network pharmacology identifies hub genes at the atropine–myopia intersection

A total of 128 atropine-associated targets and 195 myopia-associated genes yielded 47 common genes (Fig. 2A). Of these, 44 formed a connected PPI network (191 edges; Fig. 2B). Top hub genes by degree: TP53 and AKT1 (21 each; betweenness centrality 0.058 and 0.046), IL6, CTNNB1, and TNF (19 each), EGFR (17, betweenness 0.019), and FOS (16) (Table 1). TGFB1 ranked 17th (degree 12, betweenness 0.001). KEGG enrichment identified pathways in cancer (adjusted P = 2.1 × 10⁻³⁵), lipid and atherosclerosis (adjusted P = 5.8 × 10⁻²⁸), and IL-17 signaling (adjusted P = 1.2 × 10⁻²²) among 168 significant pathways. Hippo signaling was not enriched, consistent with the deliberate exclusion of Hippo-YAP components.

### 3.2. Four receptor classes converge on Hippo-YAP with pathway-specific significance

All four receptor classes reached Hippo-YAP components: muscarinic (40 paths), nicotinic (32), adrenergic (24), and dopaminergic (16). Representative paths: DRD1 → FOS → TP53 → LATS1 (distance 3); CHRNA3 → ACHE → EGFR → LATS1 (distance 3); CHRM1 → AKT1 → YAP1 (distance 2); ADRA2A → TP53 → LATS1 (distance 2). Mean shortest-path distance was 2.7 ± 0.5 steps. Permutation testing against 1,000 random KEGG pathways confirmed pathway-specific convergence (P = 0.010 for path count; P = 0.048 for combined convergence score; Supplementary Fig. S1), ruling out a trivial small-world network artifact.

### 3.3. MR implicates TGFB1 as causally protective against myopia

Among 22 candidates, seven had sufficient instruments (Table 2, Panel A). TGFB1 showed a Bonferroni-significant causal protective effect (Wald β = −0.027, SE = 0.009, 95% CI −0.045 to −0.009, P = 0.003; F = 27.2; lead SNP rs1963413, EAF = 0.614). Steiger directionality confirmed correct causal direction (P = 1.7 × 10⁻⁵); reverse MR was null (P = 0.90). LATS2 showed a nominal association that did not survive Bonferroni correction (Wald β = +0.018, SE = 0.009, P = 0.040; F = 30.7; lead SNP rs10891299). HIF1A was suggestive (IVW P = 0.154; weighted median P = 0.068). COMT (P = 0.191), ADRA2A (P = 0.796), CHRM3 (P = 0.403), and LOX (P = 0.743) were null.

### 3.4. TGFB1 effect is robust to height conditioning and phenotype replication

PhenoScanner identified a genome-wide significant association between rs1963413 and standing height (β = −0.013, P = 2.8 × 10⁻²⁰). Multivariable MR decomposition demonstrated that only 6.2% of the total TGFB1–myopia effect was mediated through height (indirect β = −0.0017), while the direct effect remained robust (β = −0.0254, 93.8% of total; Table 2, Panel B). TGFB1 was replicated using continuous refractive error: right eye (β = +0.253, P = 4.0 × 10⁻⁴) and left eye (β = +0.264, P = 2.3 × 10⁻⁴). All three phenotype definitions yielded P < 0.001 with consistent directionality, though these represent correlated outcomes within the same cohort rather than independent replications.

### 3.5. Colocalization

Bayesian colocalization for the TGFB1 locus (2,668 SNPs) yielded PP.H1 = 94.95% and PP.H4 = 1.79% (Table 2, Panel C), indicating a strong eQTL signal but no shared GWAS peak at this locus. This likely reflects the polygenic architecture of myopia rather than instrument invalidity, though the causal inference for TGFB1 should be considered provisional pending tissue-specific eQTL colocalization.

### 3.6. Drug signature analysis and molecular docking provide supporting evidence

EGFR inhibitors appeared eight times among the top 50 reversal compounds (gefitinib, tyrphostin AG 1478, canertinib, pelitinib), consistent with EGFR's hub position (degree 17) and Extension Layer bridge role (CHRNA3 → ACHE → EGFR → LATS1). MEK/ERK inhibitors appeared six times. No muscarinic compounds appeared in the top 50. Atropine showed drug-like binding at YAP-TEAD (−7.9 kcal/mol), MOB1-LATS1 (−7.6), and TGFβ1R (−7.5), exceeding the positive control threshold (CHRM1 −8.8). Negative control docking demonstrated scaffold specificity: caffeine yielded substantially weaker binding at all targets (−5.2 to −6.6 kcal/mol), while scopolamine (tropane scaffold) showed comparable binding to atropine at MOB1-LATS1 (−7.4 vs −7.6), indicating tropane-scaffold-dependent rather than atropine-specific binding (Table 4).

## 4. Discussion

The principal computational observation of this study is that all four of atropine's receptor classes — muscarinic, dopaminergic, adrenergic, and nicotinic — converge on Hippo-YAP components within three interaction steps, with this convergence confirmed as pathway-specific by permutation testing (P = 0.010). This convergence was not assumed a priori; Hippo-YAP genes were deliberately placed in a separate Extension Layer, and the convergence emerged from data-driven analysis. These findings suggest that atropine may function as a network modulator — a compound whose effect arises from partial inhibition of multiple inputs feeding a common convergence point (Hopkins, 2008). If this interpretation is correct, it could explain why 0.01% atropine retains efficacy at concentrations far below the IC₅₀ for any individual muscarinic receptor (Yam et al., 2020; Navarra et al., 2025).

The MR results provide suggestive genetic evidence linking a Hippo-TGFβ pathway component to myopia. TGFB1 showed a Bonferroni-significant protective effect (P = 0.003), with the direct causal estimate retaining 93.8% of its magnitude after conditioning on height — the primary pleiotropic concern. Consistency across three phenotype definitions within the same cohort (all P < 0.001) further supports this association, though these do not constitute independent replications. The colocalization result (PP.H4 = 1.79%) represents a genuine limitation: while the dominant PP.H1 (94.95%) confirms robust cis-regulation of TGFB1 expression, the absence of a sharp GWAS peak at this locus means the causal inference should be considered provisional pending tissue-specific eQTL colocalization. LATS2 showed only a nominal association (P = 0.040) that did not survive Bonferroni correction, and its biological interpretation should be treated with particular caution.

Huang et al. (2025) previously constructed a PPI network centered on CHRM1-5, identifying AKT1, HIF-1α, and CTNNB1 as hubs. Our study extends this by incorporating all four receptor classes, introducing the Extension Layer strategy with permutation validation, and providing genetic causal evidence through MR. The addition of MR elevates the evidence from associative network topology to putative genetic causality (Davey Smith and Hemani, 2014), though the single-instrument limitation for TGFB1 and LATS2 constrains the strength of this inference.

If blood eQTL effects are mirrored in scleral tissue, the TGFB1 protective effect is consistent with its role in maintaining scleral fibroblast quiescence through Smad2/3-p21 signaling (Jobling et al., 2004; Totaro et al., 2018). The nominal LATS2 association, if confirmed, would be mechanistically coherent: elevated LATS2 would increase YAP phosphorylation and reduce nuclear YAP — the pattern observed by Liu et al. (2025) in myopic sclera. However, these tissue-specific interpretations remain speculative given our reliance on blood-derived eQTLs.

The null MR results for COMT (P = 0.191), CHRM3 (P = 0.403), and ADRA2A (P = 0.796) are consistent with, but do not prove, the network modulator hypothesis. Importantly, the most informative pathway genes — TH, DRD1, DRD2 (dopamine), CHRM1, CHRM4 (muscarinic), YAP1, LATS1, TEAD1 (Hippo) — could not be tested due to insufficient instrumental variables. These pathways are therefore undertested rather than excluded, and absence of evidence should not be interpreted as evidence of absence.

The drug signature analysis and molecular docking provide supporting but preliminary evidence. EGFR inhibitors dominated the reversal compounds, consistent with EGFR's bridge role in the Extension Layer (CHRNA3 → ACHE → EGFR → LATS1). Molecular docking showed scaffold-dependent binding at Hippo pathway protein–protein interfaces, with tropane alkaloids (atropine, scopolamine) consistently exceeding the binding of the structurally dissimilar caffeine control by 1.8–2.7 kcal/mol. However, computational docking predictions require experimental validation through surface plasmon resonance or isothermal titration calorimetry. Whether binding at MOB1-LATS1 or YAP-TEAD interfaces modulates Hippo output in a biologically relevant manner remains to be determined.

Several additional limitations should be acknowledged. First, our MR analysis relied on blood-derived eQTLs from eQTLGen rather than ocular tissue-specific eQTLs; GTEx fibroblasts (N ≈ 504) had insufficient power (Võsa et al., 2021). Second, TGFB1 and LATS2 each relied on single instrumental variables, precluding conventional sensitivity analyses. Third, 15 of 22 candidate genes could not be tested by MR. Fourth, the drug signature analysis used Enrichr rather than direct L1000CDS2 query. Fifth, published evidence mapping was conducted as a narrative review rather than a systematic analysis.

In conclusion, network pharmacology and genetic evidence suggest that atropine's anti-myopia mechanism may involve multi-receptor convergence on the TGFβ-Hippo-YAP axis. TGFB1 is implicated as a putatively causal mediator, with its protective effect robust to height conditioning. These findings provide a hypothesis-generating framework for pathway-targeted myopia pharmacotherapy. Experimental validation in scleral tissue models is needed to confirm these computational and genetic predictions.

## Acknowledgements

None.

## Declaration of competing interest

The author declares no conflicts of interest.

## Funding

This research did not receive any specific grant from funding agencies in the public, commercial, or not-for-profit sectors.

## CRediT authorship contribution statement

**Park Jungyul**: Conceptualization, Methodology, Software, Formal analysis, Investigation, Data curation, Writing – original draft, Writing – review & editing, Visualization.

## Data availability

All code and data are publicly available at https://github.com/JungyulPark/Myopia_Study_1.

## Appendix A. Supplementary data

Supplementary data to this article can be found online.

---

## References

Arumugam, B., McBrien, N.A., 2012. Muscarinic antagonist control of myopia: evidence for M4 and M1 receptor-based pathways in the inhibition of experimentally-induced axial myopia in the tree shrew. Invest. Ophthalmol. Vis. Sci. 53, 5827–5837.

Barathi, V.A., Beuerman, R.W., Schaeffel, F., 2013. Muscarinic cholinergic receptor (M2) plays a crucial role in the development of myopia in mice. Dis. Model. Mech. 6, 1146–1158.

Carr, B.J., Stell, W.K., Bhatt, D.K., 2018. Myopia-inhibiting concentrations of muscarinic receptor antagonists block activation of alpha2A-adrenoceptors in vitro. Invest. Ophthalmol. Vis. Sci. 59, 2778–2791.

Daina, A., Michielin, O., Zoete, V., 2019. SwissTargetPrediction: updated data and new features for efficient prediction of protein targets of small molecules. Nucleic Acids Res. 47, W357–W364.

Davey Smith, G., Hemani, G., 2014. Mendelian randomization: genetic anchors for causal inference in epidemiological studies. Hum. Mol. Genet. 23, R89–R98.

Elsworth, B., Lyon, M., Alexander, T., et al., 2020. The MRC IEU OpenGWAS data infrastructure. eLife 9, e59298.

Feldkaemper, M., Schaeffel, F., 2013. An updated view on the role of dopamine in myopia. Exp. Eye Res. 114, 106–119.

Flitcroft, D.I., He, M., Jonas, J.B., et al., 2019. IMI — Defining and classifying myopia: a proposed set of standards. Invest. Ophthalmol. Vis. Sci. 60, M20–M30.

Gentle, A., Liu, Y., Martin, J.E., Conti, G.L., McBrien, N.A., 2003. Collagen gene expression and the altered accumulation of scleral collagen during the development of high myopia. J. Biol. Chem. 278, 16587–16594.

Giambartolomei, C., Vukcevic, D., Schadt, E.E., et al., 2014. Bayesian test for colocalisation between pairs of genetic association studies using summary statistics. PLoS Genet. 10, e1004383.

Groppe, J., Hinck, C.S., Samavarchi-Tehrani, P., et al., 2008. Cooperative assembly of TGF-β superfamily signaling complexes. Mol. Cell 29, 157–168.

Hemani, G., Tilling, K., Davey Smith, G., 2017. Orienting the causal relationship between imprecisely measured traits using GWAS summary data. PLoS Genet. 13, e1007081.

Holden, B.A., Fricke, T.R., Wilson, D.A., et al., 2016. Global prevalence of myopia and high myopia and temporal trends from 2000 through 2050. Ophthalmology 123, 1036–1042.

Hopkins, A.L., 2008. Network pharmacology: the next paradigm in drug discovery. Nat. Chem. Biol. 4, 682–690.

Huang, L., Zhang, J., Luo, Y., 2025. The role of atropine in myopia control: insights into choroidal and scleral mechanisms. Front. Pharmacol. 16, 1509196.

Jobling, A.I., Nguyen, M., Gentle, A., McBrien, N.A., 2004. Isoform-specific changes in scleral transforming growth factor-beta expression and the regulation of collagen synthesis during myopia progression. J. Biol. Chem. 279, 18121–18126.

Jung, S.K., Lee, J.H., Kakizaki, H., Jee, D., 2012. Prevalence of myopia and its association with body stature and educational level in 19-year-old male conscripts in Seoul, South Korea. Invest. Ophthalmol. Vis. Sci. 53, 5579–5583.

Lachmann, A., Torre, D., Keenan, A.B., et al., 2018. Massive mining of publicly available RNA-seq data from human and mouse. Nat. Commun. 9, 1366.

Lee, S.H., Tsai, P.C., Chiu, Y.C., Wang, J.H., Chiu, C.J., 2024. Myopia progression after cessation of atropine in children: a systematic review and meta-analysis. Front. Pharmacol. 15, 1343698.

Li, Z., Zhao, B., Wang, P., et al., 2010. Structural insights into the YAP and TEAD complex. Genes Dev. 24, 235–240.

Liu, Y., Wang, X., Li, H., et al., 2025. ECM stiffness modulates scleral remodeling through integrin/F-actin/YAP axis in myopia. Invest. Ophthalmol. Vis. Sci. 66, 22.

Liu, Y., Yang, X., Gan, J., et al., 2022. CB-Dock2: improved protein-ligand blind docking by integrating cavity detection, docking and homologous template fitting. Nucleic Acids Res. 50, W159–W164.

Liu-Chittenden, Y., Huang, B., Shim, J.S., et al., 2012. Genetic and pharmacological disruption of the TEAD-YAP complex suppresses the oncogenic activity of YAP. Genes Dev. 26, 1300–1305.

McBrien, N.A., Gentle, A., 2003. Role of the sclera in the development and pathological complications of myopia. Prog. Retin. Eye Res. 22, 307–338.

Meng, Z., Moroishi, T., Guan, K.L., 2016. Mechanisms of Hippo pathway regulation. Genes Dev. 30, 1–17.

Morgan, I.G., French, A.N., Ashby, R.S., et al., 2018. The epidemics of myopia: aetiology and prevention. Prog. Retin. Eye Res. 62, 134–149.

Morgan, I.G., Ohno-Matsui, K., Saw, S.M., 2012. Myopia. Lancet 379, 1739–1748.

Navarra, R., Richiardi, L., Morani, F., et al., 2025. Efficacy of 0.01% atropine for myopia control in children: a systematic review and meta-analysis. Front. Pharmacol. 16, 1497667.

Ni, L., Zheng, Y., Hara, M., et al., 2015. Structural basis for auto-inhibition of the NDR family kinase LATS1. Structure 23, 1467–1476.

Pagadala, N.S., Syed, K., Tuszynski, J., 2017. Software for molecular docking: a review. Biophys. Rev. 9, 91–102.

Shannon, P., Markiel, A., Ozier, O., et al., 2003. Cytoscape: a software environment for integrated models of biomolecular interaction networks. Genome Res. 13, 2498–2504.

Skrivankova, V.W., Richmond, R.C., Woolf, B.A.R., et al., 2021. Strengthening the reporting of observational studies in epidemiology using Mendelian randomization: the STROBE-MR statement. JAMA 326, 1614–1621.

Staley, J.R., Blackshaw, J., Kamat, M.A., et al., 2016. PhenoScanner: a database of human genotype-phenotype associations. Bioinformatics 32, 3207–3209.

Stone, R.A., Lin, T., Laties, A.M., Iuvone, P.M., 1989. Retinal dopamine and form-deprivation myopia. Proc. Natl. Acad. Sci. USA 86, 704–706.

Szklarczyk, D., Kirsch, R., Koutrouli, M., et al., 2023. The STRING database in 2023. Nucleic Acids Res. 51, D483–D489.

Thal, D.M., Sun, B., Feng, D., et al., 2016. Crystal structures of the M1 and M4 muscarinic acetylcholine receptors. Nature 531, 335–340.

Thomson, K., Kelly, T., Gao, B., Morgan, I.G., Bhatt, D.K., 2021. Insights into the mechanism by which atropine inhibits myopia: evidence against cholinergic hyperactivity and modulation of dopamine release. Br. J. Pharmacol. 179, 4359–4376.

Totaro, A., Panciera, T., Piccolo, S., 2018. YAP/TAZ upstream signals and downstream responses. Nat. Cell Biol. 20, 888–899.

Upadhyay, A., Beuerman, R.W., 2020. Biological mechanisms of atropine control of myopia. Eye Contact Lens 46, 129–137.

Võsa, U., Claringbould, A., Westra, H.J., et al., 2021. Large-scale cis- and trans-eQTL analyses identify thousands of genetic loci and polygenic scores that regulate blood gene expression. Nat. Genet. 53, 1300–1310.

Wallman, J., Winawer, J., 2004. Homeostasis of eye growth and the question of myopia. Neuron 43, 447–468.

Wu, H., Chen, W., Zhao, F., et al., 2018. Scleral hypoxia is a target for myopia control. Proc. Natl. Acad. Sci. USA 115, E7091–E7100.

Yam, J.C., Li, F.F., Zhang, X., et al., 2020. Two-year clinical trial of the LAMP Study: Phase 2 report. Ophthalmology 127, 910–919.

Yin, X., Ge, J., 2025. The role of scleral changes in the progression of myopia: a review and future directions. Clin. Ophthalmol. 19, 1699–1707.

Yu, F.X., Zhao, B., Guan, K.L., 2015. Hippo pathway in organ size control, tissue homeostasis, and cancer. Cell 163, 811–828.

Zhu, H., Chen, W., Ling, X., Jiao, S., Yu, L., Liu, H., et al., 2026. Decreased scleral Wnt5a-hi fibroblasts exacerbate myopia progression by disrupting extracellular matrix homeostasis in mice. Nat. Commun. 17, 554.
