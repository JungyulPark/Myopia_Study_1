import json
import pandas as pd

def main():
    combined_path = "results/results_combined.json"
    try:
        with open(combined_path, "r", encoding="utf-8") as f:
            records = json.load(f)
    except Exception as e:
        print(f"Error loading {combined_path}: {e}")
        return

    # Filter only successful Zero-Shot runs
    valid_records = [
        r for r in records
        if r["strategy"] == "A_zero_shot" and r["llm_result"]["status"] == "success"
    ]
    print(f"Loaded {len(valid_records)} zero-shot records for analysis.\n")

    summary_data = []

    for r in valid_records:
        data = r["llm_result"].get("data", {})
        true_diag = r["true_diagnosis"]
        
        # 1. Is report informative (according to LLM)
        is_inf = data.get("report_informative")
        if isinstance(is_inf, str):
            is_inf = (is_inf.lower() == "true")
        inf_val = 1 if is_inf else 0
        
        # 2. Key findings count
        kf = data.get("key_findings", [])
        if isinstance(kf, list):
            kf_count = len(kf)
        else:
            kf_count = 0
            
        # 3. Differential Diagnosis Accuracy
        pred_diag = data.get("primary_diagnosis", "")
        diff_list = data.get("differential_diagnoses", [])
        if not isinstance(diff_list, list):
            diff_list = []
            
        # "Is the true diagnosis in either primary OR the differential list?"
        # Clean up strings for comparison
        all_preds = [str(x).lower().strip() for x in [pred_diag] + diff_list]
        true_clean = str(true_diag).lower().strip()
        
        match_top1 = 1 if true_clean == str(pred_diag).lower().strip() else 0
        match_diff = 1 if any(true_clean in p for p in all_preds) else 0

        summary_data.append({
            "diagnosis": true_diag,
            "inf_val": inf_val,
            "kf_count": kf_count,
            "match_top1": match_top1,
            "match_diff": match_diff
        })

    df = pd.DataFrame(summary_data)
    
    # Calculate overall metrics
    overall_inf = df["inf_val"].mean() * 100
    overall_kf = df["kf_count"].mean()
    overall_top1 = df["match_top1"].mean() * 100
    overall_diff = df["match_diff"].mean() * 100
    
    print("=" * 60)
    print("OVERALL METRICS (Zero-Shot)")
    print("=" * 60)
    print(f"Total Cases: {len(df)}")
    print(f"(1) LLM Report Informative Rate: {overall_inf:.1f}%")
    print(f"(2) Avg Key Findings Count:      {overall_kf:.1f} findings/case")
    print(f"(3) Top-1 Diagnosis Accuracy:    {overall_top1:.1f}%")
    print(f"    Top-N (Diff) Accuracy:       {overall_diff:.1f}%")
    print()
    
    # Calculate per-diagnosis metrics
    print("=" * 80)
    print(f"{'Diagnosis Category':<25s} | {'N':>4s} | {'Top-1 Acc':>10s} | {'Top-N (Diff) Acc':>16s} | {'Info Rate':>10s} | {'Avg KF':>6s}")
    print("-" * 80)
    
    grp = df.groupby("diagnosis")
    
    # Sort by N descending
    for diag, G in sorted(grp, key=lambda x: -len(x[1])):
        n = len(G)
        t1 = G["match_top1"].mean() * 100
        tn = G["match_diff"].mean() * 100
        inf = G["inf_val"].mean() * 100
        kf = G["kf_count"].mean()
        
        print(f"{diag:<25s} | {n:4d} | {t1:9.1f}% | {tn:15.1f}% | {inf:9.1f}% | {kf:6.1f}")
        
    print("=" * 80)

if __name__ == "__main__":
    main()
