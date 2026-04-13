#!/usr/bin/env python3
"""
CP2: scRNA-seq Re-analysis Pipeline
M-LIGHT Myopia Research Program

Objective: Map CP1 hub genes and Hippo-YAP cascade genes to specific
cell types in myopia-relevant ocular tissues.

Datasets:
  1. GSE228370 — Human developing eye scRNA-seq (KDELR3 paper, 22 samples)
  2. CRA025141 — Mouse scleral scRNA-seq (Wnt5a paper, GSA)
  3. GSE243413 — Mouse retina atlas (reference, 323K cells)

Dependencies: scanpy, anndata, leidenalg, matplotlib, pandas, numpy
"""

import os
import sys
import glob
import tarfile
import gzip
import warnings
warnings.filterwarnings('ignore')

import numpy as np
import pandas as pd
import scanpy as sc
import anndata as ad
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

# Configuration
sc.settings.verbosity = 2
sc.settings.set_figure_params(dpi=150, facecolor='white', frameon=False)

BASE_DIR = r'c:\Projectbulid\CP2'
DATA_DIR = os.path.join(BASE_DIR, 'data')
RESULTS_DIR = os.path.join(BASE_DIR, 'results')
FIGURES_DIR = os.path.join(BASE_DIR, 'figures')
os.makedirs(RESULTS_DIR, exist_ok=True)
os.makedirs(FIGURES_DIR, exist_ok=True)

# ============================================================
# M-LIGHT Gene Lists (from CP1)
# ============================================================

# CP1 Hub genes (intersection)
CP1_HUB_GENES = [
    'TP53', 'AKT1', 'IL6', 'CTNNB1', 'TNF', 'IL1B', 'JUN',
    'CASP3', 'EGFR', 'FOS', 'EGR1', 'TGFB1', 'MAPK1', 'MAPK3',
    'MAPK14', 'MAPK8', 'RHOA', 'DVL2', 'RELA', 'PTGS2'
]

# Hippo-YAP cascade (Extension Layer)
HIPPO_YAP_GENES = [
    'LATS1', 'LATS2', 'YAP1', 'WWTR1', 'TEAD1', 'TEAD2',
    'TEAD3', 'TEAD4', 'MST1', 'MST2', 'SAV1', 'NF2', 'AMOT',
    'STK3', 'STK4',  # MST1/2 aliases
]

# M-LIGHT hypothesis genes
MLIGHT_GENES = {
    'Light_sensing': ['OPN5', 'OPN4'],
    'Dopamine': ['TH', 'DDC', 'DRD1', 'DRD2', 'COMT', 'SLC6A3'],
    'Muscarinic': ['CHRM1', 'CHRM2', 'CHRM3', 'CHRM4', 'CHRM5'],
    'Hippo_YAP': ['LATS1', 'LATS2', 'YAP1', 'WWTR1', 'TEAD1', 'TEAD2',
                  'TEAD3', 'TEAD4', 'MST1', 'MST2', 'SAV1', 'NF2', 'AMOT'],
    'IEG': ['FOS', 'JUN', 'EGR1', 'JUNB', 'FOSB'],
    'ECM': ['COL1A1', 'COL1A2', 'FN1', 'MMP2', 'MMP9', 'LOX',
            'TGFB1', 'CTGF', 'SPARC'],
    'HIF_Hypoxia': ['HIF1A', 'VEGFA', 'LDHA', 'NOS2'],
    'Convergence_bridge': ['CTNNB1', 'DVL2', 'EGFR', 'AKT1', 'TP53'],
}

ALL_MLIGHT_GENES = list(set(
    CP1_HUB_GENES + HIPPO_YAP_GENES +
    [g for genes in MLIGHT_GENES.values() for g in genes]
))


# ============================================================
# STEP 1: DATA LOADING
# ============================================================

def extract_geo_tar(tar_path, out_dir):
    """Extract GEO tar file into per-sample directories."""
    print(f"\n[1] Extracting {os.path.basename(tar_path)}...")
    
    with tarfile.open(tar_path, 'r') as tar:
        tar.extractall(out_dir)
    
    # List extracted files
    files = os.listdir(out_dir)
    print(f"  Extracted {len(files)} files")
    
    # Group by GSM sample ID
    samples = {}
    for f in files:
        if f.endswith('.gz'):
            # Typical format: GSMxxxxxxx_samplename_barcodes.tsv.gz
            parts = f.split('_')
            gsm = parts[0] if parts[0].startswith('GSM') else None
            if gsm:
                samples.setdefault(gsm, []).append(f)
    
    print(f"  Found {len(samples)} samples: {list(samples.keys())[:5]}...")
    return samples


