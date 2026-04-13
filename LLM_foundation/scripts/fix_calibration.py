"""
CALIBRATION FIX: 올바른 calibration 보고
==========================================
문제: Training data에서 logit-based calibration slope = 1.0은 동어반복
해결: 
  1. Decile calibration plot (training data에서도 유의미)
  2. Bootstrap-corrected calibration slope (optimism-adjusted)

실행: python fix_calibration.py
"""

import pandas as pd
import numpy as np
import os
import re
import warnings
warnings.filterwarnings('ignore')

import statsmodels.api as sm
from sklearn.metrics import roc_auc_score

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

OUTPUT_DIR = r"paper1_output"
RESULTS_DIR = os.path.join(OUTPUT_DIR, "results")
FIGURES_DIR = os.path.join(OUTPUT_DIR, "figures")

plt.rcParams['font.family'] = 'DejaVu Sans'
plt.rcParams['figure.dpi'] = 300

# ============================================================
# 데이터 로드 + 변수 준비 (이전 모듈과 동일)
# ============================================================
orbital = pd.read_csv(os.path.join(OUTPUT_DIR, 'orbital_cleaned.csv'))
has_report = orbital[orbital['판독분류'] != 'no_report'].copy()

REPORT_KW = {
    'TED': '판독_TED', 'Lymphoma': '판독_Lymphoma',
    'Pseudotumor': '판독_Pseudotumor',
    'Cavernous hemangioma': '판독_Cavernous hemangioma',
    'Pleomorphic adenoma': '판독_Pleomorphic adenoma',
    'Meningioma': '판독_Meningioma', 'IgG4-RD': '판독_IgG4-RD',
}

def define_miss(row):
    cat = row['진단카테고리']
    if cat in REPORT_KW:
        col = REPORT_KW[cat]
        if col in row.index:
            return 0 if row[col] else 1
    if cat in ['Benign tumor', 'Malignant tumor', 'Other orbital disease', 'Lymphangioma']:
        if '판독_mass' in row.index:
            return 0 if row['판독_mass'] else 1
    return np.nan

df = has_report.copy()
df['miss'] = df.apply(define_miss, axis=1)
df = df.dropna(subset=['miss']).copy()
df['miss'] = df['miss'].astype(int)

df['img_CT_NCE'] = (df['영상카테고리'] == 'CT_NCE').astype(int)
df['img_MRI'] = (df['영상카테고리'] == 'MRI_CE').astype(int)
df['report_short'] = (df['판독문'].str.len().fillna(0) < 200).astype(int)
df['entirely_normal'] = (df['판독분류'] == 'entirely_normal').astype(int)
df['mass_mentioned'] = df['판독_mass'].astype(int)

def count_diffs(text):
    if pd.isna(text): return 0
    t = str(text)
    ro = len(re.findall(r'r/o\b|rule out|DDx|differential|versus|vs\.', t, re.IGNORECASE))
    num = len(re.findall(r'\n\s*\d+\.\s', t))
    return max(ro, num)

df['no_differential'] = (df['판독문'].apply(count_diffs) == 0).astype(int)
df['has_clinical_info'] = df['판독문'].str.contains(
    r'Clinical information|Clinical history|Clinical Info|CI:', case=False, na=False).astype(int)
df['is_followup'] = (df['시트'] == '다수').astype(int)

feature_cols = ['img_CT_NCE', 'img_MRI', 'report_short', 'entirely_normal',
                'mass_mentioned', 'no_differential', 'has_clinical_info', 'is_followup']

X = sm.add_constant(df[feature_cols].values)
y = df['miss'].values

# 원래 모델
model = sm.Logit(y, X).fit(disp=0)
pred_prob = model.predict(X)
auc_apparent = roc_auc_score(y, pred_prob)

print("=" * 70)
print("CALIBRATION FIX")
print("=" * 70)
print(f"Apparent AUC: {auc_apparent:.3f}")
print(f"N = {len(df)}, Events = {y.sum()}")


# ============================================================
# 1. DECILE CALIBRATION PLOT (올바른 방법)
# ============================================================
print(f"\n{'='*70}")
print("1. Decile Calibration Plot")
print("="*70)

