# VLM Blind Reading Pilot v2 - Summary

- **Date**: 20260401_184048
- **Model**: claude-sonnet-4-6
- **Prompt version**: v2 (orientation-neutral)
- **Cases**: 8
- **Lymphoma detected**: 4/8 (50.0%)

## Prompt
```
이 영상은 동일 환자의 안와(Orbit) 영상 3장입니다.

다음을 수행해 주세요:
1. 영상의 종류(CT/MRI)와 촬영 방향(axial/coronal/sagittal)을 판단
2. 병변(mass, lesion, enlargement 등)의 유무 및 형태학적 특징 묘사
3. 가장 가능성 있는 감별진단(Differential Diagnosis) 5개를 순위별로 제시

출력 형식:
[IMAGING]
(영상 종류 및 촬영 방향)

[FINDING]
(병변에 대한 영상의학적 소견 묘사)

[DIFFERENTIAL DIAGNOSIS]
1. (진단명 1) - (근거 한 줄)
2. (진단명 2) - (근거 한 줄)
3. (진단명 3) - (근거 한 줄)
4. (진단명 4) - (근거 한 줄)
5. (진단명 5) - (근거 한 줄)
```

## Results

| Case | Lymphoma | Rank | Status |
|------|----------|------|--------|
| R10084 | No | - | MISS |
| R10090 | No | - | MISS |
| R10195 | Yes | #3 | HIT |
| R10501 | No | - | MISS |
| R10603 | Yes | #4 | HIT |
| R10710 | Yes | #1 | HIT |
| R10816 | Yes | #5 | HIT |
| R10909 | No | - | MISS |

## v1 vs v2 Comparison

| Case | v1 (Axial prompt) | v2 (Neutral prompt) |
|------|-------------------|---------------------|
| R10084 | HIT | MISS |
| R10090 | MISS | MISS |
| R10195 | MISS | HIT |
| R10501 | HIT | MISS |
| R10603 | HIT | HIT |
| R10710 | HIT | HIT |
| R10816 | MISS | HIT |
| R10909 | MISS | MISS |


## Full Responses

### R10084
```
[IMAGING]
MRI, T2 weighted image (T2WI)
촬영 방향: Coronal plane (관상면)
- 3장의 영상은 anterior → posterior 방향으로 연속된 coronal 절편으로 판단됨
- T2 고신호의 안구 유리체(vitreous), 뇌피질의 gyral pattern이 명확히 보임

---

[FINDING]

**양측 안구(Bilateral Globes):**
- 양측 안구 크기가 현저히 증대(enlarged globes)되어 있음
- T2WI에서 유리체(vitreous)는 정상적인 고신호 유지
- **좌측 안구(Left Globe):** 안구 자체의 크기 증대와 함께, 후극부(posterior pole) 또는 시신경-공막 접합부 주변에 **T2 고신호의 원형/난원형 종괴(mass)**가 관찰됨 → 안구 후방 외측에 well-defined, round, hyperintense lesion 존재
- **우측 안구(Right Globe):** 마찬가지로 안구 비대 소견, 좌측에 비해 대칭적으로 유사한 형태
- 양측 안구 크기가 두개골 내 뇌 용적 대비 **상대적으로 매우 크게** 보임 → **megalophthalmos / buphthalmos** 양상
- 안와 내 구후 공간(retrobulbar space): 별도의 명확한 구후 종괴는 식별되지 않음
- 시신경(optic nerve): 양측 시신경의 두께 평가에서 특별한 sheath enlargement는 뚜렷하지 않음
- 비강(nasal cavity) 및 부비동: T2 중등도 신호의 점막 비후 소견(부비동염 가능성)
- 대뇌: 정상적인 gyration 및 sulcation 패턴, 이상 신호 없음

**핵심 소견 요약:**
> **양측성 안구 비대(bilateral buphthalmos/megalophthalmos)** + 좌측 안구 후벽 부위 T2 고신호 병변

---

[DIFFERENTIAL DIAGNOSIS]

1. **선천성 녹내장 (Congenital Glaucoma / Buphthalmos)** - 양측성 안구 비대의 가장 흔한 원인으로, 방수 유출 장애로 인한 안압 상승이 안구 확장을 초래하며 소아에서 전형적으로 발생

2. **Retinoblastoma (망막모세포종)** - 소아에서 안구 내 T2 고신호 또는 혼합 신호의 종괴, 편측 또는 양측성으로 발생 가능하며 안구 후벽의 종괴성 병변과 일치

3. **Coats Disease (코츠병)** - 망막 삼출 및 삼출성 망막박리로 인해 후극부에 T2 고신호 병변 형성, 주로 소아 남아에서 발생하며 안구 크기 증대 동반 가능

4. **Persistent Hyperplastic Primary Vitreous (PHPV) / Persistent Fetal Vasculature (PFV)** - 태생기 초자체 혈관 잔존으로 인한 안구 내 T2 이상 신호 및 소안구증보다 드물지만 안구 변형 동반 가능

5. **Sturge-Weber Syndrome 또는 Neurofibromatosis Type 1 (NF1) 연관 녹내장** - 신경피부증후군에 동반된 안압 상승으로 인한 이차성 buphthalmos, 뇌 MRI 상 이상 소견과 병합될 수 있음

---

> ⚠️ **임상 참고:** 최종 진단을 위해서는 안압 측정, 안저 검사, 조영증강 MRI 추가 및 소아 안과/소아 신경과 협진이 필요합니다.
```

