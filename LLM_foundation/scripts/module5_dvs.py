"""
논문 1 - Module 5: Diagnostic Vulnerability Score (DVS)
========================================================
핵심: "어떤 특성의 판독문이 진단을 놓칠 위험이 높은가?"

분석:
  1. 종속변수 정의: 판독 miss (확정진단을 판독문에서 놓침)
  2. 독립변수 추출: 판독문 특성 (진단 확정 전에 알 수 있는 것들만)
  3. Univariable → Multivariable logistic regression
  4. C-statistic (AUC)
  5. Bootstrap internal validation (1000회)
  6. Nomogram figure 생성

실행:
  pip install pandas numpy scikit-learn statsmodels matplotlib
  python module5_dvs.py
"""

import pandas as pd
import numpy as np
import os
import re
import warnings
warnings.filterwarnings('ignore')

from scipy import stats

try:
    import statsmodels.api as sm
    from statsmodels.formula.api import logit
    from statsmodels.stats.outliers_influence import variance_inflation_factor
except ImportError:
    print("pip install statsmodels"); exit()

try:
    from sklearn.metrics import roc_auc_score, roc_curve
    from sklearn.utils import resample
except ImportError:
    print("pip install scikit-learn"); exit()

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

# ============================================================
# 데이터 로드
# ============================================================
print("=" * 60)
print("Module 5: Diagnostic Vulnerability Score (DVS)")
print("=" * 60)

orbital = pd.read_csv(os.path.join(OUTPUT_DIR, 'orbital_cleaned.csv'))

# 판독문 있는 건만
df = orbital[orbital['판독분류'] != 'no_report'].copy()
print(f"판독문 있는 건: {len(df)}")

# ============================================================
# 1. 종속변수: 판독 MISS 정의
# ============================================================
print(f"\n{'='*60}")
print("1. 종속변수 정의: 판독 Miss")
print("="*60)

# 각 진단카테고리별로 판독문에 해당 진단이 언급되었는지
# 진단-키워드 매핑에서 키워드 컬럼이 있는 질환만 포함
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
    """판독 miss 여부 판정"""
    cat = row['진단카테고리']
    
    if cat in keyword_col_map:
        col = keyword_col_map[cat]
        if col in row.index:
            return 0 if row[col] else 1  # 언급됨=0(정확), 미언급=1(miss)
    
    # Benign tumor, Malignant tumor: mass/lesion 언급 여부로 판정
    if cat in ['Benign tumor', 'Malignant tumor']:
        if '판독_mass' in row.index:
            return 0 if row['판독_mass'] else 1
    
    # Other orbital disease, Lymphangioma: mass 언급 여부
    if cat in ['Other orbital disease', 'Lymphangioma']:
        if '판독_mass' in row.index:
            return 0 if row['판독_mass'] else 1
    
    return np.nan  # 분류 불가 → 제외

df['miss'] = df.apply(define_miss, axis=1)
df_valid = df.dropna(subset=['miss']).copy()
df_valid['miss'] = df_valid['miss'].astype(int)

miss_rate = df_valid['miss'].mean()
print(f"DVS 분석 대상: {len(df_valid)}건")
print(f"전체 Miss rate: {df_valid['miss'].sum()}/{len(df_valid)} ({miss_rate*100:.1f}%)")

print(f"\n진단별 miss rate:")
for cat in df_valid['진단카테고리'].unique():
    subset = df_valid[df_valid['진단카테고리'] == cat]
    mr = subset['miss'].mean()
    print(f"  {cat}: {subset['miss'].sum()}/{len(subset)} ({mr*100:.1f}%)")

# ============================================================
# 2. 독립변수 추출 (판독 시점에 알 수 있는 것들만)
# ============================================================
print(f"\n{'='*60}")
print("2. 독립변수 추출")
print("="*60)

# 2a. 영상 종류
df_valid['img_CT_CE'] = (df_valid['영상카테고리'] == 'CT_CE').astype(int)
df_valid['img_CT_NCE'] = (df_valid['영상카테고리'] == 'CT_NCE').astype(int)
df_valid['img_MRI'] = (df_valid['영상카테고리'] == 'MRI_CE').astype(int)
# Reference: CT_CE (가장 흔함)

# 2b. 판독문 길이 (report thoroughness proxy)
df_valid['report_length'] = df_valid['판독문'].str.len().fillna(0)
# 카테고리화: short (<200), medium (200-500), long (>500)
df_valid['report_short'] = (df_valid['report_length'] < 200).astype(int)
df_valid['report_long'] = (df_valid['report_length'] > 500).astype(int)
# Reference: medium

