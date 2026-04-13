# VLM Pilot Results - Critical Review
## 1. 프롬프트 검증 (Prompt Verification)
사용한 프롬프트는 림프종을 명시하지 않은 완전히 중립적인 프롬프트입니다:
```text이 영상은 안와(Orbit) CT 또는 MRI의 축상면(Axial) 이미지 3장입니다.
영상을 판독하여 병변(mass/lesion/enlargement 등)의 유무 및 형태학적 특징을 묘사하고,
가장 가능성 있는 감별진단(Differential Diagnosis) 질환 목록을 1위부터 5위까지 제시해 주세요.

출력 형식:
[FINDING]
(병변에 대한 영상의학적 소견 묘사)

[DIFFERENTIAL DIAGNOSIS]
1. (진단명 1)
2. (진단명 2)
...```
## 2. R10442 제외 사유
- **사유:** R10442 환자의 영상 데이터는 안와(Orbit) 스캔이 아닌 복부(Abdomen) CT/MRI 스캔임이 전체 DICOM 시리즈 몽타주 분석 과정에서 확인되었습니다. 따라서 안와 종양 진단 파일럿의 대상이 될 수 없어 연구 대상에서 명시적으로 배제(Exclude)하였습니다.

## 3. 케이스별 원문 결과 분석 (Raw JSON Export)
### 성공 케이스 (림프종 감별 성공 - 4건)

#### 🟢 R10084
```text
# 안와 MRI 판독 소견

## [FINDING]

**영상 기법:** T2 강조 축상면(Axial T2-weighted) MRI, 3개의 연속 슬라이스

**주요 소견:**

**양측 안구(Globes):**
- 양측 안구가 **현저히 돌출(Proptosis/Exophthalmos)**되어 있음
- 양측 안구 크기가 **비대칭적으로 증대**되어 있으며, 특히 **우측(Right) 안구가 좌측에 비해 더 크고 전방으로 돌출**된 소견
- 양측 안구 내부에 **T2 고신호강도(hyperintense)**의 유리체(vitreous) 확인
- **공막(sclera)** 주변으로 이상 신호 없음

**안와 내 연부조직:**
- 양측 안와 내 **외안근(extraocular muscles)의 비후(enlargement)** 소견 관찰
- 특히 **내직근(medial rectus) 및 하직근(inferior rectus)**의 비후가 두드러짐
- 안와 지방(orbital fat)의 **T2 신호 증가** 소견 (염증성 변화 시사)
- **시신경(optic nerve)**은 양측 모두 확인되나 압박 소견 동반 가능

**부비동(Paranasal sinuses):**
- 사골동(ethmoid sinus) 및 상악동(maxillary sinus) 내 **점막 비후 또는 연부조직 음영** 관찰
- 비강 내 구조물의 변형 소견

**두개내(Intracranial):**
- 상위 슬라이스에서 대뇌 피질 구조는 대체로 정상 범위
- 뇌회(gyri) 및 뇌구(sulci) 패턴 정상

---

## [DIFFERENTIAL DIAGNOSIS]

### 1순위: **Graves' Ophthalmopathy (Thyroid Eye Disease, TED)**
> 양측성 외안근 비후, 안구 돌출, 안와 지방 증가의 전형적 소견. 가장 흔한 양측성 안와 질환.

### 2순위: **Idiopathic Orbital Inflammatory Disease (Orbital Pseudotumor)**
> 안와 내 연부조직의 비특이적 염증, 외안근 비후, T2 신호 변화. 단측 또는 양측 발생 가능.

### 3순위: **Orbital Lymphoma (MALT Lymphoma 등)**
> 안와 내 연부조직 종괴, 외안근 침범 가능. 성인에서 흔하며 양측성 발생 가능.

### 4순위: **Cavernous Sinus Thrombosis / AV Fistula (Carotid-Cavernous Fistula)**
> 안와 정맥 울혈로 인한 안구 돌출 및 외안근 비후. 혈관성 원인 고려.

### 5순위: **Orbital Cellulitis / Subperiosteal Abscess**
> 부비동염 동반 소견과 함께 안와 내 염증성 변화. 특히 사골동염 동반 시 안와 내 파급 가능.

---

> ⚠️ **임상 권고사항:** 갑상선 기능 검사(TS
```

