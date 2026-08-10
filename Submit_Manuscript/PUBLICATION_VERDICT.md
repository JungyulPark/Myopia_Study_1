# Publication verdict — read this first

Status as of 2026-08-05, branch `claude/busy-heisenberg-lP58T`.

---

## Verdict

**The manuscript cannot be submitted today.** One result is missing, and it is the result
that decides what kind of paper this is. Everything else is done.

**It is not blocked by the absence of a second human screener.** That was over-stated in an
earlier assessment and is corrected here: a single-reader search is acceptable for a
re-analysis that uses the search only to assemble its sample, provided the protocol and the
screening log are published — both are (`LITERATURE_SEARCH_PROTOCOL.md`,
`outputs/literature_screening_log.csv`). The only consequence is wording: call it a
**systematic search**, never a *systematic review*, and state the single-reader limitation.

---

## The one blocking gate: the positive-control panel (Phase 3)

The paper's central claim is that published nominations fail a uniform colocalization
standard. That claim is only interpretable if the pipeline can detect colocalization when
it is genuinely present. Until the positive-control panel is run, **we do not know whether
we have a finding or an artefact of an insensitive assay.**

The interpretation rule was fixed in advance (`LITERATURE_SEARCH_PROTOCOL.md` §8) so the
conclusion cannot be chosen after seeing the data:

| Positive-control outcome | What the paper becomes | Realistic venue |
|---|---|---|
| **Recovers a substantial fraction** of established loci at PP.H4 > 0.8 | **Audit paper.** "Most genetically nominated myopia targets show no shared causal variant", plus the blood-provenance finding. The strong version. | IOVS, TVST, Genet Epidemiol |
| **Fails to recover** them | **Methods-caution paper.** "Blood-eQTL colocalization is underpowered for myopia; MR robustness ≠ colocalization." Negative findings must be reported as **uninformative, not as non-reproduction.** | Ophthalmic Genet, BMC Med Genomics |

Either way this is **not a discovery paper** — gate G0 is closed and evidence-backed: no
pharmacology-prioritized gene is a defensibly novel myopia-causal locus.

---

## Everything that must still be run (all require the PI's machine)

The analysis environment here has no access to eQTLGen (3.6 GB) or `ukb-b-6353.vcf.gz`;
both hosts are blocked by the organisation's egress policy, and the files are not in the
repository. This is an access limitation, not a missing script.

Run `value_add/ANTIGRAVITY_PHASE_0-3_REQUEST.md`. In priority order:

1. **Phase 3 — positive controls.** The gate above. If nothing else is done, do this.
2. **Phase 0 — three defects.** PRMT6's instruments-versus-empty-coloc-window contradiction;
   the invalid `UBE` row (source gene is **UBE2I**, ENSG00000103275); Ensembl ID
   verification. A table containing a known-invalid row cannot be submitted.
3. **Phase 0e — novelty reference update.** *Nat Genet* 2026 (PMID 42009823, ~1.76 M
   participants, 932 variants) supersedes Tedja 2018. **CD55's novelty flag may flip.**
4. **Phase 2 — re-test the 11 new genes** listed in `outputs/published_targets_master.csv`.

When those return, the remaining writing is mechanical: fill the two `‹PENDING›` markers in
the abstract, add Figure 6 (positive controls), and update Tables 1–2.

---

## What is finished and locked

- **Manuscript** reframed audit-first (title + abstract), with figure/table callouts,
  curated references (37 main + 9 supplementary), and figure legends.
- **Systematic search executed** — 253 records screened, 9 studies, 24 gene nominations,
  PRISMA counts filled, deviations recorded honestly.
- **Statistics computed** (`07`, `09`, `10` in `value_add/run_scripts/`, R 4.3.3):
  exact binomial CIs, PP.H4 threshold sensitivity, Bonferroni-vs-FDR robustness, screening
  agreement, tissue provenance, and audit-size precision.
- **Three factual errors corrected** and traced to primary sources: the audited paper is
  **Qin et al.** (not "Wang et al."); the nominated gene is **UBE2I** (not "UBE"), confirmed
  in the abstract of Dong et al.; CD55 is no longer described as an established GWAS locus.

## Known limitations to state in print

- Single-reader search; PubMed/MEDLINE only (Embase/WoS/Scopus unreachable); formal citation
  chasing not performed. All recorded in `LITERATURE_SEARCH_PROTOCOL.md` §10.
- Reproduction proportion has a wide interval (0.2–38.5% at n = 12; 0.1–21.1% at n = 24).
  **Report the direction, never a percentage.** Roughly 100 audited genes would be needed
  for a ±10-point interval.
- Blood-eQTL instruments. Mitigated but not removed by the finding that 75% of the
  nominations being audited are themselves blood-derived.
- One record (PMID 36508524) had no retrievable metadata and was never screened.