# 2c. Entirely normal report
df_valid['entirely_normal'] = (df_valid['판독분류'] == 'entirely_normal').astype(int)

# 2d. Mass/lesion 언급 여부
df_valid['mass_mentioned'] = df_valid['판독_mass'].astype(int) if '판독_mass' in df_valid.columns else 0

# 2e. 감별진단 개수 추출 (판독문에서 r/o, DDx, 1. 2. 3. 패턴)
def count_differentials(report):
    if pd.isna(report):
        return 0
    text = str(report)
    # "r/o", "DDx:", "differential", "rule out" 패턴
    ro_count = len(re.findall(r'r/o\b|rule out|DDx|differential|versus|vs\.', text, re.IGNORECASE))
    # 번호 매긴 진단 (1. xxx 2. xxx)
    numbered = len(re.findall(r'\n\s*\d+\.\s', text))
    return max(ro_count, numbered)

df_valid['n_differentials'] = df_valid['판독문'].apply(count_differentials)
df_valid['no_differential'] = (df_valid['n_differentials'] == 0).astype(int)

# 2f. 임상정보 제공 여부
df_valid['has_clinical_info'] = df_valid['판독문'].str.contains(
    r'Clinical information|Clinical history|Clinical Info|CI:', case=False, na=False
).astype(int)

# 2g. 시트 (일회성 vs 다수 = 초진 vs 추적)
df_valid['is_followup'] = (df_valid['시트'] == '다수').astype(int)

print("독립변수 요약:")
predictors_desc = {
    'img_CT_NCE': 'Non-contrast CT (vs CE CT)',
    'img_MRI': 'MRI (vs CE CT)',
    'report_short': 'Short report (<200 chars)',
    'report_long': 'Long report (>500 chars)',
    'entirely_normal': 'Entirely normal report',
    'mass_mentioned': 'Mass/lesion mentioned',
    'no_differential': 'No differential diagnosis',
    'has_clinical_info': 'Clinical info provided',
    'is_followup': 'Follow-up study (vs initial)',
}

for var, desc in predictors_desc.items():
    n_pos = df_valid[var].sum()
    pct = n_pos / len(df_valid) * 100
    miss_in_pos = df_valid[df_valid[var] == 1]['miss'].mean() * 100 if n_pos > 0 else 0
    miss_in_neg = df_valid[df_valid[var] == 0]['miss'].mean() * 100
    print(f"  {desc}: n={n_pos} ({pct:.1f}%), miss rate: {miss_in_pos:.1f}% vs {miss_in_neg:.1f}%")

# ============================================================
# 3. Univariable Logistic Regression
# ============================================================
print(f"\n{'='*60}")
print("3. Univariable Analysis")
print("="*60)

predictor_list = ['img_CT_NCE', 'img_MRI', 'report_short', 'report_long',
                  'entirely_normal', 'mass_mentioned', 'no_differential',
                  'has_clinical_info', 'is_followup']

univar_results = []
print(f"\n{'Variable':<25} {'OR':>6} {'95% CI':>16} {'p-value':>10}")
print("-" * 60)

for var in predictor_list:
    try:
        X = sm.add_constant(df_valid[var].values)
        y = df_valid['miss'].values
        model = sm.Logit(y, X).fit(disp=0)
        
        or_val = np.exp(model.params[1])
        ci = np.exp(model.conf_int().iloc[1])
        p = model.pvalues[1]
        
        ci_str = f"({ci[0]:.2f}-{ci[1]:.2f})"
        p_str = f"{p:.4f}" if p >= 0.001 else "<0.001"
        
        print(f"  {predictors_desc[var]:<25} {or_val:>5.2f} {ci_str:>16} {p_str:>10}")
        
        univar_results.append({
            'Variable': predictors_desc[var],
            'OR': or_val, 'CI_low': ci[0], 'CI_high': ci[1], 'p': p,
            'significant': p < 0.05,
        })
    except Exception as e:
        print(f"  {var}: ERROR - {e}")

univar_df = pd.DataFrame(univar_results)
univar_df.to_csv(os.path.join(RESULTS_DIR, 'dvs_univariable.csv'), index=False)

# ============================================================
# 4. Multivariable Logistic Regression
# ============================================================
print(f"\n{'='*60}")
print("4. Multivariable Logistic Regression")
print("="*60)

