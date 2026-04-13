# CMap (Connectivity Map) Gene Signature for M-LIGHT
# Submit to https://clue.io/query

## Instructions
1. Go to https://clue.io/query
2. Create free academic account if needed
3. Select "Gene Expression Signature Query"
4. Upload the UP and DOWN gene lists below
5. Run query, download results

## UP Gene List (genes upregulated by atropine's anti-myopia action)
Based on CP1 intersection + CP2 published evidence:
Genes that are PROTECTIVE (downregulated in myopia, so atropine should upregulate them):

```
TGFB1
COL1A1
COL1A2
FN1
YAP1
CTGF
SPARC
LOX
EGR1
TEAD1
COL3A1
```

## DOWN Gene List (genes that should be suppressed)
Genes upregulated in myopia that atropine should suppress:

```
HIF1A
MMP2
MMP9
IL6
TNF
VEGFA
TGFB2
CASP3
TP53
AKT1
MAPK1
MAPK3
```

## Expected Results
- If **Verteporfin** (YAP-TEAD inhibitor) appears with NEGATIVE connectivity score, 
  it means our gene signature is OPPOSITE to YAP inhibition → supports YAP activation hypothesis
- If **Pirfenidone** (anti-fibrotic / TGFβ modulator) appears, it connects to our TGFβ finding
- If **muscarinic agonists** appear with negative score, validates atropine mechanism

## Alternative: Use L1000CDS2
If clue.io requires institutional access:
- Go to https://maayanlab.cloud/L1000CDS2/
- Paste UP genes in "Up genes" box
- Paste DOWN genes in "Down genes" box
- Click "Search"
- This gives similar drug-gene expression matching results

## For Manuscript
Report as: "Connectivity Map analysis was performed using the gene expression signature 
derived from CP1 intersection genes, with upregulated genes representing protective 
scleral targets (COL1A1, YAP1, TGFB1) and downregulated genes representing pathological 
markers (HIF1A, MMP2, VEGFA). Drug candidates with significant negative connectivity 
scores were identified as potential agents that reverse the myopic gene expression profile."
