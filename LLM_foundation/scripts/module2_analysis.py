"""
논문 1 - Module 2: 통계 분석 (Statistical Analysis)
====================================================
입력: paper1_output/orbital_cleaned.csv, patient_cleaned.csv
출력: paper1_output/results/ 폴더에 테이블 및 분석 결과

실행: python module2_analysis.py
"""

import pandas as pd
import numpy as np
import os
from collections import OrderedDict

OUTPUT_DIR = r"paper1_output"
RESULTS_DIR = os.path.join(OUTPUT_DIR, "results")
os.makedirs(RESULTS_DIR, exist_ok=True)

# ============================================================
# 데이터 로드
# ============================================================
print("=" * 60)
print("Module 2: 통계 분석")
print("=" * 60)

orbital = pd.read_csv(os.path.join(OUTPUT_DIR, 'orbital_cleaned.csv'))
patient = pd.read_csv(os.path.join(OUTPUT_DIR, 'patient_cleaned.csv'))

print(f"영상 단위: {len(orbital)}건")
print(f"환자 단위: {len(patient)}명")

# ============================================================
# 분석용 헬퍼 함수
# ============================================================
def wilson_ci(p, n, z=1.96):
    """Wilson score interval for proportion"""
    if n == 0:
        return (0, 0)
    denom = 1 + z**2 / n
    center = (p + z**2 / (2*n)) / denom
    spread = z * np.sqrt((p*(1-p) + z**2/(4*n)) / n) / denom
    return (max(0, center - spread), min(1, center + spread))

# ============================================================
# TABLE 1: Patient Demographics & Disease Distribution
# ============================================================
print(f"\n{'='*60}")
print("TABLE 1: Disease Distribution")
print("="*60)

# 진단 카테고리 순서
diag_order = ['TED', 'Lymphoma', 'Benign tumor', 'Other orbital disease',
              'Pseudotumor', 'Cavernous hemangioma', 'Pleomorphic adenoma',
              'Meningioma', 'Malignant tumor', 'IgG4-RD', 'Lymphangioma', 'Other']

table1_rows = []
for cat in diag_order:
    pt_count = (patient['진단카테고리'] == cat).sum()
    img_count = (orbital['진단카테고리'] == cat).sum()
    if pt_count > 0:
        table1_rows.append({
            'Diagnosis': cat,
            'Patients_n': pt_count,
            'Patients_pct': pt_count / len(patient) * 100,
            'Images_n': img_count,
            'Images_pct': img_count / len(orbital) * 100,
        })

table1 = pd.DataFrame(table1_rows)
# Total row
table1.loc[len(table1)] = ['Total', len(patient), 100.0, len(orbital), 100.0]

print(table1.to_string(index=False))
table1.to_csv(os.path.join(RESULTS_DIR, 'table1_disease_distribution.csv'), index=False)

# 영상 종류별 분포
print(f"\n영상 종류 분포:")
img_dist = orbital['영상카테고리'].value_counts()
for img, cnt in img_dist.items():
    print(f"  {img}: {cnt} ({cnt/len(orbital)*100:.1f}%)")

# 병원별 분포
print(f"\n병원 분포:")
hosp = orbital['병원'].value_counts()
for h, cnt in hosp.items():
    print(f"  {h}: {cnt}")

# 검사 연도 범위
orbital['검사년도'] = pd.to_numeric(orbital['검사일'].astype(str).str[:4], errors='coerce')
yr_min, yr_max = orbital['검사년도'].min(), orbital['검사년도'].max()
print(f"\n검사 기간: {yr_min:.0f} ~ {yr_max:.0f}")

# 연도별 건수
yearly = orbital.groupby('검사년도').size()
print(f"\n연도별 건수:")
for yr, cnt in yearly.items():
    if not np.isnan(yr):
        print(f"  {yr:.0f}: {cnt}")

# ============================================================
# TABLE 2: Diagnostic Accuracy of Radiology Reports
# ============================================================
print(f"\n{'='*60}")
print("TABLE 2: Diagnostic Accuracy")
print("="*60)

# 판독문이 있는 건만
has_report = orbital[orbital['판독분류'] != 'no_report'].copy()
print(f"판독문 있는 건: {len(has_report)}")

