"""
논문 1 - Module 3: 그래프 생성 (Figures)
========================================
입력: paper1_output/results/*.csv
출력: paper1_output/figures/*.png

실행: pip install matplotlib
      python module3_figures.py
"""

import pandas as pd
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.font_manager as fm
import os

OUTPUT_DIR = r"paper1_output"
RESULTS_DIR = os.path.join(OUTPUT_DIR, "results")
FIGURES_DIR = os.path.join(OUTPUT_DIR, "figures")
os.makedirs(FIGURES_DIR, exist_ok=True)

# 폰트 설정 (한글 깨짐 방지)
plt.rcParams['font.family'] = 'DejaVu Sans'
plt.rcParams['figure.dpi'] = 300
plt.rcParams['savefig.bbox'] = 'tight'

print("=" * 60)
print("Module 3: Figure 생성")
print("=" * 60)

# ============================================================
# Figure 1: Disease Distribution (Pie + Bar)
# ============================================================
table1 = pd.read_csv(os.path.join(RESULTS_DIR, 'table1_disease_distribution.csv'))
table1 = table1[table1['Diagnosis'] != 'Total']

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Pie chart (환자 기준)
colors = plt.cm.Set3(np.linspace(0, 1, len(table1)))
wedges, texts, autotexts = ax1.pie(
    table1['Patients_n'], labels=None, autopct='%1.1f%%',
    colors=colors, pctdistance=0.85, startangle=90
)
for t in autotexts:
    t.set_fontsize(7)
ax1.legend(table1['Diagnosis'], loc='center left', bbox_to_anchor=(-0.3, 0.5), fontsize=7)
ax1.set_title('Disease Distribution (Patient-level)', fontsize=11, fontweight='bold')

# Bar chart (영상 기준)
bars = ax2.barh(table1['Diagnosis'], table1['Images_n'], color=colors)
ax2.set_xlabel('Number of Imaging Studies')
ax2.set_title('Imaging Studies by Diagnosis', fontsize=11, fontweight='bold')
for bar, val in zip(bars, table1['Images_n']):
    ax2.text(bar.get_width() + 5, bar.get_y() + bar.get_height()/2,
             str(int(val)), va='center', fontsize=8)
ax2.invert_yaxis()

plt.tight_layout()
plt.savefig(os.path.join(FIGURES_DIR, 'fig1_disease_distribution.png'))
plt.close()
print("  Fig 1: disease_distribution.png")

# ============================================================
# Figure 2: Diagnostic Sensitivity (Forest Plot Style)
# ============================================================
table2 = pd.read_csv(os.path.join(RESULTS_DIR, 'table2_diagnostic_accuracy.csv'))
table2 = table2.sort_values('Sensitivity', ascending=True)

fig, ax = plt.subplots(figsize=(8, 5))

y_pos = range(len(table2))
colors_sens = ['#e74c3c' if s < 0.5 else '#f39c12' if s < 0.7 else '#27ae60'
               for s in table2['Sensitivity']]

ax.barh(y_pos, table2['Sensitivity'] * 100, color=colors_sens, height=0.6, alpha=0.8)

# CI error bars
for i, (_, row) in enumerate(table2.iterrows()):
    ci_low = row['Sens_95CI_low'] * 100
    ci_high = row['Sens_95CI_high'] * 100
    sens = row['Sensitivity'] * 100
    ax.plot([ci_low, ci_high], [i, i], color='black', linewidth=1.5)
    ax.plot([ci_low, ci_low], [i-0.15, i+0.15], color='black', linewidth=1.5)
    ax.plot([ci_high, ci_high], [i-0.15, i+0.15], color='black', linewidth=1.5)

labels = [f"{row['Diagnosis']} (n={int(row['N_confirmed'])})" for _, row in table2.iterrows()]
ax.set_yticks(y_pos)
ax.set_yticklabels(labels, fontsize=9)
ax.set_xlabel('Sensitivity (%)', fontsize=11)
ax.set_title('Diagnostic Sensitivity of Radiology Reports\nby Disease Category', fontsize=12, fontweight='bold')
ax.set_xlim(0, 105)
ax.axvline(x=50, color='gray', linestyle='--', alpha=0.5)

# 수치 표시
for i, (_, row) in enumerate(table2.iterrows()):
    ax.text(row['Sensitivity'] * 100 + 2, i,
            f"{row['Sensitivity']:.1%}", va='center', fontsize=9, fontweight='bold')

plt.tight_layout()
plt.savefig(os.path.join(FIGURES_DIR, 'fig2_sensitivity_forest.png'))
plt.close()
print("  Fig 2: sensitivity_forest.png")