# 10분위로 나누기
df['pred'] = pred_prob
df['decile'] = pd.qcut(df['pred'], 10, duplicates='drop', labels=False)

cal = df.groupby('decile').agg(
    n=('miss', 'count'),
    events=('miss', 'sum'),
    observed=('miss', 'mean'),
    predicted=('pred', 'mean'),
).reset_index()

print(f"\n{'Decile':>7} {'N':>6} {'Events':>7} {'Observed':>10} {'Predicted':>11} {'O/E':>6}")
print("-" * 50)
for _, row in cal.iterrows():
    oe = row['observed'] / row['predicted'] if row['predicted'] > 0 else 0
    print(f"  {int(row['decile'])+1:>5} {int(row['n']):>6} {int(row['events']):>7} "
          f"{row['observed']:>9.3f} {row['predicted']:>10.3f} {oe:>5.2f}")

# Calibration plot
fig, ax = plt.subplots(figsize=(6, 6))

# Perfect calibration line
ax.plot([0, 1], [0, 1], 'k--', linewidth=1, alpha=0.5, label='Perfect calibration')

# Decile points (size proportional to n)
sizes = cal['n'] * 0.3
ax.scatter(cal['predicted'], cal['observed'], s=sizes, 
           color='#e74c3c', zorder=5, edgecolors='white', linewidth=0.5,
           label='Observed by decile')

# Connect points
cal_sorted = cal.sort_values('predicted')
ax.plot(cal_sorted['predicted'], cal_sorted['observed'], '-', 
        color='#e74c3c', linewidth=1.5, alpha=0.7)

# Rug plots (distribution of predictions)
ax.plot(pred_prob[y==1], np.full(sum(y==1), -0.02), '|', 
        color='#e74c3c', alpha=0.1, markersize=5, label='Events')
ax.plot(pred_prob[y==0], np.full(sum(y==0), -0.04), '|', 
        color='#3498db', alpha=0.1, markersize=5, label='Non-events')

# Labels
ax.set_xlabel('Predicted probability of diagnostic miss', fontsize=11)
ax.set_ylabel('Observed proportion of diagnostic miss', fontsize=11)
ax.set_title('Calibration Plot\nDiagnostic Vulnerability Score', fontsize=12, fontweight='bold')

# Axis limits
max_val = max(cal['predicted'].max(), cal['observed'].max()) + 0.05
ax.set_xlim(-0.05, max_val)
ax.set_ylim(-0.06, max_val)

ax.legend(fontsize=8, loc='upper left')

