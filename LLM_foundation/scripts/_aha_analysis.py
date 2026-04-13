import json
import pandas as pd
import re

def main():
    combined_path = "results/results_combined.json"
    excel_path = "SR202503119329_안과_박정열_산출물3.데이터_v1.0(1).xlsx"
    
    # 1. Load LLM Results
    try:
        with open(combined_path, "r", encoding="utf-8") as f:
            records = json.load(f)
    except Exception as e:
        print(f"Error loading {combined_path}: {e}")
        return

    # Filter only successful Zero-Shot runs
    valid_records = {
        r["case_id"]: r 
        for r in records
        if r["strategy"] == "A_zero_shot" and r["llm_result"]["status"] == "success"
    }
    
    # 2. Load original Excel to get the raw report text
    try:
        df_raw = pd.read_excel(excel_path)
    except Exception as e:
        print(f"Error loading Excel: {e}")
        return
        
    print(f"Loaded {len(valid_records)} zero-shot records.")
    
    # Create a mapping from '연구번호' to the actual report text
    raw_texts = {}
    for _, row in df_raw.iterrows():
        case_id = str(row.get('연구번호', '')).strip()
        report = str(row.get('영상검사 판독문', '')).strip()
        if case_id and report:
            raw_texts[case_id] = report

    # Analysis 1: True Lymphoma, missed in report
    lymphoma_fn = []
    # Analysis 2: True Pseudotumor, missed in report
    pseudo_fn = []
    # Analysis 3: Lymphoma false alarms
    lymphoma_fp = []
    
    lymphoma_keywords = ["lymphoma", "malt", "maltoma"]
    pseudo_keywords = ["pseudotumor", "inflammatory", "ioi"]
    
    for case_id, r in valid_records.items():
        true_diag = r["true_diagnosis"]
        data = r["llm_result"].get("data", {})
        
        is_inf = str(data.get("report_informative", "")).lower() == "true"
        
        # Get REAL report text from excel
        # Removing 'R' if present in case_id to match excel format. 
        # (Assuming 'R10001' -> '10001' logic or identical matching)
        real_id = case_id
        if real_id not in raw_texts and real_id.startswith('R'):
             real_id = real_id[1:]
             
        report_text = raw_texts.get(real_id, "")
        if not report_text:
             report_text = raw_texts.get(case_id, "") # Fallback
             
        report_text_lower = report_text.lower()
        
        ddx = data.get("differential_diagnoses", [])
        
        # === 1. Missed Lymphoma ===
        if true_diag == "orbital_lymphoma":
            mentions_lymphoma = any(kw in report_text_lower for kw in lymphoma_keywords)
            if not mentions_lymphoma and is_inf:
                lymphoma_fn.append({
                    "case_id": case_id,
                    "report_snippet": report_text[:300].replace('\n', ' ') + "...",
                    "llm_ddx": ddx
                })
                
        # === 2. Missed Pseudotumor ===
        elif true_diag == "pseudotumor":
            mentions_pseudo = any(kw in report_text_lower for kw in pseudo_keywords)
            if not mentions_pseudo and is_inf:
                pseudo_fn.append({
                    "case_id": case_id,
                    "report_snippet": report_text[:300].replace('\n', ' ') + "...",
                    "llm_ddx": ddx
                })
                
        # === 3. False Alarm Lymphoma ===
        else:
            mentions_lymphoma = any(kw in report_text_lower for kw in lymphoma_keywords)
            if mentions_lymphoma:
                lymphoma_fp.append({
                    "case_id": case_id,
                    "true_diagnosis": true_diag,
                    "llm_ddx": ddx
                })

    # Stats
    total_lymphoma = sum(1 for r in valid_records.values() if r["true_diagnosis"] == "orbital_lymphoma")
    total_pseudo = sum(1 for r in valid_records.values() if r["true_diagnosis"] == "pseudotumor")
    total_non_lymphoma = len(valid_records) - total_lymphoma
    
    print("\n" + "="*80)
    print(" AHA! PATIENT SAFETY ANALYSIS (CORRECTED TEXT MAPPING)")
    print("="*80)
    
    print(f"\n1. Missed Lymphoma (True Lymphoma, NOT mentioned in report, BUT report is informative)")
    print(f"   Count: {len(lymphoma_fn)} out of {total_lymphoma} total lymphomas ({len(lymphoma_fn)/total_lymphoma*100:.1f}%)")
    for i, case in enumerate(lymphoma_fn[:10]):
        print(f"   [{i+1}] {case['case_id']} - LLM DDx: {case['llm_ddx']}")
        print(f"       Raw Report: {case['report_snippet']}")
        
    print(f"\n2. Missed Pseudotumor (True Pseudotumor, NOT mentioned in report, BUT report is informative)")
    print(f"   Count: {len(pseudo_fn)} out of {total_pseudo} total pseudotumors ({len(pseudo_fn)/total_pseudo*100:.1f}%)")
        
    print(f"\n3. False Alarm Lymphoma (Not Lymphoma, BUT report mentions it)")
    print(f"   Count: {len(lymphoma_fp)} out of {total_non_lymphoma} non-lymphomas ({len(lymphoma_fp)/total_non_lymphoma*100:.1f}%)")
    print("\n" + "="*80)

if __name__ == "__main__":
    main()
