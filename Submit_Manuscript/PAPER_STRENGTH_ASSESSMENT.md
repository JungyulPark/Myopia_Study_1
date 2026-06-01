# M-LIGHT — Paper Strength & Publication-Viability Assessment

**Assessor view:** senior reviewer / co-author honest read
**Date:** 2026-06-01
**Scope:** the *current* (Stage 2) version of the paper — the 5-anchor RDH5/CD55 framing,
not the older TGFβ–Hippo manuscript text still sitting in the repo.

> ⚠️ Read this first: the paper **evolved**. Active analysis/writing is in Antigravity.
> The repo's `Manuscript_FINAL_Submission.md` is the OLD framing; the Stage 2 figures
> (`Stage2_Figures/`) are the NEW framing. They do not yet match (see §5).

---

## 1. What the paper now claims

- **Working title:** "An atropine-motivated Mendelian randomization framework prioritizes
  RDH5 and CD55 as genetic anchors for human myopia."
- **Two honest questions, two answers:**
  - Q1 — can atropine pharmacology be used as a prior to prioritize myopia genetic anchors?
    → **Yes.** Five anchors: Tier A (RDH5, CD55), Tier B (TGFB1, CTNNB1, FBN1).
  - Q2 — are these atropine's direct molecular targets?
    → **No / unresolved** by transcriptomic MR (stated plainly, not hidden).

---

## 2. Core results (single source of truth = disk-verified)

| Anchor | Tier | UKB discovery P | Tedja 2018 replication P | Coloc | Note |
|---|---|---|---|---|---|
| **RDH5** | A | 1.2e-6 | **3.3e-33** | PP.H4 0.991/0.916/0.999 (robust) | visual cycle / RPE |
| **CD55** | A | 3.6e-5 | 8.3e-14 | PP.H4 0.801/0.287/0.976 (prior-sensitive) | complement; convergent w/ Wang Y 2024 |
| TGFB1 | B | 0.003 | 4.7e-3 (LD proxy r²=0.83, **discordant**) | PP.H1 0.944 (distinct) | weakest; single instrument |
| CTNNB1 | B | 4.4e-5 | 6.9e-8 | PP.H3 0.767 (distinct) | Wnt/β-catenin |
| FBN1 | B | 3.3e-4 | 5.8e-4 | PP.H1 0.702 (distinct) | fibrillin/ECM |

Replication = **Tedja 2018 CREAM+23andMe, N=160,420** (genuinely independent of UKB).
Network + docking are **exploratory supplementary** (S1, S2), explicitly hypothesis-generating.

---

## 3. Strengths (what makes this publishable)

> **Correction (literature audit, 2026-06-01): the two headline anchors are NOT novel.**
> A web/literature check shows: **RDH5** is a *previously identified* refractive-error
> susceptibility gene (rs3138141/rs3138144; Tedja/CREAM 2018), and its **eQTL colocalization
> with the myopia GWAS signal has already been published — in fetal RPE eQTL** (Bryan/Mvududu
> et al., biorxiv 446799), i.e. in a *better* tissue than our blood eQTL. **CD55** is one of the
> six MR drug targets already reported by **Wang Y 2024 IOVS**, with anti-myopia complement
> biology already described. **BICC1** (Tier 2) is a known high-myopia candidate; several other
> Tier 2 hits (SPACA3, GATAD2A, TMEM258) sit in LD clusters containing already-known myopia
> genes (TMEM98, TSSK6, SREBF2), so their lead-gene assignment is fragile. **Net: there is no
> clear genuinely-new myopia gene here.** The contribution is methodological/consolidative, not
> discovery. The strengths below should be read in that light.

1. **Rigorous triangulation framework** — network → expanded MR → 3-prior colocalization →
   true ancestry-independent replication (Tedja 2018, N=160,420) → exploratory docking, in one
   reproducible pipeline. The *method/quality* exceeds the comparator (Wang Y 2024).
2. **Honest negative result** — atropine's clinical effect does NOT map onto a clean
   transcriptomic-MR target; prioritized genes are general refractive-error loci (visual cycle,
   complement, ECM), not atropine-specific receptors. This is a genuinely useful corrective to
   the many uncritical atropine network-pharmacology papers.
3. **Confirmation/consolidation value** — independent replication of CD55 (vs Wang Y) and of the
   RDH5 locus, with added 3-prior coloc robustness, has modest but real corroborative worth.
4. **Disciplined honesty / provenance integrity** — distinct-variant disclosure, demotion of
   network+docking to supplementary, removal of the fabricated "CREAM N=542,934" artifact.

## 4. Weaknesses / reviewer attack surface (be honest)

1. **Blood eQTLs (eQTLGen), not eye tissue.** MR of *blood* expression for an *ocular* phenotype
   is the #1 reviewer objection. Must be foregrounded as a limitation; future retinal/RPE/scleral
   eQTL validation flagged. Cannot be fully resolved now.
2. **No wet-lab validation.** Entirely computational/genetic. Biological axes (visual-cycle /
   complement / ECM) are post-hoc literature interpretation, not tested.
3. **TGFB1 is fragile** — single instrument, LD-proxy in replication (r²=0.83), discordant
   direction, PP.H1 (not H4). It links to the original mechanistic story but is the weakest leg;
   keep it strictly Tier B.
