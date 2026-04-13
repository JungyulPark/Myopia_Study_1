"""
논문 1 - Module 4: 검증 + 보완 분석
=====================================
1. 무작위 100건 검증 세트 생성 (수작업 검증용)
2. TED 조직검사 검체 확인
3. 림프종 결막/안와 분리 sensitivity
4. CT vs MRI sensitivity 비교
5. 환자 단위 sensitivity (보완)

실행: python module4_validation.py
"""

import pandas as pd
import numpy as np
import os
import random

OUTPUT_DIR = r"paper1_output"
RESULTS_DIR = os.path.join(OUTPUT_DIR, "results")
VALID_DIR = os.path.join(OUTPUT_DIR, "validation")
os.makedirs(VALID_DIR, exist_ok=True)

orbital = pd.read_csv(os.path.join(OUTPUT_DIR, 'orbital_cleaned.csv'))
print("=" * 60)
print("Module 4: 검증 + 보완 분석")
print("=" * 60)

# ============================================================
# 1. 무작위 100건 검증 세트
# ============================================================
print(f"\n{'='*60}")
print("1. 무작위 100건 검증 세트 생성")
print("="*60)

has_report = orbital[orbital['판독분류'] != 'no_report'].copy()

# Stratified sampling: 주요 진단에서 비례 추출
random.seed(42)
np.random.seed(42)

# 질환별 비율에 맞춰 100건 추출
diag_counts = has_report['진단카테고리'].value_counts()
total = len(has_report)
sample_indices = []

for diag, count in diag_counts.items():
    n_sample = max(1, round(count / total * 100))  # 최소 1건
    diag_subset = has_report[has_report['진단카테고리'] == diag]
    n_actual = min(n_sample, len(diag_subset))
    sampled = diag_subset.sample(n=n_actual, random_state=42)
    sample_indices.extend(sampled.index.tolist())

# 100건 맞추기
if len(sample_indices) > 100:
    sample_indices = random.sample(sample_indices, 100)
elif len(sample_indices) < 100:
    remaining = has_report[~has_report.index.isin(sample_indices)]
    extra = remaining.sample(n=100-len(sample_indices), random_state=42)
    sample_indices.extend(extra.index.tolist())

validation_set = has_report.loc[sample_indices].copy()

# 검증용 컬럼 생성
validation_output = validation_set[['ID', '영상종류', '진단카테고리', '최종진단', '판독분류', '판독문']].copy()

# 자동 분류 결과 컬럼 추가
for col in ['판독_TED', '판독_Lymphoma', '판독_Pseudotumor',
            '판독_Cavernous hemangioma', '판독_Pleomorphic adenoma',
            '판독_Meningioma', '판독_IgG4-RD', '판독_mass']:
    if col in validation_set.columns:
        validation_output[f'자동_{col}'] = validation_set[col]

# 수작업 검증 컬럼 (빈칸)
validation_output['수작업_정확'] = ''  # Y/N
validation_output['수작업_코멘트'] = ''

# 판독문은 200자로 자르기 (너무 길면 검토 어려움)
validation_output['판독문_요약'] = validation_output['판독문'].str[:300]

validation_output.to_excel(os.path.join(VALID_DIR, 'validation_100cases.xlsx'), index=False)
print(f"검증 세트 저장: {VALID_DIR}/validation_100cases.xlsx")
print(f"진단별 분포:")
print(validation_output['진단카테고리'].value_counts().to_string())

print(f"""
[검증 방법]
1. validation_100cases.xlsx 열기
2. 각 건의 '판독문_요약'과 '자동_*' 컬럼 비교
3. 자동 분류가 맞으면 '수작업_정확'에 Y, 틀리면 N
4. 틀린 경우 '수작업_코멘트'에 이유 기재
5. 완료 후 정확도 = Y 개수 / 100
→ Methods에 "무작위 추출 100건에 대해 수작업 검증하여 정확도 XX%를 확인"으로 기술
""")

# ============================================================
# 2. TED 조직검사 검체 확인
# ============================================================
print(f"\n{'='*60}")
print("2. TED 조직검사 검체 확인")
print("="*60)

ted = orbital[orbital['진단카테고리'] == 'TED']
ted_biopsy = ted[ted['조직검사시행'] == True]
print(f"TED 전체: {len(ted)}건")
print(f"TED 조직검사 시행: {len(ted_biopsy)}건 ({len(ted_biopsy)/len(ted)*100:.1f}%)")

print(f"\nTED 조직검사 검체 분류:")
for cls, cnt in ted_biopsy['검체분류'].value_counts().items():
    print(f"  {cls}: {cnt}")

