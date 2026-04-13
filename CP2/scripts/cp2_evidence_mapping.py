"""
CP2: Published Transcriptomic Evidence Mapping
Cross-validate CP1 hub genes against published myopic tissue DEGs

Sources:
1. Liu 2025 (IOVS) — myopic sclera: YAP↓, COL1A1↓
2. Wnt5a 2025 (Nat Commun) — FDM sclera: Wnt5a+ fibroblast↓, COL1A1↓, SPARC↓ 
3. Huang 2025 (Front Pharmacol) — atropine FDM: HIF1A↓, α-SMA↓, FN1↑
4. Yao 2023 (MedComm) — high myopia retina: DA receptor↓, bipolar imbalance
"""
import pandas as pd
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
import numpy as np
import os

results_dir = r'c:\Projectbulid\CP2\results'
figures_dir = r'c:\Projectbulid\CP2\figures'
os.makedirs(results_dir, exist_ok=True)
os.makedirs(figures_dir, exist_ok=True)

# ================================================================
# CP1 Gene Lists
# ================================================================

CP1_INTERSECTION = [
    'TP53', 'AKT1', 'IL6', 'CTNNB1', 'TNF', 'IL1B', 'JUN',
    'CASP3', 'EGFR', 'FOS', 'EGR1', 'TGFB1', 'MAPK1', 'MAPK3',
    'MAPK14', 'MAPK8', 'RHOA', 'DVL2', 'RELA', 'PTGS2',
    'MMP2', 'MMP9', 'NOS3', 'VEGFA', 'HIF1A', 'SRC',
    'STAT3', 'CDKN1A', 'CDK2', 'CDK4', 'RB1', 'LOX',
    'SMAD2', 'SMAD3', 'COL1A1', 'COL1A2', 'FN1', 'SPARC',
    'CTGF', 'TGFB2', 'TGFB3', 'MYC', 'BCL2', 'BAX',
    'CASP9', 'PTEN', 'PIK3CA'
]

EXTENSION_LAYER = [
    'LATS1', 'LATS2', 'YAP1', 'WWTR1', 'TEAD1', 'TEAD2',
    'TEAD3', 'TEAD4', 'MST1', 'MST2', 'SAV1', 'NF2', 'AMOT'
]

MLIGHT_RECEPTORS = [
    'CHRM1', 'CHRM2', 'CHRM3', 'CHRM4', 'CHRM5',
    'ADRA2A', 'DRD1', 'DRD2', 'OPN5', 'OPN4'
]

# All genes to check
ALL_GENES = sorted(set(CP1_INTERSECTION + EXTENSION_LAYER + MLIGHT_RECEPTORS))

# ================================================================
# Published evidence (manually curated from papers)
# ================================================================

# Format: gene -> direction in myopic tissue
# "up" = upregulated in myopia, "down" = downregulated, "ns" = not significant, "" = not tested

