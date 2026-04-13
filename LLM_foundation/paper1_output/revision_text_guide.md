================================================================
원고 수정 사항 11개 — 반영 가이드
================================================================
각 수정의 위치, 이전 텍스트, 수정된 텍스트를 명시합니다.
revision_analysis.py 실행 후 나온 수치를 [FILL] 부분에 채워주세요.

================================================================
FIX 5: 제목 환자 수 통일
================================================================

위치: Title

이전:
"...Missed Diagnosis in 1,461 Patients"

수정:
"...Missed Diagnosis in 2,177 Imaging Studies"

이유: 1,461은 전체 코호트(판독 없는 건 포함), 1,421은 분석 코호트.
혼란을 피하기 위해 영상 건수로 통일. 영상 건수가 분석 단위이므로
더 정확함.

Abstract도 수정:
이전: "2,177 orbital CT and MRI studies from 1,421 patients"
수정: "2,177 orbital imaging studies (CT and MRI) from 1,421 
patients" (유지 — 본문에서 두 숫자 모두 보고)


================================================================
FIX 6: "Never caught" → "Never specifically mentioned"
================================================================

위치: Table 4 컬럼명 + Results + Discussion

Table 4 컬럼명:
이전: "Never caught, n"
수정: "Never specifically mentioned†, n"

각주 추가:
"†'Never specifically mentioned' indicates that the exact 
diagnostic term was not found in any radiology report during 
follow-up. This does not imply that the condition was 
clinically unrecognized, as equivalent descriptive terminology 
(e.g., 'myositis' for pseudotumor, 'EOM enlargement' for TED) 
may have been used, and the referring ophthalmologist may have 
established the diagnosis independently."

Results 수정:
이전: "...were never correctly identified in subsequent 
radiology reports ('never caught'): 70.0% (14/20) for 
pseudotumor..."

수정: "...were never specifically mentioned by name in 
subsequent radiology reports: 70.0% (14/20) for pseudotumor 
and 51.9% (28/54) for TED. However, this likely reflects 
terminological variation rather than persistent diagnostic 
failure, as radiologists may have used clinically equivalent 
terms such as 'myositis' or 'orbital inflammation' for 
pseudotumor and described TED-consistent findings without 
explicitly naming the disease."


================================================================
FIX 7: DMR 임상적 의미 — 비전문의 맥락 추가
================================================================

위치: Discussion, "DMR Varies Widely" 섹션 끝에 새 문단 추가

추가 텍스트:
"The clinical significance of DMR depends critically on who 
reads the report. For subspecialty ophthalmologists who can 
independently interpret orbital imaging findings, a report 
describing 'bilateral extraocular muscle enlargement with 
tendon sparing' provides sufficient diagnostic information 
for TED regardless of whether the term appears explicitly. 
However, for non-specialist physicians—emergency physicians, 
general practitioners, and primary care providers—who may 
rely predominantly on the diagnostic impression in the 
radiology report for clinical decision-making, the absence 
of a specific diagnostic mention may directly translate into 
diagnostic uncertainty or delay. This distinction is 
particularly important in healthcare systems where orbital 
diseases may initially present to non-ophthalmic providers. 
The DVS and clinical information provision interventions are 
therefore most impactful in settings where reports are 
interpreted by non-specialists."


================================================================
FIX 8: TED 조직검사율 명확화
================================================================

위치: Methods → Diagnosis Ascertainment

이전:
"...with orbital biopsy performed in only 4.2% of cases 
(for exclusion of alternative diagnoses)..."

수정:
"The overall biopsy rate among TED patients was 19.6%; 
however, the majority of these (75.8%) were non-ophthalmic 
specimens (thyroid, gastrointestinal, or dermatologic biopsies) 
obtained for unrelated clinical indications that happened to 
co-occur during the study period. The ophthalmic biopsy rate 
for TED was 4.2%, reflecting standard practice in which orbital 
biopsy is reserved for atypical presentations requiring 
exclusion of alternative diagnoses such as lymphoma or 
IgG4-related disease [11]."


================================================================
FIX 9: 검증 정확도 95% CI 및 블라인드 명시
================================================================

위치: Methods → Primary Outcome

이전:
"...yielding 100% concordance with automated classification."

