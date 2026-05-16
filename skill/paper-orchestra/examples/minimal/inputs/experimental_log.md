# Experimental Log

## 1. Experimental Setup

* **Datasets:** We evaluated on three long-document tasks.
  - **NaturalQuestions-Long (NQ-L):** the long-document subset of Natural
    Questions, 7,830 train / 1,200 dev / 1,200 test examples. Average
    document length 3,841 tokens.
  - **NarrativeQA:** book and movie-script question answering, 32,747
    train / 3,461 dev / 10,557 test examples. Average context length
    2,950 tokens.
  - **GovReport-Summ:** long-document summarization on government reports,
    17,517 train / 974 dev / 973 test, average source length 9,409 tokens.

* **Evaluation Metrics:**
  - NQ-L: Exact Match (EM), F1
  - NarrativeQA: ROUGE-L, BLEU-4
  - GovReport-Summ: ROUGE-1, ROUGE-2, ROUGE-L
  - Compute: tokens-per-second at inference (TPS), peak GPU memory (GB),
    forward FLOPs at sequence length 4096

* **Baselines Compared:**
  - Standard dense self-attention (Transformer-base, 12 layers, 768 dim,
    12 heads)
  - BigBird (block-sparse + global tokens)
  - Longformer (sliding window + global)
  - Reformer (LSH attention)
  - Performer (random feature attention)

* **Implementation Details:**
  - Backbone: a 12-layer Transformer encoder–decoder with 768 hidden
    size, 12 attention heads, 3072 FFN dim, layer norm pre-norm.
  - Optimizer: AdamW, learning rate 5e-5 with linear warmup (1000 steps)
    and linear decay.
  - Batch size 16, gradient clipping 1.0, dropout 0.1.
  - Training: 100k steps on each task, single NVIDIA A100 (80GB).
  - Sequence length: 4096 tokens for all long-document tasks.
  - ATK-Attention scoring head: 2-layer MLP with hidden 256, ReLU
    activation, output dim equals sequence length.
  - Gumbel-Softmax temperature annealed from 1.0 to 0.1 over the first
    20k steps, then held constant.
  - K values evaluated: 32, 64, 128, 256.
  - Auxiliary load-balancing loss weight: 0.01.

## 2. Raw Numeric Data

### Table 1: Quality on NaturalQuestions-Long (sequence length 4096)

| Method                | EM   | F1   | TPS  | Memory (GB) | Forward FLOPs (G) |
|-----------------------|------|------|------|-------------|-------------------|
| Dense self-attention  | 47.2 | 58.3 | 1241 | 18.4        | 102.4             |
| BigBird               | 44.8 | 55.6 | 2832 | 9.1         | 31.2              |
| Longformer            | 45.1 | 55.9 | 2654 | 9.6         | 33.5              |
| Reformer              | 42.3 | 53.1 | 2188 | 11.2        | 38.7              |
| Performer             | 43.7 | 54.4 | 3014 | 8.7         | 27.9              |
| ATK-Attention (K=32)  | 44.9 | 55.7 | 3221 | 8.4         | 26.3              |
| ATK-Attention (K=64)  | 46.8 | 57.9 | 2784 | 9.0         | 30.1              |
| ATK-Attention (K=128) | 47.1 | 58.2 | 2241 | 10.2        | 38.4              |
| ATK-Attention (K=256) | 47.3 | 58.4 | 1786 | 12.3        | 53.1              |

### Table 2: Quality on NarrativeQA

| Method                | ROUGE-L | BLEU-4 | TPS  |
|-----------------------|---------|--------|------|
| Dense self-attention  | 23.4    | 14.2   | 1198 |
| BigBird               | 21.6    | 12.8   | 2784 |
| Longformer            | 21.9    | 12.9   | 2611 |
| Reformer              | 19.8    | 11.3   | 2143 |
| Performer             | 20.7    | 11.9   | 2967 |
| ATK-Attention (K=32)  | 21.5    | 12.7   | 3174 |
| ATK-Attention (K=64)  | 23.0    | 13.9   | 2741 |
| ATK-Attention (K=128) | 23.2    | 14.0   | 2204 |
| ATK-Attention (K=256) | 23.4    | 14.2   | 1759 |

### Table 3: Quality on GovReport-Summ

| Method                | ROUGE-1 | ROUGE-2 | ROUGE-L |
|-----------------------|---------|---------|---------|
| Dense self-attention  | 47.8    | 19.6    | 25.1    |
| BigBird               | 45.3    | 17.9    | 23.4    |
| Longformer            | 45.6    | 18.1    | 23.7    |
| Reformer              | 43.1    | 16.8    | 22.0    |
| Performer             | 44.4    | 17.3    | 22.9    |
| ATK-Attention (K=32)  | 45.4    | 18.0    | 23.5    |
| ATK-Attention (K=64)  | 47.2    | 19.4    | 24.8    |
| ATK-Attention (K=128) | 47.5    | 19.5    | 24.9    |
| ATK-Attention (K=256) | 47.7    | 19.6    | 25.0    |

### Table 4: Ablation of design choices (NQ-L F1)

| Variant                                          | F1   |
|--------------------------------------------------|------|
| ATK-Attention (K=64) full                        | 57.9 |
| - remove load-balancing loss                     | 55.4 |
| - replace Gumbel-Softmax with straight-through   | 56.2 |
| - share scoring head across layers               | 56.6 |
| - random fixed top-K (no learned scoring)        | 51.8 |
| - position-only scoring (no content)             | 53.7 |

## 3. Qualitative Observations

* Observation: ATK-Attention K=64 matched dense self-attention F1 on
  NQ-L within 0.4 absolute (57.9 vs 58.3) while using 30.1G FLOPs vs
  102.4G — a 3.4x reduction.
* Observation: At K=256 ATK-Attention surpassed dense on NQ-L (58.4 vs
  58.3), suggesting the scoring head is making *better* than uniform
  selection at high K — hypothesis: the load-balancing term acts as a
  mild regularizer.
* Observation: The compute–quality knob is monotonic and smooth: F1
  values for K = {32, 64, 128, 256} were {55.7, 57.9, 58.2, 58.4}.
* Observation: Removing the load-balancing loss caused 3 of 12 attention
  heads in layer 6 to collapse to attending to ≤ 5 keys regardless of
  query, recovering only after re-training with the loss.
* Observation: The fixed random-top-K baseline (no learned scoring)
  underperformed all other methods (F1 51.8), confirming that learned
  selection is the source of the gains, not the sparsity itself.
* Observation: Inference TPS at K=32 was 3221, ~2.6x faster than dense
  (1241 TPS), with only a 2.6 F1 drop (58.3 → 55.7).
* Observation: Memory at K=32 was 8.4 GB vs 18.4 GB for dense, a 54%
  reduction.
* Observation: Training stability was on par with dense; loss curves
  converged within 5% of the same number of steps across all K values.
