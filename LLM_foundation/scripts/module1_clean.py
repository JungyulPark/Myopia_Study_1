"""
논문 1 - Module 1: 데이터 정제 (Data Cleaning)
================================================
입력: SR202503119329_안과_박정열_산출물3_데이터_v1_0_1_.xlsx
출력: orbital_cleaned.csv (정제 완료 데이터)

실행: python module1_clean.py
"""

import pandas as pd
import numpy as np
import re
import os

# ============================================================
# 경로 설정 — 필요시 수정
# ============================================================
INPUT_XLSX = r"SR202503119329_안과_박정열_산출물3.데이터_v1.0(1).xlsx"
OUTPUT_DIR = r"paper1_output"
os.makedirs(OUTPUT_DIR, exist_ok=True)

# ============================================================
# 1. 데이터 로드
# ============================================================
print("=" * 60)
print("Module 1: 데이터 정제")
print("=" * 60)

s1 = pd.read_excel(INPUT_XLSX, sheet_name='데이터_영상촬영 일회성', skiprows=1)
s2 = pd.read_excel(INPUT_XLSX, sheet_name='데이터_영상촬영 다수', skiprows=1)
s3 = pd.read_excel(INPUT_XLSX, sheet_name='데이터_안와골절', skiprows=1)

cols = ['병원', 'ID', '영상종류', '검사일', '판독문', '진단코드', '진단그룹', '조직검사', '조직검사결과']
for df in [s1, s2, s3]:
    df.columns = cols

s1['시트'] = '일회성'
s2['시트'] = '다수'
s3['시트'] = '골절'

all_data = pd.concat([s1, s2, s3], ignore_index=True)
print(f"\n전체 로드: {len(all_data)}건")

# ============================================================
# 2. 제외 기준 적용
# ============================================================
# PET-CT 제외
pet_mask = all_data['영상종류'].str.contains('PET', na=False)
excluded_pet = pet_mask.sum()
df = all_data[~pet_mask].copy()
print(f"PET-CT 제외: {excluded_pet}건 → 남은: {len(df)}건")

# 안와골절은 별도 코호트 → 메인 분석에서 분리
fracture = df[df['시트'] == '골절'].copy()
orbital = df[df['시트'] != '골절'].copy()
print(f"안와골절 분리: {len(fracture)}건 → 분석 대상: {len(orbital)}건")

# ============================================================
# 3. 복수 진단 처리: 마지막 진단 = 최종 진단
# ============================================================
def parse_diagnosis(diag_group):
    """복수 진단에서 최종(마지막) 진단 추출"""
    if pd.isna(diag_group):
        return None, None, 1, False
    parts = str(diag_group).split('\n')
    parts = [p.strip() for p in parts if p.strip()]
    final = parts[-1] if parts else None
    initial = parts[0] if parts else None
    n_diag = len(parts)
    changed = (n_diag > 1 and initial != final)
    return final, initial, n_diag, changed

orbital[['최종진단', '초기진단', '진단수', '진단변경']] = orbital['진단그룹'].apply(
    lambda x: pd.Series(parse_diagnosis(x))
)

n_multi = (orbital['진단수'] > 1).sum()
n_changed = orbital['진단변경'].sum()
print(f"\n복수 진단: {n_multi}건 ({n_multi/len(orbital)*100:.1f}%)")
print(f"진단 변경: {n_changed}건")

# ============================================================
# 4. 진단 카테고리 매핑
# ============================================================
DIAG_CATEGORY = {
    '갑상선 눈병증': 'TED',
    '안와림프종': 'Lymphoma',
    '양성종양': 'Benign tumor',
    '안와질환': 'Other orbital disease',
    '가성종양': 'Pseudotumor',
    '해면혈관종': 'Cavernous hemangioma',
    '다형샘종': 'Pleomorphic adenoma',
    '메닌지오마': 'Meningioma',
    '악성종양': 'Malignant tumor',
    '안와 악성종양': 'Malignant tumor',
    'IgG4 관련질환': 'IgG4-RD',
    '림프관종': 'Lymphangioma',
}

