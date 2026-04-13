import os
import sys
import glob
import numpy as np
from pathlib import Path

try:
    import pydicom
except ImportError:
    print("pydicom 설치 필요: pip install pydicom")
    sys.exit(1)

try:
    from PIL import Image
except ImportError:
    print("Pillow 설치 필요: pip install Pillow")
    sys.exit(1)


# ============================================================
# 설정
# ============================================================
BASE_DIR = r"D:\0613_추출데이터\01.영상촬영일회성"
OUTPUT_DIR = r"c:\Projectbulid\LLM_foundation\data\missed_lymphoma_images_v2"

TARGET_CASES = [
    "R10084", "R10090", "R10195", "R10442",
    "R10501", "R10603", "R10710", "R10816", "R10909"
]

NUM_SLICES = 3  # 케이스당 추출할 슬라이스 수


# ============================================================
# 유틸리티 함수
# ============================================================

def find_case_folder(base_dir: str, case_id: str):
    matches = glob.glob(os.path.join(base_dir, f"{case_id}_*"))
    if matches:
        return matches[0]
    return None

def collect_dcm_by_series(case_folder: str):
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
            if not hasattr(ds, 'pixel_data') and not hasattr(ds, 'PixelData'):
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
        except Exception:
            pass
    slices.sort(key=lambda x: x[0])
    return slices

def apply_window(pixel_array, ds):
    arr = pixel_array.astype(np.float64)
    slope = getattr(ds, 'RescaleSlope', 1.0)
    intercept = getattr(ds, 'RescaleIntercept', 0.0)
    arr = arr * float(slope) + float(intercept)

    modality = getattr(ds, 'Modality', 'CT').upper()

    if modality == 'CT':
        # Soft tissue window: center=40, width=350 
        wc, ww = 40, 350
        vmin = wc - ww / 2
        vmax = wc + ww / 2
        arr = np.clip(arr, vmin, vmax)
        arr = (arr - vmin) / (vmax - vmin) * 255
    else:
        # MRI
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

def detect_globe_score(pixel_array, ds):
    arr = pixel_array.astype(np.float64)
    slope = getattr(ds, 'RescaleSlope', 1.0)
    intercept = getattr(ds, 'RescaleIntercept', 0.0)
    arr = arr * float(slope) + float(intercept)

    h, w = arr.shape
    scores = []
    
    # Try both top half and bottom half just in case anterior is down
    for region in [arr[:h//2, :], arr[h//2:, :]]:
        left_region = region[:, w//4:w//2]
        right_region = region[:, w//2:3*w//4]

        if left_region.size == 0 or right_region.size == 0:
            scores.append(0.0)
            continue

        left_var = np.std(left_region)
        right_var = np.std(right_region)
        score = np.sqrt(left_var * right_var)

        left_mean = np.mean(left_region)
        right_mean = np.mean(right_region)
        if max(left_mean, right_mean) > 0:
            symmetry = 1.0 - abs(left_mean - right_mean) / max(left_mean, right_mean)
        else:
            symmetry = 0.0

        score *= (0.5 + 0.5 * symmetry)
        scores.append(score)

    return max(scores)

def detect_orbital_range(slices):
    if len(slices) <= NUM_SLICES:
        return list(range(len(slices)))

    scores = []
    for i, (z, arr, ds) in enumerate(slices):
        try:
            score = detect_globe_score(arr, ds)
        except Exception:
            score = 0.0
        scores.append(score)

    scores = np.array(scores)
    threshold = scores.max() * 0.5 if scores.max() > 0 else 0
    orbital_indices = np.where(scores >= threshold)[0]

    if len(orbital_indices) == 0:
        n = len(slices)
        orbital_indices = np.arange(n // 3, 2 * n // 3)

    if len(orbital_indices) <= NUM_SLICES:
        return orbital_indices.tolist()

    idx_start = orbital_indices[0]
    idx_end = orbital_indices[-1]
    span = idx_end - idx_start

    selected = []
    for i in range(NUM_SLICES):
        target = idx_start + int(span * i / (NUM_SLICES - 1))
        closest = orbital_indices[np.argmin(np.abs(orbital_indices - target))]
        if closest not in selected:
            selected.append(closest)
        else:
            remaining = [idx for idx in orbital_indices if idx not in selected]
            if remaining:
                closest = min(remaining, key=lambda x: abs(x - target))
                selected.append(closest)

    selected.sort()
    return selected

def save_slice_as_png(pixel_array, ds, output_path):
    img_arr = apply_window(pixel_array, ds)
    img = Image.fromarray(img_arr)
    if img.width < 256 or img.height < 256:
        img = img.resize((512, 512), Image.LANCZOS)
    img.save(output_path)

def main():
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    best_dir = os.path.join(OUTPUT_DIR, "best_slices")
    os.makedirs(best_dir, exist_ok=True)

    print("=" * 60)
    print("안와 LLM 연구 - Missed Lymphoma DICOM→PNG 추출 (v2 - Globe Detection)")
    print("=" * 60)

    for case_id in TARGET_CASES:
        case_folder = find_case_folder(BASE_DIR, case_id)
        if not case_folder:
            print(f"[{case_id}] FOLDER_NOT_FOUND")
            continue

        series_dict = collect_dcm_by_series(case_folder)
        best_key, best_files = pick_best_series(series_dict)
        if not best_files:
            print(f"[{case_id}] NO_VALID_SERIES")
            continue
            
        slices = read_dicom_slices(best_files)
        if not slices:
            print(f"[{case_id}] READ_FAILED")
            continue

        selected_indices = detect_orbital_range(slices)
        
        for slice_num, idx in enumerate(selected_indices, 1):
            z, arr, ds = slices[idx]
            filename = f"{case_id}_slice{slice_num}.png"
            output_path = os.path.join(OUTPUT_DIR, filename)
            save_slice_as_png(arr, ds, output_path)
            
            # Save the middle slice to best_slices
            if slice_num == 2:
                best_path = os.path.join(best_dir, f"{case_id}_best.png")
                save_slice_as_png(arr, ds, best_path)
                
        print(f"[{case_id}] OK ({len(selected_indices)}장) - Orbital Indices: {selected_indices}/{len(slices)}")

if __name__ == "__main__":
    main()
