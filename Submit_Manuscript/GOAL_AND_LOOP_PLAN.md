# M-LIGHT — Goal & Loop Plan (Decision-Grade)

> **Status:** Lead-integrated plan synthesizing five specialist memos (novelty audit, axial-length MR, druggability, journal strategy, honest reframe). All MR/coloc numbers herein are disk-verified inputs; no results are fabricated. Heavy analysis runs on the PI's local "Antigravity" machine (sensitive eQTLGen/UKB/Tedja data is NOT in this repo). Deliverables below are executable specs + writing/strategy, never invented results.

---

## 1. Honest verdict

**M-LIGHT is a confirmation-and-methods paper, not a discovery paper.** Applied honestly with replication + colocalization filters, an atropine-motivated drug-target MR pipeline converges on loci that are *already known* refractive-error genes. Only **RDH5** has robust coloc (PP.H4 0.991/0.916/0.999) — and it is the *most* already-known anchor: an established Tedja-2018 locus (rs3138141/rs3138144) whose eQTL colocalization is **already published in a more relevant tissue** (fetal RPE, bioRxiv 446799), so our blood-eQTL coloc re-derives a known result in a worse tissue. **CD55** is robust-ish but prior-sensitive (PP.H4 0.801/0.287/0.976) and is literally one of Wang Y 2024 IOVS's (PMC11314700) six complement MR targets. The three Tier-B anchors fail the shared-causal-variant test and cannot be called colocalized: **TGFB1** (single instrument, PP.H1=0.944 distinct variant, *discordant* replication direction), **CTNNB1** (PP.H3=0.767 distinct), **FBN1** (PP.H1=0.702 distinct). No Tier-2 hit is defensibly novel; the genes with any pedigree are known or LD-cluster with known genes (BICC1; SPACA3/TSSK6; GATAD2A/TMEM98; TMEM258/SREBF2), and the rest are unverified, not new. **There is no genuinely-new myopia gene.** The paper's legitimate value is methodological and corrective: a transparent, tiered, replication-and-coloc-filtered MR framework that recovers known biology as positive controls, honestly down-weights weak anchors, and benchmarks pharmacology-prioritized "targets" against prior GWAS. **It is NOT, and must not claim to be, a discovery of new myopia genes or new atropine-specific targets.**

---

## 2. Goal options (decision gate)

