import pandas as pd

df = pd.read_csv(r"c:\Projectbulid\CP1\results\Step3_Hub_Gene_Analysis.csv")
df = df.sort_values(by=['Degree', 'Betweenness_Centrality'], ascending=[False, False]).reset_index(drop=True)

receptor_map = {
    'CHRM1': 'Muscarinic', 'CHRM3': 'Muscarinic', 'CHRM5': 'Muscarinic',
    'DRD1': 'Dopaminergic', 'DRD2': 'Dopaminergic',
    'ADRA2A': 'Adrenergic', 'ADRA2C': 'Adrenergic',
    'CHRNA3': 'Nicotinic', 'CHRNA4': 'Nicotinic', 'CHRNB2': 'Nicotinic'
}

with open(r"c:\Projectbulid\manuscript\Supplementary_Table_S1.md", "w", encoding="utf-8") as f:
    f.write("# Supplementary Table S1. Topological properties of 47 intersection genes\n\n")
    f.write("| Hub Rank | Gene Symbol | Degree | Betweenness Centrality | Closeness Centrality | Receptor Class (if any) |\n")
    f.write("|----------|-------------|--------|------------------------|----------------------|-------------------------|\n")
    
    for i, row in df.iterrows():
        gene = row['Gene']
        degree = int(row['Degree'])
        bc = f"{row['Betweenness_Centrality']:.4f}"
        cc = f"{row['Closeness_Centrality']:.4f}"
        
        # Using exact Hub_Rank from CSV for the upper 20
        hub_rank = str(int(row['Hub_Rank'])) if i < 20 else "-"
        
        receptor = receptor_map.get(gene, "")
        
        f.write(f"| {hub_rank} | **{gene}** | {degree} | {bc} | {cc} | {receptor} |\n")

    f.write("\n**Abbreviations:** BC = Betweenness Centrality, CC = Closeness Centrality.\n")
    f.write("Hub rank is provided for the top 20 intersection genes based on targeted pharmacological analysis.\n")
