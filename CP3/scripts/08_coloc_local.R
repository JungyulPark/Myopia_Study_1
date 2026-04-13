# Coloc using LOCAL eQTLGen full summary stats
# File: 2019-12-11-cis-eQTLsFDR-ProbeLevel-CohortInfoRemoved-BonferroniAdded.txt.gz

Sys.setenv(OPENGWAS_JWT = "eyJhbGciOiJSUzI1NiIsImtpZCI6ImFwaS1qd3QiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJhcGkub3Blbmd3YXMuaW8iLCJhdWQiOiJhcGkub3Blbmd3YXMuaW8iLCJzdWIiOiJvcGhqeXBAbmF2ZXIuY29tIiwiaWF0IjoxNzc1OTc4NDcwLCJleHAiOjE3NzcxODgwNzB9.TT5w4_5V7kXgMEMwOabASlF8DEoJBay87xqTBv50QASMarmorUm9nX2BbXVkhvGuoXSKC6fJfG_8w_adXc8h1Nq4ECS9YobEst1ej7Qn9LU7oJ7OFx3NepNYKUg3keCDJVZK8_xFrlE9_aToYEe_f5bbhH2HjGOoPcLiA2_xh6UGUNIqbPELbyODpUl35MVwcuLeiNM6fMWssPXfQ3_06ibsqA6T3_uZIOdai7Eqkmo8WhOdp-HIE9M96RXHE9NCJdb7a4G0HtUsGTJYJWMrnSWJ9mKBU77CSCAG2GBnbyjlUzPeylXxRY7ZzZWzwKY2qD0GHFC3waZZ9xs0lAUFWw")

library(data.table)
library(coloc)
library(ieugwasr)

eqtl_file <- "c:/Projectbulid/CP3/data/2019-12-11-cis-eQTLsFDR-ProbeLevel-CohortInfoRemoved-BonferroniAdded.txt.gz"

cat("=== COLOC WITH LOCAL eQTLGen DATA ===\n\n")
cat("Reading eQTLGen file header...\n")

# Read first few lines to understand format
header <- fread(eqtl_file, nrows = 3)
cat("Columns:", paste(names(header), collapse = ", "), "\n\n")

# Gene info for region extraction
genes <- list(
    TGFB1 = list(
        ensembl = "ENSG00000105329",
        gene = "TGFB1",
        chr = 19,
        pos = 41836812,
        window = 500000  # ±500kb
    ),
    LATS2 = list(
        ensembl = "ENSG00000150082",
        gene = "LATS2",
        chr = 13,
        pos = 21546299,
        window = 500000
    )
)

# eQTLGen N = 31,684 (blood)
eqtl_N <- 31684

coloc_results <- list()