#### 🟢 R10501
```text
# 안와 MRI 판독 소견

## [FINDING]

**영상 기법:** 코로날(Coronal) 방향의 MRI 영상 3장 (T2 강조영상으로 추정)

**주요 소견:**

**양측 안구/안와:**
- 양측 안구는 정상적인 구형 형태를 유지
- **양측 안구 후방(구후부, retrobulbar region)**에 **대칭적으로 고신호강도(hyperintense)**의 원형/난원형 병변 관찰
- 병변은 **안구 후극부(posterior pole)**에 위치하며, 안구벽과 밀접하게 연관
- 병변의 경계는 비교적 명확하고 균질한 신호강도를 보임
- **양측성(bilateral)** 및 **대칭적** 분포

**뇌실질:**
- 대뇌 피질 및 백질의 신호강도는 전반적으로 정상 범위
- 뇌실 크기 및 형태 정상
- 정중선 편위 없음

**기타:**
- 비강 및 부비동 내 경미한 점막 비후 소견
- 안와 지방 신호강도는 정상

---

## [DIFFERENTIAL DIAGNOSIS]

1. **안와 정맥류 (Orbital Varix)** — 양측성, T2 고신호, 구후부 혈관성 병변

2. **안와 해면상 혈관종 (Cavernous Hemangioma)** — 가장 흔한 성인 안와 양성 종양, T2 고신호, 경계 명확

3. **시신경초 수막종 (Optic Nerve Sheath Meningioma)** — 시신경 주위 병변, 양측성 가능

4. **안와 림프종 (Orbital Lymphoma)** — 양측성 안와 종괴, 균질한 신호강도

5. **갑상선 안병증 (Thyroid-associated Orbitopathy / Graves' Ophthalmopathy)** — 양측 대칭적 안와 변화, 외안근 비대 동반 가능

---

> ⚠️ **임상적 고려사항:** 양측 대칭적 병변의 경우 전신 질환(갑상선 질환, 림프종, 전이성 병변 등)과의 연관성을 반드시 임상 소견과 함께 평가하시기 바랍니다. 조영증강 MRI 및 DWI 추가 시행을 권고합니다.
```

