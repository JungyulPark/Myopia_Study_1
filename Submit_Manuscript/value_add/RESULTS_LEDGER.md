# M-LIGHT — VERIFIED RESULTS LEDGER

> Running record of numbers returned from the PI's Antigravity runs. **Every value
> here is disk-verified from a run, not fabricated.** The manuscript draws from this
> ledger. Each block notes provenance (which script / dataset) and the honest
> interpretation under the do-not-regress rules (GOAL_AND_LOOP_PLAN §6).

---

## Analysis 06 — MR robustness (returned 2026-07, PI Antigravity run)

Source: `06_mr_robustness_table.R` → `mr_robustness_consolidated.csv`.
Instruments from `CP6_assembly/data/a3q1b_cache/`; outcomes from local UKB VCF
(ukb-b-6353); sensitivity via TwoSampleMR. Coloc PP.H4 columns are the prior
disk-verified colocalization inputs (3-prior sensitivity).

| Anchor | n_IV | F-stat | Egger intercept (P) | Weighted-median β (P) | Cochran Q P | coloc PP.H4 (default) | Verdict |
|---|---|---|---|---|---|---|---|
| **RDH5** | 2 | 814.19 | N/A (2 IV) | — | 0.125 (no het.) | **0.991** (0.916/0.999 sens.) | **Positive control** — robust coloc; known Tedja-2018 locus; fetal-RPE prior coloc (bioRxiv 446799). No heterogeneity. |
| **CD55** | 5 | 1987.93 | −0.000185 (**0.741**) | **−0.002837 (7.5×10⁻⁶)** | **0.280** (no het.) | 0.801 (0.287/0.976 sens.) | **Robust MR, coloc prior-sensitive.** Clean sensitivity panel. = Wang-2024 target → not a differentiator. |
| **CTNNB1** | 3 | 454.03 | 0.003410 (0.490) | **−0.005618 (5.6×10⁻⁵)** | 0.488 (no het.) | **0.037** (PP.H3=0.767 distinct) | **Candidate only.** MR significant + clean sensitivity, BUT coloc shows a DISTINCT causal variant → likely LD confounding, NOT shared-variant causality. Sensitivity cannot rescue a coloc failure. |
| **TGFB1** | 1 | 27.20 | N/A (single IV) | N/A | N/A | **0.018** (PP.H1=0.944 distinct) | **Excluded as positive.** Single instrument, r²=0.83 proxy, distinct variant, replication direction DISCORDANT. No directional/therapeutic claim. |
| **FBN1** | 1 | 543.11 | N/A (single IV) | N/A | N/A | **0.165** (PP.H1=0.702 distinct) | **Candidate only.** Single instrument; distinct variant (non-colocalizing). |

**Coloc cross-check (2026-07 PI run vs prior disk-verified):** default-prior PP.H4
values returned by the run (RDH5 0.991, CD55 0.801, TGFB1 0.018, CTNNB1 0.037, FBN1
0.165) are **consistent** with the prior 3-prior colocalization inputs. Locked.

### Honest takeaways for the manuscript (from 06)
1. **RDH5** is the one robustly-colocalizing anchor and a known locus → the framework's
   positive control, exactly as pre-registered.
2. **CD55** has a genuinely clean MR sensitivity profile (no pleiotropy, no
   heterogeneity, significant weighted-median) — report it as a *robust MR
   association* whose *colocalization is prior-sensitive*; concede it is a Wang-2024
   target and therefore not a novel differentiator.
3. **CTNNB1 is the key honesty exhibit:** significant IVW + weighted-median with clean
   Egger/Q, YET coloc places the causal variant elsewhere (PP.H3 dominant). This is
   the paper's clearest teaching point — *MR robustness ≠ colocalization*; without a
   shared causal variant the signal is candidate-only and consistent with LD
   confounding. Do NOT upgrade CTNNB1 on the strength of its MR sensitivity.
4. **TGFB1 / FBN1** remain single-instrument, non-colocalizing; TGFB1 stays excluded
   as a positive (discordant direction).

