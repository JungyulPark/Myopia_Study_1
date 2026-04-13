"""
논문 1 - FINAL MODULE: 최종 분석 통합
======================================
1. 결막림프종 제외한 delay 재계산
2. Table 1: 전체 baseline characteristics
3. Spot-check 반영된 최종 수치
4. 논문 초안에 바로 쓸 수 있는 수치 정리

실행: python final_analysis.py
"""

import pandas as pd
import numpy as np
import os
import re
import warnings
warnings.filterwarnings('ignore')
from datetime import datetime

import statsmodels.api as sm
from statsmodels.formula.api import logit
from sklearn.metrics import roc_auc_score, roc_curve
from sklearn.utils import resample

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

# ============================================================
# 설정
# ============================================================
INPUT_XLSX = r"SR202503119329_안과_박정열_산출물3.데이터_v1.0(1).xlsx"
OUTPUT_DIR = r"paper1_output"
RESULTS_DIR = os.path.join(OUTPUT_DIR, "results")
FIGURES_DIR = os.path.join(OUTPUT_DIR, "figures")
os.makedirs(RESULTS_DIR, exist_ok=True)
os.makedirs(FIGURES_DIR, exist_ok=True)

plt.rcParams['font.family'] = 'DejaVu Sans'
plt.rcParams['figure.dpi'] = 300

print("=" * 70)
print("FINAL ANALYSIS: 결막림프종 제외 + Table 1 + 최종 수치 정리")
print("=" * 70)

# ============================================================
# 데이터 로드 (Module 1 로직 재현)
# ============================================================
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

# PET-CT 제외, 골절 분리
pet_mask = all_data['영상종류'].str.contains('PET', na=False)
df_all = all_data[~pet_mask].copy()
fracture = df_all[df_all['시트'] == '골절'].copy()
orbital = df_all[df_all['시트'] != '골절'].copy()

# 진단 처리
def get_final_dx(diag):
    if pd.isna(diag): return None
    parts = str(diag).split('\n')
    parts = [p.strip() for p in parts if p.strip()]
    return parts[-1] if parts else None

orbital['최종진단'] = orbital['진단그룹'].apply(get_final_dx)

DIAG_MAP = {
    '갑상선 눈병증': 'TED', '안와림프종': 'Lymphoma', '양성종양': 'Benign tumor',
    '안와질환': 'Other orbital disease', '가성종양': 'Pseudotumor',
    '해면혈관종': 'Cavernous hemangioma', '다형샘종': 'Pleomorphic adenoma',
    '메닌지오마': 'Meningioma', '악성종양': 'Malignant tumor',
    '안와 악성종양': 'Malignant tumor', 'IgG4 관련질환': 'IgG4-RD',
    '림프관종': 'Lymphangioma',
}
orbital['진단카테고리'] = orbital['최종진단'].map(DIAG_MAP).fillna('Other')

# 영상 카테고리
IMG_MAP = {'Orbit CT(CE)': 'CT_CE', 'Orbit CT(NCE)': 'CT_NCE',
           'Orbit MR(CE)': 'MRI_CE', 'Facial CT(NCE)': 'Facial_CT'}
orbital['영상카테고리'] = orbital['영상종류'].map(IMG_MAP).fillna('Other')

# 판독문 키워드
REPORT_KW = {
    'TED': [r'thyroid', r'\btao\b', r'graves', r'dysthyroid'],
    'Lymphoma': [r'lymphoma', r'\bmalt\b', r'lymphoproliferative'],
    'Pseudotumor': [r'pseudotumor', r'pseudo-tumor', r'idiopathic orbital inflamm', r'\biois\b', r'\bioid\b'],
    'Cavernous hemangioma': [r'hemangioma', r'haemangioma', r'cavernous venous'],
    'Pleomorphic adenoma': [r'pleomorphic adenoma', r'mixed tumor', r'pleomorphic'],
    'Meningioma': [r'meningioma'],
    'IgG4-RD': [r'igg4', r'igg-4'],
}
for cat, kws in REPORT_KW.items():
    pattern = '|'.join(kws)
    orbital[f'판독_{cat}'] = orbital['판독문'].str.contains(pattern, case=False, na=False)

