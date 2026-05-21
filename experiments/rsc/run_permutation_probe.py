"""Block 1: Permutation Probe — measure rank instability across K passes.

For each user, run K listwise reranking passes with different candidate orderings.
Compute per-user rank variance as uncertainty signal.
Correlate with prediction error to validate the phenomenon.
"""
from __future__ import annotations
import argparse
import json
import random
import sys
from pathlib import Path
from typing import Any
import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))
from src.llm.vllm_backend import VLLMBackend


def build_listwise_prompt(history: list[str], candidates: list[str], order: list[int]) -> str:
    hist_str = ", ".join(history[-5:])
    items = [f"{i+1}. {candidates[order[i]]}" for i in range(len(order))]
    items_str = "\n".join(items)
    return (
        f"A user has purchased: {hist_str}\n\n"
        f"Rank the following items by how likely the user would purchase next. "
        f"Return ONLY a comma-separated list of numbers (e.g., 3,1,5,2,4,...) "
        f"representing the items from most to least likely.\n\n"
        f"{items_str}"
    )


def parse_ranking(text: str, n_items: int) -> list[int] | None:
    """Parse LLM output into a ranking (0-indexed positions)."""
    try:
        nums = [int(x.strip()) - 1 for x in text.replace("\n", ",").split(",") if x.strip().isdigit()]
        if len(nums) < n_items // 2:
            return None
        seen = set(nums)
        for i in range(n_items):
            if i not in seen:
                nums.append(i)
        return nums[:n_items]
    except Exception:
        return None


def run_probe(
    data_path: str,
    model_path: str,
    n_users: int = 200,
    k_passes: int = 10,
    n_candidates: int = 20,
    output_dir: str = "experiments/rsc/results/b1_probe",
    seed: int = 42,
):
    random.seed(seed)
    np.random.seed(seed)

    samples = [json.loads(l) for l in open(data_path)]
    if n_users < len(samples):
        samples = random.sample(samples, n_users)

    print(f"Loaded {len(samples)} users, {k_passes} passes, {n_candidates} candidates/list")

    backend = VLLMBackend(
        model_name_or_path=model_path,
        max_model_len=2048,
        gpu_memory_utilization=0.90,
        enable_prefix_caching=True,
        temperature=0.1,
        max_new_tokens=200,
        batch_size=256,
    )

    all_results = []

    for pass_idx in range(k_passes):
        print(f"Pass {pass_idx+1}/{k_passes}")
        prompts = []
        meta = []

        for sample in samples:
            candidates = sample["candidate_titles"][:101]
            n_cand = min(n_candidates, len(candidates))
            order = list(range(n_cand))
            random.shuffle(order)

            prompt = build_listwise_prompt(
                history=sample["history"],
                candidates=candidates,
                order=order,
            )
            prompts.append(prompt)
            pos_idx = sample["positive_item_index"]
            meta.append({
                "user_id": sample["user_id"],
                "order": order,
                "positive_idx": pos_idx if pos_idx < n_cand else -1,
            })

        results = backend.batch_generate(prompts)

        for res, m in zip(results, meta):
            ranking = parse_ranking(res["raw_text"], len(m["order"]))
            if ranking is None:
                ranking = list(range(len(m["order"])))

            original_ranking = [m["order"][r] for r in ranking if r < len(m["order"])]

            all_results.append({
                "user_id": m["user_id"],
                "pass_idx": pass_idx,
                "ranking": original_ranking,
                "positive_idx": m["positive_idx"],
                "raw_text": res["raw_text"][:200],
            })

    out_dir = Path(output_dir)
    out_dir.mkdir(parents=True, exist_ok=True)
    with open(out_dir / "raw_passes.jsonl", "w") as f:
        for r in all_results:
            f.write(json.dumps(r) + "\n")

    analyze_results(all_results, n_candidates, out_dir)