def load_10x_from_geo(data_dir, sample_dict=None):
    """Load 10x data from extracted GEO supplementary files.
    Handles various GEO file naming conventions.
    """
    adatas = []
    
    # Try loading as pre-made h5ad first
    h5ad_files = glob.glob(os.path.join(data_dir, '*.h5ad'))
    if h5ad_files:
        for f in h5ad_files:
            print(f"  Loading h5ad: {os.path.basename(f)}")
            adata = sc.read_h5ad(f)
            adatas.append(adata)
        return adatas
    
    # Try loading as h5 (CellRanger output)
    h5_files = glob.glob(os.path.join(data_dir, '*filtered*h5'))
    if h5_files:
        for f in h5_files:
            print(f"  Loading h5: {os.path.basename(f)}")
            adata = sc.read_10x_h5(f)
            adatas.append(adata)
        return adatas
    
    # Try loading as mtx + barcodes + features/genes
    mtx_files = glob.glob(os.path.join(data_dir, '*.mtx.gz')) + \
                glob.glob(os.path.join(data_dir, '*.mtx'))
    
    if mtx_files:
        # Single sample with matrix.mtx in the directory
        for mtx in mtx_files:
            parent = os.path.dirname(mtx)
            print(f"  Loading 10x mtx: {os.path.basename(mtx)}")
            try:
                adata = sc.read_10x_mtx(parent)
                adatas.append(adata)
            except Exception as e:
                print(f"    Failed: {e}")
    
    # Handle GEO-style flat files (GSMxxx_barcodes.tsv.gz, etc.)
    if not adatas and sample_dict:
        for gsm, files in sample_dict.items():
            print(f"  Loading sample {gsm}...")
            # Create temp dir with proper names
            tmp_dir = os.path.join(data_dir, f'_tmp_{gsm}')
            os.makedirs(tmp_dir, exist_ok=True)
            
            for f in files:
                src = os.path.join(data_dir, f)
                f_lower = f.lower()
                if 'barcode' in f_lower:
                    dst = os.path.join(tmp_dir, 'barcodes.tsv.gz')
                elif 'feature' in f_lower or 'gene' in f_lower:
                    dst = os.path.join(tmp_dir, 'features.tsv.gz')
                elif 'matrix' in f_lower or 'mtx' in f_lower:
                    dst = os.path.join(tmp_dir, 'matrix.mtx.gz')
                else:
                    continue
                
                if not os.path.exists(dst):
                    import shutil
                    shutil.copy2(src, dst)
            
            try:
                adata = sc.read_10x_mtx(tmp_dir)
                adata.obs['sample'] = gsm
                adatas.append(adata)
            except Exception as e:
                print(f"    Failed: {e}")
    
    return adatas


# ============================================================
# STEP 2: PREPROCESSING
# ============================================================

def preprocess(adata, sample_name='sample'):
    """Standard scRNA-seq preprocessing pipeline."""
    print(f"\n[2] Preprocessing {sample_name}...")
    print(f"  Input: {adata.n_obs} cells × {adata.n_vars} genes")
    
    # Make variable names unique
    adata.var_names_make_unique()
    
    # Basic QC metrics
    adata.var['mt'] = adata.var_names.str.startswith(('MT-', 'mt-'))
    adata.var['ribo'] = adata.var_names.str.startswith(('RPS', 'RPL', 'Rps', 'Rpl'))
    sc.pp.calculate_qc_metrics(adata, qc_vars=['mt', 'ribo'],
                                percent_top=None, log1p=False, inplace=True)
    
    # QC filtering
    n_before = adata.n_obs
    sc.pp.filter_cells(adata, min_genes=200)
    sc.pp.filter_cells(adata, max_genes=6000)
    adata = adata[adata.obs.pct_counts_mt < 20, :].copy()
    sc.pp.filter_genes(adata, min_cells=3)
    print(f"  After QC: {adata.n_obs} cells ({n_before - adata.n_obs} removed)")
    
    # Store raw
    adata.raw = adata.copy()
    
    # Normalize
    sc.pp.normalize_total(adata, target_sum=1e4)
    sc.pp.log1p(adata)
    
    # HVG selection
    sc.pp.highly_variable_genes(adata, n_top_genes=3000, flavor='seurat_v3',
                                 layer='counts' if 'counts' in adata.layers else None)
    
    # Add M-LIGHT genes to HVG (force include)
    for gene in ALL_MLIGHT_GENES:
        if gene in adata.var_names:
            adata.var.loc[gene, 'highly_variable'] = True
    
    n_hvg = adata.var.highly_variable.sum()
    n_mlight = sum(1 for g in ALL_MLIGHT_GENES if g in adata.var_names)
    print(f"  HVGs: {n_hvg} (including {n_mlight} M-LIGHT genes)")
    
    # Scale + PCA
    sc.pp.scale(adata, max_value=10)
    sc.pp.pca(adata, n_comps=50)
    
    # Neighbors + UMAP
    sc.pp.neighbors(adata, n_neighbors=15, n_pcs=30)
    sc.tl.umap(adata)
    
    # Clustering
    sc.tl.leiden(adata, resolution=0.8, key_added='leiden')
    print(f"  Clusters: {adata.obs['leiden'].nunique()}")
    
    return adata


