"""
논문 1 - Module 6: Diagnostic Delay Analysis + 논문 테이블 완성
================================================================
1. Diagnostic Delay Analysis (다수영상 환자에서 진단 지연 분석)
2. Table 1: Baseline characteristics (ALL variables)
3. Table 2: Univariate + Multivariate DVS 통합 테이블
4. 개선된 시각화

실행: python module6_delay_tables.py
"""

import pandas as pd
import numpy as np
import os
import re
import warnings
warnings.filterwarnings('ignore')

import statsmodels.api as sm
from statsmodels.formula.api import logit
from sklearn.metrics import roc_auc_score, roc_curve
from sklearn.utils import resample

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

OUTPUT_DIR = r"paper1_output"
RESULTS_DIR = os.path.join(OUTPUT_DIR, "results")
FIGURES_DIR = os.path.join(OUTPUT_DIR, "figures")
os.makedirs(RESULTS_DIR, exist_ok=True)
os.makedirs(FIGURES_DIR, exist_ok=True)

plt.rcParams['font.family'] = 'DejaVu Sans'
plt.rcParams['figure.dpi'] = 300

orbital = pd.read_csv(os.path.join(OUTPUT_DIR, 'orbital_cleaned.csv'))
patient = pd.read_csv(os.path.join(OUTPUT_DIR, 'patient_cleaned.csv'))

print("=" * 70)
print("Module 6: Diagnostic Delay + Publication Tables")
print("=" * 70)


# ============================================================
# PART 1: DIAGNOSTIC DELAY ANALYSIS
# ============================================================
print(f"\n{'='*70}")
print("PART 1: Diagnostic Delay Analysis")
print("="*70)

# 다수영상 환자만 (시트 = '다수')
followup = orbital[orbital['시트'] == '다수'].copy()
print(f"Follow-up 영상 건수: {len(followup)}")
print(f"Follow-up 환자 수: {followup['ID'].nunique()}")

# 검사일 정렬
followup['검사일_num'] = pd.to_numeric(followup['검사일'], errors='coerce')
followup = followup.sort_values(['ID', '검사일_num'])

# 각 환자의 각 영상에서: 해당 진단이 판독문에 언급되었는지
keyword_col_map = {
    'TED': '판독_TED',
    'Lymphoma': '판독_Lymphoma',
    'Pseudotumor': '판독_Pseudotumor',
    'Cavernous hemangioma': '판독_Cavernous hemangioma',
    'Pleomorphic adenoma': '판독_Pleomorphic adenoma',
    'Meningioma': '판독_Meningioma',
    'IgG4-RD': '판독_IgG4-RD',
}

def check_correct_dx_in_report(row):
    cat = row['진단카테고리']
    if cat in keyword_col_map:
        col = keyword_col_map[cat]
        if col in row.index:
            return bool(row[col])
    if cat in ['Benign tumor', 'Malignant tumor', 'Other orbital disease', 'Lymphangioma']:
        if '판독_mass' in row.index:
            return bool(row['판독_mass'])
    return False

followup['dx_in_report'] = followup.apply(check_correct_dx_in_report, axis=1)

# 환자별: 첫 영상에서 miss인지, 몇 번째에서 처음 정확해지는지
delay_results = []

for pid, group in followup.groupby('ID'):
    group = group.sort_values('검사일_num')
    n_studies = len(group)
    cat = group['진단카테고리'].iloc[-1]  # 최종 진단
    
    if n_studies < 2:
        continue
    
    has_report = group[group['판독분류'] != 'no_report']
    if len(has_report) == 0:
        continue
    
    first_correct = has_report['dx_in_report'].iloc[0]
    
    # 첫 번째 정확한 판독이 나온 순서
    correct_indices = has_report[has_report['dx_in_report'] == True].index
    
    if len(correct_indices) > 0:
        first_correct_pos = list(has_report.index).index(correct_indices[0]) + 1
    else:
        first_correct_pos = None  # 끝까지 못 잡음
    
    # 시간 지연 계산
    first_date = has_report['검사일_num'].iloc[0]
    if first_correct_pos is not None and first_correct_pos > 1:
        correct_date = has_report.iloc[first_correct_pos - 1]['검사일_num']
        delay_days = (correct_date - first_date)
        # YYYYMMDD 형식이므로 대략적 일수 변환
        try:
            from datetime import datetime
            d1 = datetime.strptime(str(int(first_date)), '%Y%m%d')
            d2 = datetime.strptime(str(int(correct_date)), '%Y%m%d')
            delay_days = (d2 - d1).days
        except:
            delay_days = None
    else:
        delay_days = 0 if first_correct_pos == 1 else None
    
    delay_results.append({
        'ID': pid,
        'diagnosis': cat,
        'n_studies': n_studies,
        'first_study_correct': first_correct,
        'first_correct_at_study_n': first_correct_pos,
        'delay_days': delay_days,
        'never_caught': first_correct_pos is None,
    })

