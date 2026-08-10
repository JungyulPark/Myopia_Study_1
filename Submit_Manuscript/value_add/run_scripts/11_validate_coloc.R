#!/usr/bin/env Rscript
# Validate the base-R coloc.abf fallback in audit_v4.R against scenarios with a
# known answer. This is a correctness check on the implementation, not on any
# myopia result. Run: Rscript 11_validate_coloc.R
suppressPackageStartupMessages(library(data.table))

src <- readLines(file.path(dirname(sub("--file=", "",
        grep("--file=", commandArgs(), value = TRUE)[1])), "audit_v4.R"))
a <- grep("^logsum <- ", src); b <- grep("^HAVE_COLOC <- ", src) - 1
eval(parse(text = paste(src[a:b], collapse = "\n")))

set.seed(42)
n <- 400
mk <- function(z) list(beta = z * 0.02, varbeta = rep(0.02^2, n), type = "quant", N = 3e4)
noise <- function() rnorm(n)

scen <- function(name, z1, z2, expect) {
  r <- coloc_abf_base(mk(z1), mk(z2))$summary
  pp <- r[c("PP.H0.abf","PP.H1.abf","PP.H2.abf","PP.H3.abf","PP.H4.abf")]
  top <- c("H0","H1","H2","H3","H4")[which.max(pp)]
  cat(sprintf("%-34s H0=%.3f H1=%.3f H2=%.3f H3=%.3f H4=%.3f | top=%s expected=%s %s\n",
              name, pp[1], pp[2], pp[3], pp[4], pp[5], top, expect,
              ifelse(top == expect, "PASS", "*** FAIL ***")))
  c(sum = sum(pp), ok = top == expect)
}

cat("Validation of base-R coloc.abf (Wakefield ABF)\n"); cat(strrep("-", 105), "\n")
res <- rbind(
  scen("null in both",            noise(),                       noise(),                       "H0"),
  scen("signal in trait 1 only",  {z<-noise(); z[100]<- 9; z},   noise(),                       "H1"),
  scen("signal in trait 2 only",  noise(),                       {z<-noise(); z[100]<- 9; z},   "H2"),
  scen("distinct causal variants",{z<-noise(); z[100]<-10; z},   {z<-noise(); z[350]<-10; z},   "H3"),
  scen("shared causal variant",   {z<-noise(); z[100]<-10; z},   {z<-noise(); z[100]<- 9; z},   "H4"))

cat(strrep("-", 105), "\n")
cat(sprintf("Posteriors sum to 1 in all scenarios : %s (max deviation %.2e)\n",
            all(abs(res[, "sum"] - 1) < 1e-9), max(abs(res[, "sum"] - 1))))
cat(sprintf("Scenarios recovering the truth       : %d/%d\n", sum(res[, "ok"]), nrow(res)))
if (all(res[, "ok"] == 1) && all(abs(res[, "sum"] - 1) < 1e-9))
  cat("\nRESULT: implementation behaves correctly on all five known-answer cases.\n") else
  cat("\nRESULT: FAILED — do not use the fallback; install the coloc package.\n")
