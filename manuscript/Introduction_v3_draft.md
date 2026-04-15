# Introduction v3 — Expanded with ~30 References
## IOVS format: references numbered by order of citation

---

## INTRODUCTION TEXT (6 paragraphs)

### Paragraph 1: Epidemiology + clinical need
Myopia affects approximately half of the global population, with projections estimating 4.9 billion affected individuals by 2050.^1 In East Asia, prevalence is particularly alarming, reaching 96.5% among 19-year-old male conscripts in Seoul.^2 The shift toward indoor-dominant lifestyles and intensive near work is widely considered a primary environmental driver,^3,4 and the associated risk of sight-threatening complications — retinal detachment, myopic maculopathy, and glaucoma — renders myopia a major public health concern.^5 Low-concentration atropine (0.01–0.05%) has emerged as the primary pharmacological intervention for myopia control, with meta-analyses demonstrating reductions in spherical equivalent progression of approximately 0.16 D/year and axial elongation of 0.07 mm/year.^6,7 A recent International Myopia Institute (IMI) report confirmed atropine among the most evidence-supported treatments.^8 However, rebound progression upon cessation remains a concern,^9 underscoring the need to understand atropine's mechanism to optimize dosing and develop next-generation agents.

### Paragraph 2: Receptor-level uncertainty
Despite widespread clinical use, the molecular mechanism by which atropine inhibits myopia remains fundamentally unresolved. The conventional explanation — muscarinic receptor blockade — has been challenged by multiple lines of evidence. In the tree shrew, both M4-selective (MT3) and M1-selective (MT7) antagonists inhibit form-deprivation myopia (FDM), implicating M4 and M1 subtypes.^10 M2 knockout mice show the greatest resistance to myopia among muscarinic subtypes.^11 Carr et al. demonstrated that antagonist potency at the α2A-adrenoceptor, rather than at any muscarinic subtype, best correlates with anti-myopia efficacy.^12 Meanwhile, retinal dopamine has long been considered a key mediator of myopia protection,^13,14 yet Thomson et al. showed that atropine's anti-myopia effect persists without measurable changes in retinal dopamine levels.^15 This accumulated evidence led Upadhyay and Beuerman to characterize atropine as a "shotgun approach" drug that simultaneously engages muscarinic, adrenergic, nicotinic, GABA, and EGFR pathways.^16

### Paragraph 3: Downstream convergence hypothesis
A critical question remains: if atropine engages multiple upstream receptors, do these signals converge on a common downstream effector? The sclera — specifically its extracellular matrix (ECM) remodeling — is the primary structural determinant of axial elongation.^17,18 Scleral remodeling in myopia involves TGFβ-dependent changes in collagen composition and matrix metalloproteinase activity,^19,20 with hypoxia emerging as an upstream trigger.^21 These observations suggest that regardless of which receptor atropine initially engages, the downstream effector may reside in the scleral signaling cascade rather than at the receptor level itself.

### Paragraph 4: Hippo-YAP and TGFβ as candidate convergence point
Recent evidence implicates the Hippo-YAP signaling pathway as a potential convergence point linking receptor-level signals to scleral remodeling. Liu et al. demonstrated that YAP expression is decreased in myopic sclera from both human tissue and guinea pig models, with ECM stiffness regulating scleral fibroblast behavior through the integrin/F-actin/YAP axis.^22 Huang et al. showed atropine suppresses HIF-1α in FDM mouse sclera, linking atropine action directly to the hypoxia-TGFβ cascade.^23 TGFβ-Smad and YAP physically interact through nuclear co-localization,^24 and the Hippo kinase cascade (MST1/2–LATS1/2–YAP/TAZ) is a central regulator of organ size and tissue homeostasis.^25,26 A recent single-cell study identified Wnt5a-positive scleral fibroblasts as a myopia-protective cell population, further connecting Wnt-Hippo crosstalk to scleral biology.^27 However, no prior study has systematically examined whether atropine's multiple receptor targets converge on the TGFβ-Hippo-YAP axis.

### Paragraph 5: Knowledge gap + novelty claim
Several network pharmacology studies have explored atropine's target profile,^28 but these have been limited to basic PPI construction without Hippo-YAP pathway analysis or genetic causal validation. Mendelian randomization (MR), which uses genetic variants as instrumental variables to infer causal relationships free from confounding,^29,30 has not been applied to test whether Hippo pathway components are causally linked to myopia. Thus, the causal role of Hippo pathway components in myopia remains untested by genetic epidemiological methods.

### Paragraph 6: Study aims
In this study, we employed five independent analytical approaches — network pharmacology, Mendelian randomization with replication and colocalization, published evidence mapping, drug signature analysis, and molecular docking — to test the hypothesis that atropine's anti-myopia mechanism operates through multi-receptor convergence on the TGFβ-Hippo-YAP axis. This integrative triangulation design, where each method addresses the limitations of the others, provides stronger evidence than any single analytical framework alone.

