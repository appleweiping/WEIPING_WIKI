---
title: "PonyRec C-CRP 四域实验状态 (2026-05-24)"
type: fact
created: 2026-05-24T15:20:00+08:00
updated: 2026-05-24T15:20:00+08:00
agent: claude
tags: [pony, c-crp, experiment, status, four-domain]
related: [pony-ccrp-v2-decision.md]
---

## 当前阶段: M5 四域验证 → 接近完成

### 主表方法: C-CRP v3 (pointwise relevance probability)

脚本: `experiments/rsc/run_ccrp_v3_domain.py`
模型: Qwen3-8B, vLLM batch, max_model_len=2048
数据: same-candidate protocol, 101 candidates/user (1 pos + 100 neg)

| Domain | Users | HR@5 | NDCG@5 | HR@10 | NDCG@10 | HR@20 | NDCG@20 | MRR | vs Best Baseline |
|--------|-------|------|--------|-------|---------|-------|---------|-----|-----------------|
| Books | 10,000 | 0.374 | 0.300 | 0.476 | 0.333 | 0.592 | 0.362 | 0.306 | **SOTA** (+21.5% vs LLMEmb) |
| Electronics | 10,000 | 0.218 | 0.157 | 0.299 | 0.183 | 0.418 | 0.213 | 0.168 | **SOTA** (+52.5% vs LLMEmb) |
| Movies | 10,000 | 0.145 | 0.108 | 0.208 | 0.128 | 0.331 | 0.159 | 0.127 | 排第4-6 (LLMEmb=0.169) |
| Beauty | 973 | — | — | 0.239* | 0.136* | — | — | — | 接近 ProEx (差6%) |

*Beauty 全指标正在排队跑

### 关键决策

1. **不用 formal C-CRP** — uncertainty decomposition + risk penalty 在 beauty 上反而变差 (0.131 vs 0.136)
2. **不用 temperature scaling** — post-hoc 无法创造区分力, movies 问题是 scoring 本身
3. **尝试 v4 enhanced prompt** — 提取 category, 更长 description, 更多 history。先跑 movies 验证

### 观察链

| 环节 | Beauty | Books | Electronics | Movies |
|------|--------|-------|-------------|--------|
| 1. Raw confidence 诊断 | ✅ | 🔄 跑中 | 🔄 跑中 | 🔄 跑中 |
| 2. Reliability bins | ✅ | 🔄 | 🔄 | 🔄 |
| 3. Baselines miscalibration | ✅ | ✅ | ✅ | ✅ |
| 4. C-CRP v3 主表 | 🔄 排队 | ✅ | ✅ | ✅ |
| 5. Official baselines 8个 | ✅ | ✅ | ✅ | ✅ |

### GPU 队列 (自动执行, 不需干预)

1. 三域诊断 (PID 2812434) — ~15h remaining
2. Beauty v3 全指标 (PID 2910032) — ~43min
3. Movies v4 验证 (PID 2911797) — ~7-9h

### 关键文件位置

- 总表: `outputs/ccrp_v3_formal/main_comparison_table.csv`
- Baseline 诊断: `outputs/baseline_calibration_diagnostic/{domain}/{method}/`
- C-CRP v3 结果: `outputs/ccrp_v3_formal/{domain}/report.json`
- v4 脚本: `experiments/rsc/run_ccrp_v4_enhanced.py`
- 服务器: `pony-rec-gpu:~/projects/pony-rec-rescue-shadow-v6/`
- 本地: `D:\Research\Uncertainty\`

### 下一步

- Movies v4 结果出来后决定: 有效 → 四域全跑 v4; 无效 → v3 + narrative 收工
- Beauty 全指标补完后更新总表
- 三域诊断完成后, 观察链 1/2 环节全部完成
- 之后进入论文写作阶段 (M6)
