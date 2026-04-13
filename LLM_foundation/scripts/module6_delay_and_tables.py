"""
논문 1 - Module 6: Diagnostic Delay, Unified Tables, and Advanced Visualizations
================================================================================
목적: 
  1. 다수 시트(Follow-up) 환자들의 진단 지연(Diagnostic Delay, Delta T) 산출
  2. Univariable & Multivariable 결과를 출판용 Table 3(Unified)로 병합
  3. DVS Risk Stratification (위험 층화) 차트 및 진단 지연 Boxplot 생성
"""

import os
import pandas as pd
import numpy as np
import matplotlib
import matplotlib.pyplot as plt
import seaborn as sns
import warnings
warnings.filterwarnings('ignore')

plt.rcParams['font.family'] = 'DejaVu Sans'
plt.rcParams['figure.dpi'] = 300

OUTPUT_DIR = r"paper1_output"
RESULTS_DIR = os.path.join(OUTPUT_DIR, "results")
FIGURES_DIR = os.path.join(OUTPUT_DIR, "figures")

print("=" * 60)
print("Module 6: Diagnostic Delay & Final Manuscript Artifacts")
print("=" * 60)

# ============================================================
# 1. Diagnostic Delay Analysis (진단 지연 산출)
# ============================================================
print("\n[1] Diagnostic Delay Analysis...")
df = pd.read_csv(os.path.join(OUTPUT_DIR, 'orbital_cleaned.csv'))

# 검사일 datetime 파싱
df['검사일'] = pd.to_datetime(df['검사일'], errors='coerce')

# 판독문 있는 건만
df = df[df['판독분류'] != 'no_report'].copy()

# Miss 여부 판정 (Module 5 로직 복제)
keyword_col_map = {
    'TED': '판독_TED',
    'Lymphoma': '판독_Lymphoma',
    'Pseudotumor': '판독_Pseudotumor',
    'Cavernous hemangioma': '판독_Cavernous hemangioma',
    'Pleomorphic adenoma': '판독_Pleomorphic adenoma',
    'Meningioma': '판독_Meningioma',
    'IgG4-RD': '판독_IgG4-RD',
}

def define_miss(row):
    cat = row['진단카테고리']
    if cat in keyword_col_map:
        col = keyword_col_map[cat]
        if col in row.index:
            return 0 if row[col] == True else 1
    if cat in ['Benign tumor', 'Malignant tumor', 'Other orbital disease', 'Lymphangioma']:
        if '판독_mass' in row.index:
            return 0 if row['판독_mass'] == True else 1
    return np.nan

df['miss'] = df.apply(define_miss, axis=1)
df = df.dropna(subset=['miss', '검사일']).copy()
df['miss'] = df['miss'].astype(int)

# 환자별 정렬
df = df.sort_values(by=['ID', '검사일'])

delay_records = []
patients_multiple = df.groupby('ID').filter(lambda x: len(x) > 1)
patient_groups = patients_multiple.groupby('ID')

first_miss_count = 0
hit_found_count = 0

for pid, group in patient_groups:
    group = group.reset_index(drop=True)
    first_scan = group.iloc[0]
    
    if first_scan['miss'] == 1:
        first_miss_count += 1
        hits = group[group['miss'] == 0]
        if not hits.empty:
            hit_found_count += 1
            first_hit = hits.iloc[0]
            delay_days = (first_hit['검사일'] - first_scan['검사일']).days
            
            if delay_days >= 0 and delay_days < 5000:
                months = delay_days / 30.44
                delay_records.append({
                    'ID': pid,
                    '진단카테고리': first_scan['진단카테고리'],
                    '영상의도_첫': first_scan['영상카테고리'],
                    '영상의도_진단': first_hit['영상카테고리'],
                    'Delay_Days': delay_days,
                    'Delay_Months': months
                })

print(f"DEBUG: Multi-scan patients: {len(patient_groups)}")
print(f"DEBUG: Patients with first scan missed: {first_miss_count}")
print(f"DEBUG: Patients who later got a hit: {hit_found_count}")

