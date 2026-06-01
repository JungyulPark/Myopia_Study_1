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

1. **One genuinely novel finding — RDH5.** First colocalization-supported myopia anchor at
   the visual-cycle/RPE axis, robust across all three priors, and replicated at P=3.3e-33 in a
   truly independent cohort. Not in Wang Y 2024 IOVS. This is a real, citable contribution.
2. **CD55 independent convergence** with a prior IOVS paper — corroboration, not a clash, and
   framed honestly (not "first discovered").
3. **Methodological rigor that beats the comparator** (Wang Y 2024): 3-prior colocalization
   sensitivity, true ancestry-independent replication (not UKB self-split), PheWAS audit,
   MVMR for height, Tier A/B honesty.
4. **Disciplined honesty.** Distinct-variant disclosure, "direct target unresolved," exploratory
   layers demoted to supplementary, weakest anchor (TGFB1) not oversold. This is the single
   biggest reason the paper will survive review.
5. **Provenance integrity.** A fabricated "CREAM N=542,934" circular-analysis artifact was
   found and replaced with genuine Tedja 2018 replication. The final paper is defensible.

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

## 6. Publication-viability verdict

**Overall: a solid, honest, methodologically rigorous genetic-epidemiology paper — publishable,
not a high-impact breakthrough.** Its value rests on RDH5 (real novelty) + rigor + honesty.
It is capped by blood-eQTL MR, no functional validation, and an atropine link that is framing
rather than mechanism.

| Target | Fit | Realistic outcome |
|---|---|---|
| **IOVS** (primary) | Strong — same journal as Wang Y 2024; our rigor is higher | Major revision likely; acceptance after revision **~30–45%**. Reviewers will press tissue-specificity. |
| **Experimental Eye Research (EER)** (backup) | Very good | **~60–75%** after minor/moderate revision |
| **JEI / similar specialty journal** | Easy fit | High acceptance, lower reach — sensible floor if IOVS+EER decline |

**Recommendation:** target IOVS first (the RDH5 novelty + Wang Y dialogue justify it); fall back
to EER, then JEI. Do **not** weaken the honest disclosures to chase impact — they are the paper's
armor.

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