### Pending for 06 (confirm with PI)
- Exact coloc PP.H4 columns as written into `mr_robustness_consolidated.csv` (to
  confirm they match the disk-verified 3-prior values above).
- F-statistics per anchor for the final table (RDH5/CD55/CTNNB1/FBN1) — the old
  `enhanced_table1_iv_details.csv` lacked these anchors; confirm the new source
  (`Suppl_TableS_full_denominator_v2.csv`) supplies them.

---

## Analysis 05 — Novelty audit (returned 2026-07, PI run) → GATE G0 CLOSED

Source: `05_novelty_audit.R` → `novelty_audit_results.csv`. Lead SNPs cross-referenced
vs GWAS Catalog + Tedja 2018 (±500 kb).

| Gene | Tier | Known locus? | Status |
|---|---|:---:|---|
| RDH5 | anchor | **TRUE** | known locus → positive control |
| CD55 | anchor | **TRUE** | known locus → positive control (= Wang-2024 target) |
| CTNNB1 | anchor | **TRUE** | **known locus**, but coloc-fail (PP.H4 0.037) → gene not confirmed as mediator |
| FBN1 | anchor | **TRUE** | **known locus**, but coloc-fail (PP.H4 0.165) → gene not confirmed as mediator |
| TGFB1 | anchor | FALSE | not-known, BUT discordant direction + single IV + coloc-fail (0.018) → excluded as positive |
| IKZF3 | tier2 unverif. | FALSE | 17q21 cluster → needs fine-map; no coloc support |
| H2BC4 | tier2 unverif. | TRUE | HIST1/MHC region → needs fine-map |
| MYBPC3 | tier2 unverif. | TRUE | known locus |
| CEP250 | tier2 unverif. | TRUE | known locus |
| CENPM | tier2 unverif. | TRUE | known locus |
| API5 | tier2 unverif. | TRUE | known locus |
| RABEPK | tier2 unverif. | FALSE | not-known, unverified → needs coloc+finemap+replication (no support) |

CD55 ∈ Wang-2024's six complement targets (CD55, CD46, CFH, C2, C3, CFB); **no other
anchor overlaps** that set.

### GATE G0 — CLOSED: no defensibly-novel gene
- 9 of 12 genes are **established loci** (not novel by definition).
- The 3 **not-previously-reported** genes each fail defensible-causality criteria:
  - **TGFB1** — discordant replication direction + single instrument + coloc-fail (0.018).
  - **IKZF3** — 17q21 LD cluster, not fine-mapped, no colocalization.
  - **RABEPK** — unverified, no coloc/fine-map/replication support.
- ∴ **"No pharmacology-prioritized gene is a defensibly novel myopia-causal locus"** is
  locked and evidence-backed. Only RDH5 clears both MR and colocalization (positive control).

### Refinement carried into Abstract/Conclusion (2026-07)
CTNNB1 and FBN1 are now stated as **known refractive-error loci whose gene-expression
signal does not colocalize** (so our data do not confirm these *genes* as the causal
mediators) — more precise than the earlier "candidate-only" wording.

---

## Tedja 2018 / CREAM replication (continuous refractive error) — returned 2026-07 (SAFE)

Source: `pathy/Stage2_Assets/Tedja_5anchor_MR_for_Figure2.csv`. Continuous spherical-
equivalent (diopters); large, well-powered. Direction sign-aligned to the myopia scale.

| Anchor | β | P | Method | Replication |
|---|---|---|---|---|
| **RDH5** | −0.0935 | **3.3×10⁻³³** | Wald | ✓ concordant |
| **CD55** | +0.0286 | 0.0079 | IVW | ✓ concordant |
| **CTNNB1** | +0.0493 | 6.9×10⁻⁸ | Wald | ✓ concordant |
| **FBN1** | −0.0440 | 5.8×10⁻⁴ | Wald | ✓ concordant |
| **TGFB1** | −0.1590 | 0.0047 | Wald | ✗ **DISCORDANT** (UKB protective → Tedja/CREAM risk-increasing) |

