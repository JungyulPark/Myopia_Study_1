# DRAFT — Honest Methods (refined from PI's methods_honest.md)

> Based on the PI's reframed Methods, with honesty refinements applied: docking
> "novel" language removed + tropane-scaffold (non-atropine-specific) caveat added;
> network/docking/CMap explicitly exploratory/supplementary with no main-text causal
> claim; colocalization 3-prior sensitivity added; novelty-audit step added; MR-vs-
> colocalization framing made explicit. Numbers must match RESULTS_LEDGER.md.

---

## 2. Methods

### 2.1 Study design
This study is a **confirmation-and-methods** framework, not a discovery study. A
pharmacology-motivated candidate list is evaluated by two-sample Mendelian
randomization (MR) and filtered through independent replication and Bayesian
colocalization, with established myopia loci used as **positive controls** to
benchmark pipeline sensitivity. Candidates lacking robust colocalization or
replication are restricted to hypothesis-generating status; no gene is claimed as a
novel myopia target. Network pharmacology, an Extension-Layer pathway map, molecular
docking, and drug-signature reversal are included as **exploratory/Supplementary**
analyses that motivate candidate selection but carry **no main-text causal claim**.
All analyses used summary-level or public data and required no IRB approval. Atropine
serves as clinical motivation only.

### 2.2 Network pharmacology and pathway mapping (exploratory, Supplementary)
Atropine target genes were retrieved from CTD (compound D001285), DrugBank, and
SwissTargetPrediction (128 targets); myopia genes from CTD (disease D009216, direct
marker/mechanism evidence), DisGeNET, and OMIM (195 genes). The 47-gene intersection
was mapped in STRING v12.0 (confidence ≥ 0.700), giving 44 connected nodes / 191
edges; centrality was computed in Cytoscape. An Extension-Layer analysis computed
shortest paths from four receptor classes to Hippo-YAP components. **These analyses
are hypothesis-generating only and are reported in the Supplement; no causal or
mechanistic conclusion is drawn from network topology in the main text.**

### 2.3 Mendelian randomization (primary causal inference)
**Exposures/outcome.** cis-eQTL instruments from eQTLGen (N = 31,684, blood).
Primary outcome: UK Biobank self-reported myopia (ukb-b-6353; N = 460,536; 37,362
cases / 423,174 controls).

**Testing denominator (anti-selection-bias).** To avoid reporting bias, the full
panel of **113 candidate genes** from the expanded mapping space (positive-control
candidates + Tier-2 sensitivity genes) was tested, and the complete results are
reported — not only significant hits. ‹CHECK 113 matches the row count in the results
files.›

**Instruments.** cis-eQTLs within ±1 Mb of the TSS at *P* < 5 × 10⁻⁶; LD clumping
against 1000 Genomes EUR (r² < 0.001, 10,000 kb); harmonization with palindromic-SNP
exclusion; instrument strength by F-statistic (F > 10 required; observed F = 27–1988).

**Estimation and sensitivity.** Wald ratio for single-instrument loci; inverse-
variance-weighted (IVW) for multi-instrument loci. For multi-instrument loci we
additionally computed the MR-Egger intercept (directional pleiotropy), weighted-median
estimate, and Cochran's Q (heterogeneity). Steiger filtering confirmed exposure→outcome
direction; reverse MR (myopia→expression) tested reverse causation; PhenoScanner v2
screened lead-SNP pleiotropy.

**Replication.** Significant associations were tested in (i) continuous refractive
error — CREAM/UK Biobank spherical equivalent (ukb-b-19994 right, ukb-b-7500 left) and
Tedja 2018 (N = 160,420); and (ii) FinnGen high/degenerative myopia (H7_MYOPIA; 8,266
cases / 254,189 controls). Directions were sign-aligned to the myopia axis.

**Colocalization (the decisive filter).** For each locus, `coloc.abf` was applied to
±500 kb regional statistics from eQTLGen and UK Biobank. To guard against
prior-dependence, we ran a **three-prior sensitivity analysis** (p₁ = p₂ = 10⁻⁴; p₁₂
= 10⁻⁵, 10⁻⁶, and 5 × 10⁻⁶). PP.H4 > 0.80 across priors was considered robust
colocalization; PP.H3/PP.H1 dominance was interpreted as distinct causal variants
(candidate-only). Because MR association can arise from linkage disequilibrium,
colocalization — not MR significance or replication alone — was treated as the
criterion for assigning a causal gene.

**Novelty adjudication.** Each candidate lead SNP was cross-referenced against known
refractive-error/myopia loci (GWAS Catalog EFO terms; Tedja 2018), ±500 kb, to
classify loci as known (positive control) versus not-previously-reported; LD-clustered
Tier-2 genes were flagged as requiring fine-mapping before any attribution.

### 2.4 Published tissue-evidence mapping
Candidates were cross-referenced against published myopic sclera/retina transcriptomic
studies (mouse, guinea pig, human); a gene was called literature-validated only with
concordant-direction expression in ≥ 2 independent peer-reviewed studies.

### 2.5 Exploratory molecular docking (Supplementary)
Blind docking (CB-Dock2) modelled atropine binding at candidate downstream
protein–protein interfaces: TGFβ1-receptor complex (3KFD), MOB1-LATS1 (5BRK; proxy
for the conserved LATS kinase domain), YAP-TEAD (3KYS), and muscarinic M1 (5CXV,
positive control). Vina scores < −7.0 kcal/mol denote drug-like affinity; FitDock
validated orthosteric binding at M1. **Negative/comparator controls** (scopolamine,
tropicamide, caffeine) were docked to test scaffold specificity. **Because comparable
binding was observed for the non-atropine tropane scopolamine, docking is interpreted
as tropane-scaffold-dependent rather than atropine-specific, is exploratory, and
supports no mechanistic or therapeutic claim.**

### 2.6 Drug-signature reversal (exploratory, Supplementary)
LINCS L1000 consensus signatures were queried via Enrichr with intersection-network
hub genes; enriched compound classes were annotated (DrugBank). Reported as
hypothesis-generating context only.

---

## Do-not-regress self-check
- [x] Network/docking/CMap explicitly exploratory/Supplementary, no main-text causal claim.
- [x] Docking "novel" language removed; tropane-scaffold (non-atropine-specific) caveat added.
- [x] Colocalization framed as the decisive filter; 3-prior sensitivity described.
- [x] Full 113-gene denominator stated (anti-selection-bias); novelty-audit step included.
- [x] Atropine motivation-only; no atropine-specific mechanism in Methods.
