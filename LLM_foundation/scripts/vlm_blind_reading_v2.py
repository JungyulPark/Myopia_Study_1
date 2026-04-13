import os
import sys
import json
import base64
import glob
from datetime import datetime
from pathlib import Path

try:
    import anthropic
except ImportError:
    print("pip install anthropic"); sys.exit(1)

# ============================================================
# 설정
# ============================================================
IMAGE_DIR = r"c:\Projectbulid\LLM_foundation\data\missed_lymphoma_images_v3"
RESULT_DIR = r"c:\Projectbulid\LLM_foundation\results"
MODEL = "claude-sonnet-4-6"

TARGET_CASES = [
    "R10084", "R10090", "R10195", "R10501",
    "R10603", "R10710", "R10816", "R10909"
]

# ============================================================
# 프롬프트 (v2 - 수정판)
# ============================================================
PROMPT = """이 영상은 동일 환자의 안와(Orbit) 영상 3장입니다.

다음을 수행해 주세요:
1. 영상의 종류(CT/MRI)와 촬영 방향(axial/coronal/sagittal)을 판단
2. 병변(mass, lesion, enlargement 등)의 유무 및 형태학적 특징 묘사
3. 가장 가능성 있는 감별진단(Differential Diagnosis) 5개를 순위별로 제시

출력 형식:
[IMAGING]
(영상 종류 및 촬영 방향)

[FINDING]
(병변에 대한 영상의학적 소견 묘사)

[DIFFERENTIAL DIAGNOSIS]
1. (진단명 1) - (근거 한 줄)
2. (진단명 2) - (근거 한 줄)
3. (진단명 3) - (근거 한 줄)
4. (진단명 4) - (근거 한 줄)
5. (진단명 5) - (근거 한 줄)"""

# ============================================================
# 함수
# ============================================================

def load_case_images(case_id: str) -> list[tuple[str, str]]:
    images = []
    for i in range(1, 4):
        filepath = os.path.join(IMAGE_DIR, f"{case_id}_slice{i}.png")
        if not os.path.exists(filepath):
            print(f"  [WARN] 파일 없음: {filepath}")
            continue
        with open(filepath, "rb") as f:
            b64 = base64.standard_b64encode(f.read()).decode("utf-8")
        images.append(("image/png", b64))
    return images


def run_blind_reading(client: anthropic.Anthropic, case_id: str, images: list) -> dict:
    content = []
    for media_type, b64_data in images:
        content.append({
            "type": "image",
            "source": {
                "type": "base64",
                "media_type": media_type,
                "data": b64_data,
            }
        })
    content.append({
        "type": "text",
        "text": PROMPT,
    })

    response = client.messages.create(
        model=MODEL,
        max_tokens=2000,
        messages=[{"role": "user", "content": content}],
    )

    response_text = ""
    for block in response.content:
        if block.type == "text":
            response_text += block.text

    return {
        "case_id": case_id,
        "model": MODEL,
        "prompt_version": "v2_orientation_neutral",
        "response": response_text,
        "input_tokens": response.usage.input_tokens,
        "output_tokens": response.usage.output_tokens,
    }


def check_lymphoma_mention(response_text: str) -> dict:
    text_lower = response_text.lower()
    keywords = ["lymphoma", "malt", "림프종", "lymphoproliferative"]
    found = [kw for kw in keywords if kw in text_lower]

    rank = None
    lines = response_text.split("\n")
    for line in lines:
        line_lower = line.lower().strip()
        for kw in keywords:
            if kw in line_lower:
                for i in range(1, 6):
                    if line_lower.startswith(f"{i}.") or line_lower.startswith(f"**{i}"):
                        rank = i
                        break
                    if f"| **{i}**" in line_lower or f"| {i} |" in line_lower:
                        rank = i
                        break
                if rank:
                    break
        if rank:
            break

    return {
        "mentioned": len(found) > 0,
        "keywords_found": found,
        "rank": rank,
    }


# ============================================================
# 메인
# ============================================================

