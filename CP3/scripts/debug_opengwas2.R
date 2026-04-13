Sys.setenv(OPENGWAS_JWT = "eyJhbGciOiJSUzI1NiIsImtpZCI6ImFwaS1qd3QiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJhcGkub3Blbmd3YXMuaW8iLCJhdWQiOiJhcGkub3Blbmd3YXMuaW8iLCJzdWIiOiJvcGhqeXBAbmF2ZXIuY29tIiwiaWF0IjoxNzc1OTc4NDcwLCJleHAiOjE3NzcxODgwNzB9.TT5w4_5V7kXgMEMwOabASlF8DEoJBay87xqTBv50QASMarmorUm9nX2BbXVkhvGuoXSKC6fJfG_8w_adXc8h1Nq4ECS9YobEst1ej7Qn9LU7oJ7OFx3NepNYKUg3keCDJVZK8_xFrlE9_aToYEe_f5bbhH2HjGOoPcLiA2_xh6UGUNIqbPELbyODpUl35MVwcuLeiNM6fMWssPXfQ3_06ibsqA6T3_uZIOdai7Eqkmo8WhOdp-HIE9M96RXHE9NCJdb7a4G0HtUsGTJYJWMrnSWJ9mKBU77CSCAG2GBnbyjlUzPeylXxRY7ZzZWzwKY2qD0GHFC3waZZ9xs0lAUFWw")
library(ieugwasr)
library(dplyr)

res <- gwasinfo()

cat("\n--- Searching for Myopia / Refractive Error GWAS ---\n")
myopia <- res %>% filter(grepl("myopia|refractive error", trait, ignore.case=TRUE)) %>% 
          arrange(desc(sample_size)) %>%
          select(id, trait, sample_size, unit, consortium)
print(head(myopia, 15))

cat("\n--- Checking COMT instruments at p<5e-5 ---\n")
comt <- extract_instruments("eqtl-a-ENSG00000093010", p1=5e-5)
cat("COMT SNPs at p<5e-5:", nrow(comt), "\n")

cat("\n--- Checking TH instruments at p<5e-5 ---\n")
th <- extract_instruments("eqtl-a-ENSG00000180176", p1=5e-5)
cat("TH SNPs at p<5e-5:", nrow(th), "\n")
if(!is.null(th)) print(head(th$SNP, 3))