orbital['판독_mass'] = orbital['판독문'].str.contains(
    r'mass|lesion|tumor|tumour|nodule|nodular|종괴', case=False, na=False)

# 판독분류
def classify_report(report):
    if pd.isna(report) or str(report).strip() == '':
        return 'no_report'
    text = str(report)
    normal_pats = [r'No remarkable finding', r'No definite abnormality', r'Negative finding',
                   r'Unremarkable finding', r'No significant finding']
    finding_pats = [r'\d+\s*(?:mm|cm)', r'mass\b', r'lesion\b', r'tumor\b',
                    r'enlargement', r'thicken', r'enhanc', r'infiltrat', r'swelling', r'nodule']
    has_finding = any(re.search(p, text, re.IGNORECASE) for p in finding_pats)
    has_normal = any(re.search(p, text, re.IGNORECASE) for p in normal_pats)
    if has_finding:
        return 'has_finding'
    elif has_normal:
        return 'entirely_normal'
    elif len(text) < 150:
        return 'entirely_normal'
    else:
        return 'has_finding'

orbital['판독분류'] = orbital['판독문'].apply(classify_report)

# 조직검사
orbital['조직검사시행'] = (orbital['조직검사'] == 0)

# 림프종 하위분류
eye_kw = ['orbit', 'conjunctiv', 'eyelid', 'eyeball', 'globe', 'lacrimal',
           'lid', 'retrobulbar', 'periorbital', 'levator', 'tarsal',
           'extraocular', 'optic', 'ocular', 'canthus', 'fornix',
           'caruncle', 'sac', 'dacryocyst']

def classify_lymphoma(row):
    if row['진단카테고리'] != 'Lymphoma':
        return 'N/A'
    biopsy = str(row['조직검사결과']).lower() if pd.notna(row['조직검사결과']) else ''
    if 'conjunctiv' in biopsy:
        return 'conjunctival'
    elif any(kw in biopsy for kw in ['orbit', 'lacrimal', 'eyelid', 'lid',
                                      'retrobulbar', 'soft tissue', 'eyeball', 'sac']):
        return 'orbital'
    elif pd.isna(row['조직검사결과']):
        return 'no_biopsy'
    else:
        return 'other'

orbital['림프종위치'] = orbital.apply(classify_lymphoma, axis=1)

# 판독 있는 건만
has_report = orbital[orbital['판독분류'] != 'no_report'].copy()

print(f"전체: {len(orbital)}건, {orbital['ID'].nunique()}명")
print(f"판독 있는 건: {len(has_report)}건")


# ============================================================
# TABLE 1: BASELINE CHARACTERISTICS (ALL VARIABLES)
# ============================================================
print(f"\n{'='*70}")
print("TABLE 1: Baseline Characteristics")
print("="*70)

rows = []

# --- Setting ---
rows.append({'Category': 'Study population', 'Variable': 'Total imaging studies, n', 'Value': f"{len(has_report)}"})
rows.append({'Category': '', 'Variable': 'Total patients, n', 'Value': f"{has_report['ID'].nunique()}"})

has_report['year'] = pd.to_numeric(has_report['검사일'].astype(str).str[:4], errors='coerce')
rows.append({'Category': '', 'Variable': 'Study period', 'Value': f"{has_report['year'].min():.0f}-{has_report['year'].max():.0f}"})

# --- Hospital ---
for h, cnt in has_report['병원'].value_counts().items():
    rows.append({'Category': 'Hospital', 'Variable': f'  {h}', 'Value': f"{cnt} ({cnt/len(has_report)*100:.1f})"})

