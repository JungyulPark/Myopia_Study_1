# ============================================================================
# HIGH-VALUE ANALYSIS 09 — AXIAL-LENGTH MEDIATION (two-step / MVMR)
# ----------------------------------------------------------------------------
# WHY: refractive error is the optical read-out; AXIAL LENGTH is the structural
# driver. If an anchor acts on refractive error THROUGH axial elongation, that is
# a mechanistically informative, structural story Wang 2024 did not tell. Two-step
# MR estimates the proportion of the anchor->refraction effect mediated by AL.
#
# DEPENDS ON: Track 2 (02_axial_length_MR.R) having produced anchor->AL estimates,
#   plus an AL->refractive-error estimate. So run 02 first.
#
# HONEST FRAMING (locked):
#   - Mediation is estimated ONLY for anchors with a defensible anchor->AL effect
#     (from Track 2). For anchors with null/imprecise AL effects, mediation is
#     "not estimable" — reported as such, not forced.
#   - RDH5/CD55 remain positive controls; a clean structural-mediation story for a
#     positive control is a mechanism-of-known-biology result, not a discovery.
#   - No proportion is reported without CIs; implausible (>1 or <0) proportions are
#     flagged as imprecise, not interpreted as literal.
#
# METHOD (two-step MR):
#   step1: b1 = anchor -> axial length            (from Track 2)
#   step2: b2 = axial length -> refractive error   (AL eQTL/GWAS instruments -> RE)
#   total: bT = anchor -> refractive error         (primary pipeline)
#   mediated proportion = (b1 * b2) / bT ; SE by delta method / bootstrap.
#   Cross-check with MVMR (anchor + AL jointly -> RE): direct vs indirect effect.
#
# DEPENDENCIES: TwoSampleMR, MVMR (optional), data.table
# ============================================================================

suppressMessages({ library(TwoSampleMR); library(data.table) })
out_dir <- if (dir.exists("c:/Projectbulid")) "c:/Projectbulid/Submit_Manuscript/value_add" else "."

# ---- inputs from prior runs (fill paths) ------------------------------------
STEP1 <- "c:/Projectbulid/Submit_Manuscript/value_add/axial_length_MR_results.csv"  # anchor->AL (Track 2)
TOTAL <- "CP3/results/MR_CDE_consolidated.csv"                                       # anchor->RE (primary)
AL_INSTRUMENTS_OUTCOME_RE <- NA_character_   # for step2: AL exposure GWAS -> RE outcome id

anchors <- c("RDH5","CD55","CTNNB1","FBN1")

# step2: axial length -> refractive error (one estimate, reused for all anchors)
estimate_AL_to_RE <- function() {
  if (is.na(AL_INSTRUMENTS_OUTCOME_RE)) { cat("[!] set AL->RE step: AL GWAS instruments -> RE outcome\n"); return(NA) }
  # exp <- extract_instruments(<AL GWAS id>); out <- extract_outcome_data(exp$SNP, "ukb-b-6353")
  # dat <- harmonise_data(exp,out); mr(dat) IVW b -> return(list(b=, se=))
  NA
}

delta_prop <- function(b1,se1,b2,se2,bT,seT) {
  ind <- b1*b2
  se_ind <- sqrt((b2^2)*(se1^2) + (b1^2)*(se2^2))
  prop <- ind / bT
  se_prop <- sqrt((se_ind/bT)^2 + (ind*seT/bT^2)^2)
  c(indirect=ind, se_indirect=se_ind, prop_mediated=prop, se_prop=se_prop)
}

s1 <- if (file.exists(STEP1)) fread(STEP1) else { cat("[!] run Track 2 (02_axial_length_MR.R) first\n"); NULL }
tot <- if (file.exists(TOTAL)) fread(TOTAL) else NULL
b2 <- estimate_AL_to_RE()

rows <- lapply(anchors, function(g) {
  if (is.null(s1) || is.null(tot) || (length(b2)==1 && is.na(b2))) return(data.table(gene=g, note="inputs missing"))
  # b1 <- s1[gene==g & outcome=="axial_length"]; bT <- tot[Gene==g]
  # if b1 null/imprecise -> not estimable
  data.table(gene=g, note="wire b1 (Track2), b2 (AL->RE), bT (primary) then delta_prop()")
})
out <- rbindlist(rows, fill=TRUE)
fwrite(out, file.path(out_dir, "axial_mediation_results.csv"))
cat("WROTE axial_mediation_results.csv\n"); print(out)
cat("\nINTERPRET: report mediated proportion + CI ONLY for anchors with a defensible\n",
    "anchor->AL effect. Positive-control structural mediation = mechanism of KNOWN biology.\n", sep="")
