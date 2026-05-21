"""Block 1 (pivot): Logit Entropy Probe — use generation entropy as uncertainty signal.

Instead of permutation instability, use the LLM's own logit entropy during
ranking generation as per-user uncertainty. High entropy = model is uncertain
about the ranking = higher prediction error expected.

Single pass, no repeated inference needed.
"""
from __future__ import annotations
import argparse
import json
import math
import random
import sys
from pathlib import Path
import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))


def build_listwise_prompt(history: list[str], candidates: list[str], n_cand: int = 20) -> str:
    hist_str = ", ".join(history[-5:])
    items = [f"{i+1}. {candidates[i]}" for i in range(min(n_cand, len(candidates)))]
    items_str = "\n".join(items)
    return (
        f"A user has purchased: {hist_str}\n\n"
        f"Rank the following items by how likely the user would purchase next. "
        f"Return ONLY a comma-separated list of numbers (e.g., 3,1,5,2,4,...) "
        f"representing the items from most to least likely.\n\n"
        f"{items_str}"
    )


def parse_ranking(text: str, n_items: int) -> list[int] | None:
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


def compute_token_entropy(logprobs_list: list) -> dict:
    """Compute entropy statistics from per-token logprobs."""
    entropies = []
    for token_lp in logprobs_list:
        if not token_lp:
            continue
        probs = [math.exp(lp.logprob) for lp in token_lp.values()]
        total = sum(probs)
        if total <= 0:
            continue
        probs = [p / total for p in probs]
        entropy = -sum(p * math.log(p + 1e-10) for p in probs if p > 0)
        entropies.append(entropy)

    if not entropies:
        return {"mean_entropy": 0.0, "max_entropy": 0.0, "std_entropy": 0.0}

    return {
        "mean_entropy": float(np.mean(entropies)),
        "max_entropy": float(np.max(entropies)),
        "std_entropy": float(np.std(entropies)),
        "n_tokens": len(entropies),
    }


def run_entropy_probe(
    data_path: str,
    model_path: str,
    n_users: int = 200,
    n_candidates: int = 20,
    output_dir: str = "experiments/rsc/results/b1_entropy",
    seed: int = 42,
):
    random.seed(seed)
    np.random.seed(seed)

    from vllm import LLM, SamplingParams

    samples = [json.loads(l) for l in open(data_path)]
    if n_users < len(samples):
        samples = random.sample(samples, n_users)

    print(f"Loaded {len(samples)} users, single pass with logprobs")

    llm = LLM(
        model=model_path,
        tokenizer=model_path,
        dtype="float16",
        max_model_len=2048,
        gpu_memory_utilization=0.90,
        enable_prefix_caching=True,
        trust_remote_code=False,
    )

    sampling_params = SamplingParams(
        temperature=0.1,
        top_p=0.95,
        max_tokens=200,
        logprobs=10,
    )

    prompts = []
    meta = []
    for sample in samples:
        candidates = sample["candidate_titles"][:101]
        n_cand = min(n_candidates, len(candidates))
        prompt = build_listwise_prompt(sample["history"], candidates, n_cand)

        from vllm.entrypoints.chat_utils import apply_hf_chat_template
        # Use raw prompt (model handles chat template internally if needed)
        prompts.append(prompt)
        pos_idx = sample["positive_item_index"]
        meta.append({
            "user_id": sample["user_id"],
            "positive_idx": pos_idx if pos_idx < n_cand else -1,
        })

    print(f"Running inference on {len(prompts)} prompts...")
    outputs = llm.generate(prompts, sampling_params)

    user_metrics = []
    for output, m in zip(outputs, meta):
        text = output.outputs[0].text.strip() if output.outputs else ""
        ranking = parse_ranking(text, n_candidates)
        if ranking is None:
            ranking = list(range(n_candidates))

        # Extract logprobs and compute entropy
        token_logprobs = output.outputs[0].logprobs if output.outputs else []
        entropy_stats = compute_token_entropy(token_logprobs)

        # Check if positive item is in top-10
        pos_idx = m["positive_idx"]
        if 0 <= pos_idx < len(ranking):
            pos_rank = ranking.index(pos_idx) if pos_idx in ranking else n_candidates
        else:
            pos_rank = n_candidates
        hit_at_10 = 1.0 if pos_rank < 10 else 0.0

        user_metrics.append({
            "user_id": m["user_id"],
            "mean_entropy": entropy_stats["mean_entropy"],
            "max_entropy": entropy_stats["max_entropy"],
            "std_entropy": entropy_stats["std_entropy"],
            "n_tokens": entropy_stats.get("n_tokens", 0),
            "positive_rank": pos_rank,
            "hit_at_10": hit_at_10,
            "error": 1.0 - hit_at_10,
            "raw_text": text[:200],
        })

    # Save and analyze
    out_dir = Path(output_dir)
    out_dir.mkdir(parents=True, exist_ok=True)

    with open(out_dir / "user_metrics.jsonl", "w") as f:
        for m in user_metrics:
            f.write(json.dumps(m) + "\n")

    analyze_entropy_results(user_metrics, out_dir)