delay_df = pd.DataFrame(delay_results)
print(f"\n다수영상 환자 분석 대상: {len(delay_df)}명")

# 첫 영상에서 miss된 비율
first_miss = (~delay_df['first_study_correct']).sum()
print(f"첫 영상에서 miss: {first_miss}/{len(delay_df)} ({first_miss/len(delay_df)*100:.1f}%)")

# miss된 환자 중 결국 잡힌 비율
missed_patients = delay_df[~delay_df['first_study_correct']]
eventually_caught = missed_patients[~missed_patients['never_caught']]
never_caught = missed_patients[missed_patients['never_caught']]

print(f"\n첫 영상 miss 환자 중:")
print(f"  후속 영상에서 잡힘: {len(eventually_caught)} ({len(eventually_caught)/max(len(missed_patients),1)*100:.1f}%)")
print(f"  끝까지 못 잡음: {len(never_caught)} ({len(never_caught)/max(len(missed_patients),1)*100:.1f}%)")

# 진단별 지연 분석
print(f"\n진단별 첫 영상 miss → 진단 지연:")
delay_by_dx = []
for cat in delay_df['diagnosis'].unique():
    subset = delay_df[delay_df['diagnosis'] == cat]
    if len(subset) < 5:
        continue
    n_miss = (~subset['first_study_correct']).sum()
    miss_rate = n_miss / len(subset) * 100
    
    delays = subset[subset['delay_days'].notna() & (subset['delay_days'] > 0)]['delay_days']
    median_delay = delays.median() if len(delays) > 0 else None
    mean_delay = delays.mean() if len(delays) > 0 else None
    
    extra_studies = subset[subset['first_correct_at_study_n'].notna() & (subset['first_correct_at_study_n'] > 1)]
    median_extra = (extra_studies['first_correct_at_study_n'] - 1).median() if len(extra_studies) > 0 else None
    
    print(f"  {cat}: miss {n_miss}/{len(subset)} ({miss_rate:.0f}%), "
          f"median delay: {median_delay:.0f}일, " if median_delay else f"  {cat}: miss {n_miss}/{len(subset)} ({miss_rate:.0f}%), "
          f"extra studies: {median_extra:.0f}" if median_extra else "")
    
    delay_by_dx.append({
        'Diagnosis': cat,
        'N_patients': len(subset),
        'First_miss_n': n_miss,
        'First_miss_rate': miss_rate,
        'Median_delay_days': median_delay,
        'Mean_delay_days': mean_delay,
        'Median_extra_studies': median_extra,
        'Never_caught_n': subset['never_caught'].sum(),
    })

delay_table = pd.DataFrame(delay_by_dx)
delay_table.to_csv(os.path.join(RESULTS_DIR, 'table6_diagnostic_delay.csv'), index=False)
print(f"\nTable 6 저장: table6_diagnostic_delay.csv")


# ============================================================
# PART 2: PUBLICATION TABLE 1 — Baseline Characteristics
# ============================================================
print(f"\n{'='*70}")
print("PART 2: Publication Table 1 — Baseline Characteristics")
print("="*70)

has_report = orbital[orbital['판독분류'] != 'no_report'].copy()

# 모든 변수 정리
table1_data = []