# --- Imaging modality ---
for img in ['CT_CE', 'CT_NCE', 'MRI_CE', 'Facial_CT', 'Other']:
    cnt = (has_report['영상카테고리'] == img).sum()
    if cnt > 0:
        rows.append({'Category': 'Imaging modality', 'Variable': f'  {img}',
                     'Value': f"{cnt} ({cnt/len(has_report)*100:.1f})"})

# --- Initial vs Follow-up ---
n_init = (has_report['시트'] == '일회성').sum()
n_fu = (has_report['시트'] == '다수').sum()
rows.append({'Category': 'Study type', 'Variable': '  Initial', 'Value': f"{n_init} ({n_init/len(has_report)*100:.1f})"})
rows.append({'Category': '', 'Variable': '  Follow-up', 'Value': f"{n_fu} ({n_fu/len(has_report)*100:.1f})"})

# --- Diagnosis ---
diag_order = ['TED', 'Lymphoma', 'Benign tumor', 'Other orbital disease', 'Pseudotumor',
              'Cavernous hemangioma', 'Pleomorphic adenoma', 'Meningioma',
              'Malignant tumor', 'IgG4-RD', 'Lymphangioma', 'Other']
for cat in diag_order:
    cnt = (has_report['진단카테고리'] == cat).sum()
    if cnt > 0:
        rows.append({'Category': 'Confirmed diagnosis', 'Variable': f'  {cat}',
                     'Value': f"{cnt} ({cnt/len(has_report)*100:.1f})"})

# Lymphoma subtype
for loc in ['conjunctival', 'orbital', 'no_biopsy', 'other']:
    cnt = (has_report['림프종위치'] == loc).sum()
    if cnt > 0:
        rows.append({'Category': '  Lymphoma subsite', 'Variable': f'    {loc}',
                     'Value': f"{cnt}"})

# --- Report characteristics ---
report_len = has_report['판독문'].str.len()
rows.append({'Category': 'Report characteristics', 'Variable': 'Report length, chars, median (IQR)',
             'Value': f"{report_len.median():.0f} ({report_len.quantile(0.25):.0f}-{report_len.quantile(0.75):.0f})"})

n_normal = (has_report['판독분류'] == 'entirely_normal').sum()
rows.append({'Category': '', 'Variable': 'Entirely normal report',
             'Value': f"{n_normal} ({n_normal/len(has_report)*100:.1f})"})

n_mass = has_report['판독_mass'].sum()
rows.append({'Category': '', 'Variable': 'Mass/lesion mentioned',
             'Value': f"{n_mass} ({n_mass/len(has_report)*100:.1f})"})

# clinical info
has_ci = has_report['판독문'].str.contains(r'Clinical information|Clinical history|Clinical Info|CI:', case=False, na=False).sum()
rows.append({'Category': '', 'Variable': 'Clinical info provided',
             'Value': f"{has_ci} ({has_ci/len(has_report)*100:.1f})"})

# differential count
def count_diffs(text):
    if pd.isna(text): return 0
    t = str(text)
    ro = len(re.findall(r'r/o\b|rule out|DDx|differential|versus|vs\.', t, re.IGNORECASE))
    num = len(re.findall(r'\n\s*\d+\.\s', t))
    return max(ro, num)

has_report['n_diff'] = has_report['판독문'].apply(count_diffs)
n_no_diff = (has_report['n_diff'] == 0).sum()
rows.append({'Category': '', 'Variable': 'No differential diagnosis',
             'Value': f"{n_no_diff} ({n_no_diff/len(has_report)*100:.1f})"})

# --- Biopsy ---
n_bx = has_report['조직검사시행'].sum()
rows.append({'Category': 'Biopsy', 'Variable': 'Biopsy performed',
             'Value': f"{n_bx} ({n_bx/len(has_report)*100:.1f})"})

table1 = pd.DataFrame(rows)
table1.to_csv(os.path.join(RESULTS_DIR, 'Table1_baseline_complete.csv'), index=False)
print(table1[['Variable', 'Value']].to_string(index=False))


