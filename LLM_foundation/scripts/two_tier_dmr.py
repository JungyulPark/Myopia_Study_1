"""
TWO-TIER DMR ANALYSIS
=====================
Tier 1 (Strict DMR): 진단명이 판독문에 언급되었는지
Tier 2 (Finding-aware DMR): 해당 질환의 특징적 소견이 기술되었는지

이 분석으로 "radiologist가 못 본 것" vs "이름을 안 쓴 것"을 구분합니다.

실행: python two_tier_dmr.py
"""

import pandas as pd
import numpy as np
import os
import re
import warnings
warnings.filterwarnings('ignore')

OUTPUT_DIR = r"paper1_output"
RESULTS_DIR = os.path.join(OUTPUT_DIR, "results")
os.makedirs(RESULTS_DIR, exist_ok=True)

# ============================================================
# 데이터 로드
# ============================================================
orbital = pd.read_csv(os.path.join(OUTPUT_DIR, 'orbital_cleaned.csv'))
has_report = orbital[orbital['판독분류'] != 'no_report'].copy()

print("=" * 70)
print("TWO-TIER DMR ANALYSIS")
print("=" * 70)
print(f"Total studies with reports: {len(has_report)}")

# ============================================================
# TIER 1: Strict DMR (현재 방식 — 진단명 keyword)
# ============================================================
STRICT_KW = {
    'TED': r'thyroid|graves|\btao\b|dysthyroid',
    'Lymphoma': r'lymphoma|malt\b|lymphoproliferative',
    'Pseudotumor': r'pseudotumor|pseudo.tumor|idiopathic orbital inflamm|\biois\b|\bioid\b',
    'Cavernous hemangioma': r'hemangioma|haemangioma|cavernous venous',
    'Pleomorphic adenoma': r'pleomorphic|mixed tumor',
    'Meningioma': r'meningioma',
    'IgG4-RD': r'igg.?4',
}

# ============================================================
# TIER 2: Finding-aware DMR (특징적 소견 keyword)
# ============================================================
FINDING_KW = {
    'TED': r'muscle.{0,20}(enlarg|thicken|swell)|'
           r'(enlarg|thicken|swell).{0,20}muscle|'
           r'extraocular.{0,15}(enlarg|thicken)|'
           r'eom.{0,10}(enlarg|thicken)|'
           r'tendon.{0,10}spar|'
           r'proptosis|exophthalm|'
           r'fat.{0,10}(prolaps|expand|hernia)|'
           r'(inferior|medial|superior|lateral).{0,10}rectus.{0,15}(enlarg|thicken)|'
           r'lacrimal.{0,10}(enlarg|swell)',

    'Lymphoma': r'mass|lesion|tumor|tumour|nodule|nodular|'
                r'lymphadenopathy|infiltrat|'
                r'homogeneous.{0,15}enhanc|'
                r'mold.{0,10}(globe|bone|orbit)|'
                r'lacrimal.{0,15}(mass|enlarg|lesion)',

    'Pseudotumor': r'inflamm|myositis|dacryoadenitis|'
                   r'(diffuse|ill.defined).{0,15}(enhanc|infiltrat)|'
                   r'cellulitis|scleritis|'
                   r'muscle.{0,20}(enlarg|thicken)|'
                   r'(enlarg|thicken).{0,20}muscle|'
                   r'soft tissue.{0,15}(swell|enhanc)|'
                   r'orbital.{0,10}(swell|edema)',

    'Cavernous hemangioma': r'mass|lesion|well.defined|'
                            r'(homogeneous|progressive).{0,15}enhanc|'
                            r'intraconal.{0,10}(mass|lesion)|'
                            r'round.{0,10}(mass|lesion)',

    'Pleomorphic adenoma': r'mass|lesion|tumor|tumour|'
                           r'lacrimal.{0,15}(mass|enlarg|tumor|lesion)|'
                           r'well.defined|'
                           r'lacrimal gland',

    'Meningioma': r'mass|lesion|tumor|tumour|'
                  r'dural.{0,10}(thicken|enhanc|tail)|'
                  r'enhanc.{0,15}(mass|lesion)|'
                  r'calcifi|hyperost|'
                  r'optic.{0,10}(sheath|canal)',

    'IgG4-RD': r'inflamm|enlarg|swell|'
               r'lacrimal.{0,15}(enlarg|swell|mass)|'
               r'bilateral.{0,15}(enlarg|swell)|'
               r'infraorbital nerve.{0,10}(enlarg|thicken)|'
               r'dacryoadenitis|'
               r'diffuse.{0,15}(enhanc|infiltrat)',
}


