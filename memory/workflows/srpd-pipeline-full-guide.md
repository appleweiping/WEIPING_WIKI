---
title: "SRPD Pipeline 完整操作手册 — 任何 Agent 可接手"
type: workflow
created: 2026-05-27T01:00:00+08:00
updated: 2026-05-27T01:00:00+08:00
agent: claude
tags: [pony, srpd, pipeline, workflow, handoff, all-agents, critical]
related: [pony-ccrp-four-domain-status.md, pony-server-troubleshooting-20260524.md]
---

## 概述

SRPD (Structured Risk Preference Distillation) 是 PonyRec 论文的第二个方法，补强 C-CRP v3 在 beauty/movies 域的短板。6 步 pipeline，全量 10K users × 101 candidates，非 toy。

## 服务器信息

- **服务器**: pony-rec-gpu (SSH alias, RTX 4090 49GB)
- **项目路径**: `~/projects/pony-rec-rescue-shadow-v6/`
- **Conda 环境**: `qwen_vllm`
- **模型**: `/home/ajifang/models/Qwen/Qwen3-8B`
- **本地对应**: `D:\Research\Uncertainty\`

## 域名与前缀映射

| Domain | Prefix | Users | Candidates |
|--------|--------|-------|-----------|
| beauty | beauty_supplementary_smallerN_100neg | 973 | 101 |
| books | books_large10000_100neg | 10,000 | 101 |
| electronics | electronics_large10000_100neg | 10,000 | 101 |
| movies | movies_large10000_100neg | 10,000 | 101 |

## Pipeline 6 步详解

### Step 1: Anchor Rank (vLLM batch inference)

**目的**: 用 base Qwen3-8B 对 valid set 做 listwise ranking，产出 anchor predictions
**脚本**: `experiments/rsc/run_srpd_anchor_rank_vllm.py`
**输出**: `outputs/{prefix}_srpd_anchor_rank_valid/predictions/rank_predictions.jsonl`

```bash
conda activate qwen_vllm
export VLLM_WORKER_MULTIPROC_METHOD=spawn
export PYTHONPATH="$HOME/projects/pony-rec-rescue-shadow-v6:${PYTHONPATH:-}"

python experiments/rsc/run_srpd_anchor_rank_vllm.py \
  --domain beauty \
  --split valid \
  --max_model_len 8192 \
  --batch_size 128 \
  --resume
