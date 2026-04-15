#!/usr/bin/env python3
"""
C1_Permutation_Test.py
======================
Extension Layer Permutation Test for IOVS Revision

PURPOSE: Test whether 4-receptor convergence on Hippo-YAP is specific
         or a trivial property of PPI network topology ("small world").

METHOD:
  1. Build the 44-node intersection PPI network from STRING data
  2. For actual Hippo-YAP genes: compute shortest paths from 4 receptor classes
  3. For 1,000 random KEGG pathways: compute same shortest paths
  4. Calculate empirical P-value: proportion of random pathways with
     equal or more paths / equal or shorter distance than Hippo-YAP

OUTPUT:
  - Console: summary statistics + empirical P-value
  - Figures: null distribution histogram with Hippo-YAP annotated
  - CSV: full permutation results

REQUIREMENTS:
  pip install networkx requests matplotlib pandas numpy

USAGE:
  python C1_Permutation_Test.py

NOTE: Requires internet access (KEGG REST API + STRING API)
"""

import os
import json
import time
import random
import requests
import numpy as np
import pandas as pd
import networkx as nx
import matplotlib.pyplot as plt
from collections import defaultdict
from itertools import product

# ============================================================
# CONFIGURATION
# ============================================================
OUTPUT_DIR = "CP1/revision"
os.makedirs(OUTPUT_DIR, exist_ok=True)

N_PERMUTATIONS = 1000
RANDOM_SEED = 42
random.seed(RANDOM_SEED)
np.random.seed(RANDOM_SEED)

# STRING confidence threshold
STRING_CONF = 700  # 0.700

# 44 connected intersection genes (from verified Cytoscape data)
INTERSECTION_GENES = [
    "TP53","AKT1","IL6","CTNNB1","TNF","JUN","IL1B","CASP3","EGFR","FOS",
    "MAPK14","PTGS2","MAPK3","MAPK8","RELA","MAPK1","TGFB1","RHOA","EGR1",
    "CDK1","CHRNB2","CHRNA4","NOS2","EDN1","PCNA","CCNE1","CHRNA7","CHRNB4",
    "CHRNA3","CHRM1","DVL2","BAX","CHRM2","NOTCH4","GABRG2","GABRA1","MCM6",
    "CHRM3","GABRB2","CHRM5","DRD2","DRD1","ADRA2C","ADRA2A"
]

# 3 singletons (excluded from PPI but kept for reference)
SINGLETONS = ["CHRM4", "ACHE", "ADRA2B"]

# Receptor classes (nodes IN the intersection network)
RECEPTORS = {
    "Muscarinic": ["CHRM1", "CHRM3", "CHRM5"],
    "Dopaminergic": ["DRD1", "DRD2"],
    "Adrenergic": ["ADRA2A", "ADRA2C"],
    "Nicotinic": ["CHRNA3", "CHRNA4", "CHRNB2"]
}

# Actual Hippo-YAP Extension Layer genes
HIPPO_YAP_GENES = [
    "LATS1", "LATS2", "YAP1", "TEAD1", "TEAD2", "TEAD3", "TEAD4",
    "WWTR1", "NF2", "SAV1", "AMOT", "MOB1A"
]

# ============================================================
# STEP 1: Build PPI Network from STRING
# ============================================================
def build_network_from_string():
    """Fetch STRING interactions for intersection genes + Hippo-YAP genes."""
    
    all_genes = INTERSECTION_GENES + HIPPO_YAP_GENES
    all_genes_unique = list(set(all_genes))
    
    print(f"[1/5] Fetching STRING interactions for {len(all_genes_unique)} genes...")
    
    # STRING API
    string_url = "https://string-db.org/api/json/network"
    
    # Query in batches if needed
    params = {
        "identifiers": "%0d".join(all_genes_unique),
        "species": 9606,  # Homo sapiens
        "required_score": STRING_CONF,
        "caller_identity": "MLIGHT_revision"
    }
    
    try:
        response = requests.get(string_url, params=params, timeout=60)
        response.raise_for_status()
        data = response.json()
    except Exception as e:
        print(f"  STRING API failed: {e}")
        print("  Falling back to local file if available...")
        return build_network_from_local_file()
    
    # Build networkx graph
    G = nx.Graph()
    G.add_nodes_from(all_genes_unique)
    
    edge_count = 0
    for interaction in data:
        g1 = interaction.get("preferredName_A", "")
        g2 = interaction.get("preferredName_B", "")
        score = interaction.get("score", 0)
        if g1 in all_genes_unique and g2 in all_genes_unique and score >= STRING_CONF/1000:
            G.add_edge(g1, g2, weight=score)
            edge_count += 1
    
    print(f"  Network: {G.number_of_nodes()} nodes, {edge_count} edges")
    return G