### R10090
```
[IMAGING]
**CT scan (비조영증강 추정), Coronal view**
- 3장 모두 동일 환자의 관상면(Coronal plane) CT 영상
- 전방(anterior)에서 후방(posterior)으로 진행하는 연속 슬라이스

---

[FINDING]

**양측 안와(Orbit) 소견:**
- **양측 안구(globe)가 현저히 비대**되어 있으며, 정상 안와 내에서 안구 크기가 비정상적으로 증가된 소견
- **양측성(bilateral), 대칭적** 안구 확대 소견
- 안구 내부 음영은 유리체(vitreous)에 해당하는 균일한 저음영으로 구성
- 안구 후방의 시신경(optic nerve) 주위 조직 및 외안근(extraocular muscles)은 비교적 보존된 형태
- **안와 골벽(orbital wall)의 remodeling** 소견 동반 — 안와가 확장/압박된 양상
- 부비동(paranasal sinuses): 특이 병변 없음 (3번째 슬라이스에서 하비갑개 확인)
- 두개 내 명확한 이상 음영은 본 슬라이스에서 관찰되지 않음

**핵심 소견 요약:**
> **양측성 대칭적 안구 확대(Bilateral symmetric buphthalmos/megaloglobus)** + 안와 골 remodeling

---

[DIFFERENTIAL DIAGNOSIS]

1. **선천성 녹내장 (Congenital Glaucoma / Buphthalmos)** - 소아에서 안압 상승으로 인한 양측성 안구 확대의 가장 흔한 원인이며, 안와 골 remodeling 동반 가능

2. **신경섬유종증 1형 (Neurofibromatosis Type 1, NF-1)** - NF-1에서 안와 이형성증 및 양측 안구 확대, 안와 골 결손 동반 가능

3. **축성 근시 (High Axial Myopia)** - 양측 고도근시에서 안축장(axial length) 증가로 인한 안구 확대 소견과 일치

4. **Axenfeld-Rieger Syndrome** - 전방각 발달 이상으로 인한 속발성 녹내장 및 안구 확대를 동반하는 선천성 안질환

5. **선천성 거안구증 (Primary Megalocornea / Nanophthalmos 반대 개념)** - 양측성 선천적 안구 확대를 보이는 드문 발달성 이상

---

> ⚠️ **임상적 고려사항**: 환자 연령, 안압 측정값, 시력, 가족력 및 전신 증상을 종합하여 최종 진단 요망. 소아 환자라면 **선천성 녹내장**이 최우선 감별 진단입니다.
```

