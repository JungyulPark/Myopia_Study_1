import json

def verify_missed_lymphomas():
    combined_path = "results/results_combined.json"
    try:
        with open(combined_path, "r", encoding="utf-8") as f:
            records = json.load(f)
    except Exception as e:
        print(f"Error loading {combined_path}: {e}")
        return
        
    valid_records = [
        r for r in records
        if r["strategy"] == "A_zero_shot" and r["llm_result"]["status"] == "success"
    ]
    
    lymphoma_keywords = ["lymphoma", "malt", "maltoma"]
    
    missed_cases = []
    
    for r in valid_records:
        if r["true_diagnosis"] != "orbital_lymphoma":
            continue
            
        report_text = r.get("report_text", "")
        # Very safe lowercasing and basic string matching
        report_text_lower = report_text.lower()
        
        data = r["llm_result"].get("data", {})
        is_inf = str(data.get("report_informative", "")).lower() == "true"
        
        # Does the string contain any of the keywords?
        mentions_lymphoma = any(kw in report_text_lower for kw in lymphoma_keywords)
        
        if not mentions_lymphoma and is_inf:
            missed_cases.append({
                "case_id": r["case_id"],
                "report_text": report_text,
                "llm_ddx": data.get("differential_diagnoses", [])
            })
            
    print("=" * 80)
    print(f"VERIFICATION: MISSED LYMPHOMA CASES")
    print("=" * 80)
    print(f"Total missed cases identified: {len(missed_cases)}")
    print(f"Keywords used (case-insensitive): {lymphoma_keywords}")
    print("\n[SAMPLE 10 CASES]")
    print("-" * 80)
    
    for i, case in enumerate(missed_cases[:10]):
        print(f"\nCASE {i+1}: {case['case_id']}")
        print(f"LLM Differential : {case['llm_ddx']}")
        print(f"RAW REPORT TEXT  :\n{case['report_text'].strip()}")
        print("-" * 80)

if __name__ == "__main__":
    verify_missed_lymphomas()
