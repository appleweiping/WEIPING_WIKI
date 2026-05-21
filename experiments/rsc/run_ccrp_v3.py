"""C-CRP v3: Profile-enhanced prompt scoring on test set."""
import json, numpy as np, time, re
from collections import defaultdict
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from src.llm.vllm_backend import VLLMBackend

def build_v3_prompt(sample):
    history = sample.get("history", [])
    hist_block = "\n".join([f"- {h}" for h in history[-5:]])
    title = sample.get("candidate_title", "")
    meta = sample.get("candidate_meta", sample.get("candidate_text", ""))[:200]
    return (
        "You are an expert recommendation system for beauty and personal care products.\n\n"
        f"User purchase history (most recent first):\n{hist_block}\n\n"
        f"Candidate item:\nTitle: {title}\nDescription: {meta}\n\n"
        "Based on the purchase pattern, estimate probability (0.0-1.0) this candidate is their next purchase. "
        "Consider category alignment, attribute match, and purchase trajectory.\n\n"
        'Return ONLY JSON: {"relevance_probability": 0.0, "reason": "one sentence"}'
    )

def parse_score(text):
    try:
        m = re.search(r'"relevance_probability"\s*:\s*([\d.]+)', text)
        if m:
            return float(m.group(1))
        m = re.search(r'(0\.\d+|1\.0)', text)
        if m:
            return float(m.group(1))
    except:
        pass
    return 0.0

def main():
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("--n_users", type=int, default=200)
    parser.add_argument("--output", type=str, default="experiments/rsc/results/ccrp_v3")
    args = parser.parse_args()

    test_path = "outputs/summary/week8_large10000_100neg_shadow_inputs/beauty_shadow_test_pointwise.jsonl"
    ranking_path = "outputs/baselines/external_tasks/beauty_supplementary_smallerN_100neg_test_same_candidate/ranking_test.jsonl"

    print("Loading data...")
    test_samples = [json.loads(l) for l in open(test_path)]
    ranking_records = [json.loads(l) for l in open(ranking_path)]

    user_ids = sorted(set(s["user_id"] for s in test_samples))[:args.n_users]
    user_set = set(user_ids)
    test_samples = [s for s in test_samples if s["user_id"] in user_set]
    ranking_records = [r for r in ranking_records if r["user_id"] in user_set]
    print(f"Using {len(user_ids)} users, {len(test_samples)} samples")

    print("Initializing vLLM...")
    backend = VLLMBackend(
        model_name_or_path="/home/ajifang/models/Qwen/Qwen3-8B",
        max_model_len=1024,
        gpu_memory_utilization=0.85,
        enable_prefix_caching=True,
        temperature=0.1,
        max_new_tokens=100,
        batch_size=512,
    )

    print(f"Building {len(test_samples)} prompts...")
    prompts = [build_v3_prompt(s) for s in test_samples]

    print("Running inference...")
    start = time.time()
    results = backend.batch_generate(prompts)
    elapsed = time.time() - start
    print(f"Done in {elapsed:.1f}s ({len(prompts)/elapsed:.1f} samples/s)")

    user_scores = defaultdict(dict)
    for sample, result in zip(test_samples, results):
        uid = sample["user_id"]
        cid = sample["candidate_item_id"]
        score = parse_score(result["raw_text"])
        user_scores[uid][cid] = score

    hits, ndcgs = [], []
    for rec in ranking_records:
        uid = rec["user_id"]
        if uid not in user_scores:
            continue
        pos_id = rec["positive_item_id"]
        candidates = rec["candidate_item_ids"]
        scored = [(user_scores[uid].get(cid, 0.0), cid) for cid in candidates]
        scored.sort(key=lambda x: -x[0])
        ranked_ids = [cid for _, cid in scored]
        if pos_id in ranked_ids:
            rank = ranked_ids.index(pos_id)
            hits.append(1.0 if rank < 10 else 0.0)
            ndcgs.append(1.0 / np.log2(rank + 2) if rank < 10 else 0.0)
        else:
            hits.append(0.0)
            ndcgs.append(0.0)

    print(f"\n{'='*50}")
    print(f"C-CRP v3 (profile prompt) - {len(hits)} users")
    print(f"{'='*50}")
    print(f"HR@10:   {np.mean(hits):.3f}")
    print(f"NDCG@10: {np.mean(ndcgs):.4f}")
    print(f"\nBaseline comparison:")
    print(f"  C-CRP v1:  HR=0.221 NDCG=0.1294")
    print(f"  ProEx:     HR=0.253 NDCG=0.1506")
    print(f"  IRLLRec:   HR=0.220 NDCG=0.1289")

    out_dir = Path(args.output)
    out_dir.mkdir(parents=True, exist_ok=True)
    report = {"hr10": float(np.mean(hits)), "ndcg10": float(np.mean(ndcgs)), "n_users": len(hits)}
    with open(out_dir / "v3_report.json", "w") as f:
        json.dump(report, f, indent=2)

if __name__ == "__main__":
    main()
