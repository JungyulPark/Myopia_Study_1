# Supplementary Figure S1 — STRING Network Input Package

**Verified against disk: Step3_Intersection_Genes.csv (47 genes, 100% match, fabrication 0%)**

---

## 1. STRING gene list (copy-paste into string-db.org → Multiple proteins)

```
ACHE ADRA2A ADRA2B ADRA2C AKT1 BAX CASP3 CCNE1 CDK1 CHRM1 CHRM2 CHRM3 CHRM4 CHRM5 CHRNA3 CHRNA4 CHRNA7 CHRNB2 CHRNB4 CTNNB1 DRD1 DRD2 DVL2 EDN1 EGFR EGR1 FOS GABRA1 GABRB2 GABRG2 IL1B IL6 JUN MAPK1 MAPK14 MAPK3 MAPK8 MCM6 NOS2 NOTCH4 PCNA PTGS2 RELA RHOA TGFB1 TNF TP53
```

Organism: **Homo sapiens**

---

## 2. STRING settings (to match our verified 191 edges)

| Setting | Value |
|---|---|
| Network type | full STRING network |
| Required confidence (score) | **0.700 (high)** ← matches our combined score ≥ 700 |
| Hide disconnected nodes | **OFF** (so the 3 singletons appear) |

Expected output: **44 connected nodes + 3 singletons (ACHE, ADRA2B, CHRM4), 191 edges**

---

## 3. Receptor-class color mapping (Cytoscape post-processing; consistent with Figs 2–4/S2)

| Receptor class | Count | Genes | Hex |
|---|---|---|---|
| Muscarinic | 5 | CHRM1, CHRM2, CHRM3, CHRM4, CHRM5 | #8E44AD (purple) |
| Nicotinic | 5 | CHRNA3, CHRNA4, CHRNA7, CHRNB2, CHRNB4 | #16A085 (teal) |
| Adrenergic | 3 | ADRA2A, ADRA2B, ADRA2C | #A0522D (brown) |
| Dopaminergic | 2 | DRD1, DRD2 | #F1C40F (yellow) |
| GABAergic | 3 | GABRA1, GABRB2, GABRG2 | #E91E63 (pink) |
| Other / signaling-hub | 29 | ACHE, AKT1, BAX, CASP3, CCNE1, CDK1, CTNNB1, DVL2, EDN1, EGFR, EGR1, FOS, IL1B, IL6, JUN, MAPK1, MAPK14, MAPK3, MAPK8, MCM6, NOS2, NOTCH4, PCNA, PTGS2, RELA, RHOA, TGFB1, TNF, TP53 | #BDC3C7 (gray) |

(Receptor subtotal 18 + Other 29 = 47 ✓)

Core hubs (Is_Core_Hub=TRUE, optional larger node / thicker border): TP53, AKT1, IL6, JUN, TNF, CTNNB1, IL1B, CASP3, EGFR, MAPK14.
Anchors in this intersection: TGFB1 (degree 12, non-hub), CTNNB1 (degree 19, hub).

---

## 4. Cytoscape style guide (optional, for receptor-color version)

1. STRING app → import network, or "Send to Cytoscape" from string-db.org
2. Add `Receptor_Type` column to Node Table (from Step3_Intersection_Genes.csv)
3. Discrete Mapping: Node Fill Color per table above
4. Layout: Prefuse Force Directed OR yFiles Organic
5. (Optional) Node Size: continuous mapping to degree → matches Fig 4 visual hierarchy
   - If you do this, keep "Node size proportional to degree" in legend
   - If you keep STRING default (uniform size), REMOVE that phrase from legend

---

## 5. Supplementary Figure S1 legend (final, honesty-checked)

**Supplementary Figure S1. Exploratory protein–protein interaction network of atropine targets and myopia-associated loci.**
The network comprises 47 intersection genes identified by converging atropine pharmacological targets with human myopia-associated genes. Node colors represent functional receptor classes: muscarinic (purple), nicotinic (teal), adrenergic (brown), dopaminergic (yellow), and GABAergic (pink); downstream signaling and hub genes are shown in gray. Edges represent high-confidence STRING associations (combined interaction score ≥ 0.700), comprising 191 edges among 44 connected nodes; three genes (ACHE, ADRA2B, CHRM4) had no high-confidence edges within the intersection and are shown as unconnected nodes. [If Cytoscape degree-mapping used: Node size is proportional to network degree.] This hypothesis-generating structural layer illustrates the broad connectivity of atropine-related targets within the myopia gene set and provides exploratory context for the prioritized biological axes in Figure 4; it does not establish a direct molecular target for atropine.

---

## Verification notes (fabrication 0%)
- 47 genes match Step3_Intersection_Genes.csv exactly
- 3 singletons (ACHE, ADRA2B, CHRM4) confirmed against memory/disk
- 191 edges, 44 connected — matches CP1/data/network_edges_700.csv
- "Muscarinic 40 / Nicotinic 32..." in memory = PATH counts (reachability), NOT gene counts; do not confuse in legend
- GABA genes are intersection members but not part of the 4-class receptor-to-Hippo reachability (Musc/Nic/Adr/Dop); reachability is a separate analysis (Figure context / Table 1)