# Total
table1_data.append({'Variable': 'Total imaging studies', 'Value': f"{len(has_report)}", 'Category': ''})
table1_data.append({'Variable': 'Total patients', 'Value': f"{has_report['ID'].nunique()}", 'Category': ''})

# 병원
for h, cnt in has_report['병원'].value_counts().items():
    table1_data.append({'Variable': f'Hospital {h}', 'Value': f"{cnt} ({cnt/len(has_report)*100:.1f}%)", 'Category': 'Setting'})

# 검사 기간
has_report['year'] = pd.to_numeric(has_report['검사일'].astype(str).str[:4], errors='coerce')
table1_data.append({'Variable': 'Study period', 'Value': f"{has_report['year'].min():.0f}-{has_report['year'].max():.0f}", 'Category': 'Setting'})

# 영상 종류
for img, cnt in has_report['영상카테고리'].value_counts().items():
    table1_data.append({'Variable': f'  {img}', 'Value': f"{cnt} ({cnt/len(has_report)*100:.1f}%)", 'Category': 'Imaging modality'})

# 진단 카테고리
diag_order = ['TED', 'Lymphoma', 'Benign tumor', 'Other orbital disease', 'Pseudotumor',
              'Cavernous hemangioma', 'Pleomorphic adenoma', 'Meningioma', 'Malignant tumor',
              'IgG4-RD', 'Lymphangioma', 'Other']
for cat in diag_order:
    cnt = (has_report['진단카테고리'] == cat).sum()
    if cnt > 0:
        table1_data.append({'Variable': f'  {cat}', 'Value': f"{cnt} ({cnt/len(has_report)*100:.1f}%)", 'Category': 'Diagnosis'})

# 판독문 특성
table1_data.append({'Variable': 'Report length, median (IQR)', 
                    'Value': f"{has_report['판독문'].str.len().median():.0f} ({has_report['판독문'].str.len().quantile(0.25):.0f}-{has_report['판독문'].str.len().quantile(0.75):.0f})",
                    'Category': 'Report characteristics'})
table1_data.append({'Variable': '  Entirely normal report',
                    'Value': f"{(has_report['판독분류']=='entirely_normal').sum()} ({(has_report['판독분류']=='entirely_normal').mean()*100:.1f}%)",
                    'Category': 'Report characteristics'})
table1_data.append({'Variable': '  Mass/lesion mentioned',
                    'Value': f"{has_report['판독_mass'].sum()} ({has_report['판독_mass'].mean()*100:.1f}%)",
                    'Category': 'Report characteristics'})

# 조직검사
table1_data.append({'Variable': 'Biopsy performed',
                    'Value': f"{has_report['조직검사시행'].sum()} ({has_report['조직검사시행'].mean()*100:.1f}%)",
                    'Category': 'Biopsy'})

# Miss rate
has_report_temp = has_report.copy()

def define_miss_simple(row):
    cat = row['진단카테고리']
    if cat in keyword_col_map:
        col = keyword_col_map[cat]
        if col in row.index:
            return 0 if row[col] else 1
    if cat in ['Benign tumor', 'Malignant tumor', 'Other orbital disease', 'Lymphangioma']:
        if '판독_mass' in row.index:
            return 0 if row['판독_mass'] else 1
    return np.nan

has_report_temp['miss'] = has_report_temp.apply(define_miss_simple, axis=1)
valid = has_report_temp.dropna(subset=['miss'])
table1_data.append({'Variable': 'Diagnostic miss (overall)',
                    'Value': f"{valid['miss'].sum():.0f}/{len(valid)} ({valid['miss'].mean()*100:.1f}%)",
                    'Category': 'Outcome'})

table1_df = pd.DataFrame(table1_data)
table1_df.to_csv(os.path.join(RESULTS_DIR, 'table1_baseline_all.csv'), index=False)
print("Table 1 저장 완료")
print(table1_df.to_string(index=False))


# ============================================================
# PART 3: PUBLICATION TABLE — DVS Univariate + Multivariate 통합
# ============================================================
print(f"\n{'='*70}")
print("PART 3: DVS Combined Univariate + Multivariate Table")
print("="*70)