| | **Option A — Honest reframe, ship fast** | **Option B — Add value-adds, aim higher** |
|---|---|---|
| **Thesis** | Corrective methods/triangulation paper: pipeline recovers known loci as positive controls; bounds novelty to zero, honestly. | Same honest core **plus** axial-length-specific MR and/or druggability map as net-new contributions differentiating from Wang 2024. |
| **Target venue** | BMC Ophthalmology / BMC Med Genomics / PLOS ONE / Sci Rep (rigor-only bar, novelty not required); **TVST** if methods framing lands. | **TVST** primary; **OVS** (clinical/repurposing angle); **IOVS** only if a value-add materially differentiates from Wang 2024. (EER/JEI were the original aspiration; on current evidence they need a mechanistic layer to fit — treat as stretch.) |
| **Added work** | Rewrite + Methods/ref fixes + S1 image only. ~2–3 weeks. | + AL-MR (gated on dataset access) and/or druggability map. ~5–8 weeks, with real access risk on AL data. |
| **Upside** | Fast, near-certain acceptance somewhere sound; zero overclaim risk. | Genuinely orthogonal to Wang 2024 (AL = structural mediator Wang didn't test; delivery-route-aware repurposing); higher-tier shot. |
| **Risk** | Modest contribution; reviewers may call it "confirmation-only." | AL summary stats may not be publicly accessible at useful N → value-add could collapse to underpowered supplementary; longer timeline. |

**Recommended default: Option B-lite (druggability-first, AL-conditional).** The **druggability/repurposing map is low-risk** (public APIs only, no sensitive data, PI runs anywhere) and gives a real differentiator from Wang 2024 via the *ocular-delivery-route* lens — so do it. The **axial-length MR is high-value but access-gated**; pursue it in parallel but **do not let it block submission**. Concretely: execute the honest rewrite + druggability map + Methods/ref fixes on the critical path (Option A scaffold), spin AL-MR as a parallel track, and at the Phase-3 gate decide whether AL landed in time to upgrade the venue (TVST/IOVS) or whether we ship the strong honest+druggability version (TVST/BMC) without waiting. This captures most of B's upside while keeping A's certainty floor.

---

## 3. Elevation roadmap

Owners: **[PI]** = runs in Antigravity / on PI's machine (analysis, sensitive data, public-API queries). **[W]** = writing/research/strategy (this side, no sensitive data).

### Phase 0 — Novelty audit completion *(blocks all "novel" claims)*
- **0.1 [PI]** For each UNVERIFIED Tier-2 gene (IKZF3, H2BC4, MYBPC3, CEP250, CENPM, API5, RABEPK), cross-reference lead SNP vs Tedja 2018 / GWAS Catalog (EFO refractive error & myopia), ±500 kb. *(0.5–1 d)*
- **0.2 [PI]** Any gene surviving 0.1 → susieR/coloc fine-map to test it (not a neighbor) is the credible causal gene. *Prior expectation: empty.* *(1–2 d)*
- **0.3 [PI]** Confirm CD55 ⊆ Wang 2024's 6 targets; list the other 5 to ensure no other anchor overlaps. *(0.5 d)*
- **0.4 [W]** Fold results into the novelty table; lock the "no defensibly-novel gene" statement (or, if 0.2 surprises, scope a single candidate carefully).
- **Gate G0:** Is any gene genuinely novel + coloc-supported + not LD-confounded? Almost certainly **No** → proceed as confirmation paper. If unexpectedly **Yes** → re-open framing.

### Phase 1 — Honest-negative rewrite *(critical path)*
- **1.1 [W]** Replace Stage-2 discovery title/abstract with corrective framing. Primary title: *"Pharmacology-prioritized myopia loci are generic refractive-error genes, not atropine-specific targets: a Mendelian randomization reappraisal."* Use Memo 5 abstract (~180 w) + 3-sentence key message. *(1–2 d)*
- **1.2 [W]** Reframe RDH5/CD55 as **positive controls / known biology recovered**, not discoveries. Demote TGFB1/CTNNB1/FBN1 to hypothesis-only with explicit coloc-failure + (TGFB1) discordant-direction language. Kill all "five colocalized anchors" phrasing. *(1 d)*
- **Depends on:** G0. **Gate G1:** title/abstract/discussion contain zero novelty/atropine-specificity overclaims (check against Section 6 rules).

### Phase 2 — Druggability map *(parallel, low-risk differentiator)*
- **2.1 [PI]** Run Open Targets GraphQL (tractability + knownDrugs), ChEMBL (on-target vs pathway-adjacent), DrugBank (route/approval), PharmGKB — per Memo 3 §2, 5 anchors. Confirm Ensembl IDs first. *(1–2 d)*
- **2.2 [PI]** Emit `/home/user/Myopia_Study_1/druggability_map.tsv` per Memo 3 §3 schema; every drug row `verify_status=verified` or it is cut. *(0.5 d)*
- **2.3 [W]** Write tractability/repurposing subsection + explicit Wang-2024 non-overlap statement (no docking, no novel-binder prediction; delivery-route lens). Keep caveats: emixustat = RPE65/visual-cycle-adjacent NOT "RDH5 inhibitor"; CD55 lever = downstream complement inhibition (intravitreal pegcetacoplan/avacincaptad exist) NOT drugging CD55; TGFB1 direction discordant → no directional claim; CTNNB1/FBN1 low/none tractability = part of the honest negative. *(1 d)*
- **Gate G2:** ≥1 honest, verified, ocular-delivery-aware differentiator vs Wang 2024 exists (CD55 intravitreal-complement handle qualifies).

### Phase 3 — Axial-length / high-myopia MR *(parallel, ACCESS-GATED — must not block submission)*
- **3.1 [PI]** **Resolve dataset access FIRST** (gating uncertainty): confirm a usable AL GWAS — PI-generated UKB AL (fields 5201/5202, ~67k eye-exam subset) vs public CREAM AL (low power) vs Pan-UKBB phenocode. Verify FinnGen `H7_MYOPIA`/degenerative endpoint vintage and BBJ high-myopia accession for the severity axis. *(1–3 d, may stall)*
- **3.2 [PI]** Run Memo 2 §3 workflow: eQTLGen instruments p<5e-6, clump r2=0.001/10Mb EUR; harmonise action=2; Wald/IVW; Steiger filter; coloc.abf with 3 p12 priors (1e-5,1e-6,5e-6). AL=quant, high-myopia=cc(s). *(2–3 d after data in hand)*
- **3.3 [W]** Pre-register the Memo 2 §4 interpretation grid so a null AL panel is *informative, not failure*; write AL-vs-refraction mechanistic contrast (structural vs optical pathway). *(1 d)*
- **Gate G3 (the venue decision):** Is a powered, defensible AL result in hand? **Yes →** upgrade venue to TVST/IOVS, AL becomes a headline triangulation. **No / underpowered / no access →** demote AL to powered-as-able supplementary (or drop), and **ship the honest+druggability version now** — do not wait.

### Phase 4 — Methods/reference & figure fixes *(critical path, can run alongside 1–3)*
- **4.1 [W]** Fix references **[27][28][35][40]** (outstanding). *(0.5 d)*
- **4.2 [W]** Correct Methods **§2.2 gene-count** to match the final anchor/Tier-2 set. *(0.5 d)*
- **4.3 [W/PI]** Regenerate / supply **S1 network image** (network layer stays Supplementary; carries no main-text target claim). *(0.5 d)*
- **4.4 [W]** Add explicit **tissue-specificity limitation** (blood eQTL ≠ eye) + the planned/role of tissue-specific coloc. *(0.5 d)*
- **Gate G4:** all Section-4 checklist items resolved.

### Phase 5 — Submission
- **5.1 [W]** Run full Section-4 pre-submission gating checklist. *(0.5 d)*
- **5.2 [W/PI]** Select venue per G3 outcome (default TVST; floor BMC/PLOS ONE; IOVS only if AL landed). Format to author guidelines, cover letter foregrounding honest triangulation + Wang-2024 differentiation. *(1 d)*
- **5.3 [PI]** Submit. **Exit criterion for the whole loop.**

**Critical path:** G0 → Phase 1 → Phase 4 → Phase 5, with Phases 2 and 3 in parallel and Phase 3 explicitly non-blocking. Realistic timeline: **Option-A floor ~2–3 wks; B-lite (with druggability) ~3–4 wks; full B (AL landed) ~6–8 wks** contingent on data access.

---

## 4. Pre-submission gating checklist

Every item must be **Done** before 5.3. Derived from journal-strategy reviewer objections (Memo 4) + outstanding repo items.

**Honesty / framing (do-not-regress — see §6):**
- [ ] No "novel gene" / "discovery" / "atropine-specific target" claim anywhere; no "five colocalized anchors" phrasing.
- [ ] RDH5 & CD55 framed as positive controls / known biology; RDH5 fetal-RPE prior coloc (bioRxiv 446799) conceded; CD55 = Wang-2024 target conceded up front.
- [ ] TGFB1 labeled single-instrument + PP.H1=0.944 distinct variant + **discordant direction**; CTNNB1 (H3) & FBN1 (H1) labeled non-colocalizing / candidate-only.
- [ ] No drug row in manuscript with `verify_status≠verified`; emixustat≠"RDH5 drug"; CD55 lever = downstream complement inhibition.

**Reviewer-objection pre-empts (Memo 4):**
- [ ] Blood-eQTL tissue limitation stated + tissue-specific coloc role addressed (obj. 1).
- [ ] Wang-2024 differentiation paragraph present: 2-cohort replication + prior-sensitivity reporting + (if landed) AL-MR + druggability route-lens (obj. 2).
- [ ] RDH5 "positive control that validates the framework" paragraph present (obj. 3).
- [ ] TGFB1 transparency paragraph present (obj. 4).
- [ ] Self-report phenotype (ukb-b-6353) addressed via measured-RE Tedja replication = conservative/non-differential argument (obj. 5).
- [ ] Atropine demoted to motivation/narrative, not analytic claim; speculation in Discussion/Supplementary (obj. 6).

**Outstanding repo items:**
- [ ] References **[27] [28] [35] [40]** fixed.
- [ ] Methods **§2.2 gene-count** corrected to final set.
- [ ] **S1 network image** regenerated and embedded.
- [ ] **Tissue-specificity limitation** paragraph added.

**Novelty audit:**
- [ ] G0 closed: Tier-2 GWAS-Catalog cross-ref + fine-map done; "no defensibly-novel gene" locked (or single candidate scoped).
- [ ] CD55 ⊆ Wang-2024 confirmed; other 5 Wang targets checked for anchor overlap.

---

## 5. LOOP ENGINEERING

**Why a loop:** the work is multi-phase with gates and one access-gated parallel track that must not stall the whole thing. A recurring checkpoint forces a weekly "is the gate met / what's blocking / what's next" decision and prevents the AL track from silently blocking submission.

**Cadence:** weekly checkpoint. Run via the `/loop` skill on the PI's machine:

```
/loop 1w <checkpoint prompt>
```

**Exit criterion:** manuscript **submitted** (Phase 5.3 done). The loop's first action each iteration is to check the exit condition and stop if met.

**Exact checkpoint prompt to loop on** (paste verbatim after `/loop 1w`):

```
M-LIGHT weekly checkpoint. Read GOAL_AND_LOOP_PLAN.md.
1. EXIT CHECK: Is the manuscript submitted (Phase 5.3 done)? If yes, STOP the loop and report "SUBMITTED".
2. Identify the current active phase(s) on the critical path (G0 -> Phase1 -> Phase4 -> Phase5) and the parallel tracks (Phase2 druggability, Phase3 AL-MR).
3. For each active phase: is its decision gate (G0/G1/G2/G3/G4) met? State met / not-met with the specific evidence.
4. BLOCKERS: What is blocking the critical path right now? Separately, is Phase 3 (axial-length data access) blocking? If AL has no usable dataset this week, confirm we are proceeding to submit the honest+druggability version WITHOUT it (G3 = No path).
5. HONESTY REGRESSION CHECK: scan any new manuscript text against Section 6 do-not-regress rules; flag any new novelty/atropine-specificity/"colocalized anchor" overclaim or unverified drug row.
6. NEXT ACTIONS: list the 1-3 concrete next tasks with owner ([PI] vs [W]) and which gate they unblock.
7. Update the Section 4 checklist boxes that are now Done.
Keep it under one screen. No fabricated results; analysis numbers come only from the Antigravity run.
```

**Fallback shorter cadence:** if a deadline compresses (e.g., final fixes week before submission), switch to a 2-day pulse with a trimmed prompt:

```
/loop 2d M-LIGHT pulse: Read GOAL_AND_LOOP_PLAN.md. (1) Submitted yet? If so STOP. (2) Current gate met? (3) Top blocker + is AL blocking submission (it must not)? (4) Next action + owner. (5) Any honesty regression vs Section 6? One screen.
```

**Self-paced option:** if the PI prefers event-driven over fixed interval, run `/loop` with no interval and let it re-checkpoint after each completed task; same prompt body.

---

## 6. Do-not-regress honesty rules

These are invariant. Any edit that violates one is a regression and must be reverted.

1. **No novel-gene / discovery claim.** RDH5 (known Tedja-2018 locus, published fetal-RPE coloc) and CD55 (Wang-2024 target) are **positive controls / known biology recovered**, never discoveries. The paper's stance is "no defensibly-novel myopia gene found."
2. **No "five colocalized anchors."** Only RDH5 (robust) and weakly CD55 survive coloc. TGFB1/CTNNB1/FBN1 **do not colocalize** (PP.H1=0.944 / PP.H3=0.767 / PP.H1=0.702 = distinct variants) and are candidate/hypothesis-only.
3. **TGFB1 direction is DISCORDANT.** Single instrument, r2=0.83 LD proxy, distinct variant. No directional / therapeutic claim permitted — exclude as a positive.
4. **No atropine-specific causal claim.** Atropine is motivation/narrative only; any mechanism speculation lives in Discussion/Supplementary.
5. **Concede prior art up front.** RDH5 fetal-RPE coloc (bioRxiv 446799) and CD55 ∈ Wang-2024 (PMC11314700) are stated as prior work; CD55 is **not** a differentiator from Wang.
6. **No fabricated numbers.** Every effect size / P / PP comes from the PI's disk-verified Antigravity run. Designs/specs never carry invented results.
7. **Drug claims are verified or cut.** No manuscript drug row with `verify_status≠verified`. emixustat = visual-cycle/RPE65-adjacent, **not** an RDH5 inhibitor; CD55's lever is **downstream complement inhibition**, not drugging CD55; CTNNB1/FBN1 low/none tractability is reported as part of the honest negative.
8. **No lead-gene attribution without fine-mapping** for LD-clustered Tier-2 genes (SPACA3/TSSK6, GATAD2A/TMEM98, TMEM258/SREBF2, IKZF3 17q21, H2BC4 HIST1/MHC). "Unverified" ≠ "novel."
9. **Tissue limitation stays stated.** Blood eQTL ≠ eye tissue; this is a named limitation, not something to paper over.
10. **A null AL result is informative, not failure** — and is never converted into a positive. Pre-registered interpretation grid governs.

---
