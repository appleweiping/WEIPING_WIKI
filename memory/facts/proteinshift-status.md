---
title: "ProteinShift DA-BCP 方法升级 — research-refine 完成"
type: fact
created: 2026-05-23T00:00:00+08:00
updated: 2026-05-25T00:00:00+08:00
agent: opus
tags: [ProteinShift, DA-BCP, bilevel-conformal, protein-optimization, research-refine, ARIS, critical]
related: [research-hard-rules.md, proteinshift-status.md]
---

## 状态

项目路径: D:\research\ProteinShift
服务器路径: ~/projects/ProteinShift/ (pony-rec-gpu, qwen_vllm env)
状态: **M0 ✓ M1 ✓ M2 Phase1 RUNNING (TEM1 done, UBE4B~70%)** — Phase 2 generative script ready
ARIS 阶段: research-refine ✓ → experiment-plan ✓ → experiment-bridge (M0 ✓, M1 ✓, M2 running)

## M1 结果 (2026-05-24)

Decision Gap 在所有 6 个数据集上 > 0.9 (阈值 0.3):
- TEM-1: DG=0.932±0.082
- UBE4B: DG=0.920±0.113
- Pab1: DG=0.932±0.085
- GFP: DG=0.923±0.074
- AAV: DG=0.951±0.040
- GB1: DG=0.936±0.056
结论: calibration 和 decision quality 几乎完全 decoupled，DA-BCP 的 motivation 极强

## 方法升级: DTCR → DA-BCP

旧方法 DTCR: w_i = density_ratio * exp(λ * acq(x_i)) — trivial extension of WCP, 一个超参
新方法 DA-BCP: 将 conformal score function 作为优化变量，bilevel optimization:
- Outer: coverage constraint (conformal validity)
- Inner: decision quality (protein fitness discovery)
- 通过 implicit differentiation 穿过 conformal quantile 反向传播
- 理论保证: relaxed coverage + decision quality improvement + online regret bound

## 核心创新

1. Decision-coupled conformal score — 新理论对象
2. 可微分 conformal quantile (soft pinball loss + implicit differentiation)
3. Score normalizer g_phi(x) 学习在哪里分配 uncertainty budget

## 8 Official Baselines (2024-2026 顶会)

1. Kermut (NeurIPS 2024 Spotlight) — GP composite kernel for protein UQ
2. CloneBO (NeurIPS 2024) — Generative BO for antibody design
3. Conformal-MFCS (ICML 2024) — CP under feedback shift
4. HDBO Benchmark (NeurIPS 2024) — Discrete sequence BO survey
5. WR-CP (ICLR 2025) — Wasserstein-regularized CP
6. ECI (ICLR 2025) — Error-quantified adaptive CP
7. ProSpero (NeurIPS 2025) — Active learning for protein design
8. Protein-UQ (Microsoft 2025) — Deep ensemble/evidential benchmark

## 计算预算

~126 GPU-hours on 1× RTX 4090 (6 tasks × 20 seeds × 15 rounds × 9 methods)

## 关键文件

- refine-logs/CLAIM_DECOMPOSITION.md
- refine-logs/LITERATURE_STRESS_TEST.md
- refine-logs/FEASIBILITY.md
- refine-logs/RESEARCH_QUESTION.md

## 下一步

1. ~~experiment-plan~~ ✓
2. ~~experiment-bridge: DA-BCP~~ ✓
3. ~~M0 sanity~~ ✓
4. ~~数据下载~~ ✓
5. ~~M1 phenomenon~~ ✓ (DG=0.92-0.95, 6/6 PASS)
6. **M2 Phase 1 pool-based** — RUNNING (PID 3716258, TEM1 done, UBE4B→Pab1→GFP→AAV→GB1)
7. **M2 Phase 2 generative** — script ready (m2_generative.py), pending Phase 1 completion
   - Official baselines: ProSpero, TuRBO (BoTorch), LatProtRL (needs VED pre-train)
   - Design: 双设定 (main=pool-based, appendix=generative)
8. M2 analysis — script ready (scripts/m2_analysis.py), run after M2 completes
9. M3-M6 (ablation, mechanism, robustness, downstream)
10. Paper writing

## 2026-05-25 进展

- M2 Phase 1: TEM1 完成, CUDA OOM 修复 (precompute_embeddings.py + resume logic)
- Phase 2 generative: 官方 baseline 全部 clone (ProSpero/LatProtRL/HDBO), m2_generative.py 写完
- 用户强制约束: 禁止 proxy/toy 化/缝合, 必须 official code + 完整数据 + 完整 metrics
- AAV 可用 JSON oracle (无需 TAPE download), GFP 需要 TAPE (被 GFW 阻断, 待解决)

## 服务器部署

- 路径: ~/projects/ProteinShift/
- 环境: qwen_vllm (Python 3.12, PyTorch 2.8, CUDA 12.8)
- 数据: 6 ProteinGym DMS assays (SPG1/CAPSD/GFP/BLAT/PABP/UBE4B)
- GPU: RTX 4090, 当前被 PonyRec + CSATG 占用
- 自动启动脚本: run_m0_after_pony.sh (等 PID 2811327 结束后启动)
- 监控: outputs/m0_launch.log
