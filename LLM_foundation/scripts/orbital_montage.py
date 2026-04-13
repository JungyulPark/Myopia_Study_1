import os
import sys
import glob
import math
import numpy as np
from pathlib import Path

try:
    import pydicom
except ImportError:
    print("pip install pydicom"); sys.exit(1)
try:
    from PIL import Image, ImageDraw, ImageFont
except ImportError:
    print("pip install Pillow"); sys.exit(1)


# ============================================================
# 설정
# ============================================================
BASE_DIR = r"D:\0613_추출데이터\01.영상촬영일회성"
MONTAGE_DIR = r"c:\Projectbulid\LLM_foundation\data\missed_lymphoma_montage"
OUTPUT_DIR = r"c:\Projectbulid\LLM_foundation\data\missed_lymphoma_images_v3"

TARGET_CASES = [
    "R10084", "R10090", "R10195", "R10442",
    "R10501", "R10603", "R10710", "R10816", "R10909"
]

THUMB_SIZE = 150       # 썸네일 크기 (px)
COLS = 8               # 몽타주 열 수
LABEL_HEIGHT = 18      # 슬라이스 번호 라벨 높이

# ============================================================
# Step 2에서 사용: 몽타주 보고 안와가 보이는 슬라이스 번호 입력
# ============================================================
SELECTIONS = {
    "R10084": [26, 42, 58],  
    "R10090": [9, 15, 21],
    "R10195": [13, 20, 27],
    "R10442": [], # Abdomen
    "R10501": [48, 59, 70], # Sagittal
    "R10603": [59, 63, 68],
    "R10710": [14, 24, 34],
    "R10816": [23, 50, 78],
    "R10909": [19, 44, 69],
}


# ============================================================
# 유틸리티 (v2에서 재사용)
# ============================================================

def find_case_folder(base_dir, case_id):
    matches = glob.glob(os.path.join(base_dir, f"{case_id}_*"))
    return matches[0] if matches else None


def collect_dcm_by_series(case_folder):
    series_dict = {}
    for root, dirs, files in os.walk(case_folder):
        dcm_files = [os.path.join(root, f) for f in files if f.endswith('.dcm')]
        if dcm_files:
            series_dict[root] = dcm_files
    return series_dict


def pick_best_series(series_dict):
    candidates = {k: v for k, v in series_dict.items() if len(v) >= 4}
    if not candidates:
        candidates = series_dict
    if not candidates:
        return None, []
    best_key = max(candidates, key=lambda k: len(candidates[k]))
    return best_key, candidates[best_key]


def read_dicom_slices(dcm_files):
    slices = []
    for fp in dcm_files:
        try:
            ds = pydicom.dcmread(fp, force=True)
            if not hasattr(ds, 'PixelData'):
                continue
            arr = ds.pixel_array
            if hasattr(ds, 'ImagePositionPatient') and ds.ImagePositionPatient:
                z = float(ds.ImagePositionPatient[2])
            elif hasattr(ds, 'SliceLocation'):
                z = float(ds.SliceLocation)
            elif hasattr(ds, 'InstanceNumber'):
                z = float(ds.InstanceNumber)
            else:
                z = 0.0
            slices.append((z, arr, ds))
        except Exception as e:
            continue
    slices.sort(key=lambda x: x[0])
    return slices


def apply_window(arr, ds):
    arr = arr.astype(np.float64)
    slope = float(getattr(ds, 'RescaleSlope', 1.0))
    intercept = float(getattr(ds, 'RescaleIntercept', 0.0))
    arr = arr * slope + intercept

    modality = getattr(ds, 'Modality', 'CT').upper()
    if modality == 'CT':
        wc, ww = 50, 350
        vmin, vmax = wc - ww/2, wc + ww/2
        arr = np.clip(arr, vmin, vmax)
        arr = (arr - vmin) / (vmax - vmin) * 255
    else:
        p1, p99 = np.percentile(arr, [1, 99])
        if p99 > p1:
            arr = np.clip(arr, p1, p99)
            arr = (arr - p1) / (p99 - p1) * 255
        else:
            arr = np.zeros_like(arr)
    return arr.astype(np.uint8)


# ============================================================
# Step 1: 몽타주 생성
# ============================================================

def create_montage(case_id, slices, output_dir):
    """전체 슬라이스를 썸네일 그리드로 만들어 저장"""
    n = len(slices)
    rows = math.ceil(n / COLS)
    cell_h = THUMB_SIZE + LABEL_HEIGHT

    montage_w = COLS * THUMB_SIZE
    montage_h = rows * cell_h

    montage = Image.new('L', (montage_w, montage_h), 0)
    draw = ImageDraw.Draw(montage)

    modality = getattr(slices[0][2], 'Modality', '?')

    for i, (z, arr, ds) in enumerate(slices):
        row = i // COLS
        col = i % COLS

        # 썸네일 생성
        img_arr = apply_window(arr, ds)
        thumb = Image.fromarray(img_arr)
        thumb = thumb.resize((THUMB_SIZE, THUMB_SIZE), Image.LANCZOS)

        x = col * THUMB_SIZE
        y = row * cell_h

        montage.paste(thumb, (x, y))

        # 슬라이스 번호 라벨
        label = f"#{i} z={z:.0f}"
        draw.text((x + 2, y + THUMB_SIZE + 1), label, fill=200)

    # 상단에 케이스 정보 추가
    info_bar = Image.new('L', (montage_w, 30), 40)
    info_draw = ImageDraw.Draw(info_bar)
    info_text = f"{case_id} | {modality} | {n} slices | 안와가 보이는 번호를 메모하세요"
    info_draw.text((5, 5), info_text, fill=255)

    final = Image.new('L', (montage_w, montage_h + 30), 0)
    final.paste(info_bar, (0, 0))
    final.paste(montage, (0, 30))

    output_path = os.path.join(output_dir, f"{case_id}_montage.png")
    final.save(output_path)
    print(f"  몽타주 저장: {output_path} ({n}장, {rows}행×{COLS}열)")
    return output_path


