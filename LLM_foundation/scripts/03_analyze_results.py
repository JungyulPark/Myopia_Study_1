"""
03_analyze_results.py
=====================
Reads the combined LLM results, computes performance metrics,
generates publication-quality figures, and outputs a summary table.
"""

import json
import sys
import warnings
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns
from sklearn.metrics import (
    accuracy_score,
    classification_report,
    cohen_kappa_score,
    confusion_matrix,
    f1_score,
    precision_score,
    recall_score,
    roc_auc_score,
    roc_curve,
)

warnings.filterwarnings("ignore")

# ── paths ──────────────────────────────────────────────────────────────
ROOT = Path(__file__).resolve().parent.parent
RESULTS_DIR = ROOT / "results"
FIGURES_DIR = ROOT / "figures"
FIGURES_DIR.mkdir(parents=True, exist_ok=True)
COMBINED_PATH = RESULTS_DIR / "results_combined.json"

STRATEGIES = ["A_zero_shot", "B_few_shot", "C_chain_of_thought"]
STRATEGY_LABELS = {
    "A_zero_shot": "Zero-Shot",
    "B_few_shot": "Few-Shot",
    "C_chain_of_thought": "Chain-of-Thought",
}

# ── style ──────────────────────────────────────────────────────────────
plt.rcParams.update({
    "font.family": "sans-serif",
    "font.size": 11,
    "axes.titlesize": 13,
    "axes.labelsize": 12,
    "figure.dpi": 300,
    "savefig.dpi": 300,
    "savefig.bbox": "tight",
})
PALETTE = sns.color_palette("Set2", n_colors=3)


# ── helpers ────────────────────────────────────────────────────────────

def extract_biopsy_pred(llm_result: dict) -> int | None:
    """Extract biopsy_recommended from LLM result. Returns 1/0 or None."""
    if llm_result.get("status") != "success" or not llm_result.get("data"):
        return None
    val = llm_result["data"].get("biopsy_recommended")
    if isinstance(val, bool):
        return int(val)
    if isinstance(val, str):
        return 1 if val.lower() == "true" else 0
    return None


def extract_diagnosis_pred(llm_result: dict) -> str | None:
    """Extract primary_diagnosis from LLM result."""
    if llm_result.get("status") != "success" or not llm_result.get("data"):
        return None
    return llm_result["data"].get("primary_diagnosis")


def extract_confidence(llm_result: dict) -> int | None:
    """Extract confidence score (1-5) from LLM result."""
    if llm_result.get("status") != "success" or not llm_result.get("data"):
        return None
    val = llm_result["data"].get("confidence")
    try:
        return int(val)
    except (TypeError, ValueError):
        return None


def compute_metrics(y_true: list, y_pred: list, y_conf: list = None) -> dict:
    """Compute biopsy prediction performance metrics."""
    acc = accuracy_score(y_true, y_pred)
    sens = recall_score(y_true, y_pred, zero_division=0)
    spec = recall_score(y_true, y_pred, pos_label=0, zero_division=0)
    ppv = precision_score(y_true, y_pred, zero_division=0)
    # NPV
    tn = sum(1 for t, p in zip(y_true, y_pred) if t == 0 and p == 0)
    fn = sum(1 for t, p in zip(y_true, y_pred) if t == 1 and p == 0)
    npv = tn / (tn + fn) if (tn + fn) > 0 else 0.0
    f1 = f1_score(y_true, y_pred, zero_division=0)
    kappa = cohen_kappa_score(y_true, y_pred)

    metrics = {
        "Accuracy": acc,
        "Sensitivity": sens,
        "Specificity": spec,
        "PPV": ppv,
        "NPV": npv,
        "F1": f1,
        "Cohen_Kappa": kappa,
        "N": len(y_true),
    }

    # AUROC if confidence scores available
    if y_conf and len(set(y_true)) > 1:
        try:
            auroc = roc_auc_score(y_true, y_conf)
            metrics["AUROC"] = auroc
        except ValueError:
            metrics["AUROC"] = float("nan")
    else:
        metrics["AUROC"] = float("nan")

    return metrics


# ── main analysis ──────────────────────────────────────────────────────