orbital['진단카테고리'] = orbital['최종진단'].map(DIAG_CATEGORY).fillna('Other')

print(f"\n진단 카테고리 분포:")
for cat, cnt in orbital['진단카테고리'].value_counts().items():
    print(f"  {cat}: {cnt} ({cnt/len(orbital)*100:.1f}%)")

# ============================================================
# 5. 조직검사 정제
# ============================================================
# 조직검사 컬럼: 0=시행, 1=미시행
orbital['조직검사시행'] = (orbital['조직검사'] == 0)
orbital['조직검사결과있음'] = orbital['조직검사결과'].notna()

# 검체 부위 추출
def extract_specimen_site(text):
    if pd.isna(text):
        return None
    patterns = [
        r'대표검체\s*:\s*(.+?)(?:_x000D_|\n|$)',
        r'세부검체\s*:\s*(.+?)(?:_x000D_|\n|$)',
    ]
    specimens = []
    for p in patterns:
        m = re.search(p, str(text))
        if m:
            specimens.append(m.group(1).strip())
    return ' / '.join(specimens) if specimens else None

orbital['검체부위'] = orbital['조직검사결과'].apply(extract_specimen_site)

# 안과 vs 비안과 검체 분류
eye_kw = ['orbit', 'conjunctiv', 'eyelid', 'eyeball', 'globe', 'lacrimal',
           'lid', 'retrobulbar', 'periorbital', 'levator', 'tarsal',
           'extraocular', 'optic', 'ocular', 'canthus', 'fornix',
           'caruncle', 'sac', 'dacryocyst']
non_eye_kw = ['breast', 'stomach', 'colon', 'liver', 'lung', 'kidney',
              'prostate', 'thyroid', 'cervix', 'uterus', 'ovary',
              'bone marrow', 'lymph node', 'tonsil', 'parotid',
              'nasopharynx', 'oropharynx', 'palate', 'tongue',
              'tympanic', 'ear', 'paranasal', 'maxill', 'rectum',
              'skin.*leg', 'skin.*arm', 'skin.*back', 'skin.*chest',
              'skin.*thigh', 'skin.*abdomen']

def classify_specimen(row):
    if pd.isna(row['조직검사결과']):
        return 'N/A'
    combined = (str(row['조직검사결과']) + ' ' + str(row.get('검체부위', ''))).lower()
    is_eye = any(re.search(kw, combined) for kw in eye_kw)
    is_non = any(re.search(kw, combined) for kw in non_eye_kw)
    if is_eye and not is_non:
        return 'ophthalmic'
    elif is_non and not is_eye:
        return 'non-ophthalmic'
    elif is_eye and is_non:
        return 'uncertain'
    else:
        return 'unclassified'

orbital['검체분류'] = orbital.apply(classify_specimen, axis=1)

print(f"\n조직검사 검체 분류:")
for cls, cnt in orbital['검체분류'].value_counts().items():
    print(f"  {cls}: {cnt}")