def build_network_from_local_file():
    """Fallback: build from local STRING export if API fails."""
    # Try to find local STRING file
    possible_paths = [
        "CP1/data/Step3_STRING_interactions.csv",
        "CP1/Step3_STRING_interactions.csv",
        "string_interactions.tsv"
    ]
    
    for path in possible_paths:
        if os.path.exists(path):
            print(f"  Using local file: {path}")
            df = pd.read_csv(path, sep=None, engine='python')
            G = nx.Graph()
            G.add_nodes_from(INTERSECTION_GENES + HIPPO_YAP_GENES)
            for _, row in df.iterrows():
                g1 = str(row.iloc[0]).strip()
                g2 = str(row.iloc[1]).strip()
                G.add_edge(g1, g2)
            return G
    
    print("  ERROR: No STRING data available. Please run with internet or provide local file.")
    print("  Expected file: CP1/data/Step3_STRING_interactions.csv")
    raise FileNotFoundError("No STRING interaction data found")


# ============================================================
# STEP 2: Compute Convergence Metrics
# ============================================================
def compute_convergence(G, target_genes):
    """
    Compute convergence metrics from 4 receptor classes to target genes.
    
    Returns:
        n_paths: total number of receptor→target shortest paths that exist
        mean_dist: mean shortest path distance across all reachable pairs
        min_dist: minimum shortest path distance
    """
    all_receptors = []
    for cls_genes in RECEPTORS.values():
        all_receptors.extend([g for g in cls_genes if g in G])
    
    target_in_G = [g for g in target_genes if g in G]
    
    if not all_receptors or not target_in_G:
        return 0, float('inf'), float('inf')
    
    distances = []
    n_paths = 0
    
    for receptor, target in product(all_receptors, target_in_G):
        if receptor == target:
            continue
        try:
            d = nx.shortest_path_length(G, receptor, target)
            distances.append(d)
            n_paths += 1
        except nx.NetworkXNoPath:
            pass
    
    if not distances:
        return 0, float('inf'), float('inf')
    
    return n_paths, np.mean(distances), np.min(distances)


