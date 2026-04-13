import os
import json
import base64
from pathlib import Path
from anthropic import Anthropic
from dotenv import load_dotenv

def get_base64_encoded_image(image_path):
    with open(image_path, "rb") as image_file:
        return base64.b64encode(image_file.read()).decode('utf-8')

def main():
    load_dotenv()
    api_key = os.getenv("ANTHROPIC_API_KEY")
    if not api_key:
        print("ANTHROPIC_API_KEY not found in environment.")
        return

    client = Anthropic(api_key=api_key)
    
    img_dir = Path("data/missed_lymphoma_images_v3")
    results_dir = Path("results")
    results_dir.mkdir(exist_ok=True)
    results_file = results_dir / "vision_pilot_results.json"
    
    # Load previous results if resuming
    if results_file.exists():
        with open(results_file, "r", encoding="utf-8") as f:
            predictions = json.load(f)
    else:
        predictions = {}

    # Get unique cases
    all_files = list(img_dir.glob("*.png"))
    cases = sorted(list(set([f.name.split('_')[0] for f in all_files])))
    
    print(f"Found {len(cases)} cases for Vision Pilot.")
    
    prompt = """
이 영상은 안와(Orbit) CT 또는 MRI의 축상면(Axial) 이미지 3장입니다.
영상을 판독하여 병변(mass/lesion/enlargement 등)의 유무 및 형태학적 특징을 묘사하고,
가장 가능성 있는 감별진단(Differential Diagnosis) 질환 목록을 1위부터 5위까지 제시해 주세요.

출력 형식:
[FINDING]
(병변에 대한 영상의학적 소견 묘사)

[DIFFERENTIAL DIAGNOSIS]
1. (진단명 1)
2. (진단명 2)
...
"""

    for case in cases:
        if case in predictions:
            print(f"[{case}] Already processed. Skipping.")
            continue
            
        print(f"[{case}] Processing...")
        
        # Get all 3 slices for this case
        slice_files = sorted(list(img_dir.glob(f"{case}_slice*.png")))
        
        content = []
        for sf in slice_files:
            b64_img = get_base64_encoded_image(sf)
            content.append({
                "type": "image",
                "source": {
                    "type": "base64",
                    "media_type": "image/png",
                    "data": b64_img
                }
            })
            
        content.append({
            "type": "text",
            "text": prompt
        })
        
        try:
            response = client.messages.create(
                model="claude-sonnet-4-6",
                max_tokens=1024,
                temperature=0.0,
                messages=[
                    {
                        "role": "user",
                        "content": content
                    }
                ]
            )
            
            result_text = response.content[0].text
            predictions[case] = {
                "raw_response": result_text,
                "lymphoma_caught": "lymphoma" in result_text.lower() or "malt" in result_text.lower()
            }
            
            print(f"  -> Caught Lymphoma: {predictions[case]['lymphoma_caught']}")
            
            # Save checkpoint
            with open(results_file, "w", encoding="utf-8") as f:
                json.dump(predictions, f, ensure_ascii=False, indent=2)
                
        except Exception as e:
            print(f"  [ERROR] API call failed for {case}: {e}")
            break

    # Final summary
    total = len(predictions)
    caught = sum(1 for v in predictions.values() if v.get("lymphoma_caught", False))
    print("\n" + "="*60)
    print(" VISION PILOT RESULTS SUMMARY")
    print("="*60)
    print(f" Total Cases Evaluated: {total}")
    print(f" Successfully Caught 'Lymphoma': {caught} ({caught/total*100:.1f}%)" if total else "0%")
    print("="*60)

if __name__ == "__main__":
    main()