df_delay = pd.DataFrame(delay_records)
if not df_delay.empty:
    print(f"진단 지연 환자 탐지: {len(df_delay)}명")
    print(f"전체 중앙값: {df_delay['Delay_Months'].median():.1f}개월 (IQR {df_delay['Delay_Months'].quantile(0.25):.1f}-{df_delay['Delay_Months'].quantile(0.75):.1f})")
    
    # 질환별 Delay
    delay_summary = df_delay.groupby('진단카테고리')['Delay_Months'].agg(['count', 'median', lambda x: x.quantile(0.25), lambda x: x.quantile(0.75)])
    delay_summary.columns = ['N_Patients', 'Median_Months', 'IQR_25', 'IQR_75']
    print("\n[질환별 진단 지연(개월)]")
    print(delay_summary.round(1))
    delay_summary.to_csv(os.path.join(RESULTS_DIR, "table7_diagnostic_delay.csv"))
    
    # Boxplot 생성
    plt.figure(figsize=(10, 6))
    sns.boxplot(y='진단카테고리', x='Delay_Months', data=df_delay, palette='Set2')
    plt.title('Diagnostic Delay by Disease Category (Months)', fontsize=14, fontweight='bold')
    plt.xlabel('Delay Space (Months)', fontsize=12)
    plt.ylabel('')
    plt.grid(axis='x', linestyle='--', alpha=0.7)
    plt.tight_layout()
    plt.savefig(os.path.join(FIGURES_DIR, "fig10_delay_boxplot.png"))
    plt.close()
else:
    print("진단 지연 조건에 맞는 환자가 없습니다.")

# ============================================================
# 2. Unified Table 3 Format (논문용 합본 테이블)
# ============================================================
print("\n[2] Generating Unified Publication Table 3...")
try:
    from statsmodels.formula.api import logit
    
    # 임시로 df에 독립변수 계산
    df['img_CT_NCE'] = (df['영상카테고리'] == 'CT_NCE').astype(int)
    df['img_MRI'] = (df['영상카테고리'] == 'MRI_CE').astype(int)
    df['report_length'] = df['판독문'].str.len().fillna(0)
    df['report_short'] = (df['report_length'] < 200).astype(int)
    df['entirely_normal'] = (df['판독분류'] == 'entirely_normal').astype(int)
    df['mass_mentioned'] = df['판독_mass'].astype(int) if '판독_mass' in df.columns else 0
    import re
    def count_diff(text):
        if pd.isna(text): return 0
        text = str(text)
        ro = len(re.findall(r'r/o\b|rule out|DDx|differential|versus|vs\.', text, re.IGNORECASE))
        num = len(re.findall(r'\n\s*\d+\.\s', text))
        return max(ro, num)
    df['no_differential'] = (df['판독문'].apply(count_diff) == 0).astype(int)
    df['has_clinical_info'] = df['판독문'].str.contains(r'Clinical information|Clinical history|Clinical Info|CI:', case=False, na=False).astype(int)
    df['is_followup'] = (df['시트'] == '다수').astype(int)

    predictor_list = ['img_CT_NCE', 'img_MRI', 'report_short', 
                      'entirely_normal', 'mass_mentioned', 'no_differential',
                      'has_clinical_info', 'is_followup']
    
    predictors_desc = {
        'img_CT_NCE': 'Non-contrast CT (vs CE CT)',
        'img_MRI': 'MRI (vs CE CT)',
        'report_short': 'Short report (<200 chars)',
        'report_long': 'Long report (>500 chars)',
        'entirely_normal': 'Entirely normal report',
        'mass_mentioned': 'Mass/lesion mentioned',
        'no_differential': 'No differential diagnosis',
        'has_clinical_info': 'Clinical info provided',
        'is_followup': 'Follow-up study (vs initial)'
    }

    # Univariable 계산
    uni_results = []
    for var in predictor_list:
        try:
            m = logit(f'miss ~ {var}', data=df).fit(disp=0)
            or_val = np.exp(m.params[var])
            ci = np.exp(m.conf_int().loc[var])
            p = m.pvalues[var]
            uni_results.append({
                'Variable': predictors_desc[var],
                'code': var,
                'Uni_OR_CI': f"{or_val:.2f} ({ci[0]:.2f}-{ci[1]:.2f})",
                'Uni_p': "<0.001" if p < 0.001 else f"{p:.3f}"
            })
        except:
            pass
    uni = pd.DataFrame(uni_results)

    multi = pd.read_csv(os.path.join(RESULTS_DIR, "dvs_multivariable.csv"))
    
    # Multi 포맷팅
    multi['Multi_aOR_CI'] = multi.apply(lambda x: f"{x['aOR']:.2f} ({x['CI_low']:.2f}-{x['CI_high']:.2f})", axis=1)
    multi['Multi_p'] = multi['p'].apply(lambda x: "<0.001" if x < 0.001 else f"{x:.3f}")
    
    # 병합
    unified = pd.merge(uni[['Variable', 'Uni_OR_CI', 'Uni_p']], 
                       multi[['Variable', 'Multi_aOR_CI', 'Multi_p']], 
                       on='Variable', how='left')
    
    # 결측치 빈칸
    unified.fillna("-", inplace=True)
    unified.columns = ['Predictor Variable', 'Univariable OR (95% CI)', 'P-value', 'Multivariable aOR (95% CI)', 'P-value ']
    
    unified.to_csv(os.path.join(RESULTS_DIR, "Table3_Unified_Predictors.csv"), index=False)
    print("Table3_Unified_Predictors.csv 저장 완료. (논문에 복붙 가능)")
    print(unified.to_string(index=False))

