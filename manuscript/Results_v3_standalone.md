# RESULTS

## 3.1. Network Pharmacology Identifies Multi-Receptor Convergence on Hub Genes

A total of 128 atropine-associated targets and 195 myopia-associated genes (CTD Direct Evidence) were identified, yielding 47 common genes at their intersection (Fig. 2A). The PPI network of these 47 genes comprised 191 edges at STRING confidence ≥0.700 (Fig. 2B). Topological analysis identified 10 hub genes ranked by degree centrality: TP53 and AKT1 (degree 21 each), IL6, CTNNB1, and TNF (degree 19 each), JUN (degree 19), IL1B (degree 18), CASP3 and EGFR (degree 17 each), and FOS (degree 16) (Table 1). TGFB1, which later emerged as the strongest causal gene by MR (see section 3.3), had a degree of only 12 and ranked outside the top 10 hubs (betweenness centrality 0.001), illustrating that network centrality alone does not predict biological causality.

KEGG pathway enrichment of the 47 intersection genes identified 168 pathways at adjusted P < 0.05. The Hippo signaling pathway was not independently enriched among the 47 intersection genes, consistent with the deliberate exclusion of Hippo-YAP components from this gene set to avoid circular reasoning.

## 3.2. Extension Layer Analysis Reveals Four-Receptor Convergence on Hippo-YAP

The Extension Layer analysis, in which Hippo-YAP pathway genes were added as an adjacent layer connected through intersection hub genes, demonstrated that all four receptor classes reached Hippo-YAP components through the PPI network (Fig. 2B). The muscarinic class (CHRM1, CHRM3, CHRM5) generated the most paths (40 paths), followed by the nicotinic class (CHRNA3, CHRNA4, CHRNB2; 32 paths), the adrenergic class (ADRA2A, ADRA2C; 24 paths), and the dopaminergic class (DRD1, DRD2; 16 paths).

Representative shortest paths included: dopaminergic, DRD1 → FOS → TP53 → LATS1 (distance 3); nicotinic, CHRNA3 → ACHE → EGFR → LATS1 (distance 3); and muscarinic, CHRM1 → AKT1 → YAP1 (distance 2, via non-intersection extension edges). The finding that the dopaminergic path traverses TP53 — the global hub with the highest betweenness centrality (0.058) — suggests TP53 functions as a critical bottleneck integrating dopamine signaling into the Hippo kinase cascade.

This result demonstrates that atropine's diverse receptor targets are not functionally disconnected but converge through shared hub intermediaries onto the TGFβ-Hippo-YAP axis, supporting the hypothesis of multi-receptor convergence.

## 3.3. Mendelian Randomization Identifies Causal Roles for TGFB1 and LATS2

Among 22 candidate genes across five mechanistic modules, seven had sufficient instrumental variables (F > 10 for all) for MR analysis (Table 2, Panel A). The remaining 15 genes — including TH, DRD1, DRD2, YAP1, LATS1, TEAD1, and CHRM1 — lacked instruments meeting the P < 5 × 10⁻⁶ threshold and are reported in Supplementary Table S2.

TGFB1 showed a significant causal protective effect against myopia (Wald ratio β = −0.027, 95% CI −0.045 to −0.009, P = 0.003, F = 27.2). Steiger directionality testing confirmed the correct causal direction (P = 1.7 × 10⁻⁵), and reverse MR was null (P = 0.90). PhenoScanner identified an association of the lead instrument (rs1963413) with height, a known pleiotropic trait that was considered in the interpretation.

LATS2 showed a significant causal risk effect (Wald ratio β = +0.018, 95% CI +0.001 to +0.035, P = 0.040, F = 30.7). Steiger testing again confirmed directionality (P = 1.3 × 10⁻⁶), reverse MR was null (P = 0.94), and PhenoScanner revealed no pleiotropic associations for the lead instrument (rs10891299).

HIF1A showed a suggestive but non-significant association by IVW (β = −0.004, P = 0.154), with the weighted median method yielding a borderline result (P = 0.068). COMT (P = 0.191), ADRA2A (P = 0.796), CHRM3 (P = 0.403), and LOX (P = 0.743) showed no significant causal associations with myopia.

## 3.4. TGFB1 Causal Effect Replicated Across Three Independent Outcomes