**KEY (drives the honest narrative):** In the well-powered continuous outcome,
RDH5/CD55/CTNNB1/FBN1 **all replicate** (they are established loci — consistent with
the 05 novelty audit). So **replication is NOT the discriminator**; **colocalization
is** — only RDH5's gene-expression signal shares the causal variant with myopia. The
other three replicate as known loci but their *gene-level eQTL* does not colocalize,
so we cannot attribute the locus signal to those genes' expression. TGFB1 is discordant
→ excluded as a positive.

## FinnGen high-myopia replication (H7_MYOPIA) — returned 2026-07 (pre-computed, SAFE)

Source: `pathy/Stage2_Assets/PathD_FinnGen_5anchor_MR.csv`. Independent cohort,
clinically-defined HIGH-myopia case/control endpoint (OR scale) — a different, more
severe phenotype than UKB general myopia / Tedja continuous refractive error.

| Anchor | SNPs | OR (95% CI) | P | Method | Replication |
|---|---|---|---|---|---|
| **RDH5** | 2 | **1.22 (1.04–1.43)** | **0.013** | IVW | **✓ replicates** (3rd cohort, severe phenotype) |
| CD55 | 5 | 0.98 (0.90–1.06) | 0.536 | IVW | ✗ null |
| CTNNB1 | 3 | 0.96 (0.81–1.15) | 0.681 | IVW | ✗ null |
| FBN1 | 1 | 0.93 (0.72–1.18) | 0.538 | Wald | ✗ null |
| TGFB1 | 1 | 1.35 (0.42–4.34) | 0.615 | Wald | ✗ null (very wide CI) |

**Interpretation (honest):** RDH5 is now the sole anchor with cross-cohort,
cross-phenotype causal support (UKB + Tedja/CREAM + FinnGen high-myopia + robust
coloc). CD55/CTNNB1/FBN1/TGFB1 do not replicate in FinnGen — concordant with their
colocalization failures. **Caveat to state:** FinnGen captures high/pathological
myopia with fewer cases → wider CIs (esp. single-instrument TGFB1/FBN1), so nulls
reflect non-replication AND reduced power/phenotype shift; do not over-read the
nulls as definitive absence of effect on general refractive error.
**Sign check — RESOLVED (no flip needed):** UKB and FinnGen are both binary
myopia case/control, both positive → risk-increasing. UKB RDH5 β = +0.0089;
FinnGen RDH5 logOR = +0.2016 (OR 1.22). Directionally concordant without
transformation. (Tedja is continuous diopter-scale, hence its β sign differs by
convention but is concordant on the myopia axis.)

## Analyses still pending return
- **01–04, 07–10, D1–D3** → per `ANTIGRAVITY_HANDOFF.md` Phases B–D.
- **BLOCKER:** OPENGWAS_JWT expired (401) → live OpenGWAS extraction (07 East-Asian,
  08 coloc-SuSiE, 10 defocus cascade, D1–D3) is paused until the token is refreshed.
- **Available offline:** FinnGen high-myopia anchor replication + coloc H4 are
  pre-computed in `pathy/Stage2_Assets/` and `CP6_assembly/data/26_master_numbers_v4.csv`
  — usable WITHOUT re-running, subject to the honesty vetting below.

### ⚠️ Honesty vetting for pre-computed Stage2 files (do NOT ingest blindly)
`26_master_numbers_v4.csv` and the Stage2_Assets are from the OLD (overclaiming)
analysis frame. Before any number enters the honest manuscript:
- ✅ SAFE to use: FinnGen high-myopia **replication of the anchors** (a genuine
  independent cohort), and coloc PP.H4 values (already cross-checked, consistent).
- ⛔ DO NOT resurrect: **TGFB1 "direct/indirect mediation proportions"** or any
  TGFB1-as-causal-mediator / TGFβ-Hippo-YAP result — TGFB1 is EXCLUDED as a positive
  (discordant). Mediation framing was part of the old overclaim.
- Every pre-computed value must be re-tagged against RESULTS_LEDGER before use.