# ============================================================
# STEP 3: M-LIGHT GENE MAPPING
# ============================================================

def mlight_analysis(adata, dataset_name='dataset'):
    """Map M-LIGHT genes to cell types/clusters."""
    print(f"\n[3] M-LIGHT gene mapping for {dataset_name}...")
    
    # Check which M-LIGHT genes are present
    present_genes = [g for g in ALL_MLIGHT_GENES if g in adata.raw.var_names]
    missing_genes = [g for g in ALL_MLIGHT_GENES if g not in adata.raw.var_names]
    print(f"  Present: {len(present_genes)}/{len(ALL_MLIGHT_GENES)} M-LIGHT genes")
    if missing_genes:
        print(f"  Missing: {missing_genes[:10]}...")
    
    # DotPlot: M-LIGHT genes × clusters
    if present_genes:
        try:
            fig, ax = plt.subplots(figsize=(20, 8))
            sc.pl.dotplot(adata, present_genes[:30], groupby='leiden',
                         show=False, ax=ax)
            plt.title(f'{dataset_name}: M-LIGHT Gene Expression by Cluster')
            plt.tight_layout()
            plt.savefig(os.path.join(FIGURES_DIR, f'{dataset_name}_mlight_dotplot.png'),
                       dpi=200, bbox_inches='tight')
            plt.close()
            print(f"  ✅ Dotplot saved")
        except Exception as e:
            print(f"  Dotplot error: {e}")
    
    # Hippo-YAP expression UMAP
    hippo_present = [g for g in HIPPO_YAP_GENES if g in adata.raw.var_names]
    if hippo_present:
        try:
            sc.pl.umap(adata, color=hippo_present[:6], ncols=3,
                      save=f'_{dataset_name}_hippo_yap.png', show=False)
            print(f"  ✅ Hippo-YAP UMAP saved")
        except Exception as e:
            print(f"  Hippo UMAP error: {e}")
    
    # CP1 Hub gene expression
    hub_present = [g for g in CP1_HUB_GENES if g in adata.raw.var_names]
    if hub_present:
        try:
            sc.pl.umap(adata, color=hub_present[:6], ncols=3,
                      save=f'_{dataset_name}_cp1_hubs.png', show=False)
            print(f"  ✅ CP1 Hub UMAP saved")
        except Exception as e:
            print(f"  Hub UMAP error: {e}")
    
    # Score cells for each M-LIGHT pathway
    results = {}
    for pathway, genes in MLIGHT_GENES.items():
        genes_present = [g for g in genes if g in adata.raw.var_names]
        if len(genes_present) >= 2:
            score_name = f'score_{pathway}'
            sc.tl.score_genes(adata, genes_present, score_name=score_name)
            
            # Mean score per cluster
            scores = adata.obs.groupby('leiden')[score_name].mean()
            top_cluster = scores.idxmax()
            results[pathway] = {
                'n_genes': len(genes_present),
                'top_cluster': top_cluster,
                'top_score': scores.max(),
                'genes': genes_present,
            }
            print(f"  {pathway}: top cluster={top_cluster}, score={scores.max():.3f}")
    
    # Save pathway scores
    if results:
        df = pd.DataFrame(results).T
        df.to_csv(os.path.join(RESULTS_DIR, f'{dataset_name}_mlight_scores.csv'))
    
    return adata, results