# ============================================================
# STEP 3: Get Random KEGG Pathways
# ============================================================
def get_kegg_pathways():
    """Fetch all human KEGG pathways and their gene lists."""
    
    print("[2/5] Fetching KEGG human pathways...")
    
    # Get pathway list
    try:
        resp = requests.get("https://rest.kegg.jp/list/pathway/hsa", timeout=30)
        resp.raise_for_status()
    except Exception as e:
        print(f"  KEGG API failed: {e}")
        print("  Using fallback random gene sampling instead.")
        return None
    
    pathways = {}
    for line in resp.text.strip().split("\n"):
        parts = line.split("\t")
        if len(parts) >= 2:
            pw_id = parts[0].replace("path:", "")
            pw_name = parts[1].split(" - ")[0].strip()
            pathways[pw_id] = {"name": pw_name, "genes": []}
    
    print(f"  Found {len(pathways)} KEGG human pathways")
    
    # Get genes for each pathway (this takes a while)
    print("  Fetching gene lists (this may take 5-10 minutes)...")
    
    for i, (pw_id, pw_info) in enumerate(pathways.items()):
        if i % 50 == 0:
            print(f"    Progress: {i}/{len(pathways)} pathways...")
        
        try:
            resp = requests.get(f"https://rest.kegg.jp/link/hsa/{pw_id}", timeout=15)
            if resp.status_code == 200:
                genes = []
                for line in resp.text.strip().split("\n"):
                    parts = line.split("\t")
                    if len(parts) >= 2:
                        gene_id = parts[1].replace("hsa:", "")
                        genes.append(gene_id)
                pw_info["genes"] = genes
            time.sleep(0.35)  # Rate limiting
        except:
            continue
    
    # Convert KEGG gene IDs to symbols using KEGG API
    print("  Converting gene IDs to symbols...")
    gene_id_to_symbol = {}
    
    # Collect all unique gene IDs
    all_ids = set()
    for pw_info in pathways.values():
        all_ids.update(pw_info["genes"])
    
    # Batch convert (10 at a time)
    id_list = list(all_ids)
    for i in range(0, len(id_list), 10):
        batch = id_list[i:i+10]
        query = "+".join([f"hsa:{gid}" for gid in batch])
        try:
            resp = requests.get(f"https://rest.kegg.jp/list/{query}", timeout=15)
            if resp.status_code == 200:
                for line in resp.text.strip().split("\n"):
                    parts = line.split("\t")
                    if len(parts) >= 2:
                        gid = parts[0].replace("hsa:", "")
                        # Symbol is usually the first word before semicolon
                        symbol = parts[1].split(",")[0].split(";")[0].strip()
                        gene_id_to_symbol[gid] = symbol
            time.sleep(0.2)
        except:
            continue
    
    # Replace IDs with symbols
    for pw_info in pathways.values():
        pw_info["genes"] = [gene_id_to_symbol.get(gid, gid) for gid in pw_info["genes"]]
    
    # Filter: keep pathways with 5-50 genes (similar to Hippo-YAP size)
    filtered = {k: v for k, v in pathways.items() 
                if 5 <= len(v["genes"]) <= 50 and len(v["genes"]) > 0}
    
    print(f"  Filtered to {len(filtered)} pathways (5-50 genes each)")
    
    # Save for reuse
    cache_path = os.path.join(OUTPUT_DIR, "kegg_pathways_cache.json")
    with open(cache_path, 'w') as f:
        json.dump(filtered, f, indent=2)
    print(f"  Cached to {cache_path}")
    
    return filtered


def get_random_gene_sets(n_sets=1000, set_size=12):
    """Fallback: if KEGG fails, use random subsets of all human genes in STRING."""
    print("  Generating random gene sets as fallback...")
    
    # Use all genes in STRING human PPI as the universe
    try:
        resp = requests.get(
            "https://string-db.org/api/json/network",
            params={
                "identifiers": "%0d".join(INTERSECTION_GENES[:10]),
                "species": 9606,
                "required_score": 400,
                "caller_identity": "MLIGHT",
                "network_type": "physical"
            },
            timeout=30
        )
        # Get unique genes from STRING
        all_string_genes = set()
        for item in resp.json():
            all_string_genes.add(item.get("preferredName_A", ""))
            all_string_genes.add(item.get("preferredName_B", ""))
    except:
        # Ultimate fallback: use intersection genes + known human gene symbols
        all_string_genes = set(INTERSECTION_GENES)
    
    gene_list = list(all_string_genes - set(INTERSECTION_GENES) - set(HIPPO_YAP_GENES))
    
    random_sets = {}
    for i in range(n_sets):
        size = random.randint(5, 20)  # Variable size like real pathways
        genes = random.sample(gene_list, min(size, len(gene_list)))
        random_sets[f"random_{i}"] = {"name": f"Random set {i}", "genes": genes}
    
    return random_sets