#### 🟢 R10603
```text
# 안와 CT 판독 소견

## [FINDING]

**영상 기술:**
제시된 3장의 영상은 **관상면(Coronal view) CT** 영상으로, 전방에서 후방으로 진행하는 연속 절편입니다.

**주요 소견:**

**양측 안와:**
- 양측 안구(eyeball)는 전반적으로 **크기가 증가**되어 있으며 (bilateral proptosis/exophthalmos 소견)
- 양측 안와 내 **외안근(extraocular muscles)의 현저한 비대(enlargement)** 관찰
- 특히 **내직근(medial rectus), 하직근(inferior rectus)** 위주의 방추형(fusiform) 비대 소견
- 근육의 **건(tendon) 부착부는 비교적 보존**된 양상 (tendon-sparing pattern)
- 안와 지방(orbital fat)의 증가 소견
- 시신경(optic nerve)은 현재 영상에서 명확한 압박 소견은 불분명하나 주변 근육 비대로 인한 압박 가능성 존재

**비강 및 부비동:**
- 비갑개(turbinate) 구조는 비교적 정상 범위
- 부비동 내 특이 병변은 현 영상에서 명확하지 않음

**전반적 특징:**
- **양측성, 대칭적** 외안근 비대
- Fusiform (방추형) 형태의 근육 비대
- Tendon-sparing 패턴

---

## [DIFFERENTIAL DIAGNOSIS]

**1. Thyroid-associated Orbitopathy (TAO) / Graves' Ophthalmopathy** ⭐
> 가장 가능성 높음. 양측성 외안근 비대, tendon-sparing pattern, 안와 지방 증가가 전형적 소견. 내직근·하직근 순으로 호발.

**2. Idiopathic Orbital Inflammatory Disease (IOID) / Orbital Pseudotumor**
> 단측 또는 양측 발생 가능. 외안근 비대 시 건 부착부까지 침범(tendon-involving)하는 경우가 많아 TAO와 감별점이 됨.

**3. Carotid-Cavernous Fistula (CCF) / Dural AVF**
> 안와 정맥 확장 및 외안근 비대 유발 가능. 상안정맥(superior ophthalmic vein) 확장 동반 여부 확인 필요.

**4. Lymphoma (Orbital Lymphoma)**
> 외안근 또는 안와 내 연부조직 종괴로 발현 가능. 양측성 발생 시 감별 필요. 균질한 연부조직 음영 종괴 형태.

**5. Metastatic Disease / Systemic Infiltrative Disease (e.g., IgG4-related disease)**
> IgG4 연관 안와 질환은 외안근 비대 및 누선(lacrimal gland) 비대를 동반할 수 있으며, 양측성 발현 가능.

---

> ⚠️ **임상 권고사항:** 갑상선 기능 검사(TSH, Free T4, T3, TSH-receptor antibody), 안압 측정, 시력 평가 및 필요 시 MRI with contrast 추가 시행을 권장합니다.
```

#### 🟢 R10710
```text
# 안와 CT 판독 소견

## [FINDING]

**영상 기술:**
제시된 3장의 영상은 **관상면(Coronal view) CT** 영상으로, 전방에서 후방 방향으로 순차적으로 촬영된 안와 CT입니다.

---

**주요 소견:**

### 우측 안와 (Right Orbit):
- **안와 내 경계가 비교적 명확한 종괴성 병변** 관찰
- 병변은 **안구 후방 및 외측**에 위치
- **불균질한 내부 음영** (heterogeneous density) - 일부 저음영 및 고음영 혼재
- **안구 변위(globe displacement)** 소견: 안구가 내측 및 전방으로 밀려있는 양상
- 병변의 경계는 비교적 명확하나 일부 불규칙
- **안와 지방 침범** 소견 동반

### 좌측 안와 (Left Orbit):
- 우측에 비해 상대적으로 **정상에 가까운 소견**
- 다만 일부 슬라이스에서 경미한 비대칭 소견

### 기타 소견:
- **비강 및 부비동**: 양측 사골동 및 상악동 내 일부 점막 비후 소견
- **두개내 구조물**: 전두엽 하부 정상 범위
- **안와 골벽**: 명확한 골 파괴 소견은 현 영상에서 확인 어려움
- 안와 내 **혈관 구조물** 확인 필요 (조영증강 여부 불명확)

---

## [DIFFERENTIAL DIAGNOSIS]

| 순위 | 진단명 | 근거 |
|------|--------|------|
| **1** | **해면상 혈관종 (Cavernous Hemangioma)** | 성인에서 가장 흔한 안와 내 양성 종양, 경계 명확, 근원추(muscle cone) 내 위치, 불균질 음영 |
| **2** | **림프종 (Orbital Lymphoma / MALT Lymphoma)** | 안와 내 연부조직 종괴, 비교적 균질, 안구 주위 주형(molding) 양상 가능 |
| **3** | **신경초종 / 신경섬유종 (Schwannoma / Neurofibroma)** | 경계 명확한 방추형 종괴, 신경 주행 방향 따라 위치 |
| **4** | **안와 가성종양 (Idiopathic Orbital Inflammatory Pseudotumor)** | 불규칙한 경계, 안와 구조물 침범, 임상적으로 통증·부종 동반 가능 |
| **5** | **전이성 종양 (Metastatic Tumor)** | 불균질 음영, 골 파괴 동반 가능, 기저 악성 종양 병력 확인 필요 |

---

> ⚠️ **임상적 참고사항:**
> - 정확한 진단을 위해 **조영증강 CT 또는 MRI (T1/T2/Gd 조영증강)** 추가 촬영 권고
> - 임상 증상(안구돌출, 복시, 시력저하, 통증 등) 및 발병 연령과
```

