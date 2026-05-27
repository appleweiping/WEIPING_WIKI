---
title: "CSATG-EDA (Analog-Agent) 项目状态 — Phase 6c 全对比完成"
type: fact
created: 2026-05-18T00:00:00+08:00
updated: 2026-05-27T07:00:00+08:00
agent: claude
tags: [CSATG-EDA, analog-agent, AI4EDA, circuit-design, research, sky130, SOTA, critical]
related: []
---

## 状态

**Phase 6c: Full 4-circuit comparison COMPLETE (7/8 methods). CSATG-OPT v4 is SOTA on OTA2.**

目标: DAC/ICCAD 2026 投稿。

## 当前结果 (2026-05-27)

| Circuit | CSATG-OPT | Best Baseline | Rank | Note |
|---------|-----------|---------------|------|------|
| OTA2 | 13.99±3.85 | MACE 12.62 | **#1** | +10.9% |
| Folded Cascode | 2.34±1.09 | AutoCkt 2.60 | #3 | #1 feasibility (63.5 vs 3-17) |
| LDO | 0.453 | tied | #1-4 | noise level |
| Bandgap | 0.675 | CMA-ES 0.686 | #4 | within 1.6% |

## 关键文件

- 完整实验文档: `D:\Research\CSATG-EDA\docs\EXPERIMENT_STATUS.md`
- 主代码: `D:\Research\CSATG-EDA\baselines\csatg_opt_wrapper.py`
- 结果分析: `D:\Research\CSATG-EDA\scripts\analyze_comparison.py`
- 本地结果: `D:\Research\CSATG-EDA\outputs\baseline_comparison\`
- 服务器结果: `D:\Research\CSATG-EDA\outputs\baseline_comparison_server\`
- GitHub: https://github.com/appleweiping/analog-agent (commit 48e5ab2)

## 服务器

- `ssh -p 15302 ajifang@125.71.97.70`
- SAASBO: 22h+ running, zero output (computationally intractable, recommend exclude)
- 服务器不是 git repo，用 scp 上传文件

## Next Steps

1. Plugin experiment (CSATG as add-on, local ~30min)
2. Convergence curves + Wilcoxon p-values
3. PVT/MC robustness analysis
4. Paper writing (tables, figures, LaTeX)
5. SAASBO decision (kill/reduce/wait)

## 接手指南

任何 agent 接手此项目必须:
1. 先读 `D:\Research\CSATG-EDA\docs\EXPERIMENT_STATUS.md`
2. 运行 `cd D:\Research\CSATG-EDA && python scripts/analyze_comparison.py` 验证结果
3. 按 Next Steps 顺序执行
