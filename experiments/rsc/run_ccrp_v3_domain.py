"""C-CRP v3: Run on any domain using ranking_test.jsonl directly."""
import json, numpy as np, time, re, argparse
from collections import defaultdict
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parents[2]))
from src.llm.vllm_backend import VLLMBackend

def build_v3_prompt(history, candidate_title, candidate_text=""):
    hist_block = "\n".join([f"- {h}" for h in history[-5:]])
    meta = candidate_text[:200] if candidate_text else ""
    desc_line = f"\nDescription: {meta}" if meta else ""
    return (
        "You are an expert recommendation system.\n\n"
        f"User purchase history (most recent first):\n{hist_block}\n\n"
        f"Candidate item:\nTitle: {candidate_title}{desc_line}\n\n"
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
    parser = argparse.ArgumentParser()
    parser.add_argument("--data", type=str, required=True, help="ranking_test.jsonl path")
    parser.add_argument("--n_users", type=int, default=None, help="Limit users (None=all)")
    parser.add_argument("--output", type=str, required=True)
    parser.add_argument("--model", type=str, default="/home/ajifang/models/Qwen/Qwen3-8B")
    args = parser.parse_args()

    print(f"Loading {args.data}...")
    records = [json.loads(l) for l in open(args.data)]
    if args.n_users and args.n_users < len(records):
        records = records[:args.n_users]
    print(f"Users: {len(records)}")

    print("Initializing vLLM...")
    backend = VLLMBackend(
        model_name_or_path=args.model,
        max_model_len=1024,
        gpu_memory_utilization=0.85,
        enable_prefix_caching=True,
        temperature=0.1,
        max_new_tokens=100,
        batch_size=512,
    )

    # Build all prompts (user × candidate)
    all_prompts = []
    all_meta = []
    for rec in records:
        history = rec["history"]
        candidates = rec["candidate_titles"]
        candidate_texts = rec.get("candidate_texts", [""] * len(candidates))
        for i, (title, text) in enumerate(zip(candidates, candidate_texts)):
            prompt = build_v3_prompt(history, title, text)
            all_prompts.append(prompt)
            all_meta.append({"user_id": rec["user_id"], "candidate_idx": i})

    print(f"Total prompts: {len(all_prompts)} ({len(records)} users x {len(records[0]['candidate_titles'])} candidates)")
    print("Running inference...")
    start = time.time()
    results = backend.batch_generate(all_prompts)
    elapsed = time.time() - start
    print(f"Done in {elapsed:.1f}s ({len(all_prompts)/elapsed:.1f} samples/s)")

    # Build per-user score arrays
    user_scores = defaultdict(list)
    for meta, result in zip(all_meta, results):
        score = parse_score(result["raw_text"])
        user_scores[meta["user_id"]].append((meta["candidate_idx"], score))

    # Save raw scores for post-hoc evaluation at different k
    scores_output = []
    for rec in records:
        uid = rec["user_id"]
        pos_idx = rec["positive_item_index"]
        scores = user_scores.get(uid, [])
        if not scores:
            continue
        scores.sort(key=lambda x: -x[1])
        ranked_indices = [idx for idx, _ in scores]
        rank = ranked_indices.index(pos_idx) if pos_idx in ranked_indices else len(ranked_indices)
        scores_output.append({"user_id": uid, "pos_rank": rank, "n_candidates": len(scores)})

    # Evaluate at multiple k
    pos_ranks = np.array([s["pos_rank"] for s in scores_output])

    report = {}
    for k in [5, 10, 20]:
        hr = float(np.mean(pos_ranks < k))
        ndcg = float(np.mean([1.0 / np.log2(r + 2) if r < k else 0.0 for r in pos_ranks]))
        report[f"hr{k}"] = hr
        report[f"ndcg{k}"] = ndcg

    report["mrr"] = float(np.mean([1.0 / (r + 1) for r in pos_ranks]))
    report["n_users"] = len(pos_ranks)
    report["n_prompts"] = len(all_prompts)
    report["inference_time_s"] = elapsed
    report["data_path"] = args.data

    out_dir = Path(args.output)
    out_dir.mkdir(parents=True, exist_ok=True)
    with open(out_dir / "report.json", "w") as f:
        json.dump(report, f, indent=2)

    # Save per-user ranks for post-hoc analysis
    with open(out_dir / "user_ranks.jsonl", "w") as f:
        for s in scores_output:
            f.write(json.dumps(s) + "\n")

    print(f"\n{'='*50}")
    print(f"C-CRP v3 Results ({report['n_users']} users)")
    print(f"{'='*50}")
    print(f"HR@5:    {report['hr5']:.3f}")
    print(f"HR@10:   {report['hr10']:.3f}")
    print(f"HR@20:   {report['hr20']:.3f}")
    print(f"NDCG@5:  {report['ndcg5']:.4f}")
    print(f"NDCG@10: {report['ndcg10']:.4f}")
    print(f"NDCG@20: {report['ndcg20']:.4f}")
    print(f"MRR:     {report['mrr']:.4f}")

if __name__ == "__main__":
    main()
