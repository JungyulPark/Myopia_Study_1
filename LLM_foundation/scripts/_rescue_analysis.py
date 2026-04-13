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
    
    missed_by_dr_caught_by_ai = []
    missed_by_dr_missed_by_ai = []
    
    for r in valid_records:
        if r["true_diagnosis"] != "orbital_lymphoma":
            continue
            
        cid = r["case_id"]  # e.g., "R10001"
        report_text = raw_texts.get(cid, "")
        report_text_lower = report_text.lower()
        
        data = r["llm_result"].get("data", {})
        is_inf = str(data.get("report_informative", "")).lower() == "true"
        
        mentions_lymphoma_dr = any(kw in report_text_lower for kw in lymphoma_keywords)
        
        # Focus ONLY on cases missed by the doctor
        if not mentions_lymphoma_dr and is_inf:
            llm_ddx_list = data.get("differential_diagnoses", [])
            # Check if LLM caught it
            # We check if any of the lymphoma keywords exist in any of the LLM's differential diagnosis strings
            llm_caught = False
            for ddx_term in llm_ddx_list:
                ddx_lower = str(ddx_term).lower()
                if any(kw in ddx_lower for kw in lymphoma_keywords):
                    llm_caught = True
                    break
                    
            if llm_caught:
                missed_by_dr_caught_by_ai.append({
                    "case_id": cid,
                    "llm_ddx": llm_ddx_list
                })
            else:
                missed_by_dr_missed_by_ai.append({
                    "case_id": cid,
                    "llm_ddx": llm_ddx_list
                })
                
    total_missed_by_dr = len(missed_by_dr_caught_by_ai) + len(missed_by_dr_missed_by_ai)
    
    with open("rescue_log.txt", "w", encoding="utf-8") as out_f:
        out_f.write("\n" + "="*80 + "\n")
        out_f.write(" LLM RESCUE ANALYSIS (ZERO-SHOT)\n")
        out_f.write("="*80 + "\n")
        out_f.write(f"Total True Lymphomas MISSED by Radiologist: {total_missed_by_dr}\n")
        
        caught_rate = 0
        if total_missed_by_dr > 0:
            caught_rate = len(missed_by_dr_caught_by_ai) / total_missed_by_dr * 100
            
        out_f.write(f"Of these {total_missed_by_dr} missed cases, LLM successfully included Lymphoma in DDx:\n")
        out_f.write(f"COUNT: {len(missed_by_dr_caught_by_ai)} cases ({caught_rate:.1f}%)\n")
        
        out_f.write("\n--- Cases Caught by LLM ---\n")
        for case in missed_by_dr_caught_by_ai:
             out_f.write(f"CASE {case['case_id']} - LLM DDX: {case['llm_ddx']}\n")
        
        out_f.write("\n--- Cases Missed by Both ---\n")
        for case in missed_by_dr_missed_by_ai:
             out_f.write(f"CASE {case['case_id']} - LLM DDX: {case['llm_ddx']}\n")
        out_f.write("="*80 + "\n")

if __name__ == "__main__":
    verify_aha()