---

## REFERENCE LIST (ordered by first citation in text)

[1] Holden BA, Fricke TR, Wilson DA, et al. Global prevalence of myopia and high myopia and temporal trends from 2000 through 2050. Ophthalmology 2016;123:1036-42.

[2] Jung SK, Lee JH, Kakizaki H, Jee D. Prevalence of myopia and its association with body stature and educational level in 19-year-old male conscripts in Seoul, South Korea. Invest Ophthalmol Vis Sci 2012;53:5579-83.

[3] Morgan IG, Ohno-Matsui K, Saw SM. Myopia. Lancet 2012;379:1739-48.

[4] Morgan IG, French AN, Ashby RS, et al. The epidemics of myopia: aetiology and prevention. Prog Retin Eye Res 2018;62:134-49.

[5] Flitcroft DI, He M, Jonas JB, et al. IMI — Defining and classifying myopia: a proposed set of standards for clinical and epidemiologic studies. Invest Ophthalmol Vis Sci 2019;60:M20-30.

[6] Yam JC, Li FF, Zhang X, et al. Two-year clinical trial of the Low-Concentration Atropine for Myopia Progression (LAMP) Study: Phase 2 report. Ophthalmology 2020;127:910-9.

[7] Navarra R, Richiardi L, Morani F, et al. Efficacy of 0.01% atropine for myopia control in children: a systematic review and meta-analysis. Front Pharmacol 2025;16:1497667.

[8] Wildsoet CF, Chia A, Cho P, et al. IMI — Interventions for controlling myopia onset and progression report. Invest Ophthalmol Vis Sci 2019;60:M106-31.

[9] Lee SH, Tsai PC, Chiu YC, Wang JH, Chiu CJ. Myopia progression after cessation of atropine in children: a systematic review and meta-analysis. Front Pharmacol 2024;15:1343698.

[10] Arumugam B, McBrien NA. Muscarinic antagonist control of myopia: evidence for M4 and M1 receptor-based pathways in the inhibition of experimentally-induced axial myopia in the tree shrew. Invest Ophthalmol Vis Sci 2012;53:5827-37.

[11] Barathi VA, Beuerman RW, Schaeffel F. Muscarinic cholinergic receptor (M2) plays a crucial role in the development of myopia in mice. Dis Model Mech 2013;6:1146-58.

[12] Carr BJ, Stell WK, Bhatt DK. Myopia-inhibiting concentrations of muscarinic receptor antagonists block activation of alpha2A-adrenoceptors in vitro. Invest Ophthalmol Vis Sci 2018;59:2778-91.

[13] Stone RA, Lin T, Laties AM, Iuvone PM. Retinal dopamine and form-deprivation myopia. Proc Natl Acad Sci USA 1989;86:704-6.

[14] Feldkaemper M, Schaeffel F. An updated view on the role of dopamine in myopia. Exp Eye Res 2013;114:106-19.

[15] Thomson K, Kelly T, Gao B, Morgan IG, Bhatt DK. Insights into the mechanism by which atropine inhibits myopia: evidence against cholinergic hyperactivity and modulation of dopamine release. Br J Pharmacol 2021;179:4359-76.

[16] Upadhyay A, Beuerman RW. Biological mechanisms of atropine control of myopia. Eye Contact Lens 2020;46:129-37.

[17] McBrien NA, Gentle A. Role of the sclera in the development and pathological complications of myopia. Prog Retin Eye Res 2003;22:307-38.

[18] Wallman J, Winawer J. Homeostasis of eye growth and the question of myopia. Neuron 2004;43:447-68.

[19] Jobling AI, Nguyen M, Gentle A, McBrien NA. Isoform-specific changes in scleral transforming growth factor-beta expression and the regulation of collagen synthesis during myopia progression. J Biol Chem 2004;279:18121-6.

[20] Gentle A, Liu Y, Martin JE, Conti GL, McBrien NA. Collagen gene expression and the altered accumulation of scleral collagen during the development of high myopia. J Biol Chem 2003;278:16587-94.

[21] Wu H, Chen W, Zhao F, et al. Scleral hypoxia is a target for myopia control. Proc Natl Acad Sci USA 2018;115:E7091-100.

[22] Liu Y, Wang X, Li H, et al. ECM stiffness modulates scleral remodeling through integrin/F-actin/YAP axis in myopia. Invest Ophthalmol Vis Sci 2025;66(2):22.

[23] Huang Z, Zhang Y, Luo Q. Atropine modulates HIF-1α-mediated scleral remodeling in experimental myopia. Front Pharmacol 2025;16:1509196.