# 유의한 변수 + 임상적으로 중요한 변수 포함
# entirely_normal과 mass_mentioned는 강한 상관이 있을 수 있으므로 주의
# multicollinearity 체크 후 최종 모델 결정

# 후보 변수
candidates = ['img_CT_NCE', 'img_MRI', 'report_short',
              'entirely_normal', 'mass_mentioned', 'no_differential',
              'has_clinical_info', 'is_followup']

# VIF 체크
X_check = df_valid[candidates].copy()
X_check = sm.add_constant(X_check)
print("\nVIF (Variance Inflation Factor):")
for i, col in enumerate(X_check.columns):
    if col == 'const':
        continue
    vif = variance_inflation_factor(X_check.values, i)
    print(f"  {col}: {vif:.2f}")
    if vif > 5:
        print(f"    ⚠️ High VIF - consider removing")

# 최종 multivariable 모델
formula = 'miss ~ img_CT_NCE + img_MRI + report_short + entirely_normal + mass_mentioned + no_differential + has_clinical_info + is_followup'

print(f"\nFinal model: {formula}")
multi_model = logit(formula, data=df_valid).fit(disp=0)
print(multi_model.summary2())

# OR 추출
multi_results = []
print(f"\n{'Variable':<30} {'aOR':>6} {'95% CI':>16} {'p-value':>10}")
print("-" * 65)

for var in multi_model.params.index:
    if var == 'Intercept':
        continue
    or_val = np.exp(multi_model.params[var])
    ci = np.exp(multi_model.conf_int().loc[var])
    p = multi_model.pvalues[var]
    
    desc = predictors_desc.get(var, var)
    ci_str = f"({ci[0]:.2f}-{ci[1]:.2f})"
    p_str = f"{p:.4f}" if p >= 0.001 else "<0.001"
    sig = "*" if p < 0.05 else ""
    
    print(f"  {desc:<30} {or_val:>5.2f} {ci_str:>16} {p_str:>10} {sig}")
    
    multi_results.append({
        'Variable': desc,
        'code': var,
        'aOR': or_val, 'CI_low': ci[0], 'CI_high': ci[1], 'p': p,
        'coefficient': multi_model.params[var],
    })

multi_df = pd.DataFrame(multi_results)
multi_df.to_csv(os.path.join(RESULTS_DIR, 'dvs_multivariable.csv'), index=False)

# ============================================================
# 5. Model Performance (C-statistic / AUC)
# ============================================================
print(f"\n{'='*60}")
print("5. Model Performance")
print("="*60)

y_true = df_valid['miss'].values
y_pred = multi_model.predict(df_valid)

auc = roc_auc_score(y_true, y_pred)
print(f"C-statistic (AUC): {auc:.3f}")

# Hosmer-Lemeshow goodness-of-fit (간이 버전)
# 10 deciles
df_valid['pred_prob'] = y_pred
deciles = pd.qcut(df_valid['pred_prob'], 10, duplicates='drop')
hl_table = df_valid.groupby(deciles).agg(
    observed=('miss', 'sum'),
    expected=('pred_prob', 'sum'),
    n=('miss', 'count'),
).reset_index()
print(f"\nCalibration (observed vs expected by decile):")
for _, row in hl_table.iterrows():
    print(f"  n={row['n']:4d}: observed={row['observed']:3.0f}, expected={row['expected']:.1f}")

# ============================================================
# 6. Bootstrap Internal Validation (1000회)
# ============================================================
print(f"\n{'='*60}")
print("6. Bootstrap Validation (1000 iterations)")
print("="*60)

n_boot = 1000
boot_aucs = []
optimism_values = []

feature_cols = ['img_CT_NCE', 'img_MRI', 'report_short',
                'entirely_normal', 'mass_mentioned', 'no_differential',
                'has_clinical_info', 'is_followup']

X_orig = sm.add_constant(df_valid[feature_cols].values)
y_orig = df_valid['miss'].values

for i in range(n_boot):
    # Bootstrap sample
    idx = resample(range(len(df_valid)), n_samples=len(df_valid), random_state=i)
    X_boot = X_orig[idx]
    y_boot = y_orig[idx]
    
    try:
        boot_model = sm.Logit(y_boot, X_boot).fit(disp=0, maxiter=100)
        
        # AUC on bootstrap sample (apparent)
        pred_boot = boot_model.predict(X_boot)
        auc_boot = roc_auc_score(y_boot, pred_boot)
        
        # AUC on original sample (test)
        pred_orig = boot_model.predict(X_orig)
        auc_orig = roc_auc_score(y_orig, pred_orig)
        
        optimism = auc_boot - auc_orig
        optimism_values.append(optimism)
        boot_aucs.append(auc_orig)
    except:
        continue