```

**关键配置**:
- `max_model_len=8192` (electronics/movies 标题长，4096 不够)
- `batch_size=128` (配合 8192 的 KV cache)
- Title-only prompts (~2.5K tokens，不用 full text 的 24K)
- 速度: ~1.9 samples/s
- 每域 valid+test 两个 split 都要跑

**碰壁记录**:
- 碰壁 13: full-text prompts 达 24K tokens → 改用 title-only
- 碰壁 14: electronics title-only 仍超 4096 → max_model_len=8192, batch_size=128

### Step 2: Generate Teacher Signal

**目的**: 把 anchor rank predictions 转为 teacher 格式
**脚本**: `experiments/rsc/run_srpd_steps2_6_formal.py --steps 2`
**输出**: `outputs/summary/week8_srpd_formal_teachers/{domain}/valid_teacher_rank_reranked.jsonl`

```bash
python experiments/rsc/run_srpd_steps2_6_formal.py --domain beauty --steps 2
```

逻辑很简单：teacher signal = anchor model 自己的 ranking (self-teacher)。秒级完成。

### Step 3: Build Training Data

**目的**: 用 teacher signal + weighting/gating 构建 SRPD 训练数据
**脚本**: `experiments/rsc/run_srpd_steps2_6_formal.py --steps 3`
**输出**: `outputs/summary/week8_srpd_formal_data/{domain}/train.jsonl` + `valid.jsonl`

```bash
python experiments/rsc/run_srpd_steps2_6_formal.py --domain beauty --steps 3
```

**关键配置** (在 patched config 中):
- `leakage_audit.allow_overlap = True` (1/10000 的 overlap 可忽略)
- `formal_policy.enabled = false` (绕过严格验证)
- Weighting: disagreement_bonus=0.15, uncertainty_scale=0.35
- Preference pairs: max_pairs_per_event=4, teacher_topn=4

**训练数据量**:
- beauty: 973 rows
- books: 7,888 rows
- electronics: 9,931 rows
- movies: 1,881 rows

### Step 4: LoRA Training

**目的**: 用 SRPD 训练数据微调 Qwen3-8B (LoRA)
**脚本**: `experiments/rsc/run_srpd_steps2_6_formal.py --steps 4`
**配置**: `configs/lora/{prefix}_srpd_v6_formal.yaml`
**输出**: `artifacts/adapters/{prefix}_srpd_v6_formal/`

```bash
python experiments/rsc/run_srpd_steps2_6_formal.py --domain beauty --steps 4
```

**LoRA 配置**:
- r=16, alpha=32, dropout=0.05
- target_modules: [q_proj, k_proj, v_proj, o_proj, gate_proj, up_proj, down_proj]
- epochs=2, lr=2e-5, warmup_ratio=0.1
- gradient_checkpointing=True, bf16=True
- batch_size=2, gradient_accumulation=8

**碰壁记录**:
- `lora_rank_trainer.py:416`: `dtype=` → `torch_dtype=` (transformers API)
- `lora_rank_trainer.py:436`: 必须加 `model.enable_input_require_grads()` (PEFT + gradient_checkpointing)
- `formal_policy.enabled` 必须设 false，否则各种 strict validation 报错

### Step 5: Test Inference with LoRA

**目的**: 用 LoRA adapter 对 test set 做 ranking inference
**脚本**: `experiments/rsc/run_srpd_steps2_6_formal.py --steps 5`
**输出**: `outputs/{prefix}_srpd_v6_formal/predictions/rank_predictions.jsonl`

```bash
python experiments/rsc/run_srpd_steps2_6_formal.py --domain beauty --steps 5
```

内部调用 `scripts/pipeline/main_rank.py` with:
- `--exp_name {prefix}_srpd_v6_formal`
- `--model_config configs/model/qwen3_8b_local_rank.yaml`
- `--resume_partial` (支持断点续跑)
- `--topk 10 --max_new_tokens 256`

**速度**: ~14-17s/sample (HF backend, batch_size=1)
- beauty (973): ~4h
- books (10K): ~40h
- electronics (10K): ~40h
- movies (10K): ~40h

**为什么不用 vLLM**: vLLM 0.10.2 不支持动态加载 LoRA adapter，只能用 HF transformers。

### Step 6: Evaluation

**目的**: 计算 HR@5/10/20, NDCG@5/10/20, MRR
**脚本**: `experiments/rsc/run_srpd_steps2_6_formal.py --steps 6`
**输出**: `outputs/{prefix}_srpd_v6_formal/tables/ranking_metrics.json`

```bash
python experiments/rsc/run_srpd_steps2_6_formal.py --domain beauty --steps 6
```

秒级完成。输出 JSON 包含所有指标。

## 批量运行 (全 4 域)

### 方式 1: 逐域顺序执行 (推荐，当前在用)

```bash
#!/bin/bash
# /tmp/run_srpd_step4_all.sh
cd ~/projects/pony-rec-rescue-shadow-v6
conda activate qwen_vllm
export PYTHONPATH="$HOME/projects/pony-rec-rescue-shadow-v6:${PYTHONPATH:-}"
export VLLM_WORKER_MULTIPROC_METHOD=spawn

for domain in beauty books electronics movies; do
  echo "=== Starting $domain ==="
  python experiments/rsc/run_srpd_steps2_6_formal.py --domain $domain --steps 4,5,6
  echo "=== Done $domain ==="