def run_montage():
    """Step 1: 모든 케이스의 몽타주 생성"""
    os.makedirs(MONTAGE_DIR, exist_ok=True)

    print("=" * 60)
    print("Step 1: 몽타주 생성")
    print("=" * 60)

    for case_id in TARGET_CASES:
        print(f"\n[{case_id}]")
        case_folder = find_case_folder(BASE_DIR, case_id)
        if not case_folder:
            print(f"  [ERROR] 폴더 못 찾음")
            continue

        series_dict = collect_dcm_by_series(case_folder)
        if not series_dict:
            print(f"  [ERROR] DICOM 없음")
            continue

        # 모든 시리즈 정보 출력
        print(f"  시리즈 목록:")
        all_series_info = []
        for k, v in sorted(series_dict.items(), key=lambda x: len(x[1]), reverse=True):
            sname = os.path.basename(k)
            # 첫 파일에서 시리즈 설명 읽기
            try:
                ds0 = pydicom.dcmread(v[0], force=True, stop_before_pixels=True)
                desc = getattr(ds0, 'SeriesDescription', '?')
                mod = getattr(ds0, 'Modality', '?')
            except:
                desc, mod = '?', '?'
            print(f"    Series '{sname}': {len(v)}장 [{mod}] {desc}")
            all_series_info.append((k, v, sname, desc, mod))

        # 최다 슬라이스 시리즈 선택
        best_key, best_files = pick_best_series(series_dict)
        if not best_files:
            continue
        print(f"  → 선택: '{os.path.basename(best_key)}' ({len(best_files)}장)")

        slices = read_dicom_slices(best_files)
        if not slices:
            print(f"  [ERROR] 읽기 실패")
            continue

        create_montage(case_id, slices, MONTAGE_DIR)

    print(f"\n{'='*60}")
    print(f"몽타주 생성 완료!")
    print(f"폴더: {MONTAGE_DIR}")
    print(f"\n[다음 단계]")
    print(f"1. 몽타주 이미지를 열어서 안와가 보이는 슬라이스 번호(#N)를 확인")
    print(f"2. 이 스크립트의 SELECTIONS 딕셔너리에 번호 입력")
    print(f"3. python orbital_montage.py extract 실행")


# ============================================================
# Step 2: 선택된 슬라이스 추출
# ============================================================

def run_extract():
    """Step 2: SELECTIONS에 지정된 슬라이스를 풀사이즈 PNG로 추출"""
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    print("=" * 60)
    print("Step 2: 선택 슬라이스 추출")
    print("=" * 60)

    empty = [k for k, v in SELECTIONS.items() if not v]
    if empty:
        print(f"\n[WARNING] 아직 선택 안 된 케이스: {empty}")
        print(f"SELECTIONS 딕셔너리에 슬라이스 번호를 입력해주세요.")
        if len(empty) == len(SELECTIONS):
            return

    for case_id in TARGET_CASES:
        indices = SELECTIONS.get(case_id, [])
        if not indices:
            print(f"\n[{case_id}] 건너뜀 (선택 없음)")
            continue

        print(f"\n[{case_id}] 슬라이스 {indices} 추출")
        case_folder = find_case_folder(BASE_DIR, case_id)
        if not case_folder:
            print(f"  [ERROR] 폴더 못 찾음")
            continue

        series_dict = collect_dcm_by_series(case_folder)
        best_key, best_files = pick_best_series(series_dict)
        if not best_files:
            print("  [ERROR] DICOM 없음")
            continue
            
        slices = read_dicom_slices(best_files)

        for slice_num, idx in enumerate(indices, 1):
            if idx < 0 or idx >= len(slices):
                print(f"  [ERROR] 인덱스 {idx} 범위 초과 (0~{len(slices)-1})")
                continue

            z, arr, ds = slices[idx]
            img_arr = apply_window(arr, ds)
            img = Image.fromarray(img_arr)
            if img.width < 256:
                img = img.resize((512, 512), Image.LANCZOS)

            filename = f"{case_id}_slice{slice_num}.png"
            output_path = os.path.join(OUTPUT_DIR, filename)
            img.save(output_path)
            print(f"  저장: {filename} (idx={idx}, z={z:.1f})")

    print(f"\n추출 완료! → {OUTPUT_DIR}")


# ============================================================
# 메인
# ============================================================

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("사용법:")
        print("  python orbital_montage.py montage   # Step 1: 몽타주 생성")
        print("  python orbital_montage.py extract    # Step 2: 슬라이스 추출")
        sys.exit(1)

    cmd = sys.argv[1].lower()
    if cmd == "montage":
        run_montage()
    elif cmd == "extract":
        run_extract()
    else:
        print(f"알 수 없는 명령: {cmd}")
        print("montage 또는 extract를 사용하세요.")