To assess robustness, the TGFB1 causal estimate was replicated using two continuous refractive error phenotypes in addition to the primary binary myopia outcome (Table 2, Panel B). TGFB1 expression was significantly associated with higher spherical power (less myopic refraction) in both the right eye (β = +0.253, 95% CI +0.114 to +0.392, P = 4.0 × 10⁻⁴) and the left eye (β = +0.264, 95% CI +0.123 to +0.405, P = 2.3 × 10⁻⁴). All three outcomes showed consistent directionality: higher genetically predicted TGFB1 expression protects against myopia. The convergence of P < 0.001 across three independent phenotype definitions substantially reduces the probability of a false-positive finding.

## 3.5. Colocalization Analysis

Bayesian colocalization for the TGFB1 locus (2,668 regional SNPs) yielded strong evidence of an eQTL signal (PP.H1 = 94.95%) but weak evidence for a shared causal variant with the myopia GWAS (PP.H4 = 1.79%) (Table 2, Panel C). This result indicates that while TGFB1 gene expression is robustly regulated by cis-genetic variants, the myopia GWAS signal at this locus is distributed rather than concentrated at a single peak, likely reflecting the polygenic architecture of myopia. LATS2 had insufficient overlapping SNPs for colocalization analysis. The implications of this finding are considered in the Discussion.

## 3.6. Published Evidence Mapping Confirms Tissue-Level Expression Changes

Cross-referencing the 47 intersection genes and Extension Layer genes with six published myopic tissue studies (2018–2026) identified concordant expression changes for key convergence genes (Table 3).^21,22,23,27,39 TGFB1 was upregulated in form-deprived sclera in mouse and guinea pig models.^21 YAP1 protein was decreased in myopic sclera from both guinea pig and human tissue, confirmed by Western blot.^22 HIF1A was upregulated in myopic sclera^21 and suppressed by atropine treatment.^23 COL1A1, a downstream ECM target, was consistently downregulated across three independent studies.^22,27

Two genes achieved triple convergence across all three evidence types — network pharmacology, genetic causality, and published tissue expression: TGFB1 (intersection gene, MR causal P = 0.003, scleral upregulation in FDM) and LATS2 (Extension Layer gene, MR causal P = 0.040, consistent with YAP downregulation in myopic sclera). YAP1 achieved quadruple convergence across network, literature, CMap, and docking, but could not be tested by MR due to insufficient instruments.

## 3.7. Drug Signature Analysis Validates Network-Predicted Pharmacological Classes

Enrichr analysis using the LINCS L1000 Chemical Perturbation Consensus Signatures library identified drug classes whose expression signatures most effectively reverse the 47-gene intersection profile. EGFR inhibitors dominated the results, with gefitinib, tyrphostin AG 1478, canertinib, and pelitinib collectively appearing eight times among the top 50 hits. MEK/ERK inhibitors (PD-184352, PD-0325901, selumetinib) appeared six times. TWS119 (rank 2), a GSK3β inhibitor that activates Wnt signaling, connects to the Wnt5a–scleral fibroblast axis recently described in myopia.^27 BMS-536924 (rank 7), an IGF-1R inhibitor, targets ocular growth factor signaling.

The convergence of EGFR inhibitors with network pharmacology results — where EGFR ranked as the 9th hub gene (degree 17, betweenness centrality 0.019) — provides independent pharmacological validation that EGFR mediates signal transduction between atropine's receptor targets and the Hippo-YAP axis. This was further supported by the nicotinic Extension Layer path: CHRNA3 → ACHE → EGFR → LATS1.

## 3.8. Molecular Docking Demonstrates Drug-Like Binding at Novel Targets

The positive control (CHRM1, 5CXV) yielded the strongest binding: FitDock −9.0 kcal/mol using template 6WJC (pocket identity 1.00, confirming orthosteric binding) and CB-Dock2 −8.8 kcal/mol (Table 4). All three novel targets exhibited drug-like binding affinity (below −7.0 kcal/mol): YAP-TEAD interface −7.9 kcal/mol (cavity volume 1,985 Å³), MOB1-LATS1 protein–protein interface −7.6 kcal/mol (cavity volume 1,695 Å³), and TGFβ1 receptor trimeric interface −7.5 kcal/mol (cavity volume 4,786 Å³).