ted_eye_biopsy = ted_biopsy[ted_biopsy['검체분류'] == 'ophthalmic']
ted_noneye_biopsy = ted_biopsy[ted_biopsy['검체분류'] == 'non-ophthalmic']
print(f"\n→ 안과 검체만: {len(ted_eye_biopsy)}건 ({len(ted_eye_biopsy)/len(ted)*100:.1f}%)")
print(f"→ 비안과 검체: {len(ted_noneye_biopsy)}건 (위장/갑상선 등)")
print(f"\n★ 결론: TED 환자의 실제 안과 조직검사율 = {len(ted_eye_biopsy)/len(ted)*100:.1f}%")
print(f"  (19.6%가 아니라 이 수치가 정확합니다)")

if len(ted_eye_biopsy) > 0:
    print(f"\nTED 안과 조직검사 검체 부위:")
    for spec, cnt in ted_eye_biopsy['검체부위'].value_counts().head(10).items():
        print(f"  {spec}: {cnt}")

# ============================================================
# 3. 림프종 결막/안와 분리 Sensitivity
# ============================================================
print(f"\n{'='*60}")
print("3. 림프종 결막/안와 분리 Sensitivity")
print("="*60)

lymph = has_report[has_report['진단카테고리'] == 'Lymphoma'].copy()

# 림프종위치별 sensitivity
for loc in ['conjunctival', 'orbital', 'no_biopsy', 'other']:
    subset = lymph[lymph['림프종위치'] == loc]
    if len(subset) == 0:
        continue
    mentioned = subset['판독_Lymphoma'].sum() if '판독_Lymphoma' in subset.columns else 0
    mass_found = subset['판독_mass'].sum() if '판독_mass' in subset.columns else 0
    normal = (subset['판독분류'] == 'entirely_normal').sum()

    print(f"\n{loc} lymphoma (n={len(subset)}):")
    print(f"  Lymphoma 언급 (sensitivity): {mentioned}/{len(subset)} ({mentioned/len(subset)*100:.1f}%)")
    print(f"  Mass/lesion 언급: {mass_found}/{len(subset)} ({mass_found/len(subset)*100:.1f}%)")
    print(f"  Entirely normal report: {normal}/{len(subset)} ({normal/len(subset)*100:.1f}%)")

print(f"\n★ 핵심: 결막림프종은 영상에서 안 보이므로 sensitivity가 낮은 것이 정상")
print(f"  → 논문에서 결막/안와 분리하여 보고 필수")

# ============================================================
# 4. CT vs MRI Sensitivity 비교
# ============================================================
print(f"\n{'='*60}")
print("4. CT vs MRI Sensitivity 비교")
print("="*60)

report_kw_map = {
    'TED': '판독_TED',
    'Lymphoma': '판독_Lymphoma',
    'Pseudotumor': '판독_Pseudotumor',
    'Cavernous hemangioma': '판독_Cavernous hemangioma',
}

ct_all = has_report[has_report['영상카테고리'].isin(['CT_CE', 'CT_NCE'])]
mri_all = has_report[has_report['영상카테고리'] == 'MRI_CE']

print(f"\nCT 전체: {len(ct_all)}건, MRI 전체: {len(mri_all)}건")
print(f"\n{'Diagnosis':<25} {'CT_n':>5} {'CT_sens':>8} {'MRI_n':>6} {'MRI_sens':>9}")
print("-" * 60)

ct_vs_mri_rows = []
for cat, col in report_kw_map.items():
    if col not in has_report.columns:
        continue
    # CT
    ct_disease = ct_all[ct_all['진단카테고리'] == cat]
    ct_detected = ct_disease[col].sum() if len(ct_disease) > 0 else 0
    ct_sens = ct_detected / len(ct_disease) * 100 if len(ct_disease) > 0 else 0

    # MRI
    mri_disease = mri_all[mri_all['진단카테고리'] == cat]
    mri_detected = mri_disease[col].sum() if len(mri_disease) > 0 else 0
    mri_sens = mri_detected / len(mri_disease) * 100 if len(mri_disease) > 0 else 0

    print(f"{cat:<25} {len(ct_disease):>5} {ct_sens:>7.1f}% {len(mri_disease):>6} {mri_sens:>8.1f}%")

    ct_vs_mri_rows.append({
        'Diagnosis': cat,
        'CT_n': len(ct_disease), 'CT_detected': ct_detected, 'CT_sensitivity': ct_sens,
        'MRI_n': len(mri_disease), 'MRI_detected': mri_detected, 'MRI_sensitivity': mri_sens,
    })