def analyze_entropy_results(user_metrics: list[dict], out_dir: Path):
    from scipy import stats

    entropies = [m["mean_entropy"] for m in user_metrics]
    errors = [m["error"] for m in user_metrics]

    # Filter out zero-entropy users (failed generation)
    valid = [(e, err) for e, err in zip(entropies, errors) if e > 0]
    if len(valid) < 20:
        print("Too few valid users with entropy > 0")
        return

    ent_valid, err_valid = zip(*valid)

    pearson_r, pearson_p = stats.pearsonr(ent_valid, err_valid)
    spearman_r, spearman_p = stats.spearmanr(ent_valid, err_valid)

    # Quartile analysis
    sorted_by_ent = sorted(zip(ent_valid, err_valid), key=lambda x: x[0])
    q_size = len(sorted_by_ent) // 4
    quartile_errors = []
    for q in range(4):
        q_data = sorted_by_ent[q * q_size: (q + 1) * q_size]
        q_error = np.mean([x[1] for x in q_data])
        quartile_errors.append(float(q_error))

    monotonic = all(quartile_errors[i] <= quartile_errors[i+1] for i in range(3))

    report = {
        "n_users_valid": len(valid),
        "pearson_r": float(pearson_r),
        "pearson_p": float(pearson_p),
        "spearman_r": float(spearman_r),
        "spearman_p": float(spearman_p),
        "quartile_error_rates": quartile_errors,
        "monotonic_increase": monotonic,
        "entropy_stats": {
            "min": float(np.min(ent_valid)),
            "max": float(np.max(ent_valid)),
            "mean": float(np.mean(ent_valid)),
            "std": float(np.std(ent_valid)),
        },
        "overall_error_rate": float(np.mean(err_valid)),
        "overall_hit_at_10": float(1.0 - np.mean(err_valid)),
        "decision": "PROCEED" if spearman_r > 0.2 and monotonic else "CAUTION" if spearman_r > 0.1 else "STOP",
    }

    with open(out_dir / "b1_entropy_report.json", "w") as f:
        json.dump(report, f, indent=2)

    print("\n" + "=" * 60)
    print("B1 LOGIT ENTROPY VALIDATION REPORT")
    print("=" * 60)
    print(f"Valid users: {report['n_users_valid']}")
    print(f"Overall hit@10: {report['overall_hit_at_10']:.3f}")
    print(f"Pearson r:  {pearson_r:.4f} (p={pearson_p:.4e})")
    print(f"Spearman ρ: {spearman_r:.4f} (p={spearman_p:.4e})")
    print(f"Quartile error rates: {[f'{e:.3f}' for e in quartile_errors]}")
    print(f"Monotonic increase: {monotonic}")
    print(f"Entropy range: [{np.min(ent_valid):.3f}, {np.max(ent_valid):.3f}]")
    print(f"\nDECISION: {report['decision']}")
    print("=" * 60)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--data", type=str, required=True)
    parser.add_argument("--model", type=str, default="/home/ajifang/models/Qwen/Qwen3-8B")
    parser.add_argument("--n_users", type=int, default=200)
    parser.add_argument("--n_candidates", type=int, default=20)
    parser.add_argument("--output", type=str, default="experiments/rsc/results/b1_entropy")
    parser.add_argument("--seed", type=int, default=42)
    args = parser.parse_args()

    run_entropy_probe(
        data_path=args.data,
        model_path=args.model,
        n_users=args.n_users,
        n_candidates=args.n_candidates,
        output_dir=args.output,
        seed=args.seed,
    )