mean_optimism = np.mean(optimism_values)
corrected_auc = auc - mean_optimism
boot_ci = np.percentile(boot_aucs, [2.5, 97.5])

print(f"Apparent AUC: {auc:.3f}")
print(f"Mean optimism: {mean_optimism:.3f}")
print(f"Optimism-corrected AUC: {corrected_auc:.3f}")
print(f"Bootstrap 95% CI: ({boot_ci[0]:.3f}-{boot_ci[1]:.3f})")

# ============================================================
# 7. ROC Curve Figure
# ============================================================
fpr, tpr, thresholds = roc_curve(y_true, y_pred)

fig, ax = plt.subplots(figsize=(6, 6))
ax.plot(fpr, tpr, color='#e74c3c', linewidth=2,
        label=f'DVS Model (AUC = {auc:.3f})')
ax.plot([0, 1], [0, 1], color='gray', linestyle='--', linewidth=1)
ax.set_xlabel('1 - Specificity (False Positive Rate)', fontsize=11)
ax.set_ylabel('Sensitivity (True Positive Rate)', fontsize=11)
ax.set_title('ROC Curve: Diagnostic Vulnerability Score', fontsize=12, fontweight='bold')
ax.legend(loc='lower right', fontsize=10)
ax.set_xlim(-0.02, 1.02)
ax.set_ylim(-0.02, 1.02)
plt.tight_layout()
plt.savefig(os.path.join(FIGURES_DIR, 'fig7_dvs_roc.png'))
plt.close()
print(f"\nFig 7: dvs_roc.png 저장 완료")

# ============================================================
# 8. Forest Plot of Adjusted ORs
# ============================================================
fig, ax = plt.subplots(figsize=(8, 5))

multi_df_sorted = multi_df.sort_values('aOR', ascending=True)
y_pos = range(len(multi_df_sorted))
colors = ['#e74c3c' if p < 0.05 else '#95a5a6' for p in multi_df_sorted['p']]

for i, (_, row) in enumerate(multi_df_sorted.iterrows()):
    ax.plot([row['CI_low'], row['CI_high']], [i, i], color=colors[i], linewidth=2)
    ax.plot(row['aOR'], i, 'o', color=colors[i], markersize=8)

ax.axvline(x=1.0, color='black', linestyle='--', linewidth=1, alpha=0.5)
ax.set_yticks(y_pos)
ax.set_yticklabels(multi_df_sorted['Variable'], fontsize=9)
ax.set_xlabel('Adjusted Odds Ratio (95% CI)', fontsize=11)
ax.set_title('Diagnostic Vulnerability Score:\nAdjusted Odds Ratios for Missed Diagnosis',
             fontsize=12, fontweight='bold')
ax.set_xscale('log')
ax.set_xlim(0.05, 50)

# OR 수치 표시
for i, (_, row) in enumerate(multi_df_sorted.iterrows()):
    sig = "*" if row['p'] < 0.05 else ""
    ax.text(max(row['CI_high'] * 1.1, row['aOR'] * 1.3), i,
            f"{row['aOR']:.2f}{sig}", va='center', fontsize=8)

plt.tight_layout()
plt.savefig(os.path.join(FIGURES_DIR, 'fig8_dvs_forest.png'))
plt.close()
print(f"Fig 8: dvs_forest.png 저장 완료")

# ============================================================
# 9. Nomogram Figure
# ============================================================
fig, axes = plt.subplots(len(multi_df) + 2, 1, figsize=(10, len(multi_df) * 0.8 + 3),
                          gridspec_kw={'height_ratios': [1] * (len(multi_df) + 2)})

# Points scale (0-100)
max_coef = max(abs(r['coefficient']) for _, r in multi_df.iterrows())
point_scale = 100 / max_coef if max_coef > 0 else 1

# Header: Points
ax = axes[0]
ax.set_xlim(0, 100)
ax.set_xticks(range(0, 101, 10))
ax.set_xticklabels(range(0, 101, 10), fontsize=7)
ax.set_yticks([])
ax.set_ylabel('Points', fontsize=9, fontweight='bold')
ax.xaxis.set_ticks_position('top')

