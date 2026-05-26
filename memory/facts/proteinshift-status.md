---
title: "ProteinShift DA-BCP v2 — M2 完成, rank #2/10"
type: fact
created: 2026-05-23T00:00:00+08:00
updated: 2026-05-27T00:00:00+08:00
agent: opus
tags: [ProteinShift, DA-BCP, bilevel-conformal, protein-optimization, M2-complete, ARIS, critical]
related: [research-hard-rules.md, research-core-rules.md]
---

## 状态

项目路径: D:\research\ProteinShift
服务器路径: ~/projects/ProteinShift/ (ajifang@125.71.97.70:15302, qwen_vllm env)
状态: **M2 v2 ✓ COMPLETED** — DA-BCP rank #2/10, best coverage gap #1
ARIS 阶段: research-refine ✓ → experiment-plan ✓ → experiment-bridge (M0✓ M1✓ M2✓) → 下一步 stats+mechanism+paper
Branch: `feat/m2-experiment-progress`

## M2 v2 最终结果 (2026-05-27)

6 datasets × 10 methods × 20 seeds, ESM-2 + Deep Ensemble:

| Rank | Method | Best Fitness↑ | Coverage | Gap↓ |
|------|--------|---------------|----------|------|
| 1 | kermut_gp | 3.510±1.897 | 0.799±0.211 | 0.101 |
| **2** | **dabcp** | **3.247±1.935** | **0.823±0.078** | **0.077** |
| 3 | dabcp_coverage_only | 3.114±1.718 | 0.808±0.094 | 0.092 |
| 4 | self_calibrating_cp | 3.066±1.662 | 0.754±0.077 | 0.146 |
| 5 | deep_ensemble | 2.898±1.556 | 0.172±0.068 | 0.728 |
| 6 | standard_cp | 2.853±1.476 | 0.695±0.098 | 0.205 |
| 7 | mfcs | 2.851±1.462 | 0.720±0.104 | 0.180 |
| 8 | dabcp_no_bilevel | 2.843±1.468 | 0.702±0.104 | 0.198 |
| 9 | aci | 2.836±1.462 | 0.703±0.105 | 0.197 |
| 10 | eci | 2.817±1.413 | 0.706±0.099 | 0.194 |

**关键发现:**
- DA-BCP #2 fitness, **#1 coverage gap** (0.077, 最佳校准)
- DA-BCP coverage 最稳定 (std=0.078 vs kermut_gp 0.211)
- Bilevel 明确有效: dabcp (3.247) >> dabcp_no_bilevel (2.843)
- Per-dataset: TEM1 #2, UBE4B #2, AAV #2, GFP #4, Pab1 #5, GB1 #4

## DA-BCP v2 技术细节

### v1 失败原因 (2026-05-25 诊断)
1. `torch.quantile()` 不可微 → coverage constraint 对 g_phi 梯度为零
2. Decision objective 退化 → 最大化 weighted UCB 推 g_phi→∞
3. 固定 beta=2.0 跨数据集 scale 不匹配
4. g_phi 架构弱 (2层, 128 hidden, 无 normalization)

### v2 修复 (2026-05-26)
1. **可微 soft-quantile**: sorted scores + softmax weights at target rank (temperature=0.01)
2. **非退化目标**: straight-through topk → maximize mu of selected (not UCB)
3. **Auto-beta**: `beta_adaptive = beta_base * mu_range / cal_sigma`
4. **g_phi V2**: LayerNorm(1280) → Linear(256) → GELU → LN(256) → Linear(256) → GELU → Dropout(0.1) → Linear(1) → Softplus + 0.1
5. **Cosine LR**: 150 steps, lr=3e-3, eta_min=0.1×lr
6. **Coverage penalty**: lambda_cov=200, soft bilateral `sigmoid((q-scores)*10)`

### 关键文件
- `scripts/m2_formal.py` — 主实验脚本 (ScoreNormalizer, dabcp_compute_widths, 全部 10 methods)
- `src/uq/dabcp.py` — 核心模块 (DABCPOptimizer, DABCPRegressor, ScoreNormalizer)
- `refine-logs/EXPERIMENT_TRACKER.md` — 完整结果 + 下一步
- `outputs/m2_v2_full/m2_results.json` — 原始 JSON 结果 (服务器)

## 如何接手实验

### 环境
```bash
ssh -p 15302 ajifang@125.71.97.70
source ~/miniconda3/etc/profile.d/conda.sh && conda activate qwen_vllm
cd ~/projects/ProteinShift
```

### 运行实验
```bash
# M2 已完成，结果在 outputs/m2_v2_full/
# 下一步实验示例:
python3 scripts/m2_formal.py --datasets TEM1,AAV --seeds 5 --output outputs/test_run

# 查看结果
cat outputs/m2_v2_full.log
python3 -c "import json; d=json.load(open('outputs/m2_v2_full/m2_results.json')); print(len(d))"
```

### 本地同步
```powershell
# 从服务器拉取结果
scp -P 15302 ajifang@125.71.97.70:~/projects/ProteinShift/outputs/m2_v2_full/m2_results.json D:\research\ProteinShift\outputs\
# 推送代码改动
cd D:\research\ProteinShift
git add scripts/m2_formal.py src/uq/dabcp.py
git commit -m "fix: DA-BCP v2 bilevel optimization"
git push origin feat/m2-experiment-progress
```

## 下一步 (优先级)

1. **Statistical analysis** — paired permutation tests, Holm-Bonferroni, Cohen's d, bootstrap CIs
2. **M4 mechanism** — g_phi visualization, PCA of learned scores, correlation with sequence features
3. **M5 robustness** — vary surrogate (GP/RF/ensemble), noise, embedding (ESM-2/ProtTrans)
4. **M6 downstream** — true fitness top-10, diversity, novelty vs training set
5. **M2-gen** — generative setting (ProSpero/TuRBO/DA-BCP-gen), GFP+AAV, appendix
6. **AUCE + calibration** — at alpha=0.05, 0.1, 0.15, 0.2
7. **Publication figures** — comparison table, Pareto, calibration, g_phi PCA
8. **Paper draft** — ARIS paper-write, 8 pages + appendix, target NeurIPS/ICML 2026

## 计算预算

| Date | Block | GPU-hours | Cumulative | Remaining |
|------|-------|-----------|------------|-----------|
| 2026-05-24 | M0+M1 | ~2 | 2 | 158 |
| 2026-05-25 | M2-v1 | ~12 | 14 | 146 |
| 2026-05-26 | v2 fix+val | ~1 | 15 | 145 |
| 2026-05-27 | M2-v2 full | ~14 | 29 | 131 |

## 8 Official Baselines

1. Kermut (NeurIPS 2024 Spotlight) — GP composite kernel
2. CloneBO (NeurIPS 2024) — Generative BO for antibody
3. Conformal-MFCS (ICML 2024) — CP under feedback shift
4. HDBO Benchmark (NeurIPS 2024) — Discrete sequence BO
5. WR-CP (ICLR 2025) — Wasserstein-regularized CP
6. ECI (ICLR 2025) — Error-quantified adaptive CP
7. ProSpero (NeurIPS 2025) — Active learning for protein
8. Protein-UQ (Microsoft 2025) — Deep ensemble/evidential

## 约束

- NO proxy/toy/缝合 — official code, full data, full metrics
- GitHub push 禁止泄露 API key / token / credentials
- .gitignore: .env, *.key, *.pem, credentials.json, data/, outputs/, *.pt, *.bin