def analyze_results(results: list[dict], n_candidates: int, out_dir: Path):
    from scipy import stats

    user_passes: dict[str, list] = {}
    for r in results:
        user_passes.setdefault(r["user_id"], []).append(r)

    user_metrics = []
    for user_id, passes in user_passes.items():
        if len(passes) < 3:
            continue

        positive_idx = passes[0]["positive_idx"]

        rank_matrix = np.full((len(passes), n_candidates), n_candidates - 1, dtype=float)
        for p_idx, p in enumerate(passes):
            for rank_pos, item_idx in enumerate(p["ranking"]):
                if item_idx < n_candidates:
                    rank_matrix[p_idx, item_idx] = rank_pos

        item_variances = np.var(rank_matrix, axis=0)
        mean_variance = float(np.mean(item_variances))

        if 0 <= positive_idx < n_candidates:
            pos_ranks = rank_matrix[:, positive_idx]
            pos_mean_rank = float(np.mean(pos_ranks))
            hit_at_10 = float(np.mean(pos_ranks < 10))
        else:
            pos_mean_rank = float(n_candidates)
            hit_at_10 = 0.0

        user_metrics.append({
            "user_id": user_id,
            "mean_rank_variance": mean_variance,
            "positive_mean_rank": pos_mean_rank,
            "hit_at_10": hit_at_10,
            "error": 1.0 - hit_at_10,
            "n_history": len(passes[0].get("history", [])) if "history" in passes[0] else 0,
        })

    variances = [m["mean_rank_variance"] for m in user_metrics]
    errors = [m["error"] for m in user_metrics]

    pearson_r, pearson_p = stats.pearsonr(variances, errors)
    spearman_r, spearman_p = stats.spearmanr(variances, errors)

    sorted_metrics = sorted(user_metrics, key=lambda x: x["mean_rank_variance"])
    q_size = len(sorted_metrics) // 4
    quartile_errors = []
    for q in range(4):
        q_users = sorted_metrics[q * q_size: (q + 1) * q_size]
        q_error = np.mean([u["error"] for u in q_users])
        quartile_errors.append(float(q_error))

    monotonic = all(quartile_errors[i] <= quartile_errors[i+1] for i in range(3))

    report = {
        "n_users": len(user_metrics),
        "pearson_r": float(pearson_r),
        "pearson_p": float(pearson_p),
        "spearman_r": float(spearman_r),
        "spearman_p": float(spearman_p),
        "quartile_error_rates": quartile_errors,
        "monotonic_increase": monotonic,
        "mean_variance_stats": {
            "min": float(np.min(variances)),
            "max": float(np.max(variances)),
            "mean": float(np.mean(variances)),
            "std": float(np.std(variances)),
        },
        "decision": "PROCEED" if spearman_r > 0.2 and monotonic else "CAUTION" if spearman_r > 0.1 else "STOP",
    }

    with open(out_dir / "b1_report.json", "w") as f:
        json.dump(report, f, indent=2)

    with open(out_dir / "user_metrics.jsonl", "w") as f:
        for m in user_metrics:
            f.write(json.dumps(m) + "\n")

    print("\n" + "=" * 60)
    print("B1 PHENOMENON VALIDATION REPORT")
    print("=" * 60)
    print(f"Users analyzed: {report['n_users']}")
    print(f"Pearson r:  {pearson_r:.4f} (p={pearson_p:.4e})")
    print(f"Spearman ρ: {spearman_r:.4f} (p={spearman_p:.4e})")
    print(f"Quartile error rates: {[f'{e:.3f}' for e in quartile_errors]}")
    print(f"Monotonic increase: {monotonic}")
    print(f"Variance range: [{np.min(variances):.2f}, {np.max(variances):.2f}]")
    print(f"\nDECISION: {report['decision']}")
    print("=" * 60)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--data", type=str, required=True)
    parser.add_argument("--model", type=str, default="/home/ajifang/models/Qwen/Qwen3-8B")
    parser.add_argument("--n_users", type=int, default=200)
    parser.add_argument("--k_passes", type=int, default=10)
    parser.add_argument("--n_candidates", type=int, default=20)
    parser.add_argument("--output", type=str, default="experiments/rsc/results/b1_probe")
    parser.add_argument("--seed", type=int, default=42)
    args = parser.parse_args()

    run_probe(
        data_path=args.data,
        model_path=args.model,
        n_users=args.n_users,
        k_passes=args.k_passes,
        n_candidates=args.n_candidates,
        output_dir=args.output,
        seed=args.seed,
    )
