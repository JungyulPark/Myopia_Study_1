# DRAFT — Honest Discussion (replaces the TGFβ-Hippo-YAP / docking / "converge" version)

> Built on disk-verified numbers (RESULTS_LEDGER.md). Do-not-regress rules enforced:
> RDH5/CD55 = positive controls; CTNNB1/FBN1 = known loci, coloc-fail; TGFB1 excluded
> (discordant); atropine = motivation only; no discovery/converge/Hippo-YAP claims.
> `‹FILL when run›` = Phase B–D analyses (druggability, axial-length, eye-tissue,
> East-Asian, defocus cascade) to integrate once returned.

---

## 4. Discussion

### 4.1 Principal finding
Applying a pharmacology-prioritized drug-target MR pipeline under strict replication
and colocalization filters, we find that the prioritized loci are **established
refractive-error genes recovered as positive controls, not novel atropine-specific
targets**, and that MR significance alone — even when accompanied by clean pleiotropy
and heterogeneity diagnostics — does not establish causal identity of a gene at its
locus. Only **RDH5** cleared every filter (MR, three-cohort replication including a
high-myopia endpoint, and robust colocalization). This is a deliberately conservative,
corrective result rather than a discovery, and we frame it as such.

### 4.2 RDH5 as a positive control that validates the framework
RDH5 is an established myopia/refractive-error locus (Tedja et al. 2018) whose
colocalization with retinal/RPE expression has been reported previously; our pipeline
recovers it independently, with robust colocalization (PP.H4 up to 0.999) and
replication across UK Biobank, Tedja/CREAM, and FinnGen high myopia (OR = 1.22,
*P* = 0.013). That the single most firmly established anchor is also the one that
survives every filter is the expected behaviour of a well-calibrated pipeline, and it
licenses interpretation of the negative results that follow. Mechanistically, RDH5
participates in the visual cycle and retinoid metabolism, and retinoic acid is a
well-characterized modulator of scleral growth in animal models of form deprivation
and imposed defocus; we note this as biological *context* for a known locus, not as a
new mechanistic claim.

### 4.3 CTNNB1 and the distinction between MR association and colocalization
CTNNB1 is the clearest illustration of the study's methodological point. Its cis-MR
estimate was significant and passed every sensitivity check (no pleiotropy, no
heterogeneity, robust weighted-median), and — as an established locus — it even
replicated in the continuous refractive-error data (Tedja/CREAM, *P* = 6.9 × 10⁻⁸).
Yet colocalization placed the causal variant for expression apart from that for myopia
(PP.H4 = 0.037). In other words, neither MR robustness nor replication was sufficient:
the locus is real and reproducible, but the *gene's expression* does not share the
causal variant, so CTNNB1 cannot be assigned as the causal mediator. The most
parsimonious reading is linkage disequilibrium between the expression-associated
variant and a distinct, neighbouring disease variant. FBN1 shows the same
known-locus / replicates-but-does-not-colocalize pattern (PP.H4 = 0.165). This is the
central caution of the study: **in pharmacology-prioritized drug-target MR, neither a
robust MR estimate nor independent replication substitutes for colocalization**, and
signals that clear the former but fail the latter must remain candidate-only rather
than being reported as druggable causal genes.

### 4.4 CD55: robust but prior-sensitive, and already reported
CD55 presented a robust, pleiotropy-free MR association (weighted-median
*P* = 7.5 × 10⁻⁶) that replicated in continuous refractive error (Tedja/CREAM,
*P* = 0.008), but its colocalization was prior-sensitive (PP.H4 = 0.801 default,
falling to 0.287 under one prior) and it did not replicate in the FinnGen high-myopia
endpoint. It is, moreover, one of the six complement targets already reported by Wang
et al. (2024). We therefore neither claim CD55 as novel nor over-state its causal
support; we present it as a robust, replicating association whose colocalization is
prior-dependent and whose complement biology has been described elsewhere.

### 4.5 TGFB1
TGFB1 was instrumented by a single cis-variant, did not colocalize (PP.H4 = 0.018),
and showed a replication direction discordant with discovery. We therefore exclude it
as a positive result and make no directional or therapeutic claim — a departure we
state explicitly because earlier framing had over-weighted this gene.

### 4.6 Atropine and optical defocus: what germline genetics can and cannot say
Atropine motivated the candidate-gene prioritization, but our design cannot adjudicate
its mechanism. Mendelian randomization tests lifelong germline liability, not the
acute response to a drug or to imposed myopic defocus; the retina-to-sclera signalling
cascade established in animal models is outside its reach. Consistent with this, the
muscarinic node most directly relevant to atropine that we could instrument, CHRM3,
was null (*P* = 0.40). We therefore make no claim about atropine's efficacy or its
concentration–response (e.g., 0.05% vs 0.01%), which are pharmacological questions
requiring receptor-occupancy, interventional, or animal data. Where our data do touch
mechanism, it is only to note that the one robust causal locus, RDH5, sits in the
retinoid pathway that the defocus literature independently implicates — a convergence
of *known* biology, offered as hypothesis-generating context. ‹FILL when run: if the
defocus-cascade MR (analysis 10) or axial-length MR add colocalizing support for a
specific pathway node, integrate here with the same germline-vs-acute caveat.›

### 4.7 Relationship to prior pharmacology-prioritized myopia MR (Wang 2024)
Our contribution relative to Wang et al. (2024) is not a new target — we concede CD55
overlaps their complement set — but methodological: explicit novelty adjudication
against catalogued loci, multi-cohort replication including a high-myopia endpoint,
prior-sensitivity reporting for colocalization, and transparent demotion of MR signals
that fail the shared-causal-variant test. ‹FILL when run: axial-length MR (a structural
mediator Wang did not test), eye-tissue colocalization, East-Asian replication, and a
delivery-route-aware druggability map — each a concrete, honest point of
differentiation if the results land.›

### 4.8 Limitations
First, instruments derive from blood eQTLs (eQTLGen); blood is not eye tissue, and
tissue-specific colocalization in retina/RPE is the appropriate next step ‹FILL when
run: eye-tissue coloc result›. Second, the discovery outcome (ukb-b-6353) is
self-reported; we mitigate this with measured continuous refractive-error replication
(Tedja/CREAM), a conservative, non-differential source of misclassification. Third,
several anchors rest on a single cis-instrument, precluding pleiotropy-sensitivity
analysis and widening confidence intervals, particularly in FinnGen. Fourth, the
FinnGen endpoint captures high/pathological myopia rather than general refractive
error, so its nulls partly reflect phenotype and power differences. Fifth, all
discovery and replication samples are European-ancestry; East-Asian replication —
directly relevant given atropine's clinical context — is pending ‹FILL when run›.

---

## Do-not-regress self-check
- [x] No discovery / novel-target / "converge" / TGFβ-Hippo-YAP / docking-mechanism claims.
- [x] RDH5/CD55 positive controls; CD55 = Wang-2024 prior conceded.
- [x] CTNNB1/FBN1 known loci + coloc-fail; TGFB1 excluded (discordant).
- [x] Atropine motivation-only; CHRM3 null; no dose-response mechanism claim.
- [x] Blood-eQTL, self-report, single-instrument, FinnGen-phenotype, ancestry limitations stated.
- [x] Every number traces to RESULTS_LEDGER.md.
