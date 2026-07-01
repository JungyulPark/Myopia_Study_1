# ANTIGRAVITY REQUEST — audit of PUBLISHED myopia MR/eQTL targets (local, no OpenGWAS)

**New research question (reframes the paper from "discovery" to "verification"):**
*Do the drug-target / eQTL Mendelian-randomization findings already published for
myopia survive strict colocalization and multi-cohort replication?*

Re-test each **published** target with the SAME local pipeline that produced our
113-gene screen (eQTLGen cis-eQTL → UKB ukb-b-6353 MR → 3-prior coloc → CREAM/Tedja/
FinnGen replication → known-locus novelty flag → Tier A/B/Null). **No OpenGWAS, no axial
data needed** — reuse `run_scripts/` and the local eQTLGen + UKB VCF. Branch:
`claude/busy-heisenberg-lP58T`.

## Targets to audit (published nominations)

| Gene | Ensembl (confirm) | Source paper | Their claim |
|---|---|---|---|
| CD34 | ENSG00000174059 | Wang 2024 (PMC11314700) | causal drug target (coloc-supported) |
| CD55 | ENSG00000196352 | Wang 2024 | causal drug target — *already in our screen: Tier A, PP.H4=0.80* |
| WNT3 | ENSG00000108379 | Wang 2024 | causal drug target |
| LCAT | ENSG00000213398 | Wang 2024 | causal drug target (strongest docking) |
| BTN3A1 | ENSG00000026950 | Wang 2024 | causal drug target |
| TSSK6 | ENSG00000178093 | Wang 2024 | causal drug target (testis-restricted) |
| PRMT6 | ENSG00000198890 | Multi-omics 2024 (PMC11562087) | GWAS+mQTL+eQTL SMR hit |
| SH3YL1 | ENSG00000035115 | Multi-omics 2024 | SMR hit |
| ZKSCAN4 | ENSG00000187626 | Multi-omics 2024 | SMR hit |
| GATS | ‹resolve — ambiguous (CASTOR3)› | Multi-omics 2024 | SMR hit |
| NPAT | ENSG00000149504 | Multi-omics 2024 | SMR hit |
| UBE | ‹resolve — ambiguous (UBE2? UBA?), check source paper› | Multi-omics 2024 | SMR hit |

**Resolve the Ensembl IDs against the source papers** (GATS and UBE are ambiguous
symbols — use the exact gene the paper reported). If a gene has no eQTLGen cis-eQTL at
P<5e-6, record it as "no instrument" (informative — a target that can't even be
instrumented in blood eQTL).

## Procedure (identical to the 113-gene screen, for comparability)
For each target: (1) cis-eQTL instruments from local eQTLGen (P<5e-6, LD-clump r²<0.001);
(2) MR vs UKB ukb-b-6353 (Wald/IVW), F-stat; (3) 3-prior coloc.abf (PP.H1/H3/H4);
(4) replication betas/P in CREAM (right/left), Tedja 2018, FinnGen H7_MYOPIA;
(5) known-locus flag (±500 kb GWAS Catalog/Tedja); (6) Steiger + reverse-MR.
Assign the SAME tiers: Tier_A_coloc_supported (PP.H4>0.8), Tier_B_MR_supported_distinct,
Null.

## Output → `Submit_Manuscript/value_add/outputs/published_targets_audit.csv`
Columns: `gene, ensembl, source_paper, their_claim, n_snps, F, mr_beta, mr_pval,
coloc_PP_H1, coloc_PP_H3, coloc_PP_H4, cream_R_beta, cream_R_pval, finngen_or,
finngen_pval, known_locus, steiger_correct, our_tier, survives_strict_criteria(Y/N)`.

Also write a 3-line `outputs/AUDIT_SUMMARY.txt`: of N published targets audited, how many
are Tier_A (survive), Tier_B (MR-only), Null / no-instrument.

## Commit
```bash
git add Submit_Manuscript/value_add/outputs/published_targets_audit.csv Submit_Manuscript/value_add/outputs/AUDIT_SUMMARY.txt
git commit -m "Audit of published myopia MR targets under strict coloc+replication criteria"
git push origin claude/busy-heisenberg-lP58T
```
**Do not modify the manuscript. Reuse the existing MR/coloc run_scripts so numbers are
directly comparable to the 113-gene screen. Report the commit hash + AUDIT_SUMMARY.**
