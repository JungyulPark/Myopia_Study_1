"""
01_prepare_data.py
==================
Reads the orbital CT/MRI radiology report Excel file,
applies preprocessing rules, and outputs a clean JSON cohort file.
"""

import json
import re
import sys
from pathlib import Path

import pandas as pd

# ── paths ──────────────────────────────────────────────────────────────
ROOT = Path(__file__).resolve().parent.parent
EXCEL_FILES = list(ROOT.glob("SR*.xlsx"))
if not EXCEL_FILES:
    sys.exit("ERROR: No SR*.xlsx file found in project root.")
EXCEL_PATH = EXCEL_FILES[0]
OUTPUT_PATH = ROOT / "data" / "study_cohort.json"
OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)

SHEET_NAME = "데이터_영상촬영 일회성"

# ── diagnosis mapping ──────────────────────────────────────────────────
DIAG_MAP = {
    "갑상선 눈병증": "thyroid_eye_disease",
    "안와림프종": "orbital_lymphoma",
    "가성종양": "pseudotumor",
    "양성종양": "benign_tumor",
    "안와질환": "orbital_disease_other",
    "해면혈관종": "cavernous_hemangioma",
    "메닌지오마": "meningioma",
    "다형샘종": "pleomorphic_adenoma",
    "림프관종": "lymphangioma",
    "안와 악성종양": "orbital_malignancy",
    "IgG4 관련질환": "igg4_related_disease",
}

# keywords that flag an orbital biopsy (case-insensitive check)
ORBITAL_BX_KEYWORDS = [
    "orbit", "eyelid", "conjunctiv", "lacrimal", "retrobulbar",
    "periorbital", "lid,", "lid ", "eye,", "eye ",
]

# uninformative report patterns (case-insensitive)
UNINFORMATIVE_PHRASES = [
    "unremarkable finding",
    "no definite abnormal",
    "no remarkable finding",
    "no abnormality",
    "negative finding",
]

# ── helper functions ───────────────────────────────────────────────────

def map_diagnosis(raw: str) -> tuple[str, str]:
    """Return (english_mapped, korean_first_diagnosis).
    For complex multi-diagnosis, use the first one."""
    if not raw or str(raw).strip() == "":
        return "unknown", ""
    raw = str(raw).strip()
    # multi-diagnosis: split by newline
    first_kr = raw.split("\n")[0].strip()
    # try direct match first
    if first_kr in DIAG_MAP:
        return DIAG_MAP[first_kr], first_kr
    # otherwise try partial match
    for kr, en in DIAG_MAP.items():
        if kr in first_kr:
            return en, first_kr
    return "unknown", first_kr


def is_orbital_biopsy(biopsy_result_text: str) -> bool:
    """Check if biopsy result text indicates an orbital biopsy."""
    if not biopsy_result_text:
        return False
    text_lower = biopsy_result_text.lower()
    return any(kw in text_lower for kw in ORBITAL_BX_KEYWORDS)


def is_uninformative(report: str) -> bool:
    """Flag reports that are too short or contain uninformative phrases."""
    if len(report) < 60:
        return True
    report_lower = report.lower()
    return any(phrase in report_lower for phrase in UNINFORMATIVE_PHRASES)


def deidentify_report(report: str) -> str:
    """Remove dates, IDs, and name patterns from report text."""
    # Dates: YYYY-MM-DD, YYYYMMDD, YYYY.MM.DD
    text = re.sub(r"\d{4}[-/.]\d{2}[-/.]\d{2}", "[DATE]", report)
    text = re.sub(r"\b\d{8}\b", "[DATE]", text)
    # R + 5 digits (patient IDs)
    text = re.sub(r"R\d{5}", "[ID]", text)
    # Korean name + ** pattern (e.g. 김**, 이**)
    text = re.sub(r"[가-힣]{1,4}\*{2}", "[NAME]", text)
    return text


# ── main ───────────────────────────────────────────────────────────────

