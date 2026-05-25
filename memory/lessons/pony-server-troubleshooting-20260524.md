---
title: "PonyRec 服务器实验碰壁全记录 (2026-05-23~25)"
type: lesson
created: 2026-05-24T15:20:00+08:00
updated: 2026-05-25T21:00:00+08:00
agent: claude
tags: [pony, server, lesson, troubleshooting]
---

## 碰壁 1: 脚本路径断裂
- **问题:** commit 515fad3 把 120 个 main_*.py 移到 scripts/ 子目录, 旧 .sh 脚本路径全断
- **修复:** sed 批量替换路径, 生成 week8_ccrp_formal_3domains_fixed.sh
- **教训:** 代码重组后必须同步更新所有 .sh 脚本

## 碰壁 2: PYTHONPATH 缺失
- **问题:** scripts/pipeline/main_infer.py 从子目录运行找不到 src/
- **修复:** export PYTHONPATH="$HOME/projects/pony-rec-rescue-shadow-v6:${PYTHONPATH:-}"
- **教训:** 移动脚本后如果没有 sys.path 修复, 必须设 PYTHONPATH

## 碰壁 3: python vs python3
- **问题:** 服务器系统只有 python3, 脚本写的 python
- **修复:** conda activate qwen_vllm (该环境有 python alias)

## 碰壁 4: nohup stdout buffering
- **问题:** log 文件长时间为空
- **原因:** Python stdout 在 nohup 重定向时默认 full buffering
- **应对:** 正常现象, 等待即可。或加 PYTHONUNBUFFERED=1

## 碰壁 5: GPU 内存未释放
- **问题:** kill bash wrapper 后 GPU 内存不释放, 后续 vLLM 启动 OOM
- **修复:** nvidia-smi --query-compute-apps=pid --format=csv,noheader | xargs kill
- **教训:** 必须直接 kill GPU 上的进程, 不是只 kill wrapper

## 碰壁 6: 旧 pipeline 速度不可接受
- **问题:** main_infer.py 逐条推理, 1.4s/sample, 1M samples 需要 388 小时
- **修复:** 换用 run_ccrp_v3_domain.py (vLLM batch, batch_size=512), 同样 1M 约 7.4h
- **教训:** 大规模实验必须用 vLLM batch

## 碰壁 7: max_model_len=1024 不够
- **问题:** electronics 域有 prompt 达 1166 tokens, vLLM 报 ValueError
- **修复:** 改为 max_model_len=2048, VRAM 占用不变 (KV cache 动态分配)
- **教训:** electronics/movies 域 product text 更长, 必须 2048

## 碰壁 8: ps etime 格式误读
- **问题:** "23:04" 是 23分04秒 (MM:SS), 不是 23小时
- **格式:** 两段=MM:SS, 三段=HH:MM:SS, 带天=D-HH:MM:SS
- **教训:** 检查进程运行时间时注意冒号段数

## 碰壁 9: irllrec electronics/movies score files 缺失
- **问题:** 服务器上 official_adapters/ 下没有这两域的 irllrec scores
- **原因:** 之前解压 tarball 时可能只提取了部分文件
- **修复:** 从本地 tarball 提取 scores.csv, scp 上传到服务器
- **教训:** 关键产物必须备份到本地, 服务器文件可能不完整

## 碰壁 10: SRPD HF batch_size=4 OOM (2026-05-25)
- **问题:** SRPD listwise ranking prompt 含 101 candidates 全文, 达 24K tokens. HF batch_size=4 → CUDA OOM
- **修复:** 降到 batch_size=1, 但速度 16.5s/sample = 46h/domain, 不可接受
- **教训:** listwise ranking 101 candidates 的 prompt 极长, 不能用大 batch

## 碰壁 11: SRPD HF batch_size=1 太慢
- **问题:** 10,000 users × 16.5s = 46h/domain, 6 domain-splits = 276h 仅 Step 1
- **修复:** 改用 vLLM + title-only compact prompts (2.5K tokens vs 24K), 速度 ~1.9 samples/s
- **教训:** 当 prompt 太长时, 减少信息密度 (title-only) 比减少 batch_size 更有效

## 碰壁 12: vLLM CUDA fork error
- **问题:** `RuntimeError: Cannot re-initialize CUDA in forked subprocess`
- **原因:** main_rank.py 导入链中有模块提前初始化了 CUDA, vLLM 的 fork 子进程无法重新初始化
- **修复:** `export VLLM_WORKER_MULTIPROC_METHOD=spawn`
- **教训:** 通过 pipeline 框架调用 vLLM 时必须设此环境变量

## 碰壁 13: vLLM max_model_len=4096 vs 24K prompt
- **问题:** 原始 ranking prompt (含 full text) 达 23,233 tokens, 超过 max_model_len=4096
- **修复:** 写独立脚本 `run_srpd_anchor_rank_vllm.py`, 用 title-only prompts (~2.5K tokens)
- **教训:** vLLM max_model_len 决定 KV cache 分配, 设太大会减少并发; 应优化 prompt 长度而非盲目加大 max_model_len
