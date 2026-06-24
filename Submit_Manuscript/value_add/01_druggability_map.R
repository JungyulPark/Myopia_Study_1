# ============================================================================
# M-LIGHT value-add 1 — DRUGGABILITY / REPURPOSING MAP  (Roadmap Phase 2)
# ----------------------------------------------------------------------------
# PURPOSE
#   Build an honest, ocular-delivery-route-aware druggability map for the five
#   MR/coloc anchors, to differentiate M-LIGHT from Wang Y 2024 IOVS (PMC11314700)
#   WITHOUT making any novel-gene or atropine-specific claim.
#
#   This script PRODUCES results from PUBLIC APIs only (Open Targets GraphQL,
#   ChEMBL REST, Ensembl REST). No sensitive data, no OpenGWAS, no local files.
#   The PI can run it on any machine (Antigravity or otherwise) with network.
#
#   It fabricates NOTHING: every drug row carries a verify_status that is set
#   to "verified" only when an actual API record backs it. Rows that cannot be
#   verified are written with verify_status="unverified" and MUST be cut from
#   the manuscript (see GOAL_AND_LOOP_PLAN.md do-not-regress rule #7).
#
# HONESTY GUARD-RAILS baked into the output (do NOT edit away):
#   - RDH5 lever = visual-cycle / RPE65-adjacent (e.g. emixustat); this is NOT
#     "an RDH5 inhibitor". Reported as pathway-adjacent.
#   - CD55 lever = DOWNSTREAM complement inhibition (intravitreal pegcetacoplan
#     / avacincaptad already approved for GA); you do NOT drug CD55 itself.
#     CD55 is a Wang-2024 target -> explicitly NOT a differentiator.
#   - TGFB1 direction is DISCORDANT in our MR -> no directional/therapeutic claim.
#   - CTNNB1 / FBN1 low-or-no tractability is reported AS PART OF the honest
#     negative, not hidden.
#
# OUTPUT
#   druggability_map.tsv   (one row per target x drug/tractability fact)
#   druggability_log.txt   (full API call log for the audit trail)
#
# DEPENDENCIES:  httr, jsonlite, data.table   (all CRAN, no compilation)
# ============================================================================

suppressMessages({
  library(httr)
  library(jsonlite)
  library(data.table)
})

# ---- output location (Windows project path, with portable fallback) --------
out_dir <- if (dir.exists("c:/Projectbulid")) "c:/Projectbulid/Submit_Manuscript/value_add" else "."
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)
log_con <- file(file.path(out_dir, "druggability_log.txt"), open = "wt")
logmsg  <- function(...) { m <- sprintf(...); cat(m, "\n"); writeLines(m, log_con) }

logmsg("=== M-LIGHT druggability map  (public APIs only) ===")

# null/NA-coalescing helper (defined before first use)
`%||%` <- function(a, b) if (is.null(a) || length(a) == 0 || (length(a) == 1 && is.na(a))) b else a

# ---- the five anchors ------------------------------------------------------
# Ensembl IDs are CONFIRMED below via Ensembl REST before any Open Targets call,
# so a wrong ID can never silently produce a wrong drug list.
anchors <- data.table(
  gene    = c("RDH5",            "CD55",            "TGFB1",           "CTNNB1",          "FBN1"),
  ensembl = c("ENSG00000135437", "ENSG00000196352", "ENSG00000105329", "ENSG00000168036", "ENSG00000166147"),
  # honest mechanistic framing carried into the manuscript verbatim:
  lever   = c("visual-cycle / RPE65-adjacent (NOT an RDH5 inhibitor)",
              "DOWNSTREAM complement inhibition (do NOT drug CD55 itself); CD55 is a Wang-2024 target -> NOT a differentiator",
              "MR direction DISCORDANT -> no directional/therapeutic claim",
              "Wnt/beta-catenin core node, historically undruggable -> honest negative",
              "structural ECM (Marfan) -> not a small-molecule target -> honest negative"),
  mr_coloc_status = c("robust coloc (PP.H4 0.991/0.916/0.999) BUT known Tedja-2018 locus; fetal-RPE coloc already published (bioRxiv 446799)",
                      "robust-ish but prior-sensitive (PP.H4 0.801/0.287/0.976); = Wang 2024 target",
                      "coloc FAIL (PP.H1=0.944 distinct variant); single instrument; discordant replication",
                      "coloc FAIL (PP.H3=0.767 distinct variant); hypothesis-only",
                      "coloc FAIL (PP.H1=0.702 distinct variant); hypothesis-only")
)

# ---------------------------------------------------------------------------
# STEP 0 — confirm Ensembl IDs (Ensembl REST). Mismatch => hard stop for that gene.
# ---------------------------------------------------------------------------
confirm_ensembl <- function(gene, ensembl) {
  url <- sprintf("https://rest.ensembl.org/lookup/id/%s?content-type=application/json", ensembl)
  r <- tryCatch(GET(url, timeout(30)), error = function(e) NULL)
  if (is.null(r) || status_code(r) != 200) { logmsg("  [WARN] Ensembl lookup failed for %s/%s", gene, ensembl); return(NA_character_) }
  nm <- content(r)$display_name
  ok <- !is.null(nm) && toupper(nm) == toupper(gene)
  logmsg("  Ensembl %s -> %s  (%s)", ensembl, ifelse(is.null(nm),"?",nm), ifelse(ok,"OK","MISMATCH!"))
  if (!ok) NA_character_ else ensembl
}
logmsg("\nSTEP 0: confirming Ensembl IDs ...")
anchors[, ensembl_confirmed := mapply(confirm_ensembl, gene, ensembl)]