table2_rows = []
report_keywords_map = {
    'TED': '판독_TED',
    'Lymphoma': '판독_Lymphoma',
    'Pseudotumor': '판독_Pseudotumor',
    'Cavernous hemangioma': '판독_Cavernous hemangioma',
    'Pleomorphic adenoma': '판독_Pleomorphic adenoma',
    'Meningioma': '판독_Meningioma',
    'IgG4-RD': '판독_IgG4-RD',
}

for cat, col in report_keywords_map.items():
    if col not in has_report.columns:
        continue

    # True Positive: 해당 질환이고 판독문에 언급됨
    is_disease = has_report['진단카테고리'] == cat
    is_mentioned = has_report[col] == True

    tp = (is_disease & is_mentioned).sum()
    fn = (is_disease & ~is_mentioned).sum()
    fp = (~is_disease & is_mentioned).sum()
    tn = (~is_disease & ~is_mentioned).sum()

    n_disease = tp + fn
    sensitivity = tp / n_disease if n_disease > 0 else 0
    specificity = tn / (tn + fp) if (tn + fp) > 0 else 0
    ppv = tp / (tp + fp) if (tp + fp) > 0 else 0
    npv = tn / (tn + fn) if (tn + fn) > 0 else 0

    sens_ci = wilson_ci(sensitivity, n_disease)
    spec_ci = wilson_ci(specificity, tn + fp)

    table2_rows.append({
        'Diagnosis': cat,
        'N_confirmed': n_disease,
        'TP': tp,
        'FN': fn,
        'FP': fp,
        'TN': tn,
        'Sensitivity': sensitivity,
        'Sens_95CI_low': sens_ci[0],
        'Sens_95CI_high': sens_ci[1],
        'Specificity': specificity,
        'Spec_95CI_low': spec_ci[0],
        'Spec_95CI_high': spec_ci[1],
        'PPV': ppv,
        'NPV': npv,
    })

    print(f"\n{cat} (n={n_disease}):")
    print(f"  Sensitivity: {sensitivity:.1%} ({sens_ci[0]:.1%}-{sens_ci[1]:.1%})")
    print(f"  Specificity: {specificity:.1%}")
    print(f"  PPV: {ppv:.1%}, NPV: {npv:.1%}")

table2 = pd.DataFrame(table2_rows)
table2.to_csv(os.path.join(RESULTS_DIR, 'table2_diagnostic_accuracy.csv'), index=False)

# 양성종양은 키워드가 다양하므로 mass/lesion 언급률로 대체
benign = has_report[has_report['진단카테고리'] == 'Benign tumor']
benign_mass = benign['판독_mass'].sum()
print(f"\nBenign tumor (n={len(benign)}):")
print(f"  Mass/lesion 언급: {benign_mass}/{len(benign)} ({benign_mass/max(len(benign),1)*100:.1f}%)")

# ============================================================
# TABLE 3: Biopsy Analysis
# ============================================================
print(f"\n{'='*60}")
print("TABLE 3: Biopsy Analysis")
print("="*60)

table3_rows = []
for cat in diag_order:
    subset = orbital[orbital['진단카테고리'] == cat]
    if len(subset) == 0:
        continue
    biopsy_done = subset['조직검사시행'].sum()
    eye_specimen = (subset['검체분류'] == 'ophthalmic').sum()
    non_eye = (subset['검체분류'] == 'non-ophthalmic').sum()

    table3_rows.append({
        'Diagnosis': cat,
        'Total': len(subset),
        'Biopsy_done': biopsy_done,
        'Biopsy_rate': biopsy_done / len(subset) * 100,
        'Ophthalmic_specimen': eye_specimen,
        'Non_ophthalmic': non_eye,
    })

    print(f"{cat}: biopsy {biopsy_done}/{len(subset)} ({biopsy_done/len(subset)*100:.1f}%), "
          f"eye: {eye_specimen}, non-eye: {non_eye}")

table3 = pd.DataFrame(table3_rows)
table3.to_csv(os.path.join(RESULTS_DIR, 'table3_biopsy.csv'), index=False)

# ============================================================
# TABLE 4: Report Quality - "Entirely Normal" in confirmed disease
# ============================================================
print(f"\n{'='*60}")
print("TABLE 4: Uninformative Reports")
print("="*60)