### R10195
```
[IMAGING]
**CT scan (비조영 또는 조영 CT), Coronal plane**
- 3장 모두 동일 환자의 관상면(Coronal) CT 영상으로, 후방에서 전방 방향으로 순차적으로 촬영된 슬라이스로 판단됨
- Bone window 또는 soft tissue window 혼합 관찰

---

[FINDING]

**양측 안와(Orbit) 소견:**
- **양측 안와 내 extraocular muscle(외안근)의 방추형(fusiform) 비후** 소견이 관찰됨
- 비후는 **근복부(belly of muscle)**에 주로 집중되어 있으며, 근건부(tendon insertion)는 비교적 보존된 양상 → **tendon-sparing pattern**
- **양측성(bilateral)** 으로 대칭적 혹은 비대칭적으로 침범
- 특히 **내직근(medial rectus)** 및 **하직근(inferior rectus)** 위주의 비후가 두드러짐
- 안와 내 지방(orbital fat)은 비교적 보존되어 있으나 일부 density 증가 가능성 있음
- 안구 돌출(proptosis/exophthalmos) 소견 동반 가능성 시사
- 시신경(optic nerve)의 압박 가능성 배제 불가
- 부비동(paranasal sinus)은 비교적 정상 범위, 골파괴 소견 없음

---

[DIFFERENTIAL DIAGNOSIS]

1. **Thyroid Eye Disease (Graves' Ophthalmopathy, 갑상선 안병증)** - 양측성 외안근 비후, tendon-sparing fusiform enlargement의 전형적 패턴으로 가장 합당; 내직근·하직근 우선 침범

2. **Idiopathic Orbital Inflammatory Syndrome (IOIS, 특발성 안와 염증)** - 단측 또는 양측 외안근 비후 가능, 건부 침범(tendon involvement)도 동반할 수 있어 감별 필요

3. **Orbital Lymphoma (안와 림프종)** - 외안근 또는 안와 내 연부조직의 균질한 종괴 형성, 양측성 가능하나 muscle belly 외 지방 내 침윤 동반 여부 확인 필요

4. **Carotid-Cavernous Fistula / Dural AVF (경동맥-해면정맥동루)** - 안와 내 정맥 울혈로 인한 외안근 비후 및 superior ophthalmic vein 확장 동반 가능

5. **Metastatic Disease (전이성 종양)** - 양측 외안근의 비균질 비후, 골파괴 동반 가능성; 원발암 병력 있을 시 감별 요함

---

> ⚠️ **임상 권고:** TSH, free T4, TSI(갑상선 자극 항체) 등 갑상선 기능 검사 및 임상 증상(안구 돌출, 복시, 안검 후퇴) 확인이 최우선이며, 필요 시 조영 MRI로 추가 평가 권장
```

### R10501
```
[IMAGING]
MRI (T2-weighted sequence), Coronal plane
- 3장의 영상은 anterior에서 posterior 방향으로 진행하는 연속적인 관상면(coronal) 절편
- 안구(globe)가 고신호강도(bright white)로 보이는 것은 T2 강조영상의 특징적 소견

---

[FINDING]

**양측 안구 및 안와 소견:**
- 양측 안구(eyeball)는 정상적인 구형 형태를 유지
- **양측 안구 후방(posterior segment)에 T2 고신호강도의 초승달형(crescent-shaped) 또는 렌즈형 병변**이 관찰됨
- 특히 후방 슬라이스(3번째 영상)에서 양측 안구 후극부(posterior pole)에 납작한 고신호강도 병변이 명확히 확인됨
- 병변은 **안구 후벽을 따라 편평하게 위치**하며, 안구 내 공간을 부분적으로 차지
- 유리체강(vitreous cavity)의 신호와 유사하거나 약간 상이한 신호 강도
- **안와 지방(orbital fat)의 신호 감소** 없이 정상 범위로 보임
- 외안근(extraocular muscles)의 비후나 종괴 형성은 뚜렷하지 않음
- 시신경(optic nerve)은 양측 대칭적으로 관찰되며 현저한 비후 없음
- 뇌실질(cerebral parenchyma)은 명백한 mass 또는 signal abnormality 없이 정상

**핵심 이상 소견 요약:**
> 양측 안구 후극부에 T2 고신호강도의 편평한 초승달형 병변 → **양측성 후방 안구 병변(bilateral posterior globe lesion)** 시사

---

[DIFFERENTIAL DIAGNOSIS]

1. **Posterior Staphyloma (후방 공막 확장증)** - 양측 고도근시에서 발생하는 후극부 공막 팽윤으로, 안구 후벽의 T2 고신호 편평 병변 패턴과 가장 잘 일치; 안구 변형 동반 가능

2. **Choroidal Detachment (맥락막 박리)** - 안구 후벽을 따라 렌즈형/초승달형으로 액체가 고이는 소견이 T2 고신호로 나타나며, 외상 또는 저안압에서 발생

3. **Retinal Detachment (망막 박리)** - 후방 유리체강 내 T2 고신호의 편평한 막 형성 소견으로 나타날 수 있으며, V자형 또는 편평형 배열 가능

4. **Coloboma of the Posterior Globe** - 선천성 안구 후극부 결손으로 인한 낭성 T2 고신호 병변; 소안구증(microphthalmos) 동반 가능하나 이 증례에서는 안구 크기 정상

5. **Uveal Melanoma / Choroidal Mass (맥락막 종양)** - 일측성이 더 흔하나 양측성도 드물게 존재; 그러나 이 영상에서 병변이 편평하고 종괴 효과가 적어 가능성 낮음, 감별 목적으로 포함

---

> ⚠️ **임상 권고:** 안과적 정밀 검진(안저검사, 안구 초음파, fluorescein angiography) 및 굴절 이상 여부 확인 필요. 양측성 소견이므로 전신 질환(Marfan syndrome, connective tissue disorder 등) 동반 여부도 고려 요망.
```

