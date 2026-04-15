# C3: Molecular Docking Negative Control

## 목적
아트로핀의 novel target binding이 specific한지, 아니면 비슷한 크기의 아무 분자나 결합하는지 검증.

## 대조 화합물 3개

| # | Compound | PubChem CID | MW | 선정 이유 | SMILES |
|---|----------|------------|-----|----------|--------|
| 1 | **Scopolamine** | 3000322 | 303.4 | 무스카린 길항제, 아트로핀 구조 유사체 (tropane 골격 공유), 근시 억제 효과 미보고 | `O=C(OC1CC2CCC1N2C)C(CO)c1ccccc1` → 실제: `O=C(O[C@@H]1C[C@H]2C[C@@H]1O2)C(CO)c1ccccc1` |
| 2 | **Tropicamide** | 5593 | 284.4 | 무스카린 길항제, 산동제, 근시 효과 없음 | `CCN(CC(=O)OC1CC2CCC1N2C)c1ccccc1` → 실제: `O=C(N(CC)Cc1ccccc1)C(CO)c1ccncc1` |
| 3 | **Caffeine** | 2519 | 194.2 | 비수용체 약물, 분자량 다름 (음성 대조) | `Cn1c(=O)c2c(ncn2C)n(C)c1=O` |

> **참고**: Scopolamine의 정확한 SMILES는 PubChem에서 직접 복사하세요.

## 도킹 타겟 4개 (아트로핀과 동일)

| PDB | 타겟 | Atropine Score |
|-----|------|---------------|
| 5CXV | CHRM1 (양성 대조군) | −9.0 (FitDock) / −8.8 (CB-Dock2) |
| 3KYS | YAP-TEAD | −7.9 |
| 5BRK | MOB1-LATS1 | −7.6 |
| 3KFD | TGFβ1R | −7.5 |

## 실행 절차 (CB-Dock2)

### 총 12회 도킹 (3 compounds × 4 targets)

1. **CB-Dock2** 접속: https://cadd.labshare.cn/cb-dock2/
2. **Protein**: PDB ID 입력 (예: 5CXV)
3. **Ligand**: 
   - "Input format" → SMILES 선택
   - PubChem에서 해당 compound의 Isomeric SMILES 복사/붙여넣기
4. **Submit** 클릭
5. 결과에서 기록할 항목:
   - **Top cavity Vina score** (kcal/mol)
   - **Cavity volume** (Å³)
   - **Contact residues** (4Å 이내)
6. 3개 compound × 4 targets = **12회 반복**

### FitDock (5CXV에만 해당)
- 5CXV에 대해서는 FitDock 점수도 기록 (template-based docking)
- Template 6WJC가 나오면 orthosteric binding 확인

## 결과 기록 템플릿

| Compound | PDB | Cavity | Vina Score | Volume (Å³) | FitDock Score | Key Residues |
|----------|-----|--------|-----------|-------------|--------------|-------------|
| Atropine | 5CXV | C2 | −8.8 | 1,436 | −9.0 | GLN43, TRP56, ASP63 |
| Atropine | 3KYS | C1 | −7.9 | 1,985 | N/A | PHE206, PHE275... |
| Atropine | 5BRK | C1 | −7.6 | 1,695 | N/A | TRP56, HIS646... |
| Atropine | 3KFD | C1 | −7.5 | 4,786 | N/A | TRP30, TYR50... |
| Scopolamine | 5CXV | | | | | |
| Scopolamine | 3KYS | | | | | |
| Scopolamine | 5BRK | | | | | |
| Scopolamine | 3KFD | | | | | |
| Tropicamide | 5CXV | | | | | |
| Tropicamide | 3KYS | | | | | |
| Tropicamide | 5BRK | | | | | |
| Tropicamide | 3KFD | | | | | |
| Caffeine | 5CXV | | | | | |
| Caffeine | 3KYS | | | | | |
| Caffeine | 5BRK | | | | | |
| Caffeine | 3KFD | | | | | |

## 기대 결과 및 해석

### 시나리오 A: 아트로핀 ≫ 대조군 (Best case)
- CHRM1에서는 모두 비슷 (모두 muscarinic ligand이므로)
- **Novel targets (3KYS, 5BRK, 3KFD)에서 아트로핀만 −7.0 이하, 대조군은 −6.0 이상**
- → "Atropine shows specific binding at Hippo-YAP targets"

### 시나리오 B: 아트로핀 ≈ Scopolamine > Caffeine
- Tropane 골격 공유 화합물은 비슷한 결합
- Caffeine은 현저히 약함
- → "Binding is related to tropane scaffold, not atropine-specific"
- → Discussion에서 "tropane alkaloids may share this property" 기술

### 시나리오 C: 모두 비슷 (Worst case)
- 아트로핀의 novel binding이 non-specific
- → Docking section을 "exploratory" + "preliminary"로 대폭 하향 조정
- → 여전히 네트워크 + MR로 논문은 유지 가능

## 본문 삽입 위치

### Results 3.8에 추가할 문단:
```
To assess binding specificity, three control compounds — scopolamine
(a structurally related tropane alkaloid muscarinic antagonist),
tropicamide (a non-tropane muscarinic antagonist), and caffeine
(a structurally dissimilar xanthine derivative) — were docked against
the same four targets using identical CB-Dock2 parameters
(Supplementary Table S4). At the positive control CHRM1, all three
muscarinic antagonists (atropine, scopolamine, tropicamide) showed
comparable binding energies (−X.X to −X.X kcal/mol), as expected.
At the novel Hippo-YAP targets (YAP-TEAD, MOB1-LATS1, TGFβ1R),
atropine showed [stronger/comparable/weaker] binding compared with
[scopolamine/tropicamide/caffeine], suggesting that the predicted
binding is [specific to atropine / shared among tropane alkaloids /
non-specific].
```

### Supplementary Table S4 헤더:
| Compound | MW | Target (PDB) | Vina Score | Cavity Volume | Binding Specificity |
|----------|-----|-------------|-----------|--------------|-------------------|

## Drug-Like Binding Threshold 문헌 근거 (리뷰어 요구)

−7.0 kcal/mol 근거:
- Pagadala NS, Syed K, Tuszynski J. Software for molecular docking: a review. *Biophys Rev* 2017;9:91-102.
  → "Compounds with binding energies below −7.0 kcal/mol are generally considered to have drug-like binding affinity"
- Shityakov S, Förster C. In silico predictive model to determine vector-mediated transport properties. *Adv Appl Bioinform Chem* 2014;7:23-30.
  → Used −7.0 as cut-off for BBB-permeable drug candidates