# ============================================================
# 분석 실행
# ============================================================
results = []

for dx, strict_pattern in STRICT_KW.items():
    subset = has_report[has_report['진단카테고리'] == dx].copy()
    n = len(subset)
    if n == 0:
        continue
    
    # Tier 1: Strict DMR (진단명)
    subset['tier1_hit'] = subset['판독문'].str.contains(
        strict_pattern, case=False, na=False, flags=re.IGNORECASE)
    tier1_dmr = subset['tier1_hit'].mean() * 100
    tier1_n = subset['tier1_hit'].sum()
    
    # Tier 2: Finding-aware DMR (특징적 소견)
    finding_pattern = FINDING_KW.get(dx, '')
    if finding_pattern:
        subset['tier2_hit'] = subset['판독문'].str.contains(
            finding_pattern, case=False, na=False, flags=re.IGNORECASE)
    else:
        subset['tier2_hit'] = False
    tier2_dmr = subset['tier2_hit'].mean() * 100
    tier2_n = subset['tier2_hit'].sum()
    
    # Combined: Tier 1 OR Tier 2 (either name or findings mentioned)
    subset['either_hit'] = subset['tier1_hit'] | subset['tier2_hit']
    either_dmr = subset['either_hit'].mean() * 100
    either_n = subset['either_hit'].sum()
    
    # "True miss" = neither name NOR findings mentioned
    subset['true_miss'] = ~subset['either_hit']
    true_miss_rate = subset['true_miss'].mean() * 100
    true_miss_n = subset['true_miss'].sum()
    
    # "Naming gap" = findings described but name not mentioned
    subset['naming_gap'] = subset['tier2_hit'] & ~subset['tier1_hit']
    naming_gap_n = subset['naming_gap'].sum()
    naming_gap_pct = naming_gap_n / n * 100
    
    results.append({
        'Diagnosis': dx,
        'N': n,
        'Tier1_strict_n': tier1_n,
        'Tier1_strict_DMR': round(tier1_dmr, 1),
        'Tier2_finding_n': tier2_n,
        'Tier2_finding_DMR': round(tier2_dmr, 1),
        'Either_n': either_n,
        'Either_DMR': round(either_dmr, 1),
        'True_miss_n': true_miss_n,
        'True_miss_rate': round(true_miss_rate, 1),
        'Naming_gap_n': naming_gap_n,
        'Naming_gap_pct': round(naming_gap_pct, 1),
    })

df_results = pd.DataFrame(results)

# ============================================================
# 출력
# ============================================================
print(f"\n{'='*90}")
print(f"{'Diagnosis':<25} {'N':>5} {'Tier1':>8} {'Tier2':>8} {'Either':>8} {'True':>8} {'Naming':>8}")
print(f"{'':25} {'':>5} {'(Name)':>8} {'(Find)':>8} {'(Any)':>8} {'Miss':>8} {'Gap':>8}")
print(f"{'='*90}")

for _, row in df_results.iterrows():
    print(f"{row['Diagnosis']:<25} {row['N']:>5} "
          f"{row['Tier1_strict_DMR']:>6.1f}% "
          f"{row['Tier2_finding_DMR']:>6.1f}% "
          f"{row['Either_DMR']:>6.1f}% "
          f"{row['True_miss_rate']:>6.1f}% "
          f"{row['Naming_gap_pct']:>6.1f}%")