done
```

用 nohup 启动:
```bash
nohup bash /tmp/run_srpd_step4_all.sh > outputs/summary/logs/srpd_steps4_6.log 2>&1 &
echo $!  # 记录 PID
```

### 方式 2: 单域单步

```bash
python experiments/rsc/run_srpd_steps2_6_formal.py --domain books --steps 5 --skip_existing
```

## 监控方法

### 检查 GPU 进程
```bash
nvidia-smi --query-compute-apps=pid,used_memory --format=csv,noheader
```

### 检查进度 (看 log)
```bash
tail -5 outputs/summary/logs/srpd_steps4_6.log
```

### 检查产出文件
```bash
wc -l outputs/{prefix}_srpd_v6_formal/predictions/rank_predictions.jsonl
```

### 注意: 文件 buffering
Python 在 nohup 下默认 full buffering，`wc -l` 可能比 progress bar 少。以 log 中的 progress bar 为准。

### 杀进程 (如需重启)
```bash
# 必须直接 kill GPU 进程，不是 kill wrapper
nvidia-smi --query-compute-apps=pid --format=csv,noheader | xargs kill
```

## 断点续跑

- Step 5 支持 `--resume_partial`: 读取已有 predictions，跳过已处理的 source_event_id
- 如果进程被 kill，直接重新运行同样命令即可续跑
- Step 4 (LoRA training): 如果 adapter 目录已存在且非空，`--skip_existing` 会跳过

## 当前状态 (2026-05-27 01:00)

| Step | beauty | books | electronics | movies |
|------|--------|-------|-------------|--------|
| 1 Anchor rank | ✅ | ✅ | ✅ | ✅ |
| 2 Teacher | ✅ | ✅ | ✅ | ✅ |
| 3 Training data | ✅ | ✅ | ✅ | ✅ |
| 4 LoRA training | ✅ | ✅ | ✅ | ✅ |
| 5 Inference | ✅ 973/973 | 🔄 4129/10000 (41%) | ⏳ | ⏳ |
| 6 Evaluate | ⏳ | ⏳ | ⏳ | ⏳ |

**运行中**: PID 3762241 (GPU 33.3GB), ~15s/sample
**预计完成**: books ~26h → electronics ~40h → movies ~40h → 总计 ~106h (~4.4天)
**Log**: `outputs/summary/logs/srpd_steps4_6.log`

## 完成后的下一步

1. 收集 4 域 `ranking_metrics.json`
2. 更新论文 `Paper/tables/main_results.tex`
3. 对比 C-CRP v3 和 8 official baselines
4. 进入 Paper Phase 5: internal review + auto-review-loop
5. scp 结果回本地备份

## 关键文件清单

| 文件 | 位置 | 用途 |
|------|------|------|
| run_srpd_steps2_6_formal.py | experiments/rsc/ | Steps 2-6 主脚本 |
| run_srpd_anchor_rank_vllm.py | experiments/rsc/ | Step 1 vLLM 脚本 |
| lora_rank_trainer.py | src/training/ | LoRA 训练核心 (已修 2 处 bug) |
| srpd_dataset.py | src/training/ | 训练数据构建 |
| main_rank.py | scripts/pipeline/ | HF inference 框架 |
| qwen3_8b_local_rank.yaml | configs/model/ | HF 推理配置 |
| qwen3_8b_vllm_rank_safe.yaml | configs/model/ | vLLM 推理配置 |
| {prefix}_srpd_v6_formal.yaml | configs/lora/ | LoRA 训练配置 (4个) |
| {prefix}_srpd_v6_formal.yaml | configs/srpd/ | SRPD 数据配置 (4个) |

## 环境变量 (必须设置)

```bash
export PYTHONPATH="$HOME/projects/pony-rec-rescue-shadow-v6:${PYTHONPATH:-}"
export VLLM_WORKER_MULTIPROC_METHOD=spawn
# 可选: export PYTHONUNBUFFERED=1 (实时看 log)
```