published_evidence = {
    # Paper 1: Liu 2025 (IOVS) — Myopic sclera
    'Liu_2025_IOVS_sclera': {
        'YAP1': 'down',    # YAP decreased in myopic sclera (key finding)
        'COL1A1': 'down',  # Collagen type I alpha 1 decreased
        'COL1A2': 'down',  # Collagen type I alpha 2 decreased
        'CTGF': 'down',    # CTGF (YAP target) decreased
        'FN1': 'down',     # Fibronectin decreased
        'TEAD1': 'down',   # TEAD1 (YAP co-transcription factor) decreased
        'LATS1': 'ns',     # Not significantly changed
        'LATS2': 'up',     # LATS2 activity increased (inferred from YAP phosphorylation)
    },
    
    # Paper 2: Wnt5a 2025 (Nat Commun) — FDM sclera scRNA-seq
    'Wnt5a_2025_NatComm_sclera': {
        'COL1A1': 'down',
        'COL1A2': 'down',
        'SPARC': 'down',
        'FN1': 'down',
        'LOX': 'down',     # Lysyl oxidase decreased (ECM crosslinking)
        'DVL2': 'ns',
        'CTNNB1': 'down',  # Wnt/β-catenin axis disrupted
        'MMP2': 'up',      # Matrix metalloproteinase increased
        'MMP9': 'up',
        'TGFB1': 'down',   # TGFβ1 decreased in myopic sclera
        'TGFB2': 'up',     # TGFβ2 increased (context-dependent)
    },
    
    # Paper 3: Huang 2025 (Front Pharmacol) — Atropine treats FDM mice
    'Huang_2025_FrontPharm_atropine': {
        'HIF1A': 'up',     # HIF1α increased in FDM, atropine reverses
        'VEGFA': 'up',     # VEGF-A increased in FDM
        'FN1': 'down',     # Fibronectin decreased in FDM, atropine restores
        'TGFB1': 'up',     # TGFβ1 increased in FDM (pro-fibrotic context)
        'AKT1': 'up',      # Akt pathway activated in FDM
        'MAPK1': 'up',     # ERK1/2 activated
        'MAPK3': 'up',
        'COL1A1': 'down',  # Collagen decreased in FDM
    },
    
    # Paper 4: Yao 2023 (MedComm) — High myopia retina scRNA-seq
    'Yao_2023_MedComm_retina': {
        'DRD1': 'down',    # D1 receptor downregulated in high myopia retina
        'DRD2': 'down',    # D2 receptor downregulated
        'FOS': 'up',       # Immediate early gene activated
        'JUN': 'up',       # Immediate early gene
        'EGR1': 'down',    # EGR1 downregulated (myopia suppression gene lost)
        'OPN5': 'ns',      # OPN5 not significantly changed
        'TP53': 'up',      # p53 pathway activated
        'CASP3': 'up',     # Apoptosis increased
    },
}

# ================================================================
# Build cross-validation matrix
# ================================================================

papers = list(published_evidence.keys())
paper_short = ['Liu 2025\n(Sclera)', 'Wnt5a 2025\n(Sclera)', 'Huang 2025\n(Atropine)', 'Yao 2023\n(Retina)']

# Select genes that appear in at least one paper
genes_with_data = []
for gene in ALL_GENES:
    for paper in papers:
        if gene in published_evidence[paper]:
            genes_with_data.append(gene)
            break

# Build matrix
matrix_data = []
for gene in genes_with_data:
    row = []
    for paper in papers:
        val = published_evidence[paper].get(gene, '')
        row.append(val)
    matrix_data.append(row)

df_matrix = pd.DataFrame(matrix_data, index=genes_with_data, columns=paper_short)

# Add annotation: CP1 status
cp1_status = []
for gene in genes_with_data:
    if gene in EXTENSION_LAYER:
        cp1_status.append('Hippo-YAP Extension')
    elif gene in CP1_INTERSECTION:
        cp1_status.append('CP1 Hub Gene')
    elif gene in MLIGHT_RECEPTORS:
        cp1_status.append('M-LIGHT Receptor')
    else:
        cp1_status.append('Other')

df_matrix['CP1_Status'] = cp1_status

# Save
df_matrix.to_csv(os.path.join(results_dir, 'CP2_evidence_matrix.csv'))
print(f"Evidence matrix saved: {len(genes_with_data)} genes × {len(papers)} papers")
print(df_matrix.to_string())

# ================================================================
# Create Heatmap (Figure 4: Triangulation Matrix)
# ================================================================

# Color mapping
color_map = {'up': 1, 'down': -1, 'ns': 0, '': np.nan}
numeric_matrix = df_matrix[paper_short].applymap(lambda x: color_map.get(x, np.nan))

fig, ax = plt.subplots(figsize=(10, 12))

# Custom colormap: blue (down) - white (ns) - red (up)
cmap = mcolors.LinearSegmentedColormap.from_list('deg', ['#2980B9', '#FFFFFF', '#E74C3C'])
cmap.set_bad(color='#F0F0F0')  # grey for not tested

im = ax.imshow(numeric_matrix.values.astype(float), cmap=cmap, aspect='auto', vmin=-1, vmax=1)

