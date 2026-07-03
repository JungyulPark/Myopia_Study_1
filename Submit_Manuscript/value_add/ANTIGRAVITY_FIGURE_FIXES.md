# FIGURE AUDIT — verdict + required fixes (regenerate in R)

I audited all 5 figures against the verified data (published_targets_audit.csv,
Suppl_TableS_full_denominator_v2.csv, coloc sensitivity, replication files). **All
DATA is accurate.** Two honesty/wording fixes are REQUIRED before submission (one is a
do-not-regress violation), plus two minor cosmetic fixes.

| Fig | Data accuracy | Verdict |
|---|---|---|
| 1 Pipeline | ✅ correct (113→5→Tier A n=2/B n=3/Null n=108) | OK, no change |
| 2 Forest | ✅ directions + TGFB1 discordance correct | minor wording fix |
| 3 Coloc bars | ✅ PP.H1/H3/H4 all match | minor cosmetic (legend clipped) |
| 4 Screen scatter | ✅ correct, honest | OK, no change |
| 5 Audit | ✅ PP.H4 values correct | **⚠️ REQUIRED wording fix (overclaim)** |

---

## ‼️ REQUIRED — Figure 5 subtitle is an overclaim (do-not-regress violation)
Current subtitle: *"Re-evaluation under standardized blood-eQTL pipelines exposes high
rates of false-positives."*

**Problem:** We CANNOT call these "false-positives." Our own manuscript scopes every
non-reproduction to a **blood-eQTL** standard and states the caveats: (a) Wang 2024 used
blood **and retina** eQTL — a blood non-colocalization does not prove the target false;
(b) the multi-omics targets were SMR/mQTL-derived (different method). Calling them
"false-positives" contradicts the paper's Limitations and will be attacked by reviewers
(and the original authors).

**Replace subtitle with (honest):**
> *"Under a uniform blood-eQTL standard, only CD55 reproduces (coloc + replication);
> most nominations show distinct causal variants or lack a blood eQTL — interpretation
> is bounded by tissue (retina) and method differences."*

(If too long for the plot, shorten to: *"Under a uniform blood-eQTL standard, only CD55
reproduces; others show distinct variants or lack a blood eQTL (see tissue/method
caveats)."*) **Do NOT use the word "false-positive" anywhere in the figure.**

## REQUIRED — Figure 2 subtitle slight overstatement
Current: *"Consistent replication of RDH5 and CD55…"* — but CD55 did NOT replicate in
FinnGen (OR 0.98, P=0.54); only its direction is consistent.
**Replace with:** *"RDH5 replicates across all cohorts; CD55 directionally consistent
(FinnGen non-significant); TGFB1 shows discordant direction."*

## MINOR (cosmetic) — Figure 3 legend clipped
The right legend label ("PP.H4 (Shared…") is cut off at the page edge. Widen the right
margin or move the legend below the panel so the full label shows.

## MINOR — Figure 4
Fine. Optional: y-axis extends slightly above 1.0; cap at `coord_cartesian(ylim=c(0,1))`.

---

## After fixing
Regenerate the affected figures (2, 3, 5) at 300 dpi PNG+PDF, overwrite in
`figures_honest/`, commit, and push (safe file-copy to Myopia_Study_1).
```bash
git add Submit_Manuscript/value_add/figures_honest/
git commit -m "Figure fixes: remove 'false-positive' overclaim (Fig5), soften CD55 replication wording (Fig2), fix legend clipping (Fig3)"
git push origin claude/busy-heisenberg-lP58T
```
**The Figure 5 wording fix is mandatory — it must match the manuscript's honest scoping.**
