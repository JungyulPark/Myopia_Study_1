"""
02_run_llm.py
=============
Runs three prompt strategies (zero-shot, few-shot, chain-of-thought)
against the Claude API for every case in the study cohort.
Saves results with checkpointing and automatic retry logic.
"""

import json
import os
import sys
import time
from pathlib import Path

import anthropic
from dotenv import load_dotenv
from tqdm import tqdm

# ── paths ──────────────────────────────────────────────────────────────
ROOT = Path(__file__).resolve().parent.parent
DATA_PATH = ROOT / "data" / "study_cohort.json"
RESULTS_DIR = ROOT / "results"
RESULTS_DIR.mkdir(parents=True, exist_ok=True)

# ── load API key ───────────────────────────────────────────────────────
load_dotenv(ROOT / ".env")
API_KEY = os.getenv("ANTHROPIC_API_KEY")
if not API_KEY or API_KEY.startswith("sk-ant-xxx"):
    sys.exit("ERROR: Set a valid ANTHROPIC_API_KEY in .env")

client = anthropic.Anthropic(api_key=API_KEY)

MODEL = "claude-sonnet-4-6"
TEMPERATURE = 0
MAX_TOKENS = 1000
DELAY = 0.5          # seconds between API calls
MAX_RETRIES = 5
CHECKPOINT_EVERY = 10

# ── system prompt (shared) ─────────────────────────────────────────────
SYSTEM_PROMPT = (
    "You are an experienced ophthalmologist specializing in orbital diseases. "
    "You will be given radiology reports from orbital CT or MRI scans. "
    "Your task is to assess each report and provide clinical recommendations. "
    "Always respond ONLY in valid JSON format. No markdown, no backticks, no extra text."
)

# ── strategy prompts ───────────────────────────────────────────────────

def _base_instruction(img_type: str, report: str) -> str:
    return (
        f"Based ONLY on the radiology report below, provide your clinical assessment.\n\n"
        f"**Imaging type:** {img_type}\n\n"
        f"**Radiology Report:**\n{report}\n\n"
        "Respond in this exact JSON format:\n"
        "{\n"
        '  "primary_diagnosis": "one of: thyroid_eye_disease, orbital_lymphoma, pseudotumor, '
        'benign_tumor, orbital_disease_other, cavernous_hemangioma, meningioma, malignancy, '
        'normal, cannot_determine",\n'
        '  "differential_diagnoses": ["list of differentials"],\n'
        '  "biopsy_recommended": true or false,\n'
        '  "biopsy_reasoning": "1-2 sentence explanation",\n'
        '  "confidence": 1 to 5,\n'
        '  "key_findings": ["list of key imaging findings"],\n'
        '  "report_informative": true or false\n'
        "}"
    )


FEW_SHOT_EXAMPLES = """Here are some examples:

Example 1 (Biopsy recommended):
Report: "Enhancing mass in right lacrimal fossa. DDx includes lymphoma, pseudotumor"
Assessment:
{"primary_diagnosis": "orbital_lymphoma", "differential_diagnoses": ["pseudotumor", "benign_tumor"], "biopsy_recommended": true, "biopsy_reasoning": "Lacrimal fossa mass with differential including lymphoma requires tissue diagnosis.", "confidence": 3, "key_findings": ["enhancing mass in right lacrimal fossa"], "report_informative": true}

Example 2 (Biopsy not recommended):
Report: "Fusiform enlargement of bilateral inferior rectus muscles with exophthalmos. Suggested thyroid orbitopathy"
Assessment:
{"primary_diagnosis": "thyroid_eye_disease", "differential_diagnoses": ["pseudotumor"], "biopsy_recommended": false, "biopsy_reasoning": "Classic bilateral inferior rectus enlargement with proptosis is pathognomonic for thyroid eye disease.", "confidence": 5, "key_findings": ["fusiform enlargement of bilateral inferior rectus muscles", "exophthalmos"], "report_informative": true}

Example 3 (Challenging case):
Report: "Ill-defined enhancing lesion in left orbit. RO pseudotumor, DDx lymphoma"
Assessment:
{"primary_diagnosis": "pseudotumor", "differential_diagnoses": ["orbital_lymphoma", "orbital_disease_other"], "biopsy_recommended": true, "biopsy_reasoning": "Ill-defined enhancing lesion with lymphoma in the differential necessitates biopsy to exclude malignancy.", "confidence": 2, "key_findings": ["ill-defined enhancing lesion in left orbit"], "report_informative": true}

Now assess the following report:

"""