[24] Totaro A, Panciera T, Piccolo S. YAP/TAZ upstream signals and downstream responses. Nat Cell Biol 2018;20:888-99.

[25] Meng Z, Moroishi T, Guan KL. Mechanisms of Hippo pathway regulation. Genes Dev 2016;30:1-17.

[26] Yu FX, Zhao B, Guan KL. Hippo pathway in organ size control, tissue homeostasis, and cancer. Cell 2015;163:811-28.

[27] [Wnt5a scleral fibroblast study. Nat Commun 2026;17:554.]

[28] Li X, et al. Network pharmacology analysis of atropine in myopia. Front Pharmacol 2025. [NOTE: Cite the Frontiers paper that did basic CHRM1-5 PPI without Hippo-YAP]

[29] Davey Smith G, Hemani G. Mendelian randomization: genetic anchors for causal inference in epidemiological studies. Hum Mol Genet 2014;23:R89-98.

[30] Skrivankova VW, Richmond RC, Woolf BAR, et al. Strengthening the reporting of observational studies in epidemiology using Mendelian randomization: the STROBE-MR statement. JAMA 2021;326:1614-21.

---

## ADDITIONAL REFERENCES (used in Methods/Results/Discussion only, numbered 31+)

[31] Jiang X, Pardue MT, Mori K, et al. Violet light suppresses lens-induced myopia via neuropsin (OPN5) in mice. Proc Natl Acad Sci USA 2021;118:e2100330118.

[32] Gieger C, Radhakrishnan A, et al. [coloc methods reference — Wallace 2020 or Gieger]

[33] Zhou X, Pardue MT, Iuvone PM, Qu J. Dopamine signaling and myopia development: What are the key challenges. Prog Retin Eye Res 2017;61:60-71.

---

## v1 → v3 CHANGES SUMMARY

| v1 [#] | v3 [#] | Reference | Change |
|---------|--------|-----------|--------|
| [1] | [1] | Holden 2016 | Same |
| [2] | [2] | Jung 2012 | Same |
| NEW | [3] | Morgan Lancet 2012 | **ADDED** — environment |
| NEW | [4] | Morgan ProgRetEyeRes 2018 | **ADDED** — epidemics |
| NEW | [5] | Flitcroft IMI 2019 | **ADDED** — complications |
| [3] | [6] | Yam 2020 | Renumbered |
| [4] | [7] | Navarra 2025 | Renumbered |
| NEW | [8] | Wildsoet IMI 2019 | **ADDED** — IMI interventions |
| NEW | [9] | Lee rebound | **ADDED** — rebound concern |
| [5] | [10] | Arumugam 2012 | Renumbered |
| [6] | [11] | Barathi 2013 | Renumbered |
| [7] | [12] | Carr 2018 | Renumbered |
| NEW | [13] | Stone 1989 | **ADDED** — classic DA-FDM |
| NEW | [14] | Feldkaemper 2013 | **ADDED** — DA review |
| [8] | [15] | Thomson 2021 | Renumbered |
| [9] | [16] | Upadhyay 2020 | Renumbered |
| NEW | [17] | McBrien & Gentle 2003 | **ADDED** — scleral biology |
| NEW | [18] | Wallman & Winawer 2004 | **ADDED** — homeostasis |
| [13] | [19] | Jobling 2004 | Renumbered |
| NEW | [20] | Gentle 2003 | **ADDED** — collagen |
| [14] | [21] | Wu 2018 | Renumbered |
| [10] | [22] | Liu 2025 | Renumbered |
| [11] | [23] | Huang 2025 | Renumbered |
| [12] | [24] | Totaro 2018 | Renumbered |
| [16] | [25] | Meng 2016 | Renumbered |
| [17] | [26] | Yu 2015 | Renumbered |
| [15] | [27] | Wnt5a NatComm 2026 | Renumbered |
| NEW | [28] | Li FrontPharmacol 2025 | **ADDED** — prior NP study |
| [18] | [29] | Davey Smith 2014 | Renumbered |
| NEW | [30] | STROBE-MR JAMA 2021 | **ADDED** — MR guidelines |

**Total: 30 references (Introduction) + 3 reserve (Methods/Discussion)**
**Net addition: +12 new references**

---

## NOTES FOR SUBSEQUENT SECTIONS

When updating Methods/Results/Discussion, ALL superscript numbers must be updated to match this new numbering:
- Former [10] (Liu) → now [22]
- Former [11] (Huang) → now [23]  
- Former [14] (Wu) → now [21]
- Former [15] (Wnt5a) → now [27]
- Former [12] (Totaro) → now [24]
- Former [16] (Meng) → now [25]
- Former [17] (Yu) → now [26]
- Former [18] (Davey Smith) → now [29]

Methods/Results/Discussion will cite additional refs [31]+ as needed (OPN5, coloc methods, Zhou dopamine review, etc.)