# ============================================================
# 6. 판독문 분석 — "No finding" 정확한 재분류
# ============================================================
def classify_report(report):
    """
    판독문 분류:
    - 'no_report': 판독문 없음
    - 'entirely_normal': 전체 판독이 정상/특이소견 없음
    - 'has_finding': 병변이 기술되어 있음 (일부 "otherwise unremarkable" 포함 가능)
    """
    if pd.isna(report) or str(report).strip() == '':
        return 'no_report'

    text = str(report).strip()

    # CONCLUSION 또는 전체 텍스트에서 핵심 내용만 추출
    # "No remarkable finding" 류가 판독문의 핵심인 경우
    # 짧은 판독문 (200자 미만)이면서 no finding 패턴만 있는 경우
    normal_patterns = [
        r'No remarkable finding',
        r'No definite abnormality',
        r'Negative finding',
        r'Unremarkable finding',
        r'No significant finding',
        r'No visible lesion',
        r'No interval change',  # f/u에서 변화 없음
    ]

    # 종괴/병변을 기술하는 키워드
    finding_patterns = [
        r'\d+\s*(?:mm|cm)',  # 크기 측정치
        r'mass\b', r'lesion\b', r'tumor\b', r'tumour\b',
        r'enlargement', r'thicken', r'enhanc',
        r'infiltrat', r'swelling', r'nodule', r'nodular',
        r'종괴', r'비후', r'비대',
    ]

    has_normal = any(re.search(p, text, re.IGNORECASE) for p in normal_patterns)
    has_finding = any(re.search(p, text, re.IGNORECASE) for p in finding_patterns)

    if has_finding:
        return 'has_finding'
    elif has_normal:
        return 'entirely_normal'
    else:
        # 판독문이 있지만 위 패턴에 안 걸리는 경우
        # 짧은 판독문이면 normal로, 긴 판독문이면 has_finding으로
        if len(text) < 150:
            return 'entirely_normal'
        else:
            return 'has_finding'

orbital['판독분류'] = orbital['판독문'].apply(classify_report)

print(f"\n판독문 분류:")
for cls, cnt in orbital['판독분류'].value_counts().items():
    pct = cnt / len(orbital) * 100
    print(f"  {cls}: {cnt} ({pct:.1f}%)")

# ============================================================
# 7. 판독문 진단 키워드 추출
# ============================================================
# 각 질환별 판독문 내 키워드
REPORT_KEYWORDS = {
    'TED': [r'thyroid', r'\btao\b', r'graves', r'dysthyroid', r'갑상선'],
    'Lymphoma': [r'lymphoma', r'\bmalt\b', r'lymphoproliferative', r'림프종'],
    'Pseudotumor': [r'pseudotumor', r'pseudo-tumor', r'pseudo tumor',
                    r'idiopathic orbital inflamm', r'\biois\b', r'\bioid\b',
                    r'가성종양', r'orbital inflammat'],
    'Cavernous hemangioma': [r'hemangioma', r'haemangioma', r'cavernous venous',
                             r'혈관종'],
    'Pleomorphic adenoma': [r'pleomorphic adenoma', r'mixed tumor', r'다형샘종',
                            r'pleomorphic'],
    'Meningioma': [r'meningioma', r'수막종'],
    'IgG4-RD': [r'igg4', r'igg-4'],
}

for cat, keywords in REPORT_KEYWORDS.items():
    pattern = '|'.join(keywords)
    col_name = f'판독_{cat}'
    orbital[col_name] = orbital['판독문'].str.contains(pattern, case=False, na=False)

# mass/lesion 언급 여부 (범용)
orbital['판독_mass'] = orbital['판독문'].str.contains(
    r'mass|lesion|tumor|tumour|nodule|nodular|종괴', case=False, na=False
)

print(f"\n판독문 진단 키워드 감지율:")
for cat in REPORT_KEYWORDS:
    col = f'판독_{cat}'
    subset = orbital[orbital['진단카테고리'] == cat]
    if len(subset) > 0:
        detected = subset[col].sum()
        print(f"  {cat}: {detected}/{len(subset)} ({detected/len(subset)*100:.1f}%)")

# ============================================================
# 8. 림프종 하위분류 (결막 vs 안와)
# ============================================================
def classify_lymphoma_site(row):
    if row['진단카테고리'] != 'Lymphoma':
        return 'N/A'
    biopsy = str(row['조직검사결과']).lower() if pd.notna(row['조직검사결과']) else ''
    specimen = str(row.get('검체부위', '')).lower()
    combined = biopsy + ' ' + specimen
    if 'conjunctiv' in combined:
        return 'conjunctival'
    elif any(kw in combined for kw in ['orbit', 'lacrimal', 'eyelid', 'lid',
                                        'retrobulbar', 'soft tissue', 'eyeball']):
        return 'orbital'
    elif pd.isna(row['조직검사결과']):
        return 'no_biopsy'
    else:
        return 'other'