# DVS 데이터 준비 (Module 5 로직 재현)
df = orbital[orbital['판독분류'] != 'no_report'].copy()
df['miss'] = df.apply(define_miss_simple, axis=1)
df = df.dropna(subset=['miss']).copy()
df['miss'] = df['miss'].astype(int)

# 독립변수
df['img_CT_NCE'] = (df['영상카테고리'] == 'CT_NCE').astype(int)
df['img_MRI'] = (df['영상카테고리'] == 'MRI_CE').astype(int)
df['report_length'] = df['판독문'].str.len().fillna(0)
df['report_short'] = (df['report_length'] < 200).astype(int)
df['entirely_normal'] = (df['판독분류'] == 'entirely_normal').astype(int)
df['mass_mentioned'] = df['판독_mass'].astype(int)

def count_diffs(report):
    if pd.isna(report): return 0
    text = str(report)
    ro = len(re.findall(r'r/o\b|rule out|DDx|differential|versus|vs\.', text, re.IGNORECASE))
    numbered = len(re.findall(r'\n\s*\d+\.\s', text))
    return max(ro, numbered)

df['n_differentials'] = df['판독문'].apply(count_diffs)
df['no_differential'] = (df['n_differentials'] == 0).astype(int)
df['has_clinical_info'] = df['판독문'].str.contains(
    r'Clinical information|Clinical history|Clinical Info|CI:', case=False, na=False
).astype(int)
df['is_followup'] = (df['시트'] == '다수').astype(int)

predictors = {
    'img_CT_NCE': 'Non-contrast CT (vs CE CT)',
    'img_MRI': 'MRI (vs CE CT)',
    'report_short': 'Short report (<200 chars)',
    'entirely_normal': 'Entirely normal report',
    'mass_mentioned': 'Mass/lesion mentioned',
    'no_differential': 'No differential diagnosis',
    'has_clinical_info': 'Clinical info provided',
    'is_followup': 'Follow-up study',
}

# Univariate
uni_results = []
for var, desc in predictors.items():
    try:
        X = sm.add_constant(df[var].values)
        y = df['miss'].values
        model = sm.Logit(y, X).fit(disp=0)
        or_val = np.exp(model.params[1])
        ci = np.exp(model.conf_int().iloc[1])
        p = model.pvalues[1]
        uni_results.append({
            'Variable': desc, 'code': var,
            'Uni_OR': or_val, 'Uni_CI_low': ci[0], 'Uni_CI_high': ci[1], 'Uni_p': p,
        })
    except:
        pass

# Multivariate
formula = 'miss ~ ' + ' + '.join(predictors.keys())
multi_model = logit(formula, data=df).fit(disp=0)

multi_results = {}
for var in multi_model.params.index:
    if var == 'Intercept': continue
    multi_results[var] = {
        'Multi_aOR': np.exp(multi_model.params[var]),
        'Multi_CI_low': np.exp(multi_model.conf_int().loc[var][0]),
        'Multi_CI_high': np.exp(multi_model.conf_int().loc[var][1]),
        'Multi_p': multi_model.pvalues[var],
    }

# 통합 테이블
combined = []
for u in uni_results:
    var = u['code']
    row = {
        'Variable': u['Variable'],
        'n_positive': int(df[var].sum()),
        'miss_in_positive': f"{df[df[var]==1]['miss'].mean()*100:.1f}%",
        'miss_in_negative': f"{df[df[var]==0]['miss'].mean()*100:.1f}%",
        'Crude_OR': f"{u['Uni_OR']:.2f}",
        'Crude_95CI': f"({u['Uni_CI_low']:.2f}-{u['Uni_CI_high']:.2f})",
        'Crude_p': f"{'<0.001' if u['Uni_p']<0.001 else f'{u[chr(85)+chr(110)+chr(105)+chr(95)+chr(112)]:.3f}'}",
    }
    if var in multi_results:
        m = multi_results[var]
        row['Adjusted_OR'] = f"{m['Multi_aOR']:.2f}"
        row['Adjusted_95CI'] = f"({m['Multi_CI_low']:.2f}-{m['Multi_CI_high']:.2f})"
        row['Adjusted_p'] = f"{'<0.001' if m['Multi_p']<0.001 else f'{m[chr(77)+chr(117)+chr(108)+chr(116)+chr(105)+chr(95)+chr(112)]:.3f}'}"
    combined.append(row)