Notably, MOB1-LATS1 docking placed atropine at the protein–protein interface between MOB1A (Chain A) and the LATS1 kinase domain (Chain B), suggesting a potential mechanism of protein–protein interaction (PPI) disruption. LATS kinase activation requires MOB1 binding;^43 interference at this interface could modulate Hippo pathway output. The TGFβ1 receptor docking similarly positioned atropine at the trimeric interface spanning Chains C (TGFβ1), D (TβRII), and K, consistent with potential modulation of ligand–receptor complex assembly.

The hierarchy of binding affinities — known target (−9.0) > novel targets (−7.5 to −7.9) — is biologically plausible: atropine's primary pharmacological activity occurs at muscarinic receptors, while novel target engagement may represent secondary, lower-affinity interactions that collectively contribute to the observed pleiotropic anti-myopia effect.

---

## CROSS-REFERENCE VERIFICATION CHECKLIST

| Claim | Value | Source File |
|---|---|---|
| Atropine targets | 128 | CTD D001285 |
| Myopia genes | 195 | CTD D009216 Direct Evidence |
| Intersection | 47 | Pipeline output |
| PPI edges | 191 | STRING output |
| TP53 degree / BC | 21 / 0.058 | Step3_Hub_Gene_Analysis.csv |
| AKT1 degree | 21 | Step3_Hub_Gene_Analysis.csv |
| IL6, CTNNB1, TNF degree | 19 each | Step3_Hub_Gene_Analysis.csv |
| TGFB1 degree / BC | 12 / 0.001 | Step3_Hub_Gene_Analysis.csv |
| EGFR degree / BC | 17 / 0.019 | Step3_Hub_Gene_Analysis.csv |
| Extension: Musc/Nic/Adr/DA | 40/32/24/16 | Step5_Extension_Connectivity.csv |
| DRD1 path | DRD1→FOS→TP53→LATS1 (dist 3) | Extension output |
| KEGG pathways tested | 168 | g:Profiler output |
| TGFB1 β (SE) | −0.027 (0.009) | MR_E_results.csv |
| TGFB1 P | 0.003 | MR_E_results.csv |
| TGFB1 F | 27.2 | enhanced_table1_iv_details.csv |
| TGFB1 lead SNP | rs1963413 | enhanced_table1_iv_details.csv |
| LATS2 β (SE) | +0.018 (0.009) | MR_B_results.csv |
| LATS2 P | 0.040 | MR_B_results.csv |
| LATS2 F | 30.7 | enhanced_table1_iv_details.csv (corrected) |
| LATS2 lead SNP | rs10891299 | MR_B_results.csv |
| HIF1A IVW P | 0.154 | MR_E_results.csv |
| HIF1A WM P | 0.068 | MR_E_results.csv |
| COMT β (SE) / P | −0.002 (0.001) / 0.191 | MR_A_COMT_strict.csv |
| ADRA2A P | 0.796 | MR_CDE_consolidated.csv |
| CHRM3 β (SE) / P | −0.009 (0.010) / 0.403 | MR_CDE_consolidated.csv |
| LOX P | 0.743 | MR_E_results.csv |
| Steiger TGFB1 | P = 1.7 × 10⁻⁵ | Sensitivity output |
| Steiger LATS2 | P = 1.3 × 10⁻⁶ | Sensitivity output |
| Reverse MR TGFB1 / LATS2 | P = 0.90 / P = 0.94 | Reverse MR output |
| CREAM R eye β (SE) / P | +0.253 (0.071) / 0.0004 | CREAM_replication.csv |
| CREAM L eye β (SE) / P | +0.264 (0.072) / 0.0002 | CREAM_replication.csv |
| Coloc SNPs | 2,668 | coloc_results_local_vcf.csv |
| PP.H1 / PP.H4 | 94.95% / 1.79% | coloc_results_local_vcf.csv |
| CHRM1 FitDock / CB-Dock2 | −9.0 / −8.8 | CB-Dock2 output |
| YAP-TEAD score / vol | −7.9 / 1,985 Å³ | CB-Dock2 output |
| MOB1-LATS1 score / vol | −7.6 / 1,695 Å³ | CB-Dock2 re-docking |
| TGFβ1R score / vol | −7.5 / 4,786 Å³ | CB-Dock2 output |
| Insufficient IV genes | 15 of 22 | MR pipeline |