except Exception as e:
    print(f"Error parsing Univariable/Multivariable files: {e}")

# ============================================================
# 3. DVS Risk Stratification Bar Chart
# ============================================================
print("\n[3] Generating DVS Risk Stratification Chart...")
try:
    # Logistic Regression 재시행하여 score 획득 (Module 5 동일 로직)
    from statsmodels.formula.api import logit
    df['img_CT_NCE'] = (df['영상카테고리'] == 'CT_NCE').astype(int)
    df['img_MRI'] = (df['영상카테고리'] == 'MRI_CE').astype(int)
    df['report_length'] = df['판독문'].str.len().fillna(0)
    df['report_short'] = (df['report_length'] < 200).astype(int)
    df['entirely_normal'] = (df['판독분류'] == 'entirely_normal').astype(int)
    df['mass_mentioned'] = df['판독_mass'].astype(int) if '판독_mass' in df.columns else 0
    import re
    def count_diff(text):
        if pd.isna(text): return 0
        text = str(text)
        ro = len(re.findall(r'r/o\b|rule out|DDx|differential|versus|vs\.', text, re.IGNORECASE))
        num = len(re.findall(r'\n\s*\d+\.\s', text))
        return max(ro, num)
    df['no_differential'] = (df['판독문'].apply(count_diff) == 0).astype(int)
    df['has_clinical_info'] = df['판독문'].str.contains(r'Clinical information|Clinical history|Clinical Info|CI:', case=False, na=False).astype(int)
    df['is_followup'] = (df['시트'] == '다수').astype(int)
    
    formula = 'miss ~ img_CT_NCE + img_MRI + report_short + entirely_normal + mass_mentioned + no_differential + has_clinical_info + is_followup'
    model = logit(formula, data=df).fit(disp=0)
    
    probs = model.predict(df)
    df['risk_prob'] = probs
    
    # 3등분 (Tertiles)
    df['risk_tier'] = pd.qcut(df['risk_prob'], q=3, labels=['Low Risk', 'Intermediate Risk', 'High Risk'])
    
    tier_stats = df.groupby('risk_tier')['miss'].agg(['count', 'mean']).reset_index()
    tier_stats['mean_pct'] = tier_stats['mean'] * 100
    
    plt.figure(figsize=(8, 6))
    bars = plt.bar(tier_stats['risk_tier'], tier_stats['mean_pct'], color=['#2ecc71', '#f1c40f', '#e74c3c'], edgecolor='black')
    
    for bar in bars:
        h = bar.get_height()
        plt.text(bar.get_x() + bar.get_width()/2, h + 1, f'{h:.1f}%', ha='center', va='bottom', fontweight='bold', fontsize=12)
        
    plt.ylim(0, 100)
    plt.ylabel('Observed Miss Rate (%)', fontsize=12)
    plt.title('Diagnostic Miss Rate according to\nDVS Risk Stratification Tiers', fontsize=14, fontweight='bold')
    plt.grid(axis='y', linestyle='--', alpha=0.5)
    plt.tight_layout()
    plt.savefig(os.path.join(FIGURES_DIR, "fig11_risk_stratification.png"))
    plt.close()
    print("Fig 11: Risk Stratification 생성 완료.")
    
except Exception as e:
    print(f"Risk Stratification Error: {e}")

print("\nModule 6 완료!")