### 실패 케이스 (림프종 감별 실패 - 4건)

> 논의점: 림프종 대신 어떤 양성/악성을 제시했는가? 종괴 자체를 식별하지 못한 것인가?

#### 🔴 R10090
```text
# CT 영상 판독 (부비동/안와 CT - 관상면 Coronal)

> ⚠️ **참고**: 제시된 영상은 축상면(Axial)이 아닌 **관상면(Coronal)** CT 영상입니다.

---

## [FINDING]

**영상 기술:**

**슬라이스 1 (전방부):**
- 양측 안와 내 안구 및 안와 내용물은 대칭적으로 보임
- 사골동(ethmoid sinus) 및 비강 상부는 공기 음영으로 정상 함기화
- 전두동(frontal sinus) 하부 관찰됨

**슬라이스 2 (중간부):**
- 양측 안와 내 외안근(extraocular muscles) 및 시신경 구조 관찰
- **비강 내 연부조직 음영 증가** 소견 - 비갑개 비후 또는 점막 부종 의심
- 사골동 내 부분적 혼탁(opacification) 소견
- 양측 상악동(maxillary sinus) 개구부 주변 점막 비후 가능성

**슬라이스 3 (후방부):**
- **양측 하비갑개(inferior turbinate)의 현저한 비후/비대** 소견
- 양측 하비갑개가 대칭적으로 비강 내강을 상당 부분 점유
- 하비갑개 점막의 연부조직 음영이 증가되어 있으며, 내부에 **골성 구조(bony core)** 확인됨
- 양측 상악동 내 **점막 비후 또는 부분적 혼탁** 소견 (특히 하방부)
- 비중격(nasal septum)은 비교적 정중앙에 위치하나 경미한 만곡 가능성
- 중비갑개(middle turbinate) 구조 확인됨
- 안와 하벽(orbital floor) 및 안와 내용물은 양측 대칭적으로 보임
- 명확한 안와 내 종괴(mass) 또는 안구돌출(proptosis) 소견은 관찰되지 않음

---

## [DIFFERENTIAL DIAGNOSIS]

### 주요 소견: 양측 하비갑개 비대 + 상악동 점막 비후

| 순위 | 진단명 | 근거 |
|------|--------|------|
| **1** | **만성 비염 (Chronic Rhinitis) / 비후성 비염 (Hypertrophic Rhinitis)** | 양측 대칭적 하비갑개 비대, 점막 비후, 골성 코어 보존 |
| **2** | **알레르기성 비염 (Allergic Rhinitis)** | 양측 대칭적 점막 부종, 하비갑개 비후, 상악동 점막 비후 동반 |
| **3** | **만성 부비동염 (Chronic Rhinosinusitis)** | 상악동 및 사골동 점막 비후/혼탁, 비강 점막 비후 동반 |
| **4** | **비용종증 (Nasal Polyposis)** | 비강 내 연부조직 음영 증가, 단 전형적 포도송이 모양의 명확한 폴립은 불명확 |
| **5
```

