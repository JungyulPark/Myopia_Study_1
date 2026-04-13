import json
import pandas as pd
import re

def verify_aha():
    combined_path = "results/results_combined.json"
    excel_path = "SR202503119329_안과_박정열_산출물3.데이터_v1.0(1).xlsx"
    
    with open(combined_path, "r", encoding="utf-8") as f:
        records = json.load(f)
        
    df = pd.read_excel(excel_path)
    
    # Create mapping: Excel 연구번호 -> 영상검사 판독문
    # The Excel IDs look like "R10001", results JSON might be "R10001"
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
    
    total_lymphoma = 0
    total_matched_text = 0
    
    for r in valid_records:
        if r["true_diagnosis"] != "orbital_lymphoma":
            continue
            
        total_lymphoma += 1
        cid = r["case_id"]  # e.g., "R10001"
        
        # In `01_prepare_data.py`, we created case_id = "R" + str(10000 + idx)
        # Wait, the excel might NOT have "R10001". It might have something else.
        # Let's just find the text by the row index if we have to, 
        # but the best way is to print out what `cid` and `raw_texts.keys()` look like.
        
        # For now, let's assume `01_prepare_data.py` assigned IDs sequentially to the VALID rows.
        # This implies we can't just match by `cid` if the original excel didn't have "R100xx".
        pass
        
    print(f"Excel IDs sample: {list(raw_texts.keys())[:5]}")
    print(f"JSON IDs sample: {[r['case_id'] for r in valid_records[:5]]}")

if __name__ == "__main__":
    verify_aha()