### R10603
```
[IMAGING]
CT, Coronal view (조영증강 없는 비조영 CT로 추정) — 3장 모두 동일 환자의 연속적인 관상면(Coronal) 슬라이스이며, 전방(anterior)에서 후방(posterior) 방향으로 순서대로 촬영된 안와 CT입니다.

---

[FINDING]

**양측성 소견:**
- 양측 안구(eyeball)가 전방으로 돌출(proptosis/exophthalmos)되어 있는 소견이 관찰됨
- 양측 안와 내 extraocular muscle(외안근)의 **미만성 비후(diffuse enlargement)** 가 뚜렷하게 관찰됨
  - 특히 **inferior rectus** 및 **medial rectus muscle**의 비후가 두드러짐
  - 근육의 **belly(근복부) 위주의 방추형 비후(fusiform enlargement of muscle belly)**가 관찰되며, tendon insertion 부위는 상대적으로 보존된 양상
- 비후된 근육의 밀도는 주변 연조직과 유사한 soft tissue density
- **양측성(bilateral)** 이며 비교적 **대칭적(symmetric)** 소견
- 안와 지방(orbital fat)의 증가 소견도 동반되어 있을 가능성
- 시신경(optic nerve)의 명확한 압박 소견은 본 슬라이스에서 결정적이지 않으나, 근육 비후로 인한 orbital apex 부위 압박 가능성 존재
- 부비동(paranasal sinus) 내 특이 병변은 이 슬라이스에서 명확하지 않음
- 두개내 이상 소견은 본 영상 범위 내에서 뚜렷하지 않음

---

[DIFFERENTIAL DIAGNOSIS]

1. **Thyroid-associated orbitopathy (Graves' ophthalmopathy, 갑상선 안병증)** — 양측성, 대칭적 extraocular muscle belly의 방추형 비후 + proptosis의 전형적인 패턴으로 가장 합당; inferior/medial rectus 우선 침범 양상과 일치

2. **Idiopathic orbital inflammatory disease (Orbital pseudotumor, 특발성 안와 염증)** — 외안근 비후 및 안와 내 연조직 침범 가능하나, 통상 편측성이 많고 tendón 부위까지 비후되는 경향 있어 차순위

3. **Carotid-cavernous fistula (CCF) / Dural arteriovenous fistula** — 외안근 비후 및 안구 돌출 동반 가능, 상안정맥(superior ophthalmic vein) 확장 여부 추가 확인 필요

4. **Lymphoma of the orbit (안와 림프종)** — 양측성 안와 종괴로 나타날 수 있으며 근육을 포함한 연조직에 molding pattern으로 침윤 가능; 단 근복부 방추형 비후보다는 diffuse infiltration 패턴이 더 흔함

5. **Metastatic disease to extraocular muscles (안와 근육 전이)** — 전신암의 안와 근육 전이 시 비후 가능하나, 대개 비대칭·단발성이며 임상 병력 연계 필요

---

> ⚠️ **임상 참고:** 본 소견은 **Graves' ophthalmopathy**에 가장 부합하며, TSH/Free T4/TRAb 등 갑상선 기능 검사 및 임상 소견(안구 충혈, 복시, 시력 저하 여부)과의 상관이 필요합니다. Orbital apex crowding에 의한 dysthyroid optic neuropathy 여부 평가를 위한 추가 MRI 시행을 권고합니다.
```

### R10710
```
[IMAGING]
**CT scan (조영증강 추정), Coronal plane**
- 3장 모두 관상면(Coronal) 영상으로, 전방(안구 레벨)→후방(안와 심부)으로 진행하는 연속 슬라이스
- 골 및 연부조직 모두 평가 가능한 CT 영상 (조영증강 시행된 것으로 보임)

---

[FINDING]

**우측 안와 (Right Orbit):**
- 우측 안와 내에 **비교적 경계가 명확한 원형~타원형의 고밀도 종괴**가 관찰됨
- 종괴는 **안구 후외측(retrobulbar, extraconal 또는 intraconal)** 위치에 존재
- 내부 밀도는 **불균질(heterogeneous)**하며, 조영증강 시 내부에 **혈관성 구조물 또는 불균등 조영증강** 소견 시사
- 안구 자체는 비교적 보존되어 있으나 **안구 변위(displacement)** 가능성 있음
- 안와 골벽의 **명확한 골파괴 소견은 뚜렷하지 않음**

**좌측 안와 (Left Orbit):**
- 좌측에도 유사한 양상의 종괴가 관찰되어 **양측성(bilateral) 병변** 가능성
- 대칭적이지 않으며, 우측이 더 크고 현저함

**기타:**
- 부비동(ethmoid, maxillary sinus) 일부에 점막비후 소견 동반
- 두개 내 명확한 침범 소견은 본 영상에서 확인 어려움
- 양측 안와 지방 내 종괴성 병변의 **양측성 분포**가 특징적

---

[DIFFERENTIAL DIAGNOSIS]

1. **Lymphoma (Orbital Lymphoma)** - 양측성, 경계 비교적 명확, 안와 내 균질~불균질 연부조직 종괴로 가장 흔한 성인 안와 종양 중 하나; 양측 침범 시 강력히 시사

2. **Idiopathic Orbital Inflammatory Disease (Orbital Pseudotumor)** - 양측성 안와 염증성 종괴, 경계 불명확할 수 있으며 외안근·누선 침범 동반 가능; 조영증강 잘 됨

3. **Cavernous Hemangioma (Cavernous Venous Malformation)** - 성인에서 가장 흔한 안와 내 양성 종양, 경계 명확한 원형 종괴, intraconal 호발, 점진적 조영증강 특징

4. **Metastasis (전이성 종양)** - 양측성 안와 종괴 시 전신 악성종양(유방암, 폐암 등) 전이 가능성 배제 필요; 골파괴 동반 가능

5. **Lacrimal Gland Tumor (누선종양, e.g. Pleomorphic Adenoma or Adenoid Cystic Carcinoma)** - 안와 외상방(superolateral) 위치의 종괴로 발생 가능하나, 양측성은 드물어 가능성은 낮음; 형태 및 위치에 따라 감별 필요

---
> ⚠️ **임상 참고사항**: 양측성 안와 종괴는 **림프종** 또는 **전신질환의 안와 침범(육아종증, IgG4-related disease 등)**을 강력히 시사하므로, 조직검사 및 전신 staging 검사(PET-CT, 혈액검사)가 권장됩니다.
```

### R10816
```
[IMAGING]
MRI, Coronal view (3장 모두 동일 환자의 관상면 영상)
- 영상 특성상 T1WI, T2WI, 그리고 contrast-enhanced T1WI (또는 fat-suppressed sequence)로 추정되는 3가지 시퀀스

---

[FINDING]

**양측성 안와 내 mass 소견:**

- **위치**: 양측 안구(globe) 내부 → **안구 내 종괴(intraocular mass)**
- **형태**: 양측 안구 내에 비교적 **경계가 명확한 원형-타원형** 종괴
- **신호 강도**:
  - 첫 번째 영상(T2 또는 T1): 종괴는 안구 내에서 중등도 신호
  - 두 번째 영상(밝은 영상, 아마도 T2 또는 post-contrast): 종괴가 **현저한 고신호 또는 강한 조영증강** 양상
  - 세 번째 영상(fat-suppressed 또는 다른 시퀀스): 종괴 내부의 불균질한 신호
- **크기**: 양측 안구의 상당 부분을 차지하는 **대형 종괴**
- **양측성(bilateral)** 침범이 가장 두드러진 특징
- 안구 외 구조물(extraocular muscle, optic nerve)의 명확한 침범은 이 영상에서 확인 필요
- 안구 변형(globe deformity) 동반 가능성 있음
- 유리체강(vitreous cavity) 거의 대부분을 종괴가 차지

---

[DIFFERENTIAL DIAGNOSIS]

1. **Retinoblastoma (망막모세포종)** - 소아에서 **양측성 안구 내 종괴**의 가장 흔한 원인이며, 양측성인 경우 유전성(RB1 mutation) 강력 시사; 석회화 동반 가능

2. **Persistent Hyperplastic Primary Vitreous (PHPV) / Persistent Fetal Vasculature** - 유리체강 내 이상 구조물로 안구 내 신호 이상 유발; 단, 보통 편측성이나 양측도 드물게 가능

3. **Coats' Disease (코츠병)** - 망막 삼출과 삼출성 망막박리로 안구 내 고신호 종괴 유사 소견; 주로 편측이나 양측도 보고됨

4. **Ocular Melanoma (포도막 흑색종)** - 성인에서 안구 내 종괴의 흔한 원인; T1 고신호/T2 저신호의 전형적 MRI 패턴이나 양측성은 드묾

5. **Lymphoma (안구 내 림프종)** - 양측 안구 침범 가능한 악성 종양; 유리체-망막 림프종의 경우 양측성 소견을 보일 수 있으며 조영증강 양상 동반

---

> ⚠️ **임상 참고**: 양측성 안구 내 종괴라는 점에서 **소아 환자의 경우 Retinoblastoma가 최우선 감별**이며, 즉각적인 안과 협진 및 추가 정밀 검사(MRI with contrast, fundoscopy, genetic testing)가 필요합니다.
```

### R10909
```
[IMAGING]
MRI, Coronal plane (3장 모두 동일 환자의 관상면 영상, 전방→후방 순서로 촬영된 것으로 판단됨)
- T2-weighted sequence로 추정 (안구 유리체가 고신호강도로 보임)

---

[FINDING]

**양측성 안와 내 종괴 소견:**

- **양측 안구(globe)** 내에 **경계가 명확한 원형~타원형의 종괴**가 관찰됨
- 종괴는 **T2에서 내부에 고신호강도(hyperintense) 병변**을 포함하며, 일부 **저신호강도(hypointense) 테두리(rim)**를 동반함
- **크기:** 양측 안구 대부분을 차지할 정도로 **비교적 큰 크기**
- **내부 신호 불균질(heterogeneous signal intensity):** 고형 성분과 낭성 성분이 혼재하는 양상
- **양측성(bilateral)** 병변으로, 크기는 **좌우 유사** (대칭적 혹은 거의 대칭)
- 후방 슬라이스에서 **안와 내 연부조직으로의 침범** 혹은 **외안근 변위** 가능성 시사
- **시신경(optic nerve)**의 명확한 비후나 단절 소견은 현 영상에서 확인 제한적
- **유리체강(vitreous cavity)** 내 종괴가 위치하며, **망막 기원**으로 추정되는 형태

---

[DIFFERENTIAL DIAGNOSIS]

1. **Retinoblastoma (망막모세포종)** - 소아에서 양측성으로 발생하는 가장 흔한 안내 악성종양으로, 양측성 병변 및 안구 내 종괴 소견에 가장 부합함

2. **Persistent Hyperplastic Primary Vitreous (PHPV, 일차 유리체 과증식증)** - 선천성 단측/양측 안구 내 이상 소견으로 나타날 수 있으나, 본 증례처럼 뚜렷한 종괴 형성은 덜 전형적

3. **Coats Disease (코츠병)** - 망막 삼출 및 망막박리로 인해 유리체강 내 고신호 병변을 유발할 수 있으나, 통상 단측성이 더 흔함

4. **Choroidal Melanoma (맥락막 흑색종)** - 성인에서 발생하는 안내 악성종양으로 양측성은 드물지만, 종괴의 형태학적 특징상 감별 필요

5. **Ocular Metastasis (안구 전이암)** - 전신 악성종양의 양측 안구 전이 가능성, 불균질한 내부 신호 및 양측성 병변 소견과 연관 가능

---

> ⚠️ **임상적 고려사항:** 양측성 안구 내 종괴는 **소아의 경우 Retinoblastoma를 최우선으로 배제**해야 하며, 조직학적 확인 및 전신 병기 평가(뇌·척수 MRI, 골수 검사 등)가 필요합니다.
```