# ============================================================
# Figure 3: Biopsy Rate by Diagnosis
# ============================================================
table3 = pd.read_csv(os.path.join(RESULTS_DIR, 'table3_biopsy.csv'))
table3 = table3.sort_values('Biopsy_rate', ascending=True)

fig, ax = plt.subplots(figsize=(8, 5))
bars = ax.barh(table3['Diagnosis'], table3['Biopsy_rate'], color='#3498db', alpha=0.8, height=0.6)
ax.set_xlabel('Biopsy Rate (%)')
ax.set_title('Biopsy Rate by Diagnosis', fontsize=12, fontweight='bold')
ax.set_xlim(0, 105)

for bar, rate in zip(bars, table3['Biopsy_rate']):
    ax.text(bar.get_width() + 1, bar.get_y() + bar.get_height()/2,
            f"{rate:.1f}%", va='center', fontsize=9)

plt.tight_layout()
plt.savefig(os.path.join(FIGURES_DIR, 'fig3_biopsy_rate.png'))
plt.close()
print("  Fig 3: biopsy_rate.png")

# ============================================================
# Figure 4: Uninformative Report Rate
# ============================================================
table4 = pd.read_csv(os.path.join(RESULTS_DIR, 'table4_report_quality.csv'))
table4 = table4.sort_values('Normal_rate', ascending=False)

fig, ax = plt.subplots(figsize=(8, 5))
colors_nf = ['#e74c3c' if r > 30 else '#f39c12' if r > 15 else '#27ae60'
             for r in table4['Normal_rate']]
bars = ax.barh(table4['Diagnosis'], table4['Normal_rate'], color=colors_nf, alpha=0.8, height=0.6)
ax.set_xlabel('"No Remarkable Finding" Rate (%)')
ax.set_title('Uninformative Report Rate in Confirmed Disease Patients', fontsize=11, fontweight='bold')
ax.set_xlim(0, max(table4['Normal_rate']) + 10)

for bar, (_, row) in zip(bars, table4.iterrows()):
    ax.text(bar.get_width() + 0.5, bar.get_y() + bar.get_height()/2,
            f"{row['Normal_rate']:.1f}% ({int(row['Entirely_normal'])}/{int(row['N_with_report'])})",
            va='center', fontsize=8)

plt.tight_layout()
plt.savefig(os.path.join(FIGURES_DIR, 'fig4_uninformative_reports.png'))
plt.close()
print("  Fig 4: uninformative_reports.png")

# ============================================================
# Figure 5: Yearly Trend
# ============================================================
orbital = pd.read_csv(os.path.join(OUTPUT_DIR, 'orbital_cleaned.csv'))
orbital['검사년도'] = pd.to_numeric(orbital['검사일'].astype(str).str[:4], errors='coerce')
yearly = orbital.groupby('검사년도').size().reset_index(name='count')
yearly = yearly.dropna()

fig, ax = plt.subplots(figsize=(10, 4))
ax.bar(yearly['검사년도'], yearly['count'], color='#2c3e50', alpha=0.8)
ax.set_xlabel('Year')
ax.set_ylabel('Number of Studies')
ax.set_title('Annual Volume of Orbital Imaging Studies', fontsize=12, fontweight='bold')

plt.tight_layout()
plt.savefig(os.path.join(FIGURES_DIR, 'fig5_yearly_trend.png'))
plt.close()
print("  Fig 5: yearly_trend.png")

# ============================================================
# Figure 6: Diagnosis Change Sankey-style (간단 버전)
# ============================================================
table5 = pd.read_csv(os.path.join(RESULTS_DIR, 'table5_diagnosis_change.csv'))
top_changes = table5.head(10)

fig, ax = plt.subplots(figsize=(10, 5))
labels = [f"{row['초기진단']} → {row['최종진단']}" for _, row in top_changes.iterrows()]
ax.barh(range(len(labels)), top_changes['count'], color='#9b59b6', alpha=0.8, height=0.6)
ax.set_yticks(range(len(labels)))
ax.set_yticklabels(labels, fontsize=9)
ax.set_xlabel('Number of Cases')
ax.set_title('Top 10 Diagnosis Change Patterns', fontsize=12, fontweight='bold')
ax.invert_yaxis()

for i, cnt in enumerate(top_changes['count']):
    ax.text(cnt + 0.3, i, str(cnt), va='center', fontsize=9)

plt.tight_layout()
plt.savefig(os.path.join(FIGURES_DIR, 'fig6_diagnosis_changes.png'))
plt.close()
print("  Fig 6: diagnosis_changes.png")

print(f"\n모든 Figure 저장 완료 → {FIGURES_DIR}/")
print(f"\n다음 단계: 결과를 검토하고 논문 작성 시작")