4. **Atropine link is a framing device, not a demonstrated mechanism.** "Atropine-motivated"
   is a clever Bonferroni-denominator prior; the honest "unresolved" disclosure protects it but
   also softens the headline punch.
5. **FinnGen external cohort underpowered** (1,640 cases, mostly null) — honest but weak.
6. **Discovery phenotype is noisy** self-reported myopia (ukb-b-6353, "reason for glasses").
   Independence of discovery vs replication must be airtight in Methods.

## 5. Repo/manuscript consistency risk (fix before submission)

- The repo manuscript text = **old TGFβ–Hippo / 8-gene framing**.
- Stage 2 figures = **new 5-anchor RDH5/CD55 framing**.
- These are **two different papers' identities.** The body text must be rewritten to the
  5-anchor framing (in progress in Antigravity) before anything is submitted. Submitting the
  current repo text with the new figures would be an instant desk-reject for internal inconsistency.

---

## 6. Publication-viability verdict (revised after novelty audit)

**Overall: an honest, rigorous, but largely CONFIRMATORY genetic-epidemiology paper — not a
discovery.** The headline genes are already known and RDH5's eQTL coloc is already published
(in RPE). Combined with blood-eQTL MR, no functional validation, and an atropine link that is
framing rather than mechanism, the impact ceiling is modest.

| Target | Fit | Realistic outcome |
|---|---|---|
| **IOVS** (as "discovery") | **Weak** — IOVS already published CD55 (Wang Y 2024); RDH5 RPE-coloc already out. An incremental blood-eQTL confirmation risks reject-as-incremental. | low (~10–20%) unless reframed |
| **IOVS / OVS (as methods + honest-negative)** | Possible if framed as a cautionary triangulation framework, not a gene claim | major revision; modest |
| **Experimental Eye Research (EER)** | Good fit for a rigorous confirmation/method paper | **~55–70%** after revision |
| **JEI / specialty journal** | Easy fit, honest floor | high acceptance, low reach |

**Recommendation:** do **not** submit to IOVS as a discovery — it would likely be rejected as
incremental against its own 2024 paper. Either (a) reframe honestly and target EER/JEI, or
(b) invest in one genuine value-add (§9) before deciding venue.

---

## 9. Can it be made genuinely more valuable? (honest options)

There is **no genuinely-new gene** in the current results, so "more valuable" must come from
reframing or new analysis, not from overclaiming. Realistic paths, in ROI order:

1. **Reframe around the honest negative (cheap, true, useful).** Headline message:
   *"Atropine's clinical anti-myopia effect does not resolve to a transcriptomic-MR target;
   pharmacology-prioritized loci are generic refractive-error genes (visual cycle / complement /
   ECM)."* This is a real corrective to the flood of uncritical atropine network-pharmacology
   papers and is fully supported by the data. Best low-effort lift; suits EER.
2. **Axial-length-specific MR (medium, public data).** Re-run anchors against an axial-length
   GWAS rather than refractive error. Axial length is the structural driver; a specific effect
   there is more mechanistically informative than re-confirming refractive-error loci.
3. **Druggability/repurposing map (medium).** Open Targets / DrugBank / ChEMBL: which anchors
   have existing drugs (e.g. visual-cycle modulators → RDH5 axis; complement inhibitors → CD55)?
   Position as a repurposing-candidate map — but explicitly acknowledge overlap with Wang Y 2024.
4. **Tissue-specific coloc for a non-RDH5 locus (medium).** RPE-RDH5 is taken; a retina/sclera
   coloc that *adds* something for CD55 or a Tier B gene could differentiate.
5. **Genuine novelty only via new data (high, out of current scope).** A myopia gene with no
   prior literature that survives coloc + replication + is NOT LD-confounded — the Tier 2 list
   does not currently provide a clean one (most cluster with known genes). Would need careful
   fine-mapping (coloc-SuSiE) and likely still come up empty, or new tissue/functional data.

**Bottom line for the PI:** the worst outcome is an oversold IOVS submission that gets rejected.
The honest-negative reframe (#1) is the cheapest way to make the paper *worth* submitting; #2/#3
are the realistic ways to lift it without fabrication. If none of these is appealing, an honest
EER/JEI submission of the confirmation paper is legitimate — just don't dress it as discovery.

---

## 7. Must-do before submission (gating)

1. **Rewrite manuscript body to the 5-anchor framing** (Antigravity, in progress) and reconcile
   title across body + figures + manifest.
2. **Generate Supplementary S1 network image** (STRING 0.700; input package ready).
3. **Foreground the blood-eQTL / tissue-specificity limitation** explicitly.
4. **Fix references** [27][28][35][40]; resolve Methods 2.2 Hippo-YAP gene-count discrepancy;
   Methods 2.2.5 CHRM4 location; CHRNA7/CHRNB4 justification.
5. **Lock numbers to Master Numbers v4** as the single source of truth across all sections.

## 8. Non-negotiable honesty rules (do not regress)

- Never reuse "CREAM N=542,934" — fabricated.
- CD55 = "converges with Wang Y 2024," never "first discovered."
- Atropine direct target = "unresolved."
- Network + docking = exploratory supplementary only.
- TGFB1 stays Tier B with its proxy/discordance disclosed.
