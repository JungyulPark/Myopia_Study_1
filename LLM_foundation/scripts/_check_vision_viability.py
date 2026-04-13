import json
import pandas as pd

def check_vision_viability():
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
            missed_lymphoma.append((cid, report_text))
                
    counts = {"mass": 0, "lesion": 0, "conjunctival": 0, "other": 0}
    
    with open("conjunctival_check2.txt", "w", encoding="utf-8") as f:
        f.write(f"Total Missed Lymphoma Cases checked: {len(missed_lymphoma)}\n")
        f.write("="*80 + "\n")
        
        for cid, text in missed_lymphoma:
            tl = text.lower()
            has_conj = 'conjunctival' in tl or 'conjunctiva' in tl
            has_mass = 'mass' in tl
            has_lesion = 'lesion' in tl
            
            if has_mass: counts["mass"] += 1
            if has_lesion: counts["lesion"] += 1
            if has_conj: counts["conjunctival"] += 1
            if not has_mass and not has_lesion and not has_conj: counts["other"] += 1
            
            f.write(f"CASE: {cid}\n")
            f.write(f"Keywords Found: conjunctival={has_conj}, mass={has_mass}, lesion={has_lesion}\n")
            # f.write(f"RAW REPORT:\n{text.strip()}\n")
            f.write("-" * 80 + "\n")
            
        f.write("\nSUMMARY\n")
        f.write(f"Mass mentions: {counts['mass']}\n")
        f.write(f"Lesion mentions: {counts['lesion']}\n")
        f.write(f"Conjunctival mentions: {counts['conjunctival']}\n")
        f.write(f"Other: {counts['other']}\n")

if __name__ == '__main__':
    check_vision_viability()
