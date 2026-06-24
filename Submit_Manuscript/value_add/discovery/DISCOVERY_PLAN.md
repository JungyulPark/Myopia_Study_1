# M-LIGHT — DISCOVERY PLAN (genuine new-finding engines)

> **Read this first.** No discovery can be *manufactured*. These engines are
> designed to **detect a real, defensible novel finding if one exists** and to
> **report an honest null if it does not**. The audit's "no new gene" verdict was
> bounded to the *current* analysis (refractive-error outcome, blood eQTL, 5 named
> anchors). The four engines below open **un-searched axes** where a genuinely new
> finding is still possible. Every engine has a pre-registered decision rule and a
> "this is the honest null" branch. Numbers come only from the PI's Antigravity runs.

## How we work (division of labor)

- **[CLAUDE — done now]** = scripts, specs, candidate lists, manuscript scaffolds, post-run interpretation. Already in this repo.
- **[PI — Antigravity]** = run the R, because the sensitive data (eQTLGen, UKB VCF, GTEx/eye eQTL, axial-length GWAS, LD reference) and OpenGWAS auth live only there.

Each engine below gives the **exact command** for the PI and the **decision gate**.

---

## What counts as a "new discovery" here (so we don't fool ourselves)

A finding is **reportable as novel** only if ALL of:
1. It is **not** already a Tedja-2018 / GWAS-Catalog refractive-error or myopia locus (±500 kb), AND
2. It survives **colocalization** (shared causal variant, PP.H4 > 0.7) — not mere LD, AND
3. It is the **fine-mapped credible-set gene**, not an LD neighbor, AND
4. It replicates direction in an **independent** dataset (or is flagged "needs replication").

A finding that is novel on (1) but fails (2)–(4) is a **candidate / hypothesis**, reported as such — never as a discovery. Anything failing (1) is a **recovered known locus** (positive control). This is the wall against overclaim.

---

## Engine D1 — Druggable-genome MR scan vs AXIAL LENGTH  (best shot at a new gene)

**Hypothesis:** axial length (structural driver of pathological myopia) is far
less MR-interrogated than refractive error. A hypothesis-free scan of the
**druggable genome** (Finan 2017 / Open Targets tractable set) against an
axial-length GWAS may surface an **axial-specific causal gene** that refractive-
error studies missed.

- **[CLAUDE done]** `D1_druggable_genome_axial_scan.R` — iterates druggable genes
  with cis-eQTL instruments → MR vs axial length → FDR → coloc on FDR hits →
  flags NOVEL vs known. Emits ranked `discovery_axial_candidates.csv`.
- **[PI command]**
  ```r
  # set AL_OUTCOME / AL_LOCAL and DRUGGABLE_LIST path first (see script header)
  Rscript Submit_Manuscript/value_add/discovery/D1_druggable_genome_axial_scan.R
  ```
- **Decision gate G-D1:** any gene with FDR<0.05 + PP.H4>0.7 + not-known + fine-map
  credible (hand to D2) → **candidate novel axial gene**. None → honest null:
  "no druggable-genome gene shows axial-specific causal support beyond known loci."

## Engine D2 — Fine-mapping (SuSiE) of unverified loci  (confirm causal gene)

**Hypothesis:** an "unverified Tier-2" hit (or a D1 candidate) is the *credible
causal* gene at its locus, not an LD shadow of a known gene.

- **[CLAUDE done]** `D2_finemap_unverified_loci.R` — SuSiE fine-mapping per locus,
  credible sets, maps credible SNPs → genes, coloc of the credible signal.
- **[PI command]**
  ```r
  Rscript Submit_Manuscript/value_add/discovery/D2_finemap_unverified_loci.R
  ```
- **Decision gate G-D2:** credible set points to a **non-known** gene with coloc →
  promote to candidate novel. Credible set = a known gene → recovered known.
  Diffuse/empty credible set → "not fine-mappable at this power."

## Engine D3 — Muscarinic / atropine-target MR vs axial length  (mechanism headline)

**Hypothesis (most on-theme):** the paper is atropine-motivated, yet the **direct
drug targets — muscarinic receptors CHRM1–CHRM5** and cholinergic context — have
never been causally tested against the **structural** phenotype. A causal effect
of a muscarinic-pathway gene on axial length would be a **mechanistically
meaningful, atropine-anchored discovery** (and would finally justify the atropine
framing honestly).

- **[CLAUDE done]** `D3_muscarinic_atropine_target_MR.R` — cis-MR of CHRM1–5 (+
  cholinergic context genes) vs axial length AND refractive error; coloc; Steiger.
  Honest caveat: receptors are low-expressed in blood eQTL → instruments may be
  weak/absent; script flags this and recommends GTEx eye/brain panels if available.
- **[PI command]**
  ```r
  Rscript Submit_Manuscript/value_add/discovery/D3_muscarinic_atropine_target_MR.R
  ```
- **Decision gate G-D3:** a muscarinic-pathway gene with F>10 IVs, MR P<0.05/coloc
  PP.H4>0.7 on axial length → **headline mechanistic finding** (atropine target →
  structure). Weak/absent instruments → honest "not testable in available eQTL;
  the causal muscarinic→axial link remains untested" (still a useful statement).

## Engine D4 — Eye-tissue novel-coloc sweep  (already scaffolded as Track 3, extended)

**Hypothesis:** a gene invisible in blood eQTL colocalizes in **retina/RPE**.

- **[CLAUDE done]** Track 3 `03_eye_tissue_coloc.R` covers the 5 anchors. The
  discovery extension reuses D1's FDR hits and runs them through eye-tissue coloc.
- **Decision gate G-D4:** eye-tissue-specific coloc of a non-known gene → candidate
  novel (tissue-specific). Otherwise recovered/known or null.

---

## Execution order (one by one)

| Step | Owner | Action | Unblocks |
|---|---|---|---|
| 0 | PI | Resolve datasets: **axial-length GWAS**, **druggable-gene list**, **LD reference** (1000G EUR), eye eQTL panel | D1–D4 |
| 1 | PI | Run **D3** (muscarinic) first — smallest, most on-theme, fastest signal/null | headline decision |
| 2 | PI | Run **D1** (druggable-genome axial scan) — the broad discovery sweep | candidate list |
| 3 | PI | Run **D2** (fine-map) on D1 candidates + unverified loci | causal-gene confirmation |
| 4 | PI | Run **D4** (eye-tissue coloc) on D1 candidates | tissue confirmation |
| 5 | CLAUDE | Ingest result CSVs, apply the 4-part novelty wall, write the Results/Discussion, update GOAL_AND_LOOP_PLAN venue decision | manuscript |

**Honesty contract:** if Steps 1–4 yield no gene passing the 4-part wall, the
paper ships as the strong honest-confirmation + value-add version (TVST/BMC). We
do **not** invent a discovery to fill the gap. If one *does* pass the wall, we
have a genuine new finding and aim higher (IOVS / OVS), with replication.