orbital['림프종위치'] = orbital.apply(classify_lymphoma_site, axis=1)

lymph = orbital[orbital['진단카테고리'] == 'Lymphoma']
print(f"\n림프종 하위분류:")
for loc, cnt in lymph['림프종위치'].value_counts().items():
    print(f"  {loc}: {cnt}")

# ============================================================
# 9. 영상 종류 정리
# ============================================================
IMG_MAP = {
    'Orbit CT(CE)': 'CT_CE',
    'Orbit CT(NCE)': 'CT_NCE',
    'Orbit MR(CE)': 'MRI_CE',
    'Facial CT(NCE)': 'Facial_CT',
}
orbital['영상카테고리'] = orbital['영상종류'].map(IMG_MAP).fillna('Other')

# ============================================================
# 10. 환자 단위 데이터 생성
# ============================================================
# 환자별 첫 영상의 정보 사용
patient_df = orbital.sort_values('검사일').groupby('ID').agg(
    최종진단=('최종진단', 'last'),
    진단카테고리=('진단카테고리', 'last'),
    영상건수=('판독문', 'count'),
    첫검사일=('검사일', 'first'),
    마지막검사일=('검사일', 'last'),
    진단변경=('진단변경', 'any'),
    조직검사시행=('조직검사시행', 'any'),
    시트=('시트', 'first'),
    병원=('병원', 'first'),
).reset_index()

print(f"\n환자 단위: {len(patient_df)}명")

# ============================================================
# 11. 저장
# ============================================================
# 영상 단위
orbital.to_csv(os.path.join(OUTPUT_DIR, 'orbital_cleaned.csv'), index=False, encoding='utf-8-sig')
# 환자 단위
patient_df.to_csv(os.path.join(OUTPUT_DIR, 'patient_cleaned.csv'), index=False, encoding='utf-8-sig')
# 골절 (별도)
fracture.to_csv(os.path.join(OUTPUT_DIR, 'fracture_cleaned.csv'), index=False, encoding='utf-8-sig')

print(f"\n저장 완료:")
print(f"  {OUTPUT_DIR}/orbital_cleaned.csv ({len(orbital)}건)")
print(f"  {OUTPUT_DIR}/patient_cleaned.csv ({len(patient_df)}명)")
print(f"  {OUTPUT_DIR}/fracture_cleaned.csv ({len(fracture)}건)")

# ============================================================
# 12. 정제 요약 리포트
# ============================================================
summary = f"""
{'='*60}
데이터 정제 요약 리포트
{'='*60}

■ 원본: {len(all_data)}건
  - PET-CT 제외: {excluded_pet}건
  - 안와골절 분리: {len(fracture)}건
  → 분석 대상: {len(orbital)}건, {len(patient_df)}명

■ 진단 처리
  - 단일 진단: {(orbital['진단수']==1).sum()}건 ({(orbital['진단수']==1).sum()/len(orbital)*100:.1f}%)
  - 복수 진단: {n_multi}건 → 마지막 진단을 최종진단으로 사용
  - 진단 변경 건: {n_changed}건

■ 조직검사
  - 시행: {orbital['조직검사시행'].sum()}건
  - 안과 검체: {(orbital['검체분류']=='ophthalmic').sum()}건
  - 비안과 검체: {(orbital['검체분류']=='non-ophthalmic').sum()}건 (분석 제외)

■ 판독문
  - 있음(finding 기술): {(orbital['판독분류']=='has_finding').sum()}건
  - 있음(전체 정상): {(orbital['판독분류']=='entirely_normal').sum()}건
  - 없음: {(orbital['판독분류']=='no_report').sum()}건

■ 다음 단계: module2_analysis.py 실행
"""
print(summary)

with open(os.path.join(OUTPUT_DIR, 'cleaning_summary.txt'), 'w', encoding='utf-8') as f:
    f.write(summary)