combined_df = pd.DataFrame(combined)
combined_df.to_csv(os.path.join(RESULTS_DIR, 'table_dvs_combined_uni_multi.csv'), index=False)
print("\nDVS 통합 테이블:")
print(combined_df.to_string(index=False))

# AUC
y_pred = multi_model.predict(df)
auc_val = roc_auc_score(df['miss'].values, y_pred)
print(f"\nC-statistic: {auc_val:.3f}")


# ============================================================
# PART 3B: DVS RISK STRATIFICATION
# ============================================================
print(f"\n{'='*70}")
print("PART 3B: DVS Risk Stratification (Low / Intermediate / High)")
print("="*70)

# 모델 예측 확률 계산
df['dvs_prob'] = multi_model.predict(df)

# 3분위로 나누기
df['risk_group'] = pd.qcut(df['dvs_prob'], 3, labels=['Low Risk', 'Intermediate', 'High Risk'])

# 각 군의 실제 miss rate
print(f"\n{'Risk Group':<18} {'N':>6} {'Observed Miss':>15} {'Miss Rate':>10} {'Mean DVS Prob':>15}")
print("-" * 70)

strat_rows = []
for group in ['Low Risk', 'Intermediate', 'High Risk']:
    subset = df[df['risk_group'] == group]
    n = len(subset)
    n_miss = subset['miss'].sum()
    miss_rate = subset['miss'].mean() * 100
    mean_prob = subset['dvs_prob'].mean() * 100
    print(f"  {group:<16} {n:>6} {n_miss:>8}/{n:<6} {miss_rate:>8.1f}% {mean_prob:>13.1f}%")
    strat_rows.append({
        'Risk_Group': group, 'N': n, 'N_miss': n_miss,
        'Observed_miss_rate': miss_rate, 'Predicted_mean_prob': mean_prob,
    })

strat_df = pd.DataFrame(strat_rows)
strat_df.to_csv(os.path.join(RESULTS_DIR, 'table_dvs_risk_stratification.csv'), index=False)

# Risk Stratification Bar Chart
fig, ax = plt.subplots(figsize=(8, 5))
groups = strat_df['Risk_Group']
miss_rates = strat_df['Observed_miss_rate']
colors_risk = ['#27ae60', '#f39c12', '#e74c3c']
bars = ax.bar(groups, miss_rates, color=colors_risk, width=0.5, edgecolor='white', linewidth=2)

for bar, (_, row) in zip(bars, strat_df.iterrows()):
    ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 1.5,
            f"{row['Observed_miss_rate']:.1f}%\n({int(row['N_miss'])}/{int(row['N'])})",
            ha='center', va='bottom', fontsize=11, fontweight='bold')

ax.set_ylabel('Observed Diagnostic Miss Rate (%)', fontsize=12)
ax.set_title('DVS Risk Stratification:\nObserved Miss Rate by Predicted Risk Group',
             fontsize=13, fontweight='bold')
ax.set_ylim(0, max(miss_rates) * 1.3)
ax.axhline(y=df['miss'].mean()*100, color='gray', linestyle='--', alpha=0.5,
           label=f'Overall miss rate ({df["miss"].mean()*100:.1f}%)')
ax.legend(fontsize=9)