# ============================================================
# DIAGNOSTIC DELAY: 결막림프종 제외 재계산
# ============================================================
print(f"\n{'='*70}")
print("DIAGNOSTIC DELAY: 결막림프종 제외")
print("="*70)

followup = orbital[orbital['시트'] == '다수'].copy()
followup = followup[followup['판독문'].notna() & (followup['판독분류'] != 'no_report')]
followup = followup.sort_values(['ID', '검사일'])

def check_hit(row):
    cat = row['진단카테고리']
    if cat in REPORT_KW:
        col = f'판독_{cat}'
        return bool(row.get(col, False))
    if cat in ['Benign tumor', 'Malignant tumor', 'Other orbital disease', 'Lymphangioma']:
        return bool(row.get('판독_mass', False))
    return False

followup['hit'] = followup.apply(check_hit, axis=1)

# === 결막림프종 환자 ID 목록 ===
# 해당 환자의 모든 조직검사결과에서 conjunctival인지 확인
lymph_patients = orbital[orbital['진단카테고리'] == 'Lymphoma']
conjunctival_ids = set()
for pid, group in lymph_patients.groupby('ID'):
    for _, row in group.iterrows():
        biopsy = str(row['조직검사결과']).lower() if pd.notna(row['조직검사결과']) else ''
        if 'conjunctiv' in biopsy:
            conjunctival_ids.add(pid)
            break

print(f"결막림프종 환자 ID: {len(conjunctival_ids)}명 → delay 분석에서 제외")

# Delay 분석
delay_results = []
for pid, group in followup.groupby('ID'):
    group = group.reset_index(drop=True)
    if len(group) < 2:
        continue

    cat = group['진단카테고리'].iloc[-1]

    # 결막림프종 제외
    if cat == 'Lymphoma' and pid in conjunctival_ids:
        continue

    first = group.iloc[0]
    first_hit = first['hit']

    # 이후 hit 찾기
    if not first_hit:
        hits = group[group['hit'] == True]
        if hits.empty:
            delay_days = None
            never_caught = True
        else:
            try:
                d1 = datetime.strptime(str(int(first['검사일'])), '%Y%m%d')
                d2 = datetime.strptime(str(int(hits.iloc[0]['검사일'])), '%Y%m%d')
                delay_days = (d2 - d1).days
                never_caught = False
            except:
                delay_days = None
                never_caught = True
    else:
        delay_days = 0
        never_caught = False

    delay_results.append({
        'ID': pid,
        'diagnosis': cat,
        'n_studies': len(group),
        'first_miss': not first_hit,
        'delay_days': delay_days,
        'never_caught': never_caught,
    })

delay_df = pd.DataFrame(delay_results)
print(f"\nDelay 분석 대상 (결막림프종 제외): {len(delay_df)}명")

# 질환별 요약
print(f"\n{'Diagnosis':<25} {'N':>5} {'1st miss':>10} {'%':>6} {'Med delay':>10} {'Never caught':>13}")
print("-" * 75)

delay_summary_rows = []
for cat in delay_df['diagnosis'].unique():
    sub = delay_df[delay_df['diagnosis'] == cat]
    if len(sub) < 3:
        continue
    n_miss = sub['first_miss'].sum()
    miss_pct = n_miss / len(sub) * 100

    delays = sub[(sub['delay_days'].notna()) & (sub['delay_days'] > 0)]['delay_days']
    med_delay = delays.median() if len(delays) > 0 else None
    n_never = sub['never_caught'].sum()

    med_str = f"{med_delay:.0f}d" if med_delay is not None else "N/A"
    print(f"  {cat:<23} {len(sub):>5} {n_miss:>7}/{len(sub):<3} {miss_pct:>5.0f}% {med_str:>10} {n_never:>10}/{n_miss}")

    delay_summary_rows.append({
        'Diagnosis': cat,
        'N_followup_patients': len(sub),
        'First_miss_n': n_miss,
        'First_miss_pct': round(miss_pct, 1),
        'Median_delay_days': med_delay,
        'Never_caught_n': n_never,
        'Never_caught_of_miss': n_never,
    })

