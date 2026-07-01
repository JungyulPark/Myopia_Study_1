# DRAFT — Results subsection: MR robustness & the coloc-vs-sensitivity distinction

> Manuscript-ready draft built ONLY from disk-verified numbers (Analysis 06, PI
> Antigravity run; recorded in RESULTS_LEDGER.md). `‹FILL›` = one pending value
> (per-anchor F-statistic) to lift from `Suppl_TableS_full_denominator_v2.csv`.
> Honest framing per GOAL_AND_LOOP_PLAN §6.

---

## 3.x Instrument strength and MR sensitivity

All anchor instruments were strong (F-statistic: RDH5 814.2, CD55 1987.9, CTNNB1
454.0, FBN1 543.1, TGFB1 27.2; all > 10). For the two anchors with three or more
instruments we ran the full sensitivity panel. **CD55** (5 instruments) showed no
evidence of horizontal pleiotropy (MR-Egger intercept = −0.000185, *P* = 0.741) and
no heterogeneity (Cochran's *Q* *P* = 0.280), and its causal estimate was robust to a
pleiotropy-resistant estimator (weighted median β = −0.00284, *P* = 7.5 × 10⁻⁶).
**CTNNB1** (3 instruments) likewise showed no pleiotropy (Egger intercept = 0.00341,
*P* = 0.490) and no heterogeneity (*Q* *P* = 0.488), with a significant
weighted-median estimate (β = −0.00562, *P* = 5.6 × 10⁻⁵). **RDH5** (2 instruments)
showed no heterogeneity (*Q* *P* = 0.125). **TGFB1** and **FBN1** were each instrumented by a
single cis-variant, so pleiotropy- and heterogeneity-based sensitivity analyses are
not applicable by construction.

## 3.y Colocalization is not implied by MR robustness

A clean MR sensitivity profile does **not** establish a shared causal variant, and
our anchors illustrate the distinction directly. **RDH5** both survives MR and
colocalizes robustly (PP.H4 = 0.991 / 0.916 / 0.999 across three priors), consistent
with its status as an established refractive-error locus and a published fetal-RPE
colocalization (positive control). **CTNNB1**, by contrast, has a significant,
pleiotropy-free, homogeneous MR signal yet **fails colocalization**: the posterior
favours *distinct* causal variants for expression and for myopia (PP.H3 = 0.767).
The same pattern holds for **FBN1** (PP.H1 = 0.702, distinct variant) and **TGFB1**
(PP.H1 = 0.944, single instrument, and — critically — a *discordant* replication
direction). We therefore treat CTNNB1, FBN1, and TGFB1 as **candidate/hypothesis
signals only**: their MR associations are most parsimoniously explained by linkage
disequilibrium with a neighbouring causal variant rather than by a shared effect,
and we make no directional or therapeutic claim for them. **CD55** occupies an
intermediate position — a robust, pleiotropy-free MR association whose
colocalization is prior-sensitive (PP.H4 = 0.801 / 0.287 / 0.976) — and we note it
is one of the six complement targets reported by Wang et al. (2024), so it is not a
point of novelty relative to that work.

**Interpretation.** The one anchor that clears both MR and colocalization, RDH5, is
also the most firmly established prior locus; the framework thus recovers known
biology as a positive control while transparently declining to elevate signals
(CTNNB1, FBN1, TGFB1) that pass MR but fail the shared-causal-variant test. This
MR-versus-colocalization separation is a central methodological point of the study,
not a shortcoming.