for (gene_name in names(genes)) {
    g <- genes[[gene_name]]
    cat(sprintf("\n========== %s (chr%d:%d) ==========\n", gene_name, g$chr, g$pos))
    
    # Step 1: Extract eQTL data for this gene from local file
    cat("Extracting eQTL data from local file...\n")
    
    # Read the gene-specific rows using grep on gene name or ensembl ID
    # eQTLGen format: Pvalue, SNP, SNPChr, SNPPos, AssessedAllele, OtherAllele, Zscore, Gene, GeneSymbol, GeneChr, GenePos, NrCohorts, NrSamples, FDR, BonferroniP
    eqtl_data <- tryCatch({
        # Use fread with grep for efficiency (avoid loading entire file)
        cmd <- sprintf('findstr /C:"%s" "%s"', g$ensembl, gsub("/", "\\\\", eqtl_file))
        
        # Alternative: read full file and filter (slower but more reliable for .gz)
        cat("  Loading full dataset (this may take a few minutes for .gz)...\n")
        
        # Try reading with gene filter
        full <- fread(
            cmd = sprintf('gzip -dc "%s" | findstr "%s"', eqtl_file, g$ensembl),
            header = FALSE,
            sep = "\t"
        )
        
        # If cmd approach fails, try R-native approach
        if (nrow(full) == 0) {
            cat("  Trying R-native reading...\n")
            full <- fread(eqtl_file)
            full <- full[full[[8]] == g$ensembl | full[[9]] == g$gene, ]
        }
        
        full
    }, error = function(e) {
        cat("  Command-line extraction failed, trying R-native...\n")
        cat("  Error was:", conditionMessage(e), "\n")
        
        # Fallback: read entire file
        tryCatch({
            cat("  Reading entire eQTLGen file (may take several minutes)...\n")
            full <- fread(eqtl_file)
            cat("  Total rows:", nrow(full), "\n")
            cat("  Column names:", paste(names(full), collapse=", "), "\n")
            
            # Filter for our gene
            gene_col <- grep("Gene|gene|ENSEMBL", names(full), value = TRUE)
            symbol_col <- grep("Symbol|symbol|GENE", names(full), value = TRUE)
            
            if (length(gene_col) > 0) {
                filtered <- full[full[[gene_col[1]]] == g$ensembl, ]
            } else if (length(symbol_col) > 0) {
                filtered <- full[full[[symbol_col[1]]] == g$gene, ]
            } else {
                # Try common column positions
                filtered <- full[full[[8]] == g$ensembl | full[[9]] == g$gene, ]
            }
            
            cat("  Filtered rows for", gene_name, ":", nrow(filtered), "\n")
            filtered
        }, error = function(e2) {
            cat("  Failed to read file:", conditionMessage(e2), "\n")
            NULL
        })
    })
    
    if (is.null(eqtl_data) || nrow(eqtl_data) == 0) {
        cat("  No eQTL data found for", gene_name, "\n")
        next
    }
    
    cat("  eQTL SNPs for", gene_name, ":", nrow(eqtl_data), "\n")
    
    # Standardize column names
    col_names <- names(eqtl_data)
    cat("  Columns:", paste(col_names, collapse=", "), "\n")
    
    # Map columns based on eQTLGen format
    # Expected: Pvalue, SNP, SNPChr, SNPPos, AssessedAllele, OtherAllele, Zscore, Gene, GeneSymbol, GeneChr, GenePos, NrCohorts, NrSamples, FDR, BonferroniP
    if ("Pvalue" %in% col_names) {
        pval_col <- "Pvalue"
        snp_col <- "SNP"
        z_col <- "Zscore"
        n_col <- "NrSamples"
        chr_col <- "SNPChr"
        pos_col <- "SNPPos"
        ea_col <- "AssessedAllele"
        oa_col <- "OtherAllele"
    } else {
        # Use positional
        names(eqtl_data) <- c("Pvalue", "SNP", "SNPChr", "SNPPos", "AssessedAllele", 
                               "OtherAllele", "Zscore", "Gene", "GeneSymbol", 
                               "GeneChr", "GenePos", "NrCohorts", "NrSamples", 
                               "FDR", "BonferroniP")[1:ncol(eqtl_data)]
        pval_col <- "Pvalue"
        snp_col <- "SNP"
        z_col <- "Zscore"
        n_col <- "NrSamples"
        chr_col <- "SNPChr"
        pos_col <- "SNPPos"
        ea_col <- "AssessedAllele"
        oa_col <- "OtherAllele"
    }
    
    # Convert Zscore to beta/se (approximation for coloc)
    eqtl_data$beta_eqtl <- as.numeric(eqtl_data[[z_col]]) / sqrt(as.numeric(eqtl_data[[n_col]]))
    eqtl_data$se_eqtl <- 1 / sqrt(as.numeric(eqtl_data[[n_col]]))
    eqtl_data$pval_eqtl <- as.numeric(eqtl_data[[pval_col]])
    eqtl_data$snp <- eqtl_data[[snp_col]]
    eqtl_data$pos <- as.numeric(eqtl_data[[pos_col]])
    
    # Filter to ±500kb region
    eqtl_region <- eqtl_data[abs(eqtl_data$pos - g$pos) <= g$window, ]
    cat("  SNPs in ±500kb region:", nrow(eqtl_region), "\n")
    
    if (nrow(eqtl_region) < 10) {
        cat("  Insufficient regional SNPs for coloc\n")
        next
    }
    
    # Step 2: Get GWAS data for these SNPs from OpenGWAS
    cat("  Extracting UKB myopia GWAS data for", nrow(eqtl_region), "SNPs...\n")
    
    gwas_data <- tryCatch({
        associations(
            variants = eqtl_region$snp,
            id = "ukb-b-6353",
            proxies = 0
        )
    }, error = function(e) {
        cat("  GWAS query error:", conditionMessage(e), "\n")
        # Try in batches
        batch_size <- 100
        results <- list()
        for (start in seq(1, nrow(eqtl_region), batch_size)) {
            end <- min(start + batch_size - 1, nrow(eqtl_region))
            batch_snps <- eqtl_region$snp[start:end]
            batch_result <- tryCatch(
                associations(variants = batch_snps, id = "ukb-b-6353", proxies = 0),
                error = function(e) NULL
            )
            if (!is.null(batch_result)) results[[length(results)+1]] <- batch_result
            Sys.sleep(1)  # Rate limiting
        }
        if (length(results) > 0) do.call(rbind, results) else NULL
    })
    
    if (is.null(gwas_data) || nrow(gwas_data) == 0) {
        cat("  No GWAS data retrieved\n")
        next
    }
    cat("  GWAS SNPs retrieved:", nrow(gwas_data), "\n")
    
    # Step 3: Merge eQTL and GWAS
    merged <- merge(
        eqtl_region[, c("snp", "beta_eqtl", "se_eqtl", "pval_eqtl", "pos")],
        gwas_data[, c("rsid", "beta", "se", "p", "n", "eaf")],
        by.x = "snp", by.y = "rsid"
    )
    
    cat("  Merged SNPs:", nrow(merged), "\n")
    
    if (nrow(merged) < 10) {
        cat("  Insufficient merged SNPs\n")
        next
    }
    
    # Step 4: Prepare coloc datasets
    # Remove NAs and invalid values
    merged <- merged[!is.na(merged$beta_eqtl) & !is.na(merged$beta) & 
                     !is.na(merged$eaf) & merged$eaf > 0.01 & merged$eaf < 0.99, ]
    
    cat("  Valid SNPs for coloc:", nrow(merged), "\n")
    
    dataset1 <- list(
        beta = merged$beta_eqtl,
        varbeta = merged$se_eqtl^2,
        snp = merged$snp,
        position = merged$pos,
        type = "quant",
        N = eqtl_N,
        MAF = pmin(merged$eaf, 1 - merged$eaf)
    )
    
    dataset2 <- list(
        beta = merged$beta,
        varbeta = merged$se^2,
        snp = merged$snp,
        position = merged$pos,
        type = "cc",
        N = 460536,
        s = 37362/460536,  # case proportion
        MAF = pmin(merged$eaf, 1 - merged$eaf)
    )
    
    # Step 5: Run coloc
    cat("  Running colocalization...\n")
    result <- tryCatch({
        coloc.abf(dataset1, dataset2)
    }, error = function(e) {
        cat("  Coloc error:", conditionMessage(e), "\n")
        NULL
    })
    
    if (!is.null(result)) {
        cat(sprintf("\n  ===== %s COLOC RESULTS =====\n", gene_name))
        cat(sprintf("  nSNPs:              %d\n", nrow(merged)))
        cat(sprintf("  H0 (no assoc):      %.4f\n", result$summary["PP.H0.abf"]))
        cat(sprintf("  H1 (eQTL only):     %.4f\n", result$summary["PP.H1.abf"]))
        cat(sprintf("  H2 (GWAS only):     %.4f\n", result$summary["PP.H2.abf"]))
        cat(sprintf("  H3 (both, diff):    %.4f\n", result$summary["PP.H3.abf"]))
        cat(sprintf("  H4 (shared causal): %.4f\n", result$summary["PP.H4.abf"]))
        
        h4 <- result$summary["PP.H4.abf"]
        if (h4 > 0.8) {
            cat(sprintf("  ✅ STRONG COLOCALIZATION (H4=%.3f)\n", h4))
        } else if (h4 > 0.5) {
            cat(sprintf("  ⚠️ MODERATE colocalization (H4=%.3f)\n", h4))
        } else {
            cat(sprintf("  ❌ WEAK colocalization (H4=%.3f)\n", h4))
        }
        
        coloc_results[[gene_name]] <- data.frame(
            Gene = gene_name,
            nSNPs = nrow(merged),
            PP.H0 = result$summary["PP.H0.abf"],
            PP.H1 = result$summary["PP.H1.abf"],
            PP.H2 = result$summary["PP.H2.abf"],
            PP.H3 = result$summary["PP.H3.abf"],
            PP.H4 = result$summary["PP.H4.abf"]
        )
    }
}

# Save results
if (length(coloc_results) > 0) {
    coloc_df <- do.call(rbind, coloc_results)
    write.csv(coloc_df, "c:/Projectbulid/CP3/results/coloc_results_local.csv", row.names = FALSE)
    cat("\n✅ Coloc results saved to CP3/results/coloc_results_local.csv\n")
    print(coloc_df)
}

cat("\n=== COLOC ANALYSIS COMPLETE ===\n")