# ============================================================
# STEP 4: Run Permutation Test
# ============================================================
def run_permutation_test(G, pathways):
    """Run the full permutation test."""
    
    print("[3/5] Computing actual Hippo-YAP convergence...")
    actual_n_paths, actual_mean_dist, actual_min_dist = compute_convergence(G, HIPPO_YAP_GENES)
    print(f"  Hippo-YAP: {actual_n_paths} paths, mean distance {actual_mean_dist:.2f}, min {actual_min_dist}")
    
    print(f"[4/5] Running permutation test ({N_PERMUTATIONS} random pathways)...")
    
    # Select random pathways
    pw_keys = list(pathways.keys())
    
    # Remove Hippo signaling pathway itself from random pool
    hippo_keys = [k for k in pw_keys if "hippo" in pathways[k]["name"].lower()]
    for hk in hippo_keys:
        pw_keys.remove(hk)
        print(f"  Excluded actual Hippo pathway: {pathways[hk]['name']}")
    
    if len(pw_keys) < N_PERMUTATIONS:
        # Sample with replacement if not enough pathways
        selected = random.choices(pw_keys, k=N_PERMUTATIONS)
    else:
        selected = random.sample(pw_keys, N_PERMUTATIONS)
    
    results = []
    for i, pw_key in enumerate(selected):
        if i % 100 == 0:
            print(f"  Progress: {i}/{N_PERMUTATIONS}...")
        
        pw_genes = pathways[pw_key]["genes"]
        n_paths, mean_dist, min_dist = compute_convergence(G, pw_genes)
        
        results.append({
            "pathway_id": pw_key,
            "pathway_name": pathways[pw_key]["name"],
            "n_genes": len(pw_genes),
            "n_paths": n_paths,
            "mean_distance": mean_dist,
            "min_distance": min_dist
        })
    
    df = pd.DataFrame(results)
    
    # Calculate empirical P-values
    # P(n_paths): proportion of random pathways with >= actual n_paths
    p_n_paths = (df["n_paths"] >= actual_n_paths).mean()
    
    # P(mean_dist): proportion with <= actual mean_dist (lower = more convergent)
    df_reachable = df[df["mean_distance"] < float('inf')]
    if len(df_reachable) > 0:
        p_mean_dist = (df_reachable["mean_distance"] <= actual_mean_dist).mean()
    else:
        p_mean_dist = 0.0
    
    # Combined metric: n_paths / mean_dist
    actual_score = actual_n_paths / actual_mean_dist if actual_mean_dist > 0 else 0
    df_reachable_copy = df_reachable.copy()
    df_reachable_copy["score"] = df_reachable_copy["n_paths"] / df_reachable_copy["mean_distance"]
    p_combined = (df_reachable_copy["score"] >= actual_score).mean() if len(df_reachable_copy) > 0 else 0.0
    
    return {
        "actual": {
            "n_paths": actual_n_paths,
            "mean_distance": actual_mean_dist,
            "min_distance": actual_min_dist,
            "score": actual_score
        },
        "permutation_df": df,
        "p_values": {
            "p_n_paths": p_n_paths,
            "p_mean_distance": p_mean_dist,
            "p_combined": p_combined
        }
    }


