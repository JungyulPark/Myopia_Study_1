options(opengwas_jwt = "eyJhbGciOiJSUzI1NiIsImtpZCI6ImFwaS1qd3QiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJhcGkub3Blbmd3YXMuaW8iLCJhdWQiOiJhcGkub3Blbmd3YXMuaW8iLCJzdWIiOiJvcGhqeXBAbmF2ZXIuY29tIiwiaWF0IjoxNzc1OTc4NDcwLCJleHAiOjE3NzcxODgwNzB9.TT5w4_5V7kXgMEMwOabASlF8DEoJBay87xqTBv50QASMarmorUm9nX2BbXVkhvGuoXSKC6fJfG_8w_adXc8h1Nq4ECS9YobEst1ej7Qn9LU7oJ7OFx3NepNYKUg3keCDJVZK8_xFrlE9_aToYEe_f5bbhH2HjGOoPcLiA2_xh6UGUNIqbPELbyODpUl35MVwcuLeiNM6fMWssPXfQ3_06ibsqA6T3_uZIOdai7Eqkmo8WhOdp-HIE9M96RXHE9NCJdb7a4G0HtUsGTJYJWMrnSWJ9mKBU77CSCAG2GBnbyjlUzPeylXxRY7ZzZWzwKY2qD0GHFC3waZZ9xs0lAUFWw")
library(TwoSampleMR)
library(ieugwasr)
library(dplyr)

cat("Checking API Token status...\n")
print(user()) 

cat("Searching datasets for eQTLs of TH (Tyrosine hydroxylase)...\n")
res <- gwasinfo()
th_datasets <- res %>% filter(grepl("ENSG00000180176", id) | grepl(" TH ", trait)) %>% select(id, trait, sample_size, pmid, year)
print(head(th_datasets))

drd1_datasets <- res %>% filter(grepl("ENSG00000184845", id) | grepl(" DRD1 ", trait)) %>% select(id, trait, sample_size, pmid)
print(head(drd1_datasets))

cat("\nTesting basic extraction without strict p1 filter...\n")
# Try p=1e-5 to see if anything appears
exp_dat <- extract_instruments("eqtl-a-ENSG00000180176", p1=1e-5)
print(head(exp_dat))
