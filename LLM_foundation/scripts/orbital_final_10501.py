import os, glob
import numpy as np
import pydicom
from PIL import Image

BASE_DIR = r"D:\0613_추출데이터\01.영상촬영일회성"
OUTPUT_DIR = r"c:\Projectbulid\LLM_foundation\data\missed_lymphoma_images_v3"

def force_extract(case_id, series_str, target_indices):
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    
    matches = glob.glob(os.path.join(BASE_DIR, f"{case_id}_*"))
    if not matches:
        print(f"Folder not found for {case_id}")
        return
    case_folder = matches[0]
    
    series_dcm = []
    # Identify exact series folder
    for root, dirs, files in os.walk(case_folder):
        if os.path.basename(root) == series_str:
            dcm_files = [os.path.join(root, f) for f in files if f.endswith('.dcm')]
            if dcm_files:
                series_dcm = dcm_files
                break
                
    if not series_dcm:
        print(f"Series '{series_str}' not found")
        return
        
    slices = []
    for fp in series_dcm:
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
    
    for slice_num, idx in enumerate(target_indices, 1):
        if idx >= len(slices):
            idx = len(slices) - 1
            
        z, arr, ds = slices[idx]
        
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
                
        img_arr = arr.astype(np.uint8)
        img = Image.fromarray(img_arr)
        if img.width < 256:
            img = img.resize((512, 512), Image.LANCZOS)
            
        filename = f"{case_id}_slice{slice_num}.png"
        output_path = os.path.join(OUTPUT_DIR, filename)
        img.save(output_path)
        print(f"Saved: {filename} from Series {series_str} Index {idx}")

if __name__ == '__main__':
    # Range: 124 to 162
    # Span: 38
    # Evenly spaced slices: 130, 143, 155
    indices = [130, 143, 155]
    force_extract("R10501", "7", indices)
