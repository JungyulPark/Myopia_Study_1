"""Quick check of early zero-shot results."""
import json

with open("results/results_A_zero_shot.json", "r", encoding="utf-8") as f:
    data = json.load(f)

print(f"Total records so far: {len(data)}")
success = sum(1 for r in data if r["llm_result"]["status"] == "success")
json_err = sum(1 for r in data if r["llm_result"]["status"] == "json_error")
print(f"Success: {success}, JSON errors: {json_err}")
print()

# Quick biopsy accuracy on available data
correct_bx = 0
total_bx = 0
for r in data:
    d = r["llm_result"].get("data") or {}
    pred = d.get("biopsy_recommended")
    if pred is not None:
        total_bx += 1
        pred_int = 1 if pred else 0
        if pred_int == r["true_biopsy"]:
            correct_bx += 1

print(f"Biopsy accuracy so far: {correct_bx}/{total_bx} = {correct_bx/total_bx:.1%}" if total_bx else "No biopsy data")
print()

# Show first 10
for r in data[:10]:
    d = r["llm_result"].get("data") or {}
    bx = "Y" if d.get("biopsy_recommended") else "N"
    tbx = "Y" if r["true_biopsy"] == 1 else "N"
    ok = "OK" if (bx == "Y" and tbx == "Y") or (bx == "N" and tbx == "N") else "XX"
    diag = (d.get("primary_diagnosis") or "?")[:25]
    tdiag = r["true_diagnosis"][:25]
    conf = d.get("confidence", "?")
    print(f"  {r['case_id']:8s} bx={bx}(t={tbx}){ok}  diag={diag:25s}(t={tdiag:25s})  c={conf}")