def main():
    if not COMBINED_PATH.exists():
        sys.exit(f"ERROR: {COMBINED_PATH} not found. Run 02_run_llm.py first.")

    with open(COMBINED_PATH, "r", encoding="utf-8") as f:
        records = json.load(f)

    print(f"Loaded {len(records)} records from results_combined.json")

    # Build dataframe
    rows = []
    for r in records:
        bx_pred = extract_biopsy_pred(r["llm_result"])
        diag_pred = extract_diagnosis_pred(r["llm_result"])
        conf = extract_confidence(r["llm_result"])
        rows.append({
            "case_id": r["case_id"],
            "strategy": r["strategy"],
            "true_diagnosis": r["true_diagnosis"],
            "true_biopsy": r["true_biopsy"],
            "uninformative": r["uninformative"],
            "pred_biopsy": bx_pred,
            "pred_diagnosis": diag_pred,
            "confidence": conf,
            "api_status": r["llm_result"]["status"],
        })

    df = pd.DataFrame(rows)
    print(f"API success rates by strategy:")
    for s in STRATEGIES:
        sub = df[df["strategy"] == s]
        success = (sub["api_status"] == "success").sum()
        print(f"  {STRATEGY_LABELS[s]}: {success}/{len(sub)}")

    # Filter to successful results only
    df_ok = df[df["pred_biopsy"].notna()].copy()
    df_ok["pred_biopsy"] = df_ok["pred_biopsy"].astype(int)
    df_ok["true_biopsy"] = df_ok["true_biopsy"].astype(int)

    # ══════════════════════════════════════════════════════════════════
    # 1. DIAGNOSIS CLASSIFICATION OVERALL
    # ══════════════════════════════════════════════════════════════════
    print(f"\n{'='*60}")
    print("  DIAGNOSIS CLASSIFICATION PERFORMANCE")
    print(f"{'='*60}")

    df_diag = df_ok[df_ok["pred_diagnosis"].notna()].copy()
    
    # We will compute metrics for diagnosis
    summary_rows = []
    
    for s in STRATEGIES:
        sub = df_diag[df_diag["strategy"] == s]
        if len(sub) == 0:
            continue
            
        y_true = sub["true_diagnosis"].tolist()
        y_pred = sub["pred_diagnosis"].tolist()
        
        acc = accuracy_score(y_true, y_pred)
        kappa = cohen_kappa_score(y_true, y_pred)
        
        # Weighted F1/Precision/Recall for multiclass
        f1_w = f1_score(y_true, y_pred, average="weighted", zero_division=0)
        prec_w = precision_score(y_true, y_pred, average="weighted", zero_division=0)
        rec_w = recall_score(y_true, y_pred, average="weighted", zero_division=0)
        
        m = {
            "Strategy": STRATEGY_LABELS[s],
            "N": len(y_true),
            "Accuracy": acc,
            "Precision (w)": prec_w,
            "Recall (w)": rec_w,
            "F1 (w)": f1_w,
            "Cohen_Kappa": kappa
        }
        summary_rows.append(m)

        print(f"\n  {STRATEGY_LABELS[s]} (n={m['N']}):")
        for k, v in m.items():
            if k not in ("N", "Strategy"):
                print(f"    {k:15s}: {v:.4f}")

    summary_df = pd.DataFrame(summary_rows)
    summary_path = RESULTS_DIR / "diagnosis_summary_table.csv"
    summary_df.to_csv(summary_path, index=False)
    print(f"\nDiagnosis summary table → {summary_path}")

    # ══════════════════════════════════════════════════════════════════
    # 2. DIAGNOSIS CLASSIFICATION PER CATEGORY
    # ══════════════════════════════════════════════════════════════════
    print(f"\n{'='*60}")
    print("  PER-DIAGNOSIS ACCURACY (Zero-Shot)")
    print(f"{'='*60}")

    sub = df_diag[df_diag["strategy"] == "A_zero_shot"]
    diag_groups = sub.groupby("true_diagnosis")
    
    per_diag_data = []
    for diag, grp in sorted(diag_groups, key=lambda x: -len(x[1])):
        acc = (grp["true_diagnosis"] == grp["pred_diagnosis"]).mean()
        print(f"  {diag:30s}  {acc:.3f}  (n={len(grp)})")
        per_diag_data.append({
            "Diagnosis": diag,
            "Accuracy": acc,
            "N": len(grp)
        })

    # ══════════════════════════════════════════════════════════════════
    # 3. SUBGROUP ANALYSIS
    # ══════════════════════════════════════════════════════════════════
    print(f"\n{'='*60}")
    print("  SUBGROUP ANALYSIS: Informative vs Uninformative (Zero-Shot)")
    print(f"{'='*60}")

    for label, is_uninf in [("Informative", False), ("Uninformative", True)]:
        grp = sub[sub["uninformative"] == is_uninf]
        if len(grp) < 2:
            continue
        acc = accuracy_score(grp["true_diagnosis"], grp["pred_diagnosis"])
        f1_w = f1_score(grp["true_diagnosis"], grp["pred_diagnosis"], average="weighted", zero_division=0)
        print(f"  {label} (n={len(grp)}): Acc = {acc:.3f}, F1(w) = {f1_w:.3f}")

    # ══════════════════════════════════════════════════════════════════
    # 4. FIGURES
    # ══════════════════════════════════════════════════════════════════
    print(f"\n{'='*60}")
    print("  GENERATING FIGURES")
    print(f"{'='*60}")

    # ── Fig 1: Diagnosis Accuracy per Category ──
    fig, ax = plt.subplots(figsize=(10, 6))
    diag_df = pd.DataFrame(per_diag_data)
    # Only plot if N >= 5 for visual clarity
    diag_df_plot = diag_df[diag_df["N"] >= 5].copy()
    
    sns.barplot(data=diag_df_plot, x="Diagnosis", y="Accuracy", color=PALETTE[0], ax=ax)
    
    # Add N labels on top of bars
    for i, p in enumerate(ax.patches):
        ax.annotate(f"n={diag_df_plot.iloc[i]['N']}", 
                    (p.get_x() + p.get_width() / 2., p.get_height()), 
                    ha='center', va='bottom', xytext=(0, 5), textcoords='offset points')
                    
    ax.set_title("Primary Diagnosis Accuracy by Category (N>=5)")
    ax.set_xlabel("")
    ax.set_ylabel("Accuracy")
    ax.set_ylim([0, 1.1])
    plt.xticks(rotation=45, ha="right")
    fig.tight_layout()
    for fmt in ["png", "pdf"]:
        fig.savefig(FIGURES_DIR / f"fig1_dx_accuracy_by_category.{fmt}")
    plt.close(fig)
    print("  ✓ fig1_dx_accuracy_by_category")

    # ── Fig 2: Confusion Matrix ──
    labels = sorted(list(set(sub["true_diagnosis"].unique()) | set(sub["pred_diagnosis"].unique())))
    cm = confusion_matrix(sub["true_diagnosis"], sub["pred_diagnosis"], labels=labels)
    
    # Filter out very small classes to make CM readable
    # Keep classes that appear at least 10 times in true or pred
    class_totals_true = cm.sum(axis=1)
    class_totals_pred = cm.sum(axis=0)
    keep_idx = [i for i, (t, p) in enumerate(zip(class_totals_true, class_totals_pred)) if t >= 10 or p >= 10]
    
    if len(keep_idx) > 0:
        cm_filtered = cm[keep_idx][:, keep_idx]
        labels_filtered = [labels[i] for i in keep_idx]
        
        fig, ax = plt.subplots(figsize=(10, 8))
        sns.heatmap(cm_filtered, annot=True, fmt="d", cmap="Blues",
                    xticklabels=labels_filtered, yticklabels=labels_filtered, ax=ax)
        
        ax.set_title("Diagnosis Confusion Matrix (Classes with N>=10)")
        ax.set_xlabel("Predicted Diagnosis")
        ax.set_ylabel("True Diagnosis")
        plt.xticks(rotation=45, ha="right")
        fig.tight_layout()
        for fmt in ["png", "pdf"]:
            fig.savefig(FIGURES_DIR / f"fig2_dx_confusion_matrix.{fmt}")
        plt.close(fig)
        print("  ✓ fig2_dx_confusion_matrix")

    # ── Fig 3: Informative vs Uninformative ──
    inf_data = []
    for label, is_uninf in [("Informative", False), ("Uninformative", True)]:
        grp = sub[sub["uninformative"] == is_uninf]
        if len(grp) >= 5:
            acc = accuracy_score(grp["true_diagnosis"], grp["pred_diagnosis"])
            inf_data.append({"Report Type": label, "Accuracy": acc, "N": len(grp)})
            
    if inf_data:
        inf_df = pd.DataFrame(inf_data)
        fig, ax = plt.subplots(figsize=(6, 5))
        sns.barplot(data=inf_df, x="Report Type", y="Accuracy", palette=["#4CAF50", "#FF9800"], ax=ax)
        for i, p in enumerate(ax.patches):
            ax.annotate(f"n={inf_df.iloc[i]['N']}", 
                        (p.get_x() + p.get_width() / 2., p.get_height()), 
                        ha='center', va='bottom', xytext=(0, 5), textcoords='offset points')
        ax.set_title("Diagnosis Accuracy: Informative vs Uninformative reports")
        ax.set_ylim([0, 1.1])
        fig.tight_layout()
        for fmt in ["png", "pdf"]:
            fig.savefig(FIGURES_DIR / f"fig3_dx_informative_comparison.{fmt}")
        plt.close(fig)
        print("  ✓ fig3_dx_informative_comparison")

    print(f"\nAll figures saved to {FIGURES_DIR}/")
    print("DONE.")


if __name__ == "__main__":
    main()
