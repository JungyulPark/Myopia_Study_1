# Honest assessment — can we discover something new? (axial-length route)

> Straight odds, no cheerleading. Read before spending the effort.

## Why axial length is the one real shot

- Refractive-error genetics is **saturated** (Tedja 2018 found 400+ loci); our anchors
  already proved to be known loci there. A new refractive-error gene is very unlikely.
- **Axial length** is the *structural* driver of pathological myopia and is **far less
  MR-interrogated**. Fewer prior scans → a genuinely novel, colocalizing axial-length
  causal gene is *plausible*, not just wishful.
- It runs **entirely on local data** (eQTLGen + the PI's UKB axial-length GWAS), so
  OpenGWAS being down does **not** block it.

## What `AXIAL_DISCOVERY_local.R` actually tests

Transcriptome-wide cis-MR (lead cis-eQTL per gene) of expression → axial length, FDR
across ~16k genes, colocalization on the FDR hits, then a novelty filter vs known
refractive-error/myopia loci. Output: `axial_DISCOVERY_candidates.csv` = FDR-sig +
PP.H4 > 0.7 + **not** a known locus.

## Honest probabilities (my estimate)

| Outcome | Rough odds | Meaning |
|---|---|---|
| ≥1 FDR-sig gene with coloc>0.7 | **high (~80%)** | Expected; most will be KNOWN loci (recovered controls). |
| ≥1 such gene that is **not** a known refractive-error/myopia locus | **~30–45%** | A *candidate* novel axial-length gene. Real but not landmark. |
| That candidate also survives fine-mapping **and** replication in a 2nd AL GWAS | **~15–25%** | A **defensible new finding** → upgrades venue (TVST/IOVS). |
| Nothing not-known colocalizes | **~55–70%** | Honest null → ship the confirmation paper (Sci Rep/BMC). |

So: **more likely than not we still end with the honest confirmation paper**, but there
is a real (~1-in-4 to 1-in-3) chance of a *candidate* novel axial-length gene, and a
smaller (~1-in-5) chance of one solid enough to genuinely raise the paper's level.
That asymmetric bet is worth one local run because the cost is low and the downside is
just "we proceed with the paper we already have."

## What would make a hit a REAL discovery (not overclaim)

All four, per the wall (DISCOVERY_PLAN.md):
1. Not a known refractive-error/myopia locus (±500 kb) — this script.
2. Colocalizes (PP.H4 > 0.7) — this script.
3. Fine-mapped credible-set gene, not an LD neighbor — run D2 next (needs 1000G LD).
4. Replicates direction in a 2nd axial-length dataset (CREAM AL / another cohort).

A hit passing 1–2 only = **candidate**, reported as such. A known locus = recovered
positive control. Nothing = honest null. **We do not upgrade the venue on a candidate
alone.**

## The realistic plan

1. PI resolves the **axial-length GWAS path** (`AL_FILE`) — the single blocker.
2. Run `AXIAL_DISCOVERY_local.R` (offline). ~minutes–1h depending on file size.
3. Paste back `axial_DISCOVERY_candidates.csv` + the anchors table.
4. If a not-known coloc hit appears → run D2 fine-map + find a 2nd AL cohort → decide
   venue. If not → we finalize the honest confirmation paper. Either way, **one run
   settles it.**
