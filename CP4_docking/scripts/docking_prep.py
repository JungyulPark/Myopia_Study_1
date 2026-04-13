"""
Molecular Docking: Atropine × TGFB1/LATS2 Pathway Proteins
Using AutoDock Vina via Python (vina or meeko) or CB-Dock2 alternative

This script prepares the docking inputs and runs local docking if possible.
If AutoDock Vina is not installed, generates CB-Dock2 submission files.
"""
import os
import json
import subprocess

results_dir = r'c:\Projectbulid\CP4_docking\results'
structures_dir = r'c:\Projectbulid\CP4_docking\structures'
os.makedirs(results_dir, exist_ok=True)
os.makedirs(structures_dir, exist_ok=True)

# ================================================================
# Step 1: Define docking targets
# ================================================================

TARGETS = {
    # Priority 1: Direct MR-validated targets
    "TGFB1_receptor": {
        "pdb_id": "3KFD",   # TGF-β1:TβRII complex
        "description": "TGF-beta1 bound to type II receptor",
        "rationale": "Test if atropine can modulate TGFβ1-receptor interaction"
    },
    "LATS2": {
        "pdb_id": "5BRK",   # LATS2 kinase domain (or closest available)
        "description": "LATS2 Hippo kinase",
        "rationale": "Test if atropine can inhibit LATS2 kinase activity"
    },
    # Priority 2: Known atropine targets for validation
    "CHRM1": {
        "pdb_id": "5CXV",   # Muscarinic M1 receptor
        "description": "Muscarinic M1 receptor (positive control)",
        "rationale": "Validate docking protocol against known target"
    },
    # Priority 3: Extension layer
    "YAP1_TEAD1": {
        "pdb_id": "3KYS",   # YAP-TEAD complex
        "description": "YAP-TEAD transcription factor complex",
        "rationale": "Test if atropine can modulate YAP-TEAD interaction"
    }
}

# Atropine SMILES
ATROPINE_SMILES = "O=C(OC1CC2CCC(C1)N2C)C(CO)c1ccccc1"
ATROPINE_MW = 289.37

print("=" * 60)
print("MOLECULAR DOCKING PREPARATION")
print("Atropine × CP3-validated targets")
print("=" * 60)

# ================================================================
# Step 2: Check local docking tools
# ================================================================

vina_available = False
try:
    result = subprocess.run(["vina", "--version"], capture_output=True, text=True, timeout=5)
    if result.returncode == 0:
        vina_available = True
        print(f"\n✅ AutoDock Vina found: {result.stdout.strip()}")
except:
    pass

obabel_available = False
try:
    result = subprocess.run(["obabel", "-V"], capture_output=True, text=True, timeout=5)
    if result.returncode == 0:
        obabel_available = True
        print(f"✅ OpenBabel found: {result.stdout.strip()}")
except:
    pass

if not vina_available:
    print("\n⚠ AutoDock Vina not found locally.")
    print("Generating CB-Dock2 submission files instead.")
    print("Submit at: https://cadd.labshare.cn/cb-dock2/php/index.php")

# ================================================================
# Step 3: Download PDB structures
# ================================================================

print("\n--- Downloading PDB structures ---")

import urllib.request

for target_name, info in TARGETS.items():
    pdb_id = info["pdb_id"]
    pdb_file = os.path.join(structures_dir, f"{pdb_id}.pdb")
    
    if not os.path.exists(pdb_file):
        url = f"https://files.rcsb.org/download/{pdb_id}.pdb"
        try:
            urllib.request.urlretrieve(url, pdb_file)
            print(f"  ✅ Downloaded {pdb_id}.pdb ({target_name})")
        except Exception as e:
            print(f"  ❌ Failed to download {pdb_id}: {e}")
    else:
        print(f"  ✓ {pdb_id}.pdb already exists")

# ================================================================
# Step 4: Generate atropine ligand file
# ================================================================

print("\n--- Generating atropine ligand ---")

ligand_sdf = os.path.join(structures_dir, "atropine.sdf")

# Try RDKit first
try:
    from rdkit import Chem
    from rdkit.Chem import AllChem, Draw
    
    mol = Chem.MolFromSmiles(ATROPINE_SMILES)
    mol = Chem.AddHs(mol)
    AllChem.EmbedMolecule(mol, randomSeed=42)
    AllChem.MMFFOptimizeMolecule(mol)
    
    writer = Chem.SDWriter(ligand_sdf)
    writer.write(mol)
    writer.close()
    print(f"  ✅ Atropine 3D structure generated via RDKit: {ligand_sdf}")
    
    # Save as PDB too
    ligand_pdb = os.path.join(structures_dir, "atropine.pdb")
    Chem.MolToPDBFile(mol, ligand_pdb)
    
except ImportError:
    print("  RDKit not available. Using PubChem download instead.")
    pubchem_url = "https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/174174/SDF?record_type=3d"
    try:
        urllib.request.urlretrieve(pubchem_url, ligand_sdf)
        print(f"  ✅ Downloaded atropine from PubChem: {ligand_sdf}")
    except:
        print("  ❌ Could not download atropine structure")

# ================================================================
# Step 5: Run docking or generate submission files
# ================================================================

if vina_available and obabel_available:
    print("\n--- Running AutoDock Vina ---")
    # Full local docking pipeline would go here
    # For now, this is a placeholder for the actual vina commands
    for target_name, info in TARGETS.items():
        pdb_id = info["pdb_id"]
        print(f"\nDocking atropine into {target_name} ({pdb_id})...")
        # vina --receptor X.pdbqt --ligand atropine.pdbqt --out result.pdbqt ...
else:
    print("\n--- CB-Dock2 Submission Files ---")
    print("Upload the following files to https://cadd.labshare.cn/cb-dock2/")
    print()
    
    submission_info = []
    for target_name, info in TARGETS.items():
        pdb_id = info["pdb_id"]
        pdb_file = os.path.join(structures_dir, f"{pdb_id}.pdb")
        entry = {
            "target": target_name,
            "pdb_id": pdb_id,
            "pdb_file": pdb_file,
            "ligand_file": ligand_sdf,
            "description": info["description"],
            "rationale": info["rationale"]
        }
        submission_info.append(entry)
        print(f"  Job {len(submission_info)}:")
        print(f"    Target: {target_name} ({pdb_id})")
        print(f"    Receptor: {pdb_file}")
        print(f"    Ligand: {ligand_sdf}")
        print(f"    Rationale: {info['rationale']}")
        print()
    
    # Save submission guide
    with open(os.path.join(results_dir, "docking_submission_guide.json"), 'w') as f:
        json.dump(submission_info, f, indent=2)
    print("✅ Submission guide saved: CP4_docking/results/docking_submission_guide.json")

# ================================================================
# Step 6: Summary
# ================================================================

print("\n" + "=" * 60)
print("DOCKING PREPARATION COMPLETE")
print("=" * 60)
print(f"Targets prepared: {len(TARGETS)}")
print(f"PDB structures: {structures_dir}")
print(f"Ligand: atropine (MW={ATROPINE_MW})")
if not vina_available:
    print("\nNEXT STEP: Install AutoDock Vina or use CB-Dock2 web server")
    print("  pip install vina  (or download from https://vina.scripps.edu/)")
    print("  CB-Dock2: https://cadd.labshare.cn/cb-dock2/php/index.php")