COT_JSON_FORMAT = (
    "Respond in this exact JSON format:\n"
    "{\n"
    '  "step1_findings": "List all key imaging findings from the report",\n'
    '  "step2_differential": "Based on findings, list possible diagnoses and reasoning",\n'
    '  "step3_biopsy_assessment": "Evaluate whether tissue diagnosis is needed and why",\n'
    '  "step4_final_decision": "State your final recommendation with confidence level",\n'
    '  "primary_diagnosis": "one of: thyroid_eye_disease, orbital_lymphoma, pseudotumor, '
    'benign_tumor, orbital_disease_other, cavernous_hemangioma, meningioma, malignancy, '
    'normal, cannot_determine",\n'
    '  "differential_diagnoses": ["list of differentials"],\n'
    '  "biopsy_recommended": true or false,\n'
    '  "biopsy_reasoning": "1-2 sentence explanation",\n'
    '  "confidence": 1 to 5,\n'
    '  "key_findings": ["list of key imaging findings"],\n'
    '  "report_informative": true or false\n'
    "}"
)


def build_prompt(strategy: str, img_type: str, report: str) -> str:
    """Build the user prompt for a given strategy."""
    if strategy == "A_zero_shot":
        return _base_instruction(img_type, report)
    elif strategy == "B_few_shot":
        return FEW_SHOT_EXAMPLES + _base_instruction(img_type, report)
    elif strategy == "C_chain_of_thought":
        return (
            f"Based ONLY on the radiology report below, provide your clinical assessment "
            f"using step-by-step reasoning.\n\n"
            f"**Imaging type:** {img_type}\n\n"
            f"**Radiology Report:**\n{report}\n\n"
            f"{COT_JSON_FORMAT}"
        )
    else:
        raise ValueError(f"Unknown strategy: {strategy}")


# ── API call with retry ────────────────────────────────────────────────

def call_api(strategy: str, img_type: str, report: str) -> dict:
    """Call Claude API with retry logic. Returns dict with status + data."""
    prompt = build_prompt(strategy, img_type, report)

    for attempt in range(1, MAX_RETRIES + 1):
        try:
            response = client.messages.create(
                model=MODEL,
                max_tokens=MAX_TOKENS,
                temperature=TEMPERATURE,
                system=SYSTEM_PROMPT,
                messages=[{"role": "user", "content": prompt}],
            )
            raw_text = response.content[0].text.strip()

            # Try to parse JSON
            # Strip markdown fences if present
            if raw_text.startswith("```"):
                raw_text = raw_text.split("\n", 1)[1]
                if raw_text.endswith("```"):
                    raw_text = raw_text[:-3].strip()

            data = json.loads(raw_text)
            return {"status": "success", "data": data, "raw": raw_text}

        except anthropic.RateLimitError as e:
            wait = min(2 ** attempt * 5, 120)
            print(f"    Rate limited (attempt {attempt}/{MAX_RETRIES}). Waiting {wait}s...")
            time.sleep(wait)
        except anthropic.APIError as e:
            wait = min(2 ** attempt * 2, 60)
            print(f"    API error (attempt {attempt}/{MAX_RETRIES}): {e}. Waiting {wait}s...")
            time.sleep(wait)
        except json.JSONDecodeError:
            return {"status": "json_error", "data": None, "raw": raw_text}
        except Exception as e:
            return {"status": "error", "data": None, "raw": str(e)}

    return {"status": "max_retries_exceeded", "data": None, "raw": ""}