table4_rows = []
for cat in diag_order:
    subset = has_report[has_report['진단카테고리'] == cat]
    if len(subset) == 0:
        continue
    entirely_normal = (subset['판독분류'] == 'entirely_normal').sum()
    rate = entirely_normal / len(subset) * 100
    table4_rows.append({
        'Diagnosis': cat,
        'N_with_report': len(subset),
        'Entirely_normal': entirely_normal,
        'Normal_rate': rate,
    })
    print(f"{cat}: 'entirely normal' {entirely_normal}/{len(subset)} ({rate:.1f}%)")

table4 = pd.DataFrame(table4_rows)
table4.to_csv(os.path.join(RESULTS_DIR, 'table4_report_quality.csv'), index=False)

# ============================================================
# TABLE 5: Diagnosis Change Patterns
# ============================================================
print(f"\n{'='*60}")
print("TABLE 5: Diagnosis Change Patterns")
print("="*60)

changed = orbital[orbital['진단변경'] == True][['초기진단', '최종진단']].copy()
change_patterns = changed.groupby(['초기진단', '최종진단']).size().reset_index(name='count')
change_patterns = change_patterns.sort_values('count', ascending=False)

print(f"\n진단 변경 패턴 (상위 15개):")
for _, row in change_patterns.head(15).iterrows():
    print(f"  {row['초기진단']} → {row['최종진단']}: {row['count']}건")

change_patterns.to_csv(os.path.join(RESULTS_DIR, 'table5_diagnosis_change.csv'), index=False)

# ============================================================
# 영상 종류별 진단 정확도 비교
# ============================================================
print(f"\n{'='*60}")
print("Supplementary: 영상 종류별 Sensitivity 비교")
print("="*60)

for img_cat in ['CT_CE', 'MRI_CE', 'CT_NCE']:
    img_subset = has_report[has_report['영상카테고리'] == img_cat]
    print(f"\n{img_cat} (n={len(img_subset)}):")
    for cat, col in report_keywords_map.items():
        if col not in img_subset.columns:
            continue
        disease = img_subset[img_subset['진단카테고리'] == cat]
        if len(disease) < 5:
            continue
        detected = disease[col].sum()
        sens = detected / len(disease) * 100
        print(f"  {cat}: {detected}/{len(disease)} ({sens:.1f}%)")

# ============================================================
# 림프종 하위분석: 결막 vs 안와
# ============================================================
print(f"\n{'='*60}")
print("Supplementary: 림프종 하위분석")
print("="*60)

lymph_report = has_report[has_report['진단카테고리'] == 'Lymphoma']
for loc in ['conjunctival', 'orbital', 'no_biopsy', 'other']:
    subset = lymph_report[lymph_report['림프종위치'] == loc]
    if len(subset) == 0:
        continue
    mentioned = subset['판독_Lymphoma'].sum()
    normal = (subset['판독분류'] == 'entirely_normal').sum()
    mass = subset['판독_mass'].sum()
    print(f"\n{loc} (n={len(subset)}):")
    print(f"  Lymphoma 언급: {mentioned} ({mentioned/len(subset)*100:.1f}%)")
    print(f"  Mass/lesion 언급: {mass} ({mass/len(subset)*100:.1f}%)")
    print(f"  Entirely normal: {normal} ({normal/len(subset)*100:.1f}%)")

# ============================================================
# 최종 요약
# ============================================================
summary = f"""
{'='*60}
분석 결과 요약
{'='*60}

■ 대상: {len(orbital)}건, {len(patient)}명
■ 검사 기간: {yr_min:.0f}-{yr_max:.0f}
■ 판독문 있는 건: {len(has_report)}건

■ Primary Endpoint - 진단별 Sensitivity:
"""

for _, row in table2.iterrows():
    summary += f"  {row['Diagnosis']}: {row['Sensitivity']:.1%} "
    summary += f"({row['Sens_95CI_low']:.1%}-{row['Sens_95CI_high']:.1%}), n={row['N_confirmed']}\n"

summary += f"""
■ 저장된 파일:
  {RESULTS_DIR}/table1_disease_distribution.csv
  {RESULTS_DIR}/table2_diagnostic_accuracy.csv
  {RESULTS_DIR}/table3_biopsy.csv
  {RESULTS_DIR}/table4_report_quality.csv
  {RESULTS_DIR}/table5_diagnosis_change.csv

■ 다음 단계: module3_figures.py 실행 (그래프 생성)
"""
print(summary)

with open(os.path.join(RESULTS_DIR, 'analysis_summary.txt'), 'w', encoding='utf-8') as f:
    f.write(summary)