#### 🔴 R10195
```text
# CT 영상 판독 (부비동/안와 CT - 관상면 Coronal)

> ⚠️ **주의**: 제시된 영상은 **축상면(Axial)이 아닌 관상면(Coronal)** CT 영상입니다.

---

## [FINDING]

**영상 기술:**
- 관상면(Coronal) CT, 비조영증강, 연부조직/골 윈도우

**주요 소견:**

### 🔴 양측 상악동 (Maxillary Sinus)
- **양측 상악동 내 완전 또는 거의 완전한 연부조직 음영 충만(opacification)** 관찰
- 내부 음영은 **균질한 연부조직 밀도(soft tissue density)**로, 액체 저류 또는 점막 비후 양상
- 골벽의 **명확한 파괴(bony destruction) 소견은 뚜렷하지 않음**
- 우측 상악동이 좌측에 비해 더 광범위한 충만 소견

### 🔴 비강 (Nasal Cavity)
- **비강 내 다발성 연부조직 음영** 관찰 → 비갑개 비후 또는 비용종(nasal polyp) 의심
- 중비도(middle meatus) 부위 폐쇄 소견
- **비중격(nasal septum)의 편위** 가능성 있음

### 🟡 사골동 (Ethmoid Sinus)
- **양측 사골동의 부분적 혼탁(partial opacification)** 소견
- 사골 기포(ethmoid air cells)의 연부조직 충만

### 🟢 안와 (Orbit)
- 양측 안구 및 안와 내 구조물은 **비교적 대칭적**으로 보임
- 안와 내 명확한 종괴 형성 소견은 현 영상에서 뚜렷하지 않음
- 안와 하벽(orbital floor)의 연속성은 유지된 것으로 보임

### 🟢 전두동 (Frontal Sinus)
- 영상 상단부에서 **양측 전두동은 비교적 함기화(pneumatization) 유지**

### 골 구조물
- 현재 영상에서 **명확한 골 미란(erosion)이나 파괴 소견은 확인되지 않음**
- 단, 골 윈도우 별도 평가 필요

---

## [DIFFERENTIAL DIAGNOSIS]

### 1순위 🥇
**만성 비부비동염 동반 비용종증 (Chronic Rhinosinusitis with Nasal Polyposis)**
- 양측성 상악동 및 사골동 충만
- 비강 내 다발성 연부조직 음영
- 골 파괴 없음
- 가장 흔하고 전형적인 패턴에 부합

---

### 2순위 🥈
**알레르기성 진균성 부비동염 (Allergic Fungal Sinusitis, AFS)**
- 다발성 부비동 침범
- 내부에 고밀도 음영(fungal concretion) 가능
- 비용종과 동반 가능
- 면역 정상인에서도 발생

---

### 3순위 🥉
**만성 비부비동염 (Chronic Rhinosin
```

#### 🔴 R10816
```text
# 안와(Orbit) MRI 판독

## 영상 분석

세 장의 관상면(Coronal) MRI 영상으로 보이며, 순차적으로 전방에서 후방으로 진행하는 슬라이스로 판단됩니다.

---

## [FINDING]

**양측 안구 및 안와 소견:**

- **양측 안구(eyeball)**에 **원형(round)의 well-defined mass**가 관찰됨
- 병변은 **안구 내(intraocular)**에 위치하며, 안구 후방부(posterior segment)에 주로 분포
- **크기**: 양측 모두 안구 내 상당 부분을 차지하는 비교적 큰 병변
- **신호 강도(Signal Intensity)**:
  - T2 영상으로 추정 시: 병변 내부에 **불균질한(heterogeneous) 신호**
  - 내부에 **고신호(hyperintense) 및 저신호(hypointense) 혼재** 소견
  - 일부 **석회화 또는 출혈**을 시사하는 저신호 영역 포함 가능
- **병변의 형태**: 둥글고 경계가 비교적 명확(well-circumscribed)
- **양측성(bilateral)** 병변으로 대칭적 분포
- 안와 외벽 침범이나 시신경(optic nerve) 직접 침범 소견은 명확하지 않음
- 안와 내 외안근(extraocular muscles) 및 주변 지방 조직은 비교적 보존된 소견

---

## [DIFFERENTIAL DIAGNOSIS]

| 순위 | 진단명 | 근거 |
|------|--------|------|
| **1** | **Retinoblastoma (망막모세포종)** | 소아에서 양측성 안구 내 종괴, 불균질 신호, 석회화 동반 가능 — **가장 가능성 높음** |
| **2** | **Persistent Hyperplastic Primary Vitreous (PHPV) / Persistent Fetal Vasculature** | 소아 안구 내 병변, 유리체 내 이상 신호 |
| **3** | **Coats' Disease (코츠병)** | 망막하 삼출 및 안구 내 이상 소견, 단측 호발하나 양측 가능 |
| **4** | **Uveal Melanoma (포도막 흑색종)** | 성인에서 안구 내 종괴, 그러나 양측성은 드묾 |
| **5** | **Choroidal Hemangioma (맥락막 혈관종)** | 안구 내 well-defined 종괴, 혈관성 신호 특성 |

---

## ⚠️ 임상적 중요 소견

> **양측성 안구 내 종괴**는 **Retinoblastoma**를 **강력히 시사**합니다.
> 특히 소아 환자에서 양측성 망막모세포종은 **RB1 유전자 germline mutation**과 관련되며,
> **즉각적인 안과 및 소아종양과 협진**이 필요합니다.

*※ 본 판독은 영상만을 기반으로 한 소견이며, 최종 진단은 임상 정보 및 추가 검사와 종합하여 판단해야
```