def main():
    print(f"Reading: {EXCEL_PATH.name}")
    print(f"Sheet  : {SHEET_NAME}")

    # Read sheet; first row = Korean headers, second row = English headers
    df_raw = pd.read_excel(EXCEL_PATH, sheet_name=SHEET_NAME, header=None)
    
    # Row 0 = Korean headers, Row 1 = English headers
    en_headers = df_raw.iloc[0].tolist()  # Korean headers as index 0
    kr_headers = df_raw.iloc[0].tolist()
    en_headers = df_raw.iloc[1].tolist()  # English headers as index 1
    
    # Data starts from row 2
    df = df_raw.iloc[2:].reset_index(drop=True)
    df.columns = en_headers
    
    print(f"Raw data rows: {len(df)}")
    print(f"Columns: {list(df.columns)}")

    # ── Exclusion: PET-CT ──
    pet_mask = df["IMG_TYPE"].astype(str).str.contains("PET", case=False, na=False)
    n_pet = pet_mask.sum()
    df = df[~pet_mask].reset_index(drop=True)
    print(f"Excluded PET-CT rows: {n_pet}  →  Remaining: {len(df)}")

    # ── Exclusion: missing or very short reports ──
    df["IMG_RSLT"] = df["IMG_RSLT"].astype(str)
    short_mask = df["IMG_RSLT"].str.len() < 20
    na_mask = df["IMG_RSLT"].isin(["None", "nan", ""])
    exclude_report = short_mask | na_mask
    n_short = exclude_report.sum()
    df = df[~exclude_report].reset_index(drop=True)
    print(f"Excluded short/missing reports: {n_short}  →  Remaining: {len(df)}")

    # ── Build cohort ──
    cohort = []
    for idx, row in df.iterrows():
        case_id = str(row["RID"]).strip()
        img_type = str(row["IMG_TYPE"]).strip()
        report_raw = str(row["IMG_RSLT"]).strip()
        diag_raw = str(row.get("DIAG_GRP", "")).strip()  # Korean diagnosis group
        biopsy_yn = row.get("BIOPSY_YN")
        biopsy_result_raw = str(row.get("BIOPSY_RSLT", "") or "").replace("_x000D_", "\n").strip()

        # Deidentify report
        report = deidentify_report(report_raw)

        # Diagnosis mapping
        diag_en, diag_kr = map_diagnosis(diag_raw)

        # Biopsy encoding: 0 = 시행, 1 = 미시행
        biopsy_performed = (int(float(biopsy_yn)) == 0) if pd.notna(biopsy_yn) else False

        # Orbital biopsy: only count if biopsy was performed AND result is orbital
        orbital_bx = 0
        if biopsy_performed:
            if is_orbital_biopsy(biopsy_result_raw):
                orbital_bx = 1
            else:
                orbital_bx = 0  # non-orbital biopsy (e.g. breast, stomach)

        # Uninformative flag
        uninformative = is_uninformative(report)

        cohort.append({
            "case_id": case_id,
            "img_type": img_type,
            "report": report,
            "true_diagnosis_en": diag_en,
            "true_diagnosis_kr": diag_kr,
            "orbital_biopsy": orbital_bx,
            "uninformative": uninformative,
        })

    # ── Save ──
    OUTPUT_PATH.write_text(json.dumps(cohort, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"\nSaved {len(cohort)} cases → {OUTPUT_PATH}")

    # ── Summary statistics ──
    n_bx = sum(1 for c in cohort if c["orbital_biopsy"] == 1)
    n_no_bx = sum(1 for c in cohort if c["orbital_biopsy"] == 0)
    n_uninf = sum(1 for c in cohort if c["uninformative"])
    n_inf = sum(1 for c in cohort if not c["uninformative"])

    diag_counts = {}
    for c in cohort:
        d = c["true_diagnosis_en"]
        diag_counts[d] = diag_counts.get(d, 0) + 1

    print(f"\n{'='*50}")
    print(f"COHORT SUMMARY")
    print(f"{'='*50}")
    print(f"Total cases:        {len(cohort)}")
    print(f"Orbital biopsy=1:   {n_bx} ({100*n_bx/len(cohort):.1f}%)")
    print(f"Orbital biopsy=0:   {n_no_bx} ({100*n_no_bx/len(cohort):.1f}%)")
    print(f"Informative:        {n_inf}")
    print(f"Uninformative:      {n_uninf}")
    print(f"\nDiagnosis distribution:")
    for d, c in sorted(diag_counts.items(), key=lambda x: -x[1]):
        print(f"  {d:30s}  {c:4d}")


if __name__ == "__main__":
    main()