# Annotation
ax.text(0.95, 0.05, f'C-statistic = {auc_apparent:.3f}\nn = {len(df)}',
        transform=ax.transAxes, fontsize=9, ha='right', va='bottom',
        bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

plt.tight_layout()
plt.savefig(os.path.join(FIGURES_DIR, 'fig_calibration_CORRECTED.png'), bbox_inches='tight')
plt.close()
print(f"\nCalibration plot 저장: fig_calibration_CORRECTED.png")


# ============================================================
# 2. BOOTSTRAP-CORRECTED CALIBRATION
# ============================================================
print(f"\n{'='*70}")
print("2. Bootstrap-Corrected Calibration + AUC")
print("="*70)

n_boot = 1000
np.random.seed(42)

boot_apparent_aucs = []
boot_test_aucs = []
boot_apparent_slopes = []
boot_test_slopes = []

def compute_cal_slope(y_true, pred_prob_logit):
    """Calibration slope: logistic regression of outcome on logit(predicted)"""
    try:
        X_cal = sm.add_constant(pred_prob_logit)
        cal_model = sm.Logit(y_true, X_cal).fit(disp=0, maxiter=100)
        return cal_model.params[1]  # slope
    except:
        return np.nan

for i in range(n_boot):
    idx = np.random.choice(len(df), size=len(df), replace=True)
    X_boot = X[idx]
    y_boot = y[idx]
    
    try:
        boot_model = sm.Logit(y_boot, X_boot).fit(disp=0, maxiter=200)
        
        # Apparent: predict on bootstrap sample
        pred_boot = boot_model.predict(X_boot)
        auc_app = roc_auc_score(y_boot, pred_boot)
        
        # Test: predict on original sample
        pred_orig = boot_model.predict(X)
        auc_test = roc_auc_score(y, pred_orig)
        
        boot_apparent_aucs.append(auc_app)
        boot_test_aucs.append(auc_test)
        
        # Calibration slope (on logit scale)
        # Apparent
        logit_boot = np.log(np.clip(pred_boot, 1e-7, 1-1e-7) / (1 - np.clip(pred_boot, 1e-7, 1-1e-7)))
        slope_app = compute_cal_slope(y_boot, logit_boot)
        
        # Test
        logit_orig = np.log(np.clip(pred_orig, 1e-7, 1-1e-7) / (1 - np.clip(pred_orig, 1e-7, 1-1e-7)))
        slope_test = compute_cal_slope(y, logit_orig)
        
        if not np.isnan(slope_app) and not np.isnan(slope_test):
            boot_apparent_slopes.append(slope_app)
            boot_test_slopes.append(slope_test)
            
    except:
        continue

# AUC
mean_optimism_auc = np.mean([a - t for a, t in zip(boot_apparent_aucs, boot_test_aucs)])
corrected_auc = auc_apparent - mean_optimism_auc
ci_auc = (np.percentile(boot_test_aucs, 2.5), np.percentile(boot_test_aucs, 97.5))

print(f"\n--- AUC ---")
print(f"Apparent: {auc_apparent:.3f}")
print(f"Optimism: {mean_optimism_auc:.4f}")
print(f"Corrected: {corrected_auc:.3f}")
print(f"Bootstrap 95% CI: ({ci_auc[0]:.3f}–{ci_auc[1]:.3f})")
print(f"CI width: {ci_auc[1]-ci_auc[0]:.3f}")

# Calibration slope
if boot_apparent_slopes:
    mean_optimism_slope = np.mean([a - t for a, t in zip(boot_apparent_slopes, boot_test_slopes)])
    apparent_slope = 1.0  # by definition on training data
    corrected_slope = apparent_slope - mean_optimism_slope
    
    print(f"\n--- Calibration Slope ---")
    print(f"Apparent slope: {apparent_slope:.3f} (by definition)")
    print(f"Optimism: {mean_optimism_slope:.4f}")
    print(f"Corrected slope: {corrected_slope:.3f}")
    print(f"  (ideal = 1.0; <1.0 means overfitting)")

# 최종 수치
print(f"\n{'='*70}")
print("논문에 보고할 최종 수치")
print("="*70)

slope_str = f"{corrected_slope:.3f}" if boot_apparent_slopes else 'N/A'
slope_str2 = f"{corrected_slope:.2f}" if boot_apparent_slopes else '[FILL]'
overfit_str = 'minimal' if (boot_apparent_slopes and corrected_slope > 0.9) else 'some'

print(f"""
C-statistic: {auc_apparent:.3f}
Optimism-corrected C-statistic: {corrected_auc:.3f}
Bootstrap 95% CI: {ci_auc[0]:.3f}–{ci_auc[1]:.3f}
Calibration slope (optimism-corrected): {slope_str}

→ 원고 기재:
  "The DVS achieved a C-statistic of {auc_apparent:.3f} 
   (optimism-corrected, {corrected_auc:.3f}; bootstrap 95% CI, 
   {ci_auc[0]:.3f}–{ci_auc[1]:.3f}). The optimism-corrected 
   calibration slope was {slope_str2}, 
   indicating {overfit_str} overfitting 
   (Supplementary Fig. 1)."
""")

# 저장
results = {
    'Apparent_AUC': auc_apparent,
    'Corrected_AUC': corrected_auc,
    'CI_lower': ci_auc[0],
    'CI_upper': ci_auc[1],
    'Corrected_cal_slope': corrected_slope if boot_apparent_slopes else None,
}

with open(os.path.join(RESULTS_DIR, 'final_bootstrap_results.txt'), 'w') as f:
    for k, v in results.items():
        f.write(f"{k}: {v}\n")

print(f"\n저장 완료:")
print(f"  {FIGURES_DIR}/fig_calibration_CORRECTED.png")
print(f"  {RESULTS_DIR}/final_bootstrap_results.txt")