# ── checkpoint helpers ─────────────────────────────────────────────────

def load_checkpoint(strategy: str) -> dict:
    """Load existing results for a strategy (enables resume)."""
    path = RESULTS_DIR / f"results_{strategy}.json"
    if path.exists():
        with open(path, "r", encoding="utf-8") as f:
            records = json.load(f)
        return {r["case_id"]: r for r in records}
    return {}


def save_checkpoint(strategy: str, results: dict):
    """Save current results to disk."""
    path = RESULTS_DIR / f"results_{strategy}.json"
    records = list(results.values())
    with open(path, "w", encoding="utf-8") as f:
        json.dump(records, f, ensure_ascii=False, indent=2)


# ── main ───────────────────────────────────────────────────────────────

STRATEGIES = ["A_zero_shot"]  # Phase 1: zero-shot only
# STRATEGIES = ["A_zero_shot", "B_few_shot", "C_chain_of_thought"]  # Phase 2: all


def run_strategy(strategy: str, cohort: list[dict]):
    """Run a single strategy across all cases with checkpointing."""
    print(f"\n{'='*60}")
    print(f"  Strategy: {strategy}")
    print(f"{'='*60}")

    results = load_checkpoint(strategy)
    done_ids = set(results.keys())
    pending = [c for c in cohort if c["case_id"] not in done_ids]

    if done_ids:
        print(f"  Resuming: {len(done_ids)} done, {len(pending)} remaining")
    else:
        print(f"  Starting fresh: {len(pending)} cases")

    for i, case in enumerate(tqdm(pending, desc=f"  {strategy}")):
        case_id = case["case_id"]
        llm_result = call_api(strategy, case["img_type"], case["report"])

        results[case_id] = {
            "case_id": case_id,
            "strategy": strategy,
            "true_diagnosis": case["true_diagnosis_en"],
            "true_biopsy": case["orbital_biopsy"],
            "uninformative": case["uninformative"],
            "llm_result": llm_result,
        }

        # Checkpoint
        if (i + 1) % CHECKPOINT_EVERY == 0:
            save_checkpoint(strategy, results)
            tqdm.write(f"    Checkpoint saved ({len(results)} records)")

        time.sleep(DELAY)

    # Final save
    save_checkpoint(strategy, results)
    print(f"  Completed: {len(results)} total records saved")
    return results


def main():
    # Load cohort
    if not DATA_PATH.exists():
        sys.exit(f"ERROR: {DATA_PATH} not found. Run 01_prepare_data.py first.")

    with open(DATA_PATH, "r", encoding="utf-8") as f:
        cohort = json.load(f)
    print(f"Loaded {len(cohort)} cases from {DATA_PATH.name}")

    # Run all strategies
    all_results = {}
    for strategy in STRATEGIES:
        results = run_strategy(strategy, cohort)
        for case_id, record in results.items():
            all_results.setdefault(case_id, []).append(record)

    # Combine into a single file
    combined = []
    for case_id, records in all_results.items():
        for r in records:
            combined.append(r)

    combined_path = RESULTS_DIR / "results_combined.json"
    with open(combined_path, "w", encoding="utf-8") as f:
        json.dump(combined, f, ensure_ascii=False, indent=2)
    print(f"\nAll results combined → {combined_path}")
    print(f"Total records: {len(combined)}")

    # Quick summary
    for strategy in STRATEGIES:
        strat_records = [r for r in combined if r["strategy"] == strategy]
        success = sum(1 for r in strat_records if r["llm_result"]["status"] == "success")
        print(f"  {strategy}: {success}/{len(strat_records)} successful")


if __name__ == "__main__":
    main()