ct_mri_df = pd.DataFrame(ct_vs_mri_rows)
ct_mri_df.to_csv(os.path.join(RESULTS_DIR, 'supp_ct_vs_mri.csv'), index=False)

# ============================================================
# 5. 환자 단위 Sensitivity (보완 분석)
# ============================================================
print(f"\n{'='*60}")
print("5. 환자 단위 Sensitivity")
print("="*60)

# 환자별로: 한 번이라도 판독문에 정확한 진단이 언급된 적 있는지
patient_level = has_report.groupby('ID').agg(
    진단카테고리=('진단카테고리', 'last'),
    영상수=('판독문', 'count'),
).reset_index()

for cat, col in report_kw_map.items():
    if col not in has_report.columns:
        continue
    # 환자별: 해당 진단이고, 한 건이라도 True인 환자
    disease_patients = has_report[has_report['진단카테고리'] == cat]
    patient_ever_detected = disease_patients.groupby('ID')[col].any()
    n_patients = len(patient_ever_detected)
    n_detected = patient_ever_detected.sum()
    sens = n_detected / n_patients * 100 if n_patients > 0 else 0
    print(f"{cat}: {n_detected}/{n_patients} patients ({sens:.1f}%)")

# ============================================================
# 6. "Entirely normal" 판독의 상세 확인
# ============================================================
print(f"\n{'='*60}")
print("6. 'Entirely normal' 판독 상세 확인 (표본)")
print("="*60)

normal_reports = has_report[has_report['판독분류'] == 'entirely_normal']
print(f"Entirely normal 판독: {len(normal_reports)}건")

# 질환별
print(f"\n질환별 'entirely normal' 건수:")
for cat, cnt in normal_reports['진단카테고리'].value_counts().items():
    total_cat = len(has_report[has_report['진단카테고리'] == cat])
    print(f"  {cat}: {cnt}/{total_cat} ({cnt/total_cat*100:.1f}%)")

# 표본 5건 출력 (내용 확인용)
print(f"\n표본 5건 (판독문 전문):")
for _, row in normal_reports.head(5).iterrows():
    print(f"\n  [{row['ID']}] {row['진단카테고리']} | {row['영상종류']}")
    report = str(row['판독문'])[:200]
    print(f"  판독문: {report}")

# ============================================================
# 7. 진단 변경 상세 (초기→최종)
# ============================================================
print(f"\n{'='*60}")
print("7. 초기 진단 오류 패턴 (진단 변경 건)")
print("="*60)

changed = orbital[orbital['진단변경'] == True].copy()
# 초기진단 → 최종진단 카테고리 매핑
DIAG_CATEGORY = {
    '갑상선 눈병증': 'TED', '안와림프종': 'Lymphoma', '양성종양': 'Benign tumor',
    '안와질환': 'Other orbital disease', '가성종양': 'Pseudotumor',
    '해면혈관종': 'Cavernous hemangioma', '다형샘종': 'Pleomorphic adenoma',
    '메닌지오마': 'Meningioma', '악성종양': 'Malignant tumor',
    '안와 악성종양': 'Malignant tumor', 'IgG4 관련질환': 'IgG4-RD',
    '림프관종': 'Lymphangioma',
}
changed['초기카테고리'] = changed['초기진단'].map(DIAG_CATEGORY).fillna('Other')
changed['최종카테고리'] = changed['최종진단'].map(DIAG_CATEGORY).fillna('Other')

# 가장 흔한 오인 패턴
patterns = changed.groupby(['초기카테고리', '최종카테고리']).size().reset_index(name='count')
patterns = patterns.sort_values('count', ascending=False)
print(f"\n초기 → 최종 진단 변경 패턴 (상위 10):")
for _, row in patterns.head(10).iterrows():
    print(f"  {row['초기카테고리']} → {row['최종카테고리']}: {row['count']}건")

# 림프종으로 최종 진단된 건의 초기 진단
lymph_final = changed[changed['최종카테고리'] == 'Lymphoma']
print(f"\n★ 최종 림프종 진단의 초기 진단:")
for init, cnt in lymph_final['초기카테고리'].value_counts().items():
    print(f"  {init}: {cnt}건")

patterns.to_csv(os.path.join(RESULTS_DIR, 'supp_diagnosis_change_detail.csv'), index=False)

# ============================================================
print(f"\n{'='*60}")
print("Module 4 완료")
print("="*60)
print(f"""
[다음 단계]
1. validation_100cases.xlsx를 열어서 100건 수작업 검증 수행
2. 결과를 여기로 공유 → 정확도 계산
3. 보완 분석 수치 확인 후 → 논문 작성 시작
""")