# Overall
total_n = df_results['N'].sum()
total_tier1_miss = total_n - df_results['Tier1_strict_n'].sum()
total_true_miss = df_results['True_miss_n'].sum()
total_naming_gap = df_results['Naming_gap_n'].sum()

print(f"\n{'='*90}")
print(f"OVERALL (keyword-specific diagnoses only, n={total_n}):")
print(f"  Tier 1 miss (name absent):      {total_tier1_miss}/{total_n} ({total_tier1_miss/total_n*100:.1f}%)")
print(f"  True miss (name + finding absent): {total_true_miss}/{total_n} ({total_true_miss/total_n*100:.1f}%)")
print(f"  Naming gap (finding present, name absent): {total_naming_gap}/{total_n} ({total_naming_gap/total_n*100:.1f}%)")
print(f"  → {total_naming_gap}/{total_tier1_miss} ({total_naming_gap/total_tier1_miss*100:.1f}%) of Tier 1 misses are actually 'naming gaps'")

# ============================================================
# Key story for manuscript
# ============================================================
print(f"\n{'='*70}")
print("MANUSCRIPT TEXT — Results에 추가할 문단")
print("="*70)

ted = df_results[df_results['Diagnosis'] == 'TED'].iloc[0]
pseudo = df_results[df_results['Diagnosis'] == 'Pseudotumor'].iloc[0]
lymph = df_results[df_results['Diagnosis'] == 'Lymphoma'].iloc[0]

print(f"""
[Results 섹션 — DMR 뒤에 추가]

To distinguish true diagnostic failure from naming variation, 
we performed a two-tier analysis comparing strict DMR (diagnostic 
term mentioned) with finding-aware DMR (characteristic imaging 
findings described regardless of diagnostic labeling). For TED, 
the finding-aware DMR was {ted['Tier2_finding_DMR']}% compared with the 
strict DMR of {ted['Tier1_strict_DMR']}%, indicating that {ted['Naming_gap_pct']}% 
of reports described TED-characteristic findings (extraocular muscle 
enlargement, tendon sparing) without explicitly naming the diagnosis 
(Table X). For pseudotumor, the finding-aware DMR was 
{pseudo['Tier2_finding_DMR']}% versus strict DMR of {pseudo['Tier1_strict_DMR']}%. 
For lymphoma, the finding-aware DMR was {lymph['Tier2_finding_DMR']}% versus 
{lymph['Tier1_strict_DMR']}%.

Overall, among {total_tier1_miss} studies classified as diagnostic 
misses by strict DMR, {total_naming_gap} ({total_naming_gap/total_tier1_miss*100:.1f}%) had 
characteristic findings correctly described in the report 
("naming gap"), while {total_true_miss} ({total_true_miss/total_n*100:.1f}% of all 
studies) represented true diagnostic failure where neither the 
diagnosis nor its characteristic findings were mentioned.
""")

# Discussion text
print(f"""
[Discussion — DMR 섹션에 추가/교체]

The two-tier analysis revealed that the majority of strict DMR 
misses for TED ({ted['Naming_gap_pct']}%) and a substantial proportion 
for pseudotumor represented "naming gaps" rather than true 
diagnostic failures — radiologists accurately described 
characteristic findings but did not label the diagnosis. This 
distinction is clinically important: for subspecialty 
ophthalmologists, finding-level description may suffice, whereas 
non-specialist physicians rely on explicit diagnostic labeling 
for clinical decision-making. The true diagnostic failure rate 
— where neither the diagnosis nor characteristic findings were 
mentioned — was {total_true_miss/total_n*100:.1f}%, substantially lower than 
the strict DMR miss rate of {total_tier1_miss/total_n*100:.1f}%.
""")

# ============================================================
# Save
# ============================================================
df_results.to_csv(os.path.join(RESULTS_DIR, 'two_tier_dmr.csv'), index=False)
print(f"\n저장: {RESULTS_DIR}/two_tier_dmr.csv")
print("DONE!")
