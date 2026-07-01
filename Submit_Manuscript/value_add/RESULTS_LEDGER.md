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

| Anchor | n_IV | Egger intercept P | Weighted-median β (P) | Cochran Q P | coloc PP.H4 (default/sens1/sens2) | Verdict |
|---|---|---|---|---|---|---|
| **RDH5** | 2 | N/A (2 IV) | — | 0.125 (no het.) | **0.991 / 0.916 / 0.999** | **Positive control** — robust coloc; known Tedja-2018 locus; fetal-RPE prior coloc (bioRxiv 446799). No heterogeneity. |
| **CD55** | 5 | **0.741** (no pleiotropy) | **−0.00284 (7.5×10⁻⁶)** | **0.280** (no het.) | 0.801 / 0.287 / 0.976 | **Robust MR, coloc prior-sensitive.** Clean sensitivity panel. = Wang-2024 target → not a differentiator. |
| **CTNNB1** | 3 | 0.490 (no pleiotropy) | **−0.00562 (5.6×10⁻⁵)** | 0.488 (no het.) | **PP.H3=0.767 (distinct variant)** | **Candidate only.** MR significant + clean sensitivity, BUT coloc shows a DISTINCT causal variant → likely LD confounding, NOT shared-variant causality. Sensitivity cannot rescue a coloc failure. |
| **TGFB1** | 1 | N/A (single IV) | N/A | N/A | PP.H1=0.944 (distinct) | **Excluded as positive.** Single instrument, r²=0.83 proxy, distinct variant, replication direction DISCORDANT. No directional/therapeutic claim. |
| **FBN1** | 1 | N/A (single IV) | N/A | N/A | PP.H1=0.702 (distinct) | **Candidate only.** Single instrument; distinct variant (non-colocalizing). |

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

## Analyses pending return
- **05** novelty audit → `novelty_audit_results.csv` (closes Gate G0)
- **01–04, 07–10, D1–D3** → per `ANTIGRAVITY_HANDOFF.md` Phases B–D
- Note any script that could not run for lack of a dataset (axial-length GWAS,
  East-Asian GWAS, eye eQTL, LD reference) so manuscript scope adjusts accordingly.