수정:
"The reviewing ophthalmologist (J.Y.P.) was blinded to the 
automated classification results during the review. All 100 
cases showed concordance between manual and automated 
classification (100%; 95% CI, 96.4–100.0% by Clopper-Pearson 
exact method). Seven cases were initially flagged as 
potentially discordant upon detailed review but were confirmed 
to be correctly classified by the automated algorithm, 
reflecting borderline cases where the automated result was 
ultimately deemed accurate."


================================================================
FIX 10: "Attribution failure" 정의를 Methods에 추가
================================================================

위치: Methods → Spot-Check Clinical Review

이전:
"...to determine whether the automated miss classification 
was clinically appropriate and to characterize the predominant 
error pattern."

수정:
"...to determine whether the automated miss classification 
was clinically appropriate and to characterize the predominant 
error pattern. Specifically, we distinguished between two 
types of diagnostic miss: (1) detection failure, in which 
the radiology report failed to identify any abnormal finding; 
and (2) attribution failure, in which the report correctly 
identified and described a lesion but attributed it to an 
incorrect diagnosis without including the confirmed diagnosis 
in the differential. This distinction has implications for 
targeted quality improvement, as detection failure may 
benefit from imaging technology improvements whereas 
attribution failure may be more amenable to educational 
interventions."


================================================================
FIX 11: Delay 분석 축소 (main text → 핵심만, 상세는 Supp)
================================================================

위치: Results → Diagnostic Delay 섹션

이전: 4개 문단 (장문)

수정 (2개 문단으로 축소):
"Among 428 follow-up patients (conjunctival lymphoma excluded), 
98 (22.9%) had a diagnostic miss on their first imaging study 
(Table 4; Supplementary Fig. X). The highest first-study miss 
rates were observed for IgG4-related disease (71.4%; 5/7) and 
pseudotumor (48.8%; 20/41). Among patients with initially 
missed orbital lymphoma, the median delay to correct 
radiological mention was 64 days (range, 5–1,350 days).

Notably, a substantial proportion of initially missed diagnoses 
were never specifically mentioned by name in subsequent reports: 
70.0% for pseudotumor and 51.9% for TED, likely reflecting 
terminological variation rather than persistent diagnostic 
failure (see Discussion). The diagnostic delay measured here 
represents the interval to correct radiological mention, not 
necessarily the delay in clinical management."

Discussion에서도 축소:
"Diagnostic Delay and Clinical Implications" 섹션을 1문단으로:
"Among follow-up patients, the median diagnostic delay ranged 
from 64 days for orbital lymphoma to 480 days for TED. While 
the 64-day delay for lymphoma is clinically relevant, it is 
important to note that this metric reflects radiological 
recognition delay rather than clinical management delay. In 
most cases, the referring ophthalmologist had established the 
diagnosis through clinical examination and biopsy independent 
of the imaging report. Nevertheless, for non-specialist 
physicians who rely on radiology reports, these delays could 
translate into treatment delays, reinforcing the importance 
of the DVS for identifying high-risk reports."


================================================================
추가 수정: Limitation 4번 (나이/성별) — 조건부
================================================================

데이터 확보 시:
→ Table 1에 "Age, years, median (IQR)" 및 "Sex, female, n (%)" 
  행 추가
→ Limitation 4번 삭제

데이터 미확보 시:
→ 현행 유지: "Demographic data (age, sex) were not available 
  in the current dataset, limiting our ability to adjust for 
  patient-level confounders."


================================================================
추가 수정: Sensitivity analysis 결과를 Results에 통합
================================================================

위치: Results → DVS 섹션 끝에 새 문단 추가

"Sensitivity analyses confirmed the robustness of DVS findings. 
In a patient-level analysis using only the first imaging study 
per patient (n=1421), the DVS 
achieved a C-statistic of 0.767, consistent with the 
study-level analysis. When a broader keyword dictionary 
including 'myositis' and 'inflammation' was applied for 
pseudotumor, the overall miss rate decreased from 32.5% to 
31.1%, with a DVS C-statistic of 0.766. These results 
indicate that the primary findings are robust to both 
analytical unit and keyword definition choices 
(Supplementary Table X)."


================================================================
수정 후 최종 WORD COUNT 예상
================================================================

현재: 4,646 words
삭제: Delay 축소 (~300 words 감소)
추가: DMR 임상 의미 (~120), TED biopsy (~80), 
      Attribution 정의 (~80), Sensitivity analyses (~80),
      Non-specialist paragraph (~100)
순증: 약 +80 words
예상 최종: ~4,400 words (European Radiology 5,000 상한 이내)

================================================================