delay_summary = pd.DataFrame(delay_summary_rows)
delay_summary.to_csv(os.path.join(RESULTS_DIR, 'Table_delay_excl_conjunctival.csv'), index=False)

# Delay Figure (결막 제외)
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

ds = delay_summary.sort_values('First_miss_pct', ascending=True)
colors = ['#e74c3c' if r > 50 else '#f39c12' if r > 30 else '#27ae60' for r in ds['First_miss_pct']]
ax1.barh(range(len(ds)), ds['First_miss_pct'], color=colors, height=0.6)
ax1.set_yticks(range(len(ds)))
ax1.set_yticklabels(ds['Diagnosis'], fontsize=9)
ax1.set_xlabel('First-Study Miss Rate (%)')
ax1.set_title('A. First Imaging Miss Rate\n(Conjunctival Lymphoma Excluded)', fontsize=11, fontweight='bold')
for i, (_, row) in enumerate(ds.iterrows()):
    ax1.text(row['First_miss_pct'] + 1, i,
             f"{row['First_miss_pct']:.0f}% ({row['First_miss_n']}/{row['N_followup_patients']})",
             va='center', fontsize=8)

ds_delay = delay_summary[delay_summary['Median_delay_days'].notna()].sort_values('Median_delay_days', ascending=True)
if len(ds_delay) > 0:
    ax2.barh(range(len(ds_delay)), ds_delay['Median_delay_days'], color='#3498db', height=0.6)
    ax2.set_yticks(range(len(ds_delay)))
    ax2.set_yticklabels(ds_delay['Diagnosis'], fontsize=9)
    ax2.set_xlabel('Median Diagnostic Delay (days)')
    ax2.set_title('B. Median Delay to Correct Diagnosis\n(Among Initially Missed)', fontsize=11, fontweight='bold')
    for i, (_, row) in enumerate(ds_delay.iterrows()):
        ax2.text(row['Median_delay_days'] + 5, i, f"{row['Median_delay_days']:.0f} days", va='center', fontsize=8)

plt.tight_layout()
plt.savefig(os.path.join(FIGURES_DIR, 'fig_delay_excl_conjunctival.png'), bbox_inches='tight')
plt.close()
print(f"\nFig: fig_delay_excl_conjunctival.png 저장")


# ============================================================
# SPOT-CHECK 반영 사항 정리 (논문용 기록)
# ============================================================
print(f"\n{'='*70}")
print("SPOT-CHECK 결과 반영 사항")
print("="*70)

spotcheck_notes = """
[Spot-check results — 9 cases reviewed by ophthalmologist]

LYMPHOMA (6 cases):
- R20264: Conjunctival → EXCLUDED from delay (imaging limitation)
- R20191: Lacrimal sac → Report delay (clinically already diagnosed via biopsy)
- R20408: Orbital → TRUE MISS (mass described but no differential offered)
- R20157: Orbital → MISDIAGNOSIS (labeled as dacryocystocele)
- R20374: Orbital → MISDIAGNOSIS (labeled as hemangioma; 23mm mass)
- R20244: Lacrimal sac → MISDIAGNOSIS (labeled as granuloma/benign)
- R20315: Lacrimal sac → MISDIAGNOSIS (labeled as dacryocystitis)
- R20363: Orbital → MISDIAGNOSIS (labeled as pseudotumor/hemangioma)

IgG4-RD (1 case):
- R20189: FALSE MISS — Radiologist correctly wrote "R/O Lymphoma" (appropriate DDx)
  → Keyword limitation: our algorithm searched for "IgG4" but radiologist 
    provided clinically appropriate alternative diagnosis

PSEUDOTUMOR (2 cases):
- R20400: "No finding" initially → myositis on FU (terminology overlap)
- R20406: "Infectious myositis" → pseudotumor spectrum (terminology overlap)

KEY PATTERNS:
1. Orbital/lacrimal sac lymphoma: mass correctly identified but misattributed 
   to benign conditions (hemangioma, pseudotumor, dacryocystocele, granuloma)
2. Conjunctival lymphoma: invisible on imaging (expected, not a true miss)
3. IgG4-RD: keyword-based method overestimates miss rate
4. Pseudotumor: overlap with myositis/inflammation terminology

METHODOLOGICAL IMPLICATIONS:
- Conjunctival lymphoma excluded from delay analysis
- Keyword-based miss rate acknowledged as potential overestimate in Limitations
- "Diagnostic delay" defined as "imaging report delay" not "clinical management delay"
"""
print(spotcheck_notes)