# Each variable
for idx, (_, row) in enumerate(multi_df.iterrows()):
    ax = axes[idx + 1]
    ax.set_xlim(0, 100)
    
    coef = row['coefficient']
    # 0 (absent) → 0 points, 1 (present) → coef * scale points
    points_0 = 0
    points_1 = max(0, coef * point_scale)
    
    # 음수 계수는 방향 뒤집기
    if coef < 0:
        points_0 = abs(coef) * point_scale
        points_1 = 0
    
    ax.plot([points_0], [0.5], 'o', color='#3498db', markersize=6)
    ax.plot([points_1], [0.5], 's', color='#e74c3c', markersize=6)
    ax.plot([points_0, points_1], [0.5, 0.5], '-', color='gray', linewidth=1)
    
    ax.text(points_0, 0.8, 'No', ha='center', fontsize=7, color='#3498db')
    ax.text(points_1, 0.8, 'Yes', ha='center', fontsize=7, color='#e74c3c')
    
    ax.set_yticks([])
    ax.set_ylabel(row['Variable'][:25], fontsize=7, fontweight='bold', rotation=0,
                  ha='right', va='center')
    ax.set_xticks([])
    ax.axhline(y=0, color='lightgray', linewidth=0.5)

# Total points → Probability
ax = axes[-1]
ax.set_xlim(0, 100)
total_range = np.linspace(0, 100, 6)
# Convert total points to probability
intercept = multi_model.params['Intercept']
total_coef_sum = sum(max(0, r['coefficient']) for _, r in multi_df.iterrows())
probs = []
for tp in total_range:
    logit_val = intercept + (tp / point_scale) * (total_coef_sum / sum(abs(r['coefficient']) for _, r in multi_df.iterrows())) if total_coef_sum > 0 else 0
    prob = 1 / (1 + np.exp(-logit_val))
    probs.append(prob)

ax.set_xticks(total_range)
ax.set_xticklabels([f"{p:.0%}" for p in probs], fontsize=7)
ax.set_yticks([])
ax.set_ylabel('Miss Prob', fontsize=9, fontweight='bold')
ax.xaxis.set_ticks_position('bottom')

fig.suptitle('Nomogram: Diagnostic Vulnerability Score (DVS)', fontsize=13, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig(os.path.join(FIGURES_DIR, 'fig9_dvs_nomogram.png'), bbox_inches='tight')
plt.close()
print(f"Fig 9: dvs_nomogram.png 저장 완료")

# ============================================================
# 10. 최종 요약
# ============================================================
summary = f"""
{'='*60}
DVS 분석 최종 요약
{'='*60}

■ 분석 대상: {len(df_valid)}건 (판독문 있고 miss 판정 가능한 건)
■ 전체 Miss rate: {df_valid['miss'].sum()}/{len(df_valid)} ({miss_rate*100:.1f}%)

■ Multivariable Model:
  C-statistic (AUC): {auc:.3f}
  Optimism-corrected AUC: {corrected_auc:.3f}
  Bootstrap 95% CI: ({boot_ci[0]:.3f}-{boot_ci[1]:.3f})

■ Significant predictors (p<0.05):
"""

for _, row in multi_df.iterrows():
    if row['p'] < 0.05:
        summary += f"  {row['Variable']}: aOR {row['aOR']:.2f} ({row['CI_low']:.2f}-{row['CI_high']:.2f}), p={'<0.001' if row['p']<0.001 else f'{row[chr(112)]:.3f}'}\n"

summary += f"""
■ 저장된 파일:
  {RESULTS_DIR}/dvs_univariable.csv
  {RESULTS_DIR}/dvs_multivariable.csv
  {FIGURES_DIR}/fig7_dvs_roc.png
  {FIGURES_DIR}/fig8_dvs_forest.png
  {FIGURES_DIR}/fig9_dvs_nomogram.png

■ 논문 기술:
  "We developed a Diagnostic Vulnerability Score using multivariable
   logistic regression to predict the probability of missed diagnosis
   in orbital radiology reports. The model achieved a C-statistic of
   {auc:.3f} (optimism-corrected: {corrected_auc:.3f}, 95% CI: 
   {boot_ci[0]:.3f}-{boot_ci[1]:.3f}) after bootstrap internal 
   validation with 1000 iterations."
"""
print(summary)

with open(os.path.join(RESULTS_DIR, 'dvs_summary.txt'), 'w', encoding='utf-8') as f:
    f.write(summary)

print("Module 5 완료!")