# ============================================================
# STEP 5: Generate Figures and Report
# ============================================================
def generate_outputs(results):
    """Generate figures, CSV, and summary report."""
    
    print("[5/5] Generating outputs...")
    
    actual = results["actual"]
    df = results["permutation_df"]
    pvals = results["p_values"]
    
    # Save CSV
    csv_path = os.path.join(OUTPUT_DIR, "C1_permutation_results.csv")
    df.to_csv(csv_path, index=False)
    print(f"  Saved: {csv_path}")
    
    # --- Figure 1: N_paths distribution ---
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))
    
    # Panel A: Number of paths
    ax = axes[0]
    ax.hist(df["n_paths"], bins=30, color="#4A90D9", alpha=0.7, edgecolor="white")
    ax.axvline(actual["n_paths"], color="red", linewidth=2, linestyle="--",
               label=f'Hippo-YAP ({actual["n_paths"]} paths)')
    ax.set_xlabel("Number of receptor→pathway paths", fontsize=12)
    ax.set_ylabel("Frequency", fontsize=12)
    ax.set_title(f'A. Path Count\n(P = {pvals["p_n_paths"]:.4f})', fontsize=13, fontweight='bold')
    ax.legend(fontsize=10)
    
    # Panel B: Mean distance
    ax = axes[1]
    df_finite = df[df["mean_distance"] < float('inf')]
    if len(df_finite) > 0:
        ax.hist(df_finite["mean_distance"], bins=30, color="#4A90D9", alpha=0.7, edgecolor="white")
        ax.axvline(actual["mean_distance"], color="red", linewidth=2, linestyle="--",
                   label=f'Hippo-YAP ({actual["mean_distance"]:.2f})')
        ax.set_xlabel("Mean shortest-path distance", fontsize=12)
        ax.set_ylabel("Frequency", fontsize=12)
        ax.set_title(f'B. Mean Distance\n(P = {pvals["p_mean_distance"]:.4f})', fontsize=13, fontweight='bold')
        ax.legend(fontsize=10)
    
    # Panel C: Combined score
    ax = axes[2]
    if len(df_finite) > 0:
        scores = df_finite["n_paths"] / df_finite["mean_distance"]
        ax.hist(scores, bins=30, color="#4A90D9", alpha=0.7, edgecolor="white")
        ax.axvline(actual["score"], color="red", linewidth=2, linestyle="--",
                   label=f'Hippo-YAP ({actual["score"]:.1f})')
        ax.set_xlabel("Convergence score (paths / distance)", fontsize=12)
        ax.set_ylabel("Frequency", fontsize=12)
        ax.set_title(f'C. Combined Score\n(P = {pvals["p_combined"]:.4f})', fontsize=13, fontweight='bold')
        ax.legend(fontsize=10)
    
    plt.tight_layout()
    fig_path = os.path.join(OUTPUT_DIR, "C1_Permutation_Test.png")
    plt.savefig(fig_path, dpi=300, bbox_inches="tight")
    plt.savefig(fig_path.replace(".png", ".svg"), bbox_inches="tight")
    print(f"  Saved: {fig_path}")
    plt.close()
    
    # --- Summary Report ---
    report = f"""
{'='*60}
C1 EXTENSION LAYER PERMUTATION TEST — RESULTS
{'='*60}

Actual Hippo-YAP Convergence:
  Receptor→Hippo-YAP paths:  {actual['n_paths']}
  Mean shortest distance:     {actual['mean_distance']:.3f}
  Min shortest distance:      {actual['min_distance']}
  Combined score:             {actual['score']:.2f}

Null Distribution ({N_PERMUTATIONS} random KEGG pathways):
  Path count:  mean={df['n_paths'].mean():.1f}, median={df['n_paths'].median():.0f}, sd={df['n_paths'].std():.1f}
  Mean dist:   mean={df_finite['mean_distance'].mean():.3f}, sd={df_finite['mean_distance'].std():.3f}

Empirical P-values:
  P(paths ≥ {actual['n_paths']}):       {pvals['p_n_paths']:.4f}
  P(distance ≤ {actual['mean_distance']:.2f}):  {pvals['p_mean_distance']:.4f}
  P(score ≥ {actual['score']:.1f}):       {pvals['p_combined']:.4f}

INTERPRETATION:
"""
    
    if pvals['p_combined'] < 0.05:
        report += f"  ✅ Hippo-YAP convergence is SIGNIFICANTLY more specific\n"
        report += f"     than random pathways (P = {pvals['p_combined']:.4f})\n"
        report += f"     → Extension Layer finding is NOT a trivial network property\n"
    else:
        report += f"  ⚠️ Hippo-YAP convergence is NOT significantly different\n"
        report += f"     from random pathways (P = {pvals['p_combined']:.4f})\n"
        report += f"     → Consider revising Extension Layer claims\n"
    
    report += f"\n{'='*60}\n"
    
    print(report)
    
    report_path = os.path.join(OUTPUT_DIR, "C1_Permutation_Report.txt")
    with open(report_path, 'w', encoding='utf-8') as f:
        f.write(report)
    print(f"  Saved: {report_path}")
    
    return pvals


# ============================================================
# MAIN
# ============================================================
def main():
    print("="*60)
    print("C1: EXTENSION LAYER PERMUTATION TEST")
    print("="*60)
    
    # Step 1: Build network
    G = build_network_from_string()
    
    # Step 2: Get KEGG pathways
    pathways = get_kegg_pathways()
    
    if pathways is None:
        # Fallback to random gene sets
        pathways = get_random_gene_sets(N_PERMUTATIONS)
    
    # Step 3: Run permutation test
    results = run_permutation_test(G, pathways)
    
    # Step 4: Generate outputs
    pvals = generate_outputs(results)
    
    print("\nDone! Check output in:", OUTPUT_DIR)
    return pvals


if __name__ == "__main__":
    main()
