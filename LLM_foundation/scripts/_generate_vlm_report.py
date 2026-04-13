import json
from pathlib import Path

def generate_report():
    prompt = """
이 영상은 안와(Orbit) CT 또는 MRI의 축상면(Axial) 이미지 3장입니다.
영상을 판독하여 병변(mass/lesion/enlargement 등)의 유무 및 형태학적 특징을 묘사하고,
가장 가능성 있는 감별진단(Differential Diagnosis) 질환 목록을 1위부터 5위까지 제시해 주세요.

출력 형식:
[FINDING]
(병변에 대한 영상의학적 소견 묘사)

[DIFFERENTIAL DIAGNOSIS]
1. (진단명 1)
2. (진단명 2)
...
"""

    results_file = Path("results/vision_pilot_results.json")
    if not results_file.exists():
        print("Results file not found.")
        return
        
    with open(results_file, "r", encoding="utf-8") as f:
        data = json.load(f)
        
    report = ["# VLM Pilot Results - Critical Review\n"]
    
    report.append("## 1. 프롬프트 검증 (Prompt Verification)\n")
    report.append("사용한 프롬프트는 림프종을 명시하지 않은 완전히 중립적인 프롬프트입니다:\n")
    report.append("```text")
    report.append(prompt.strip())
    report.append("```\n")
    
    report.append("## 2. R10442 제외 사유\n")
    report.append("- **사유:** R10442 환자의 영상 데이터는 안와(Orbit) 스캔이 아닌 복부(Abdomen) CT/MRI 스캔임이 전체 DICOM 시리즈 몽타주 분석 과정에서 확인되었습니다. 따라서 안와 종양 진단 파일럿의 대상이 될 수 없어 연구 대상에서 명시적으로 배제(Exclude)하였습니다.\n\n")
    
    report.append("## 3. 케이스별 원문 결과 분석 (Raw JSON Export)\n")
    
    success_cases = []
    failed_cases = []
    for k, v in data.items():
        if v.get("lymphoma_caught"):
             success_cases.append((k, v["raw_response"]))
        else:
             failed_cases.append((k, v["raw_response"]))
             
    report.append(f"### 성공 케이스 (림프종 감별 성공 - {len(success_cases)}건)\n\n")
    for case_id, raw in success_cases:
        report.append(f"#### 🟢 {case_id}\n")
        report.append("```text\n")
        report.append(raw.strip() + "\n")
        report.append("```\n\n")
        
    report.append(f"### 실패 케이스 (림프종 감별 실패 - {len(failed_cases)}건)\n\n")
    report.append("> 논의점: 림프종 대신 어떤 양성/악성을 제시했는가? 종괴 자체를 식별하지 못한 것인가?\n\n")
    for case_id, raw in failed_cases:
        report.append(f"#### 🔴 {case_id}\n")
        report.append("```text\n")
        report.append(raw.strip() + "\n")
        report.append("```\n\n")
        
    out_path = Path("results/vision_pilot_report.md")
    with open(out_path, "w", encoding="utf-8") as f:
        f.write("".join(report))
        
    print(f"Report written to {out_path.absolute()}")

if __name__ == '__main__':
    generate_report()