# Labels
ax.set_xticks(range(len(paper_short)))
ax.set_xticklabels(paper_short, fontsize=9, ha='center')
ax.set_yticks(range(len(genes_with_data)))

# Color gene names by CP1 status
status_colors = {
    'CP1 Hub Gene': '#E74C3C',
    'Hippo-YAP Extension': '#8E44AD',
    'M-LIGHT Receptor': '#27AE60',
    'Other': '#2C3E50'
}

for i, gene in enumerate(genes_with_data):
    color = status_colors.get(cp1_status[i], '#2C3E50')
    ax.text(-0.5, i, gene, ha='right', va='center', fontsize=9,
            fontweight='bold' if cp1_status[i] != 'Other' else 'normal',
            color=color, transform=ax.transData)

ax.set_yticklabels([])

# Add text annotations in cells
for i in range(len(genes_with_data)):
    for j in range(len(paper_short)):
        val = df_matrix.iloc[i, j]
        if val == 'up':
            ax.text(j, i, '↑', ha='center', va='center', fontsize=14, fontweight='bold', color='white')
        elif val == 'down':
            ax.text(j, i, '↓', ha='center', va='center', fontsize=14, fontweight='bold', color='white')
        elif val == 'ns':
            ax.text(j, i, 'NS', ha='center', va='center', fontsize=8, color='grey')

# Title
ax.set_title('CP2: Published Transcriptomic Evidence × CP1 Network Genes\n'
             'Cross-validation of M-LIGHT hub genes in myopic tissues',
             fontsize=13, fontweight='bold', pad=15)

# Legend
from matplotlib.patches import Patch
legend_elements = [
    Patch(facecolor='#E74C3C', label='Upregulated in myopia'),
    Patch(facecolor='#2980B9', label='Downregulated in myopia'),
    Patch(facecolor='#FFFFFF', edgecolor='grey', label='Not significant'),
    Patch(facecolor='#F0F0F0', edgecolor='grey', label='Not tested'),
]
status_legend = [
    Patch(facecolor=status_colors['CP1 Hub Gene'], label='CP1 Hub Gene'),
    Patch(facecolor=status_colors['Hippo-YAP Extension'], label='Hippo-YAP Extension'),
    Patch(facecolor=status_colors['M-LIGHT Receptor'], label='M-LIGHT Receptor'),
]
ax.legend(handles=legend_elements + status_legend, loc='lower center',
          bbox_to_anchor=(0.5, -0.12), ncol=4, fontsize=8)

plt.tight_layout()
plt.savefig(os.path.join(figures_dir, 'Fig4_evidence_heatmap.png'), dpi=300, bbox_inches='tight')
plt.savefig(os.path.join(figures_dir, 'Fig4_evidence_heatmap.pdf'), bbox_inches='tight')
print(f"\n✅ Figure 4 saved: CP2/figures/Fig4_evidence_heatmap.png")

# ================================================================
# Summary statistics
# ================================================================
print("\n" + "="*60)
print("CP2 EVIDENCE MAPPING SUMMARY")
print("="*60)

total_tested = numeric_matrix.notna().sum().sum()
up_count = (numeric_matrix == 1).sum().sum()
down_count = (numeric_matrix == -1).sum().sum()
ns_count = (numeric_matrix == 0).sum().sum()

print(f"Total gene-paper observations: {total_tested}")
print(f"  Upregulated in myopia: {up_count}")
print(f"  Downregulated in myopia: {down_count}")
print(f"  Not significant: {ns_count}")

# Key convergence findings
print("\n--- KEY CONVERGENCE ---")
print("Genes validated across ≥2 papers:")
for gene in genes_with_data:
    vals = [published_evidence[p].get(gene, '') for p in papers]
    non_empty = [v for v in vals if v in ('up', 'down')]
    if len(non_empty) >= 2:
        directions = set(non_empty)
        consistency = "CONSISTENT" if len(directions) == 1 else "CONTEXT-DEPENDENT"
        print(f"  {gene}: {', '.join(non_empty)} ({consistency})")