# Annotation
ax.text(0.02, 0.98, f'C-statistic = {auc_val:.3f}\nn = {len(df)}',
        transform=ax.transAxes, fontsize=9, verticalalignment='top',
        bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

plt.tight_layout()
plt.savefig(os.path.join(FIGURES_DIR, 'fig11_dvs_risk_stratification.png'), bbox_inches='tight')
plt.close()
print(f"  Fig 11: dvs_risk_stratification.png")

# Hosmer-Lemeshow style calibration
print(f"\nCalibration (5-group):")
df['prob_quintile'] = pd.qcut(df['dvs_prob'], 5, duplicates='drop')
cal = df.groupby('prob_quintile').agg(
    n=('miss', 'count'),
    observed=('miss', 'mean'),
    predicted=('dvs_prob', 'mean'),
).reset_index()
for _, row in cal.iterrows():
    print(f"  n={row['n']:4d}: observed={row['observed']:.3f}, predicted={row['predicted']:.3f}")


# ============================================================
# PART 4: IMPROVED FIGURES
# ============================================================
print(f"\n{'='*70}")
print("PART 4: Improved Figures")
print("="*70)

# --- Fig A: Diagnostic Delay Waterfall ---
if len(delay_table) > 0:
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
    
    # Left: First-study miss rate by diagnosis
    dt = delay_table.sort_values('First_miss_rate', ascending=True)
    colors = ['#e74c3c' if r > 50 else '#f39c12' if r > 30 else '#27ae60' for r in dt['First_miss_rate']]
    bars = ax1.barh(range(len(dt)), dt['First_miss_rate'], color=colors, height=0.6)
    ax1.set_yticks(range(len(dt)))
    ax1.set_yticklabels(dt['Diagnosis'], fontsize=9)
    ax1.set_xlabel('First-Study Miss Rate (%)', fontsize=11)
    ax1.set_title('A. First Imaging Study Miss Rate\n(Follow-up Patients Only)', fontsize=11, fontweight='bold')
    for i, (_, row) in enumerate(dt.iterrows()):
        ax1.text(row['First_miss_rate'] + 1, i,
                f"{row['First_miss_rate']:.0f}% ({row['First_miss_n']:.0f}/{row['N_patients']:.0f})",
                va='center', fontsize=8)
    
    # Right: Median delay in days
    dt_delay = delay_table[delay_table['Median_delay_days'].notna()].sort_values('Median_delay_days', ascending=True)
    if len(dt_delay) > 0:
        bars2 = ax2.barh(range(len(dt_delay)), dt_delay['Median_delay_days'], color='#3498db', height=0.6)
        ax2.set_yticks(range(len(dt_delay)))
        ax2.set_yticklabels(dt_delay['Diagnosis'], fontsize=9)
        ax2.set_xlabel('Median Diagnostic Delay (days)', fontsize=11)
        ax2.set_title('B. Median Delay to Correct Diagnosis\n(Among Initially Missed Cases)', fontsize=11, fontweight='bold')
        for i, (_, row) in enumerate(dt_delay.iterrows()):
            ax2.text(row['Median_delay_days'] + 5, i,
                    f"{row['Median_delay_days']:.0f} days", va='center', fontsize=8)
    
    plt.tight_layout()
    plt.savefig(os.path.join(FIGURES_DIR, 'fig10_diagnostic_delay.png'), bbox_inches='tight')
    plt.close()
    print("  Fig 10: diagnostic_delay.png")

# --- Fig B: Combined sensitivity + DVS summary ---
fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Panel A: Disease distribution pie
diag_counts = has_report['진단카테고리'].value_counts()
top_diags = diag_counts[diag_counts > 20]
other_count = diag_counts[diag_counts <= 20].sum()
plot_data = pd.concat([top_diags, pd.Series({'Other': other_count})])
colors_pie = plt.cm.Set3(np.linspace(0, 1, len(plot_data)))
axes[0].pie(plot_data, labels=plot_data.index, autopct='%1.1f%%', colors=colors_pie, 
            pctdistance=0.85, startangle=90, textprops={'fontsize': 7})
axes[0].set_title('A. Disease Distribution', fontsize=11, fontweight='bold')

# Panel B: Sensitivity bars
table2 = pd.read_csv(os.path.join(RESULTS_DIR, 'table2_diagnostic_accuracy.csv'))
table2 = table2.sort_values('Sensitivity', ascending=True)
colors_bar = ['#e74c3c' if s < 0.5 else '#f39c12' if s < 0.7 else '#27ae60' for s in table2['Sensitivity']]
axes[1].barh(range(len(table2)), table2['Sensitivity'] * 100, color=colors_bar, height=0.6)
for i, (_, row) in enumerate(table2.iterrows()):
    axes[1].plot([row['Sens_95CI_low']*100, row['Sens_95CI_high']*100], [i, i], color='black', linewidth=1.5)
    axes[1].text(row['Sensitivity']*100 + 2, i, f"{row['Sensitivity']:.0%}", va='center', fontsize=8, fontweight='bold')
labels = [f"{row['Diagnosis']}\n(n={int(row['N_confirmed'])})" for _, row in table2.iterrows()]
axes[1].set_yticks(range(len(table2)))
axes[1].set_yticklabels(labels, fontsize=7)
axes[1].set_xlabel('Sensitivity (%)')
axes[1].set_title('B. Report Diagnostic Sensitivity', fontsize=11, fontweight='bold')
axes[1].axvline(x=50, color='gray', linestyle='--', alpha=0.3)

# Panel C: DVS Forest Plot (improved)
multi_df = pd.DataFrame([
    {'var': desc, 'aOR': np.exp(multi_model.params[code]),
     'ci_low': np.exp(multi_model.conf_int().loc[code][0]),
     'ci_high': np.exp(multi_model.conf_int().loc[code][1]),
     'p': multi_model.pvalues[code]}
    for code, desc in predictors.items() if code in multi_model.params.index
]).sort_values('aOR', ascending=True)

for i, (_, row) in enumerate(multi_df.iterrows()):
    color = '#e74c3c' if row['p'] < 0.05 else '#bdc3c7'
    axes[2].plot([row['ci_low'], row['ci_high']], [i, i], color=color, linewidth=2.5)
    axes[2].plot(row['aOR'], i, 'o', color=color, markersize=8, zorder=5)
    sig = "*" if row['p'] < 0.05 else ""
    axes[2].text(max(row['ci_high']*1.1, 2), i, f"{row['aOR']:.2f}{sig}", va='center', fontsize=8)

axes[2].axvline(x=1, color='black', linestyle='--', linewidth=1, alpha=0.5)
axes[2].set_yticks(range(len(multi_df)))
axes[2].set_yticklabels(multi_df['var'], fontsize=7)
axes[2].set_xlabel('Adjusted OR (95% CI)')
axes[2].set_title(f'C. DVS Predictors (AUC={auc_val:.3f})', fontsize=11, fontweight='bold')
axes[2].set_xscale('log')
axes[2].set_xlim(0.1, 30)

plt.tight_layout()
plt.savefig(os.path.join(FIGURES_DIR, 'fig_central_illustration.png'), bbox_inches='tight')
plt.close()
print("  Central Illustration 저장 완료")


# ============================================================
# PART 5: 최종 요약
# ============================================================
summary = f"""
{'='*70}
Module 6 최종 요약
{'='*70}

■ Diagnostic Delay Analysis:
  - Follow-up 환자: {len(delay_df)}명
  - 첫 영상 miss: {first_miss}/{len(delay_df)} ({first_miss/len(delay_df)*100:.1f}%)
  - Miss 후 결국 잡힘: {len(eventually_caught)}명
  - 끝까지 못 잡힘: {len(never_caught)}명

■ 저장된 파일:
  - {RESULTS_DIR}/table1_baseline_all.csv
  - {RESULTS_DIR}/table6_diagnostic_delay.csv
  - {RESULTS_DIR}/table_dvs_combined_uni_multi.csv
  - {FIGURES_DIR}/fig10_diagnostic_delay.png
  - {FIGURES_DIR}/fig_central_illustration.png

■ 논문 구조 완성:
  Part 1: Disease spectrum (Table 1, Fig 1)
  Part 2: Diagnostic accuracy (Table 2, Fig 2) 
  Part 3: DVS model (Table DVS, Fig forest/ROC)
  Part 4: Diagnostic delay (Table 6, Fig 10)
  → Central Illustration: 3-panel 종합 figure
"""
print(summary)

with open(os.path.join(RESULTS_DIR, 'module6_summary.txt'), 'w', encoding='utf-8') as f:
    f.write(summary)

print("Module 6 완료!")