#### 🔴 R10909
```text
# 안와(Orbit) MRI 판독

## 영상 분석

3장의 코로날(Coronal) MRI 영상으로 보이며 (축상면이 아닌 관상면으로 판단됨), T2 강조영상으로 추정됩니다.

---

## [FINDING]

**양측 안구(Bilateral Eyeball) 소견:**
- **양측 안구에 대칭적으로 거대한 종괴성 병변** 관찰됨
- 병변은 **안구 내부(intraocular)**에 위치하며, 안구 전체를 거의 대체하는 양상
- T2 신호 강도: **혼합 신호(heterogeneous signal)** — 내부에 고신호 및 저신호 혼재
- 일부 영상에서 **내부 격벽(internal septation)** 또는 **고형 성분(solid component)** 시사
- 병변의 경계는 비교적 **명확(well-defined)**
- **양측성(bilateral)** 침범이 특징적
- 안구 외벽(sclera)의 침범 여부는 불명확하나, 안구 크기가 증대된 양상
- 시신경(optic nerve)의 두께는 현재 영상에서 평가 제한적
- 안와 외 구조물(extraorbital extension)의 명확한 침범 소견은 현 영상에서 불명확

**추가 소견:**
- 비강 및 부비동 구조는 비교적 정상 범위로 보임
- 뇌실질의 명확한 이상 소견은 현 영상에서 평가 제한적

---

## [DIFFERENTIAL DIAGNOSIS]

1. **Retinoblastoma (망막모세포종)** ⭐
   - 양측성 발생이 특징적 (전체 retinoblastoma의 약 30-40%)
   - 소아에서 가장 흔한 안구 내 악성 종양
   - 양측성인 경우 유전성(RB1 germline mutation) 강력 시사
   - 내부 석회화 동반 가능 (CT에서 더 잘 보임)

2. **Persistent Hyperplastic Primary Vitreous (PHPV) / Persistent Fetal Vasculature (PFV)**
   - 보통 단측성이나 양측성도 가능
   - 소안구증(microphthalmia) 동반 가능
   - T2에서 유리체 내 이상 신호

3. **Coats Disease (코츠병)**
   - 삼출성 망막박리를 동반한 망막혈관 이상
   - 주로 단측성이나 양측성 드물게 가능
   - T2 고신호의 삼출액

4. **Uveal Melanoma (포도막 흑색종)**
   - 성인에서 호발하는 안구 내 악성 종양
   - 양측성은 드물지만 감별 필요
   - T1 고신호, T2 저신호가 전형적

5. **Endophthalmitis / Toxocariasis (안내염 / 톡소카라증)**
   - 염증성 병변으로 안구 내 혼탁 및 삼출
   - 양측성 가능
   - 임상 증상(통증, 시력저하)과 연관

---

> ⚠️ **임상적 고려사항**: 양
```

