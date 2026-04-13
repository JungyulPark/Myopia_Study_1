import os
import glob
import pydicom
import numpy as np
import matplotlib.pyplot as plt
import csv
from pathlib import Path

def apply_window_ct(img, ds, wc=40, ww=350):
    """Apply soft tissue window for CT."""
    if hasattr(ds, 'RescaleSlope') and hasattr(ds, 'RescaleIntercept'):
        img = img * ds.RescaleSlope + ds.RescaleIntercept
        
    wl = wc - ww / 2
    wu = wc + ww / 2
    
    img = np.clip(img, wl, wu)
    img = (img - wl) / (wu - wl) * 255.0
    return img.astype(np.uint8)

def apply_window_mri(img):
    """Apply 1-99% percentile normalization for MRI."""
    # Ignore absolute zeros often found in borders
    valid_pixels = img[img > 0]
    if len(valid_pixels) == 0:
        return np.zeros_like(img, dtype=np.uint8)
        
    p1, p99 = np.percentile(valid_pixels, (1, 99))
    if p99 == p1:
        img_norm = np.zeros_like(img)
    else:
        img_norm = np.clip(img, p1, p99)
        img_norm = (img_norm - p1) / (p99 - p1) * 255.0
        
    return img_norm.astype(np.uint8)

def process_cases():
    cases = ['R10084', 'R10090', 'R10195', 'R10442', 'R10501', 'R10603', 'R10710', 'R10816', 'R10909']
    base_dir = r"D:\0613_추출데이터\01.영상촬영일회성"
    out_dir = r"c:\Projectbulid\LLM_foundation\data\missed_lymphoma_images"
    best_dir = os.path.join(out_dir, "best_slices")
    
    os.makedirs(out_dir, exist_ok=True)
    os.makedirs(best_dir, exist_ok=True)
    
    summary = []
    
    # Pre-find all folders
    all_dirs = [os.path.join(base_dir, d) for d in os.listdir(base_dir) if os.path.isdir(os.path.join(base_dir, d))]
    
    for case in cases:
        # Step 1: Find folder
        target_dirs = [d for d in all_dirs if case in d]
        if not target_dirs:
            summary.append({"case": case, "status": "Folder Not Found", "modality": "", "series": 0, "slices": 0})
            continue
            
        case_dir = target_dirs[0]
        
        # Gather all DICOMs
        dicom_files = glob.glob(os.path.join(case_dir, "**", "*.dcm"), recursive=True)
        if not dicom_files:
            summary.append({"case": case, "status": "No DICOMs", "modality": "", "series": 0, "slices": 0})
            continue
            
        # Group by Series Instance UID
        series_dict = {}
        for f in dicom_files:
            try:
                ds = pydicom.dcmread(f, stop_before_pixels=True)
                # Keep only axial
                desc = getattr(ds, 'SeriesDescription', '').lower()
                modality = getattr(ds, 'Modality', '')
                suid = ds.SeriesInstanceUID
                
                # Check orientation
                if hasattr(ds, 'ImageOrientationPatient'):
                    iop = np.round(ds.ImageOrientationPatient)
                    # Axial is roughly [1,0,0, 0,1,0]
                    if not (abs(iop[0]) == 1 and abs(iop[4]) == 1):
                         continue # Skip non-axial
                         
                if suid not in series_dict:
                    series_dict[suid] = {"desc": desc, "modality": modality, "files": []}
                series_dict[suid]["files"].append(f)
            except Exception:
                pass
                
        # Select best series (prefer "orbit" or "axial", prefer max slice count if multiple)
        best_suid = None
        best_score = -1
        
        for suid, info in series_dict.items():
            score = len(info["files"])
            if "orbit" in info["desc"]:
                score += 1000
            if "ax" in info["desc"]:
                score += 500
            # penalize scouts
            if "scout" in info["desc"] or "local" in info["desc"] or score < 10:
                continue
                
            if score > best_score:
                best_score = score
                best_suid = suid
                
        if not best_suid:
            summary.append({"case": case, "status": "No Axial Series Found", "modality": "", "series": len(series_dict), "slices": 0})
            continue
            
        # Step 2: Extract slices
        selected_info = series_dict[best_suid]
        modality = selected_info["modality"]
        series_files = selected_info["files"]
        
        # Load fully
        slices = []
        for f in series_files:
            try:
                ds = pydicom.dcmread(f)
                z = ds.ImagePositionPatient[2]
                slices.append((z, ds))
            except:
                pass
                
        slices.sort(key=lambda x: x[0]) # Superior to inferior or vice versa
        
        n_slices = len(slices)
        
        # We want lower 30% - 50%
        # Usually smaller Z is inferior. So indices 30% to 50%
        # If head first supine, smaller Z is inferior.
        start_idx = int(n_slices * 0.3)
        end_idx = int(n_slices * 0.5)
        
        if end_idx <= start_idx:
            summary.append({"case": case, "status": "Too Few Slices", "modality": modality, "series": len(series_dict), "slices": n_slices})
            continue
            
        # Pick 3 evenly spaced slices in this range
        step = max(1, (end_idx - start_idx) // 3)
        target_indices = list(range(start_idx, end_idx, step))[:3]
        
        if len(target_indices) < 2:
             # Just grab middle of stack if it's a very short stack like an orbit-only MRI
             mid = n_slices // 2
             target_indices = [max(0, mid-1), mid, min(n_slices-1, mid+1)]
             
        # Step 3: Save images
        best_slice_idx = target_indices[len(target_indices)//2]
        
        for i, idx in enumerate(target_indices):
            z, ds = slices[idx]
            img = ds.pixel_array
            
            if modality == "CT":
                out_img = apply_window_ct(img, ds)
            else:
                out_img = apply_window_mri(img)
                
            out_filename = f"{case}_slice{i+1}.png"
            out_path = os.path.join(out_dir, out_filename)
            plt.imsave(out_path, out_img, cmap='gray')
            
            if idx == best_slice_idx:
                best_path = os.path.join(best_dir, f"{case}_best.png")
                plt.imsave(best_path, out_img, cmap='gray')
                
        summary.append({
            "case": case, 
            "status": "Success", 
            "modality": modality, 
            "series": len(series_dict), 
            "slices": n_slices
        })
        
    # Step 4: Summary
    print("="*60)
    print("EXTRACTION SUMMARY")
    for s in summary:
        print(f"[{s['case']}] {s['status']} | Modality: {s['modality']} | Series: {s['series']} | Total Slices in Best Series: {s['slices']}")
        
    print("\nFiles in best_slices/:")
    for f in sorted(os.listdir(best_dir)):
        print(" - " + f)

if __name__ == "__main__":
    process_cases()
