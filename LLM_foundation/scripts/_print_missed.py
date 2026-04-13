import json
import pandas as pd

def verify_aha():
    combined_path = "results/results_combined.json"
    excel_path = "SR202503119329_안과_박정열_산출물3.데이터_v1.0(1).xlsx"
    
    with open(combined_path, "r", encoding="utf-8") as f:
        records = json.load(f)
        
    df = pd.read_excel(excel_path)
    
    raw_texts = {}
    for _, row in df.iterrows():
        rid = str(row.get('연구번호', '')).strip()
        rpt = str(row.get('영상검사 판독문', '')).strip()
        raw_texts[rid] = rpt
        
    valid_records = [
        r for r in records
        if r["strategy"] == "A_zero_shot" and r["llm_result"]["status"] == "success"
    ]
    
    lymphoma_keywords = ["lymphoma", "malt", "maltoma"]
    pseudo_keywords = ["pseudotumor", "inflammatory", "ioi"]
    
    missed_lymphoma = []
    
    for r in valid_records:
        if r["true_diagnosis"] != "orbital_lymphoma":
            continue
            
        cid = r["case_id"]  # e.g., "R10001"
        report_text = raw_texts.get(cid, "")
        report_text_lower = report_text.lower()
        
        data = r["llm_result"].get("data", {})
        is_inf = str(data.get("report_informative", "")).lower() == "true"
        
        mentions_lymphoma = any(kw in report_text_lower for kw in lymphoma_keywords)
        
        if not mentions_lymphoma and is_inf:
            missed_lymphoma.append({
                "case_id": cid,
                "raw_text": report_text,
                "llm_ddx": data.get("differential_diagnoses", [])
            })
            
    print(f"Total True Lymphomas: {sum(1 for r in valid_records if r['true_diagnosis'] == 'orbital_lymphoma')}")
    print(f"Total Missed Lymphomas: {len(missed_lymphoma)}")
    
    print("\n============== SAMPLE 5 MISSED LYMPHOMAS ==============\n")
    for i, case in enumerate(missed_lymphoma[:5]):
        print(f"CASE {case['case_id']}: LLM Predicted -> {case['llm_ddx']}")
        # Print first 500 chars 
        snippet = case['raw_text']
        if len(snippet) > 500: snippet = snippet[:500] + "..."
        print(f"REPORT TEXT:\n{snippet}\n")
        print("-" * 60)

if __name__ == "__main__":
    verify_aha()