# ============================================================
# STEP 4: DIFFERENTIAL EXPRESSION
# ============================================================

def differential_expression(adata, dataset_name='dataset'):
    """Rank genes per cluster, check M-LIGHT gene enrichment."""
    print(f"\n[4] Differential expression for {dataset_name}...")
    
    # Wilcoxon rank-sum test per cluster
    sc.tl.rank_genes_groups(adata, 'leiden', method='wilcoxon')
    
    # Check if any M-LIGHT gene is a top DEG
    mlight_degs = []
    n_clusters = adata.obs['leiden'].nunique()
    
    for cluster in range(n_clusters):
        top_genes = pd.DataFrame(sc.get.rank_genes_groups_df(adata, group=str(cluster)))
        
        for gene in ALL_MLIGHT_GENES:
            match = top_genes[top_genes['names'] == gene]
            if len(match) > 0:
                row = match.iloc[0]
                if row['pvals_adj'] < 0.05 and abs(row['logfoldchanges']) > 0.5:
                    mlight_degs.append({
                        'cluster': cluster,
                        'gene': gene,
                        'logFC': row['logfoldchanges'],
                        'pval_adj': row['pvals_adj'],
                        'pathway': next((k for k, v in MLIGHT_GENES.items() if gene in v), 'CP1_Hub'),
                    })
    
    if mlight_degs:
        deg_df = pd.DataFrame(mlight_degs)
        deg_df.to_csv(os.path.join(RESULTS_DIR, f'{dataset_name}_mlight_DEGs.csv'), index=False)
        print(f"  Found {len(mlight_degs)} M-LIGHT DEGs across {deg_df['cluster'].nunique()} clusters")
        print(f"  Top DEGs: {deg_df.sort_values('pval_adj').head(10)['gene'].tolist()}")
    else:
        print(f"  No significant M-LIGHT DEGs found")
    
    return adata


# ============================================================
# MAIN
# ============================================================

def main():
    print("=" * 70)
    print("CP2: scRNA-seq Re-analysis Pipeline")
    print("M-LIGHT Myopia Research Program")
    print("=" * 70)
    
    # Check which datasets are available
    datasets_available = []
    
    # GSE228370
    tar_228370 = os.path.join(DATA_DIR, 'GSE228370', 'GSE228370_RAW.tar')
    if os.path.exists(tar_228370):
        print(f"\n✅ GSE228370 available ({os.path.getsize(tar_228370)/1024/1024:.0f} MB)")
        datasets_available.append('GSE228370')
    else:
        print(f"\n⏳ GSE228370 not yet downloaded")
    
    # GSE243413 (mouse retina atlas)
    tar_243413 = os.path.join(DATA_DIR, 'GSE243413', 'GSE243413_RAW.tar')
    if os.path.exists(tar_243413):
        datasets_available.append('GSE243413')
    
    # Process available datasets
    for ds in datasets_available:
        print(f"\n{'='*50}")
        print(f"Processing {ds}...")
        print('='*50)
        
        ds_dir = os.path.join(DATA_DIR, ds)
        tar_file = os.path.join(ds_dir, f'{ds}_RAW.tar')
        
        # Step 1: Extract
        samples = extract_geo_tar(tar_file, ds_dir)
        
        # Step 2: Load
        adatas = load_10x_from_geo(ds_dir, samples)
        
        if not adatas:
            print(f"  ⚠️ Could not load data for {ds}")
            continue
        
        # Concatenate samples
        if len(adatas) > 1:
            adata = ad.concat(adatas, join='outer', label='sample', index_unique='-')
        else:
            adata = adatas[0]
        
        # Step 3: Preprocess
        adata = preprocess(adata, ds)
        
        # Step 4: M-LIGHT mapping
        adata, scores = mlight_analysis(adata, ds)
        
        # Step 5: DE analysis
        adata = differential_expression(adata, ds)
        
        # Save processed h5ad
        out_h5ad = os.path.join(RESULTS_DIR, f'{ds}_processed.h5ad')
        adata.write(out_h5ad)
        print(f"\n  ✅ Saved: {out_h5ad}")
    
    if not datasets_available:
        print("\n⏳ No datasets downloaded yet. Run download script first.")
        print("  python /tmp/download_geo.py")
    
    print("\n" + "=" * 70)
    print("CP2 PIPELINE READY")
    print("=" * 70)


if __name__ == '__main__':
    main()