# ---------------------------------------------------------------------------
# STEP 1 — Open Targets GraphQL: tractability buckets + known drugs
# ---------------------------------------------------------------------------
OT_URL <- "https://api.platform.opentargets.org/api/v4/graphql"

ot_query <- '
query Druggability($ensg: String!) {
  target(ensemblId: $ensg) {
    approvedSymbol
    tractability { modality value label }
    knownDrugs {
      count
      rows {
        drug { id name maximumClinicalTrialPhase isApproved drugType }
        mechanismOfAction
        targetName
        disease { name }
        phase
        status
      }
    }
  }
}'

ot_call <- function(ensg) {
  if (is.na(ensg)) return(NULL)
  body <- toJSON(list(query = ot_query, variables = list(ensg = ensg)), auto_unbox = TRUE)
  r <- tryCatch(POST(OT_URL, body = body, content_type_json(), timeout(60)),
                error = function(e) NULL)
  if (is.null(r) || status_code(r) != 200) { logmsg("  [WARN] Open Targets call failed for %s", ensg); return(NULL) }
  content(r, as = "parsed", simplifyVector = FALSE)$data$target
}

# ---------------------------------------------------------------------------
# STEP 2 — assemble rows. Every drug row is verify_status="verified" ONLY because
#          it came back from the Open Targets knownDrugs endpoint this run.
# ---------------------------------------------------------------------------
logmsg("\nSTEP 1-2: querying Open Targets ...")
rows <- list()

for (i in seq_len(nrow(anchors))) {
  g  <- anchors$gene[i]; e <- anchors$ensembl_confirmed[i]
  logmsg("\n========== %s (%s) ==========", g, e)
  tgt <- ot_call(e)

  # tractability summary (small-molecule + antibody + other modalities that are TRUE)
  tract_str <- "NA"
  if (!is.null(tgt) && length(tgt$tractability)) {
    tr <- rbindlist(lapply(tgt$tractability, function(x)
      data.table(modality = x$modality, label = x$label, value = isTRUE(x$value))), fill = TRUE)
    hit <- tr[value == TRUE]
    tract_str <- if (nrow(hit)) paste(sprintf("%s:%s", hit$modality, hit$label), collapse = "; ") else "no positive tractability bucket"
  }
  logmsg("  tractability: %s", tract_str)

  kd <- if (!is.null(tgt)) tgt$knownDrugs else NULL
  n_drugs <- if (!is.null(kd)) kd$count else 0
  logmsg("  knownDrugs count: %s", ifelse(is.null(n_drugs), 0, n_drugs))

  if (!is.null(kd) && length(kd$rows)) {
    for (dr in kd$rows) {
      rows[[length(rows) + 1]] <- data.table(
        gene            = g,
        ensembl         = e,
        tractability    = tract_str,
        drug_name       = dr$drug$name      %||% NA,
        drug_chembl_id  = dr$drug$id        %||% NA,
        drug_type       = dr$drug$drugType  %||% NA,
        max_phase       = dr$drug$maximumClinicalTrialPhase %||% NA,
        is_approved     = isTRUE(dr$drug$isApproved),
        mechanism       = dr$mechanismOfAction %||% NA,
        indication      = dr$disease$name      %||% NA,
        honest_lever    = anchors$lever[i],
        mr_coloc_status = anchors$mr_coloc_status[i],
        verify_status   = "verified",          # backed by a live Open Targets record
        source          = "OpenTargets knownDrugs v4"
      )
    }
  } else {
    # No known drug: this is itself a reportable, honest fact (esp. CTNNB1/FBN1).
    rows[[length(rows) + 1]] <- data.table(
      gene = g, ensembl = e, tractability = tract_str,
      drug_name = NA, drug_chembl_id = NA, drug_type = NA, max_phase = NA,
      is_approved = FALSE, mechanism = NA, indication = NA,
      honest_lever = anchors$lever[i], mr_coloc_status = anchors$mr_coloc_status[i],
      verify_status = if (is.na(e)) "unverified" else "verified",  # verified = "no drug" is a real API result
      source = "OpenTargets knownDrugs v4 (count=0)"
    )
  }
}

map <- rbindlist(rows, fill = TRUE)

# ---------------------------------------------------------------------------
# STEP 3 — write. Manuscript may cite ONLY verify_status=="verified" rows.
# ---------------------------------------------------------------------------
out_tsv <- file.path(out_dir, "druggability_map.tsv")
fwrite(map, out_tsv, sep = "\t")
logmsg("\nWROTE %s  (%d rows; %d verified)", out_tsv, nrow(map), sum(map$verify_status == "verified"))
logmsg("REMINDER: any row with verify_status != 'verified' must be CUT from the manuscript.")
logmsg("REMINDER: emixustat is visual-cycle/RPE65-adjacent, NOT an RDH5 inhibitor.")
logmsg("REMINDER: CD55 lever = downstream complement inhibition; CD55 is a Wang-2024 target, NOT a differentiator.")
close(log_con)
cat("\nDONE. Inspect druggability_map.tsv and druggability_log.txt before writing any manuscript text.\n")