def main():
    os.makedirs(RESULT_DIR, exist_ok=True)

    from dotenv import load_dotenv
    load_dotenv()
    
    api_key = os.environ.get("ANTHROPIC_API_KEY")
    if not api_key:
        print("[ERROR] ANTHROPIC_API_KEY 환경변수를 설정해주세요.")
        sys.exit(1)

    client = anthropic.Anthropic(api_key=api_key)

    print("=" * 60)
    print("VLM 블라인드 판독 v2 (프롬프트 수정판)")
    print(f"모델: {MODEL}")
    print(f"대상: {len(TARGET_CASES)}건")
    print("=" * 60)
    print(f"\n프롬프트:\n{PROMPT}\n")
    print("=" * 60)

    all_results = []
    summary = []

    for case_id in TARGET_CASES:
        print(f"\n[{case_id}] 판독 중...")

        images = load_case_images(case_id)
        if len(images) < 3:
            print(f"  [ERROR] 이미지 부족 ({len(images)}/3)")
            continue

        try:
            result = run_blind_reading(client, case_id, images)
        except Exception as e:
            print(f"  [ERROR] API 호출 실패: {e}")
            continue

        lymphoma = check_lymphoma_mention(result["response"])
        result["lymphoma_detected"] = lymphoma["mentioned"]
        result["lymphoma_rank"] = lymphoma["rank"]
        result["lymphoma_keywords"] = lymphoma["keywords_found"]

        all_results.append(result)

        status = "HIT" if lymphoma["mentioned"] else "MISS"
        rank_str = f"#{lymphoma['rank']}" if lymphoma['rank'] else "N/A"
        print(f"  → 림프종: {status} (순위: {rank_str})")
        print(f"  → 토큰: in={result['input_tokens']}, out={result['output_tokens']}")

        summary.append({
            "case_id": case_id,
            "lymphoma_detected": lymphoma["mentioned"],
            "lymphoma_rank": lymphoma["rank"],
        })

    # 결과 저장
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")

    json_path = os.path.join(RESULT_DIR, f"vlm_pilot_v2_{timestamp}.json")
    with open(json_path, "w", encoding="utf-8") as f:
        json.dump(all_results, f, ensure_ascii=False, indent=2)
    print(f"\n전체 결과 저장: {json_path}")

    report_path = os.path.join(RESULT_DIR, f"vlm_pilot_v2_summary_{timestamp}.md")
    with open(report_path, "w", encoding="utf-8") as f:
        hits = sum(1 for s in summary if s["lymphoma_detected"])
        total = len(summary)

        f.write("# VLM Blind Reading Pilot v2 - Summary\n\n")
        f.write(f"- **Date**: {timestamp}\n")
        f.write(f"- **Model**: {MODEL}\n")
        f.write(f"- **Prompt version**: v2 (orientation-neutral)\n")
        f.write(f"- **Cases**: {total}\n")
        f.write(f"- **Lymphoma detected**: {hits}/{total} ({hits/total*100:.1f}%)\n\n")

        f.write("## Prompt\n```\n")
        f.write(PROMPT)
        f.write("\n```\n\n")

        f.write("## Results\n\n")
        f.write("| Case | Lymphoma | Rank | Status |\n")
        f.write("|------|----------|------|--------|\n")
        for s in summary:
            status = "HIT" if s["lymphoma_detected"] else "MISS"
            rank = f"#{s['lymphoma_rank']}" if s['lymphoma_rank'] else "-"
            f.write(f"| {s['case_id']} | {'Yes' if s['lymphoma_detected'] else 'No'} | {rank} | {status} |\n")

        f.write(f"\n## v1 vs v2 Comparison\n\n")
        f.write("| Case | v1 (Axial prompt) | v2 (Neutral prompt) |\n")
        f.write("|------|-------------------|---------------------|\n")
        v1_hits = {"R10084": True, "R10090": False, "R10195": False,
                   "R10501": True, "R10603": True, "R10710": True,
                   "R10816": False, "R10909": False}
        for s in summary:
            v1 = "HIT" if v1_hits.get(s["case_id"], False) else "MISS"
            v2 = "HIT" if s["lymphoma_detected"] else "MISS"
            f.write(f"| {s['case_id']} | {v1} | {v2} |\n")

        f.write("\n\n## Full Responses\n\n")
        for r in all_results:
            f.write(f"### {r['case_id']}\n")
            f.write(f"```\n{r['response']}\n```\n\n")

    print(f"요약 리포트 저장: {report_path}")

    print(f"\n{'='*60}")
    print(f"결과 요약: 림프종 감별 {hits}/{total} ({hits/total*100:.1f}%)")
    print(f"{'='*60}")
    for s in summary:
        status = "HIT" if s["lymphoma_detected"] else "MISS"
        rank = f"#{s['lymphoma_rank']}" if s['lymphoma_rank'] else "-"
        print(f"  {s['case_id']}: {status} (rank: {rank})")


if __name__ == "__main__":
    main()
