# Table 1 — Anchor genes: MR, sensitivity, colocalization, replication, tier

*All values verified from `outputs/Suppl_TableS_full_denominator_v2.csv` (full 113-gene
screen) + `outputs/mr_robustness_consolidated.csv` + FinnGen/Tedja replication files.
Of 113 pharmacology-prioritized genes, 5 were Bonferroni-significant (shown); 108 null;
only 2 (RDH5, CD55) were colocalization-supported.*

| Gene | Tier | n_IV | F | UKB β (P) | CREAM β (P) | Tedja β (P) | FinnGen OR (P) | coloc PP.H4 / H3 / H1 | Steiger | Verdict |
|---|---|---|---|---|---|---|---|---|---|---|
| **RDH5** | A: coloc-supported | 2 | 814.2 | +0.0089 (1.2×10⁻⁶) | −0.145 (1.5×10⁻¹⁵) | −0.0935 (3.3×10⁻³³) | 1.22 (0.013) | **0.991** / 0.009 / ~0 | ✓ | Positive control (known Tedja locus; robust coloc; replicates in all cohorts) |
| **CD55** | A: coloc-supported | 5 | 1987.9 | −0.00284 (3.6×10⁻⁵) | +0.0418 (1.5×10⁻⁷) | +0.0286 (0.008) | 0.98 (0.54) | 0.801 / 0.096 / 0.103 | ✓ | Robust MR, prior-sensitive coloc; = Wang-2024 target (not novel) |
| **CTNNB1** | B: distinct variants | 3 | 454.0 | −0.00552 (4.4×10⁻⁵) | +0.0588 (2.5×10⁻⁸) | +0.0493 (6.9×10⁻⁸) | 0.96 (0.68) | 0.037 / **0.767** / 0.196 | ✓ | Known locus; MR+replication but coloc FAIL (distinct variant) → candidate only |
| **FBN1** | B: distinct variants | 1 | 543.1 | +0.00747 (3.3×10⁻⁴) | −0.0669 (3.9×10⁻⁵) | −0.0440 (5.8×10⁻⁴) | 0.93 (0.54) | 0.165 / 0.134 / **0.702** | ✓ | Known locus; coloc FAIL (distinct variant) → candidate only |
| **TGFB1** | B: distinct variants | 1† | 27.2 | −0.0271 (0.003) | +0.252 (4×10⁻⁴) | −0.159 (0.005)‡ | 1.35 (0.62) | 0.018 / – / **0.950** | ✓ | Excluded as positive: pQTL instrument†, coloc FAIL, discordant replication‡ |

† TGFB1 was instrumented by a single **protein-QTL** variant (rs1963413), not an
eQTLGen cis-eQTL — a mixed-instrument-source limitation.
‡ TGFB1 replication direction is discordant (UKB vs Tedja/CREAM sign reversal).
Reverse-MR was null for all anchors (no reverse causation). Directions sign-aligned to
the myopia axis; note UKB/FinnGen (binary) vs CREAM/Tedja (continuous diopter) coding.

**Screen summary (Table S-full, 113 genes):** Tier A (coloc-supported) = 2 (RDH5, CD55);
Tier B (MR-supported, distinct variants) = 3 (CTNNB1, FBN1, TGFB1); Null = 108. No
non-anchor gene reached PP.H4 > 0.7.
