import os, sys, glob, math
import numpy as np

try:
    import pydicom
except ImportError:
    print("pip install pydicom"); sys.exit(1)
try:
    from PIL import Image, ImageDraw
except ImportError:
    print("pip install Pillow"); sys.exit(1)

# ============================================================
# 설정
# ============================================================
BASE_DIR = r"D:\0613_추출데이터\01.영상촬영일회성"
OUTPUT_DIR = r"c:\Projectbulid\LLM_foundation\data\missed_lymphoma_images_v3"
MONTAGE_DIR = r"c:\Projectbulid\LLM_foundation\data\missed_lymphoma_montage"

# 안와 확인된 7건: (case_id, start_idx, end_idx)
CONFIRMED_CASES = {
    "R10084": (26, 58),
    "R10090": (9, 21),
    "R10195": (13, 27),
    "R10603": (59, 68),
    "R10710": (14, 34),
    "R10816": (23, 78),
    "R10909": (19, 69),
}

# 재확인 필요 케이스
REDO_CASES = ["R10442", "R10501"]

THUMB_SIZE = 150
COLS = 8
NUM_SLICES = 3


# ============================================================
# 공통 함수
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
        except:
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
        valid = arr[arr > 0]
        if len(valid) == 0:
            return np.zeros_like(arr, dtype=np.uint8)
        p1, p99 = np.percentile(valid, [1, 99])
        if p99 > p1:
            arr = np.clip(arr, p1, p99)
            arr = (arr - p1) / (p99 - p1) * 255
        else:
            arr = np.zeros_like(arr)
    return arr.astype(np.uint8)

def save_slice(arr, ds, output_path):
    img_arr = apply_window(arr, ds)
    img = Image.fromarray(img_arr)
    if img.width < 256:
        img = img.resize((512, 512), Image.LANCZOS)
    img.save(output_path)


# ============================================================
# Step 1: 확인된 7건 추출
# ============================================================

def run_extract():
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    print("=" * 60)
    print("확인된 7건 추출 (상/중/하 3장씩)")
    print("=" * 60)

    for case_id, (start, end) in CONFIRMED_CASES.items():
        print(f"\n[{case_id}] 범위 #{start}~#{end}")

        case_folder = find_case_folder(BASE_DIR, case_id)
        if not case_folder:
            print(f"  [ERROR] 폴더 못 찾음"); continue

        series_dict = collect_dcm_by_series(case_folder)
        best_key, best_files = pick_best_series(series_dict)
        if not best_files:
            continue
            
        slices = read_dicom_slices(best_files)

        if end >= len(slices):
            print(f"  [WARN] end={end} > 총 슬라이스 {len(slices)}, 조정")
            end = len(slices) - 1

        # 범위 내에서 균등 3장: 상(anterior/inferior), 중간, 하(posterior/superior)
        span = end - start
        indices = [
            start + span // 6,           # 상단 1/6 지점
            start + span // 2,            # 중간
            start + span * 5 // 6,        # 하단 5/6 지점
        ]

        for slice_num, idx in enumerate(indices, 1):
            idx = min(idx, len(slices) - 1)
            z, arr, ds = slices[idx]
            filename = f"{case_id}_slice{slice_num}.png"
            output_path = os.path.join(OUTPUT_DIR, filename)
            save_slice(arr, ds, output_path)
            print(f"  저장: {filename} (idx={idx}/{len(slices)-1}, z={z:.1f})")

    print(f"\n7건 추출 완료 → {OUTPUT_DIR}")


# ============================================================
# Step 2: R10442, R10501 전 시리즈 개별 몽타주
# ============================================================

def run_remontage():
    os.makedirs(MONTAGE_DIR, exist_ok=True)
    print("=" * 60)
    print("R10442, R10501: 모든 시리즈 개별 몽타주 생성")
    print("=" * 60)

    for case_id in REDO_CASES:
        print(f"\n{'─'*50}")
        print(f"[{case_id}]")

        case_folder = find_case_folder(BASE_DIR, case_id)
        if not case_folder:
            print(f"  [ERROR] 폴더 못 찾음"); continue

        series_dict = collect_dcm_by_series(case_folder)
        print(f"  총 {len(series_dict)}개 시리즈:")

        for series_path, dcm_files in sorted(series_dict.items(), key=lambda x: len(x[1]), reverse=True):
            sname = os.path.basename(series_path)

            try:
                ds0 = pydicom.dcmread(dcm_files[0], force=True, stop_before_pixels=True)
                desc = getattr(ds0, 'SeriesDescription', '?')
                mod = getattr(ds0, 'Modality', '?')
                orient = getattr(ds0, 'ImageOrientationPatient', None)
                if orient:
                    orient_str = ','.join([f"{float(x):.1f}" for x in orient])
                else:
                    orient_str = '?'
            except:
                desc, mod, orient_str = '?', '?', '?'

            print(f"    Series '{sname}': {len(dcm_files)}장 [{mod}] {desc}")
            print(f"      Orientation: {orient_str}")

            if len(dcm_files) <= 2:
                print(f"      → scout, 스킵")
                continue

            slices = read_dicom_slices(dcm_files)
            if not slices:
                print(f"      → 읽기 실패, 스킵")
                continue

            n = len(slices)
            rows = math.ceil(n / COLS)
            cell_h = THUMB_SIZE + 18
            montage_w = COLS * THUMB_SIZE
            montage_h = rows * cell_h + 30

            montage = Image.new('L', (montage_w, montage_h), 0)
            draw = ImageDraw.Draw(montage)

            header = f"{case_id} | Series '{sname}' | {mod} | {desc} | {n}장 | Orient: {orient_str}"
            draw.text((5, 5), header, fill=255)

            for i, (z, arr, ds) in enumerate(slices):
                row = i // COLS
                col = i % COLS
                img_arr = apply_window(arr, ds)
                thumb = Image.fromarray(img_arr)
                thumb = thumb.resize((THUMB_SIZE, THUMB_SIZE), Image.LANCZOS)
                x = col * THUMB_SIZE
                y = 30 + row * cell_h
                montage.paste(thumb, (x, y))
                draw.text((x + 2, y + THUMB_SIZE + 1), f"#{i} z={z:.0f}", fill=200)

            out_path = os.path.join(MONTAGE_DIR, f"{case_id}_series{sname}_montage.png")
            montage.save(out_path)
            print(f"      → 몽타주 저장: {os.path.basename(out_path)}")

    print(f"\n몽타주 생성 완료 → {MONTAGE_DIR}")


# ============================================================

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("사용법:")
        print("  python orbital_final.py extract     # 7건 추출")
        print("  python orbital_final.py remontage   # R10442/R10501 시리즈별 몽타주")
        sys.exit(1)

    cmd = sys.argv[1].lower()
    if cmd == "extract":
        run_extract()
    elif cmd == "remontage":
        run_remontage()
    else:
        print(f"알 수 없는 명령: {cmd}")
