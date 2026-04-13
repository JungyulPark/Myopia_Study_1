import os
import glob
import pydicom
import numpy as np
import matplotlib.pyplot as plt
from pathlib import Path

def apply_window(img, wc=40, ww=350):
    """Apply soft tissue window."""
    wl = wc - ww / 2
    wu = wc + ww / 2
    
    img = np.clip(img, wl, wu)
    img = (img - wl) / (wu - wl) * 255.0
    return img.astype(np.uint8)

def extract_globe_slices():
    dicom_dir = "c:/Projectbulid/LLM_foundation/DCOM/R10001_RCHA40201G_2019-06-27"
    out_dir = "c:/Projectbulid/LLM_foundation/figures/pilot_images"
    os.makedirs(out_dir, exist_ok=True)
    
    # 1. Load all DICOM files
    files = glob.glob(f"{dicom_dir}/**/*.dcm", recursive=True)
    if not files:
        print("No DICOM files found.")
        return
        
    slices = []
    for f in files:
        try:
            ds = pydicom.dcmread(f)
            # Only keep structural CT (ignore localizers/scouts)
            if hasattr(ds, 'ImagePositionPatient'):
                z = ds.ImagePositionPatient[2]
                slices.append((z, ds))
        except Exception as e:
            pass
            
    if not slices:
        print("No valid CT slices found.")
        return
        
    # Sort by Z-position (head to foot or foot to head)
    # usually smaller Z is inferior, larger Z is superior
    slices.sort(key=lambda x: x[0])
    
    print(f"Loaded {len(slices)} valid axial slices.")
    
    # 2. To find the globe, we want slices where the eyes are visible.
    # The scan likely includes the whole brain and orbits. 
    # Orbits are typically in the lower third or middle-lower section.
    # Let's try slices around 35%-45% of the way from the inferior-most slice.
    
    start_idx = int(len(slices) * 0.35)
    end_idx = int(len(slices) * 0.45)
    
    # Pick 5 evenly spaced slices in this range
    step = max(1, (end_idx - start_idx) // 5)
    indices = list(range(start_idx, end_idx, step))[:5]
    
    # Keep them within bounds
    indices = [i for i in indices if 0 <= i < len(slices)]
    
    for i, idx in enumerate(indices):
        z_pos, ds = slices[idx]
        
        # Convert to Hounsfield Units (HU)
        img = ds.pixel_array
        if hasattr(ds, 'RescaleSlope') and hasattr(ds, 'RescaleIntercept'):
            slope = ds.RescaleSlope
            intercept = ds.RescaleIntercept
            img = img * slope + intercept
            
        # Apply Window
        windowed = apply_window(img, wc=40, ww=350)
        
        # Save
        out_path = os.path.join(out_dir, f"slice_{i:02d}_z{z_pos:.1f}.png")
        plt.imsave(out_path, windowed, cmap='gray')
        print(f"Saved {out_path}")

if __name__ == "__main__":
    extract_globe_slices()