with open(os.path.join(RESULTS_DIR, 'spotcheck_summary.txt'), 'w', encoding='utf-8') as f:
    f.write(spotcheck_notes)


# ============================================================
# 최종 논문 수치 정리 (바로 쓸 수 있는 형태)
# ============================================================
print(f"\n{'='*70}")
print("논문에 바로 쓸 수 있는 핵심 수치")
print("="*70)

manuscript_numbers = f"""
[ABSTRACT 수치]
- Study period: {has_report['year'].min():.0f}-{has_report['year'].max():.0f}
- Total: {len(has_report)} imaging studies from {has_report['ID'].nunique()} patients
- Most common: TED ({(has_report['진단카테고리']=='TED').sum()} studies, {(has_report['진단카테고리']=='TED').sum()/len(has_report)*100:.1f}%)
- Overall miss rate: 707/2177 (32.5%)
- Lowest sensitivity: Pseudotumor 29.7% (95% CI 24.0-36.2)
- DVS C-statistic: 0.761 (optimism-corrected 0.757)
- Risk stratification: Low 16.1% → Intermediate 23.3% → High 58.4%

[KEY FINDINGS for RESULTS]
- Pseudotumor sensitivity: 29.7% (n=212)
- TED sensitivity: 65.6% (n=948)
- Lymphoma overall: 66.7% (n=312)
  - Conjunctival: 62.9%
  - Orbital (non-conjunctival): 73.0%
- IgG4-RD sensitivity: 45.0% (n=20)
- Entirely normal report in confirmed disease: 218/2177 (10.0%)

[DVS PREDICTORS]
- Entirely normal report: aOR 7.53 (4.84-11.71), p<0.001
- No differential diagnosis: aOR 1.79 (1.43-2.24), p<0.001
- MRI (vs CE CT): aOR 1.30 (1.00-1.69), p=0.048
- Clinical info provided: aOR 0.32 (0.25-0.40), p<0.001 [PROTECTIVE]
- Mass/lesion mentioned: aOR 0.57 (0.45-0.72), p<0.001 [PROTECTIVE]

[DIAGNOSTIC DELAY — conjunctival lymphoma excluded]
(수치는 재계산 결과 확인 필요 — 위 출력 참조)

[SPOT-CHECK KEY MESSAGE]
- 9 lymphoma cases reviewed: 6 true misdiagnoses
  (mass correctly identified but attributed to benign conditions)
- Pattern: hemangioma/pseudotumor/granuloma misattribution
- 1 false miss (IgG4-RD: keyword limitation)
"""
print(manuscript_numbers)

with open(os.path.join(RESULTS_DIR, 'manuscript_numbers.txt'), 'w', encoding='utf-8') as f:
    f.write(manuscript_numbers)


# ============================================================
print(f"\n{'='*70}")
print("FINAL ANALYSIS 완료!")
print("="*70)
print(f"""
저장된 파일:
  {RESULTS_DIR}/Table1_baseline_complete.csv
  {RESULTS_DIR}/Table_delay_excl_conjunctival.csv
  {RESULTS_DIR}/spotcheck_summary.txt
  {RESULTS_DIR}/manuscript_numbers.txt
  {FIGURES_DIR}/fig_delay_excl_conjunctival.png

→ 다음 단계: 논문 초안 작성 (Methods → Results → Discussion)
""")
