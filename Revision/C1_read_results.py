"""Read C1 permutation results and compute P-values from saved CSV."""
import pandas as pd
import numpy as np
import networkx as nx
import requests
from itertools import product

INTERSECTION_GENES = [
    "TP53","AKT1","IL6","CTNNB1","TNF","JUN","IL1B","CASP3","EGFR","FOS",
    "MAPK14","PTGS2","MAPK3","MAPK8","RELA","MAPK1","TGFB1","RHOA","EGR1",
    "CDK1","CHRNB2","CHRNA4","NOS2","EDN1","PCNA","CCNE1","CHRNA7","CHRNB4",
    "CHRNA3","CHRM1","DVL2","BAX","CHRM2","NOTCH4","GABRG2","GABRA1","MCM6",
    "CHRM3","GABRB2","CHRM5","DRD2","DRD1","ADRA2C","ADRA2A"
]
HIPPO_YAP_GENES = ["LATS1","LATS2","YAP1","TEAD1","TEAD2","TEAD3","TEAD4",
                   "WWTR1","NF2","SAV1","AMOT","MOB1A"]
RECEPTORS = {
    "Muscarinic": ["CHRM1","CHRM3","CHRM5"],
    "Dopaminergic": ["DRD1","DRD2"],
    "Adrenergic": ["ADRA2A","ADRA2C"],
    "Nicotinic": ["CHRNA3","CHRNA4","CHRNB2"]
}

# --- Load permutation CSV from first run ---
df = pd.read_csv("CP1/revision/C1_permutation_results.csv")
print(f"Loaded {len(df)} permutation results")

# --- Rebuild network (quick STRING call) ---
all_genes = list(set(INTERSECTION_GENES + HIPPO_YAP_GENES))
params = {
    "identifiers": "\r".join(all_genes),
    "species": 9606,
    "required_score": 700,
    "caller_identity": "MLIGHT_revision"
}
resp = requests.get("https://string-db.org/api/json/network", params=params, timeout=60)
data = resp.json()

G = nx.Graph()
G.add_nodes_from(all_genes)
for item in data:
    g1 = item.get("preferredName_A", "")
    g2 = item.get("preferredName_B", "")
    if g1 in all_genes and g2 in all_genes:
        G.add_edge(g1, g2)

print(f"Network: {G.number_of_nodes()} nodes, {G.number_of_edges()} edges")

# --- Compute actual Hippo-YAP convergence ---
all_receptors = []
for cls_genes in RECEPTORS.values():
    all_receptors.extend([g for g in cls_genes if g in G])
target_in_G = [g for g in HIPPO_YAP_GENES if g in G]

print(f"Hippo-YAP nodes in network: {target_in_G}")
print(f"Receptor nodes: {all_receptors}")

distances = []
for r, t in product(all_receptors, target_in_G):
    if r == t:
        continue
    try:
        d = nx.shortest_path_length(G, r, t)
        distances.append(d)
    except nx.NetworkXNoPath:
        pass

actual_n_paths = len(distances)
actual_mean_dist = float(np.mean(distances)) if distances else float("inf")
actual_score = actual_n_paths / actual_mean_dist if actual_mean_dist > 0 else 0

print(f"\nActual Hippo-YAP: n_paths={actual_n_paths}, mean_dist={actual_mean_dist:.3f}, score={actual_score:.2f}")

# --- Empirical P-values from null distribution ---
df_finite = df[df["mean_distance"] < 1e9].copy()
df_finite["score"] = df_finite["n_paths"] / df_finite["mean_distance"]

p_n = float((df["n_paths"] >= actual_n_paths).mean())
p_d = float((df_finite["mean_distance"] <= actual_mean_dist).mean())
p_s = float((df_finite["score"] >= actual_score).mean())

print("\n=== EMPIRICAL P-VALUES ===")
print(f"P(n_paths >= {actual_n_paths}): {p_n:.4f}")
print(f"P(mean_dist <= {actual_mean_dist:.2f}): {p_d:.4f}")
print(f"P(combined score >= {actual_score:.1f}): {p_s:.4f}")
print()
null_mean = float(df["n_paths"].mean())
null_max = int(df["n_paths"].max())
null_dist_mean = float(df_finite["mean_distance"].mean())
print(f"Null distribution: mean n_paths={null_mean:.2f}, max={null_max}")
print(f"Null mean_dist (reachable pathways only): {null_dist_mean:.3f}")

print()
if p_s < 0.05:
    print("RESULT: Hippo-YAP convergence is SIGNIFICANTLY more specific (P={:.4f}).".format(p_s))
    print("Extension Layer finding is NOT a trivial small-world property. Core claim VALIDATED.")
else:
    print("RESULT: NOT significantly different (P={:.4f}). Consider revising core claims.".format(p_s))

# Save report
report = f"""{'='*60}
C1 EXTENSION LAYER PERMUTATION TEST - RESULTS
{'='*60}

Actual Hippo-YAP Convergence:
  Receptor->Hippo-YAP paths: {actual_n_paths}
  Mean shortest distance:    {actual_mean_dist:.3f}
  Combined score:            {actual_score:.2f}

Null Distribution (1000 random KEGG pathways):
  Path count: mean={null_mean:.1f}, max={null_max}
  Mean dist (reachable): {null_dist_mean:.3f}

Empirical P-values:
  P(paths >= {actual_n_paths}):           {p_n:.4f}
  P(distance <= {actual_mean_dist:.2f}):  {p_d:.4f}
  P(score >= {actual_score:.1f}):         {p_s:.4f}

INTERPRETATION:
  {'VALIDATED: Hippo-YAP convergence is pathway-specific (P=' + f'{p_s:.4f})' if p_s < 0.05 else 'NOT VALIDATED: Consider revising Extension Layer claims'}
{'='*60}
"""

with open("CP1/revision/C1_Permutation_Report.txt", "w", encoding="utf-8") as f:
    f.write(report)
print("\nReport saved: CP1/revision/C1_Permutation_Report.txt")
