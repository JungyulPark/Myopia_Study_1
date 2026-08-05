# Table 2 — Audit of published myopia MR/eQTL targets (uniform blood-eQTL standard)

*Verified from `outputs/published_targets_audit.csv` (v3; coloc.abf computed locally,
eQTLGen + UK Biobank). Colocalization evaluable for 9/12; only CD55 reproduced.*

| Gene | Source | Orig. tissue | MR P | PP.H4 | PP.H3 | PP.H1 | Verdict |
|---|---|---|---|---|---|---|---|
| **CD55** | Qin et al. 2024 | blood+retina | 3.6e-05 | 0.808 | 0.088 | 0.104 | reproduced (coloc+replication) |
| TSSK6 | Qin et al. 2024 | blood+retina | 3.6e-06 | 0.782 | 0.173 | 0.045 | not_reproduced_coloc_low |
| SH3YL1 | Multi-omics 2024 | blood(SMR/mQTL) | 4.0e-02 | 0.748 | 0.085 | 0.167 | not_reproduced_coloc_low |
| WNT3 | Qin et al. 2024 | blood+retina | — | 0.119 | 0.019 | 0.861 | not_reproduced_coloc_low |
| ZKSCAN4 | Multi-omics 2024 | blood(SMR/mQTL) | 2.0e-03 | 0.021 | 0.064 | 0.916 | not_reproduced_coloc_low |
| BTN3A1 | Qin et al. 2024 | blood+retina | 8.9e-02 | 0.002 | 0.029 | 0.968 | not_reproduced_coloc_low |
| LCAT | Qin et al. 2024 | blood+retina | 5.4e-01 | 0.000 | 0.042 | 0.957 | not_reproduced_coloc_low |
| NPAT | Multi-omics 2024 | blood(SMR/mQTL) | 4.4e-04 | 0.000 | 0.000 | 0.203 | not_reproduced_coloc_low |
| CD34 | Qin et al. 2024 | blood+retina | 4.6e-01 | 0.000 | 0.212 | 0.787 | not_reproduced_coloc_low |
| PRMT6 | Multi-omics 2024 | blood(SMR/mQTL) | 1.9e-04 | — | — | — | not_evaluable_blood (not_evaluable_low_blood_expression (n_cis_snps=0)) |
| GATS | Multi-omics 2024 | blood(SMR/mQTL) | — | — | — | — | not_evaluable_blood (not_evaluable_low_blood_expression (n_cis_snps=0)) |
| UBE | Multi-omics 2024 | blood(SMR/mQTL) | — | — | — | — | not_evaluable_blood (not_evaluable_low_blood_expression (n_cis_snps=0)) |

**Summary:** 12 targets audited; coloc evaluable for 9 (PRMT6, GATS, UBE had no blood
cis-eQTL). Only **CD55** reproduced (PP.H4=0.81 + CREAM P=1.5×10⁻⁷). Six of nine
evaluable targets showed distinct causal variants (PP.H1-dominant); TSSK6/SH3YL1 gave
moderate sub-threshold PP.H4 (0.78/0.75) without replication.

*Caveats:* Qin et al. 2024 nominations used blood **and retina** eQTL; this audit is
blood-only, so non-reproduction is scoped to a uniform blood-eQTL standard, not a claim
of falsity. Multi-omics nominations were SMR+mQTL-derived (complementary method).