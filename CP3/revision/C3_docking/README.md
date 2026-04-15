# C3 Docking Negative Control — 실행 패키지

## 파일 목록
| 파일 | 용도 |
|------|------|
| `5CXV.pdb` | CHRM1 구조 (양성 대조군) |
| `3KYS.pdb` | YAP-TEAD 구조 |
| `5BRK.pdb` | MOB1-LATS1 구조 |
| `3KFD.pdb` | TGFβ1R 구조 |
| `ligands_SMILES.txt` | 3종 대조 화합물 SMILES (붙여넣기용) |
| `C3_results_template.csv` | 결과 기록 템플릿 (엑셀로 열어 편집) |
| `analyze_C3_results.R` | 결과 자동 분석 + 논문 문구 생성 |

---

## CB-Dock2 실행 순서

**URL**: https://cadd.labshare.cn/cb-dock2/

### 총 12회 도킹 (3 compounds × 4 targets)

| # | Compound | Target PDB | SMILES 파일 위치 |
|---|----------|-----------|-----------------|
| 1 | Scopolamine | 5CXV | `ligands_SMILES.txt` → [LIGAND 1] |
| 2 | Scopolamine | 3KYS | " |
| 3 | Scopolamine | 5BRK | " |
| 4 | Scopolamine | 3KFD | " |
| 5 | Tropicamide | 5CXV | `ligands_SMILES.txt` → [LIGAND 2] |
| 6 | Tropicamide | 3KYS | " |
| 7 | Tropicamide | 5BRK | " |
| 8 | Tropicamide | 3KFD | " |
| 9 | Caffeine | 5CXV | `ligands_SMILES.txt` → [LIGAND 3] |
| 10 | Caffeine | 3KYS | " |
| 11 | Caffeine | 5BRK | " |
| 12 | Caffeine | 3KFD | " |

### 각 도킹 단계
1. CB-Dock2 접속 → **"Blind Docking"** 탭
2. **Protein**: PDB ID 직접 입력 (예: `5CXV`)
3. **Ligand format**: SMILES 선택
4. **SMILES**: `ligands_SMILES.txt`에서 해당 화합물 SMILES 복사/붙여넣기
5. Submit → 완료 후 **Top cavity Vina Score** 기록

### 기록할 값 (C3_results_template.csv에 입력)
- `Vina_Score_kcal_mol` : 음수값 (예: -7.2)
- `Cavity_Volume_A3` : 선택사항
- `Key_Residues` : 선택사항

---

## 결과 분석

CSV 채운 후 RStudio에서:
```r
source("c:/Projectbulid/CP3/revision/C3_docking/analyze_C3_results.R")
```
→ 자동으로 시나리오 판단 + 논문 문구 생성

---

## Atropine 기준값 (비교용)

| Target | Atropine Vina Score |
|--------|-------------------|
| 5CXV (CHRM1) | **−8.8** |
| 3KYS (YAP-TEAD) | **−7.9** |
| 5BRK (MOB1-LATS1) | **−7.6** |
| 3KFD (TGFβ1R) | **−7.5** |

> 기준: novel targets에서 대조군이 ≥ −6.0이면 **Atropine 특이적 결합 확인** (Scenario A)
