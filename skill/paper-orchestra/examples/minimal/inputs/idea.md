## Problem Statement

Standard self-attention scales quadratically with sequence length, which
makes it expensive to apply Transformers to long-context tasks such as
multi-document question answering and long-form summarization. Existing
sparse-attention variants (block sparse, strided, local + global) trade
quality for efficiency by hand-designing the attention sparsity pattern.
The pattern is fixed at training time and cannot adapt to the input.

## Core Hypothesis

We propose that the sparsity pattern of attention should be
**content-adaptive** rather than position-adaptive. Concretely: a small
auxiliary scoring head can predict, for each query token, the K most
relevant key positions to attend to. We hypothesize that learning this
gating function jointly with the main task loss yields:

1. Better quality at the same FLOP budget than fixed-pattern sparse
   attention.
2. A smooth quality–compute tradeoff: K can be tuned at inference time
   without retraining.

## Proposed Methodology (High-Level Technical Approach)

We will introduce **Adaptive Top-K Attention (ATK-Attention)**, a drop-in
replacement for standard self-attention with the following components:

1. **Query-side scoring head.** A lightweight MLP takes each query
   embedding and outputs a logit vector over all key positions. This is a
   learnable "relevance estimator" that predicts which keys matter for a
   given query.

2. **Top-K selection (forward).** At inference, we keep only the top-K
   scored keys per query and zero out the rest before the softmax. K is a
   hyperparameter we vary.

3. **Differentiable surrogate (training).** Top-K is non-differentiable,
   so during training we use a Gumbel-Softmax relaxation that softly
   selects keys, annealing the temperature toward a hard top-K over
   training. This lets gradients flow into the scoring head.

4. **Auxiliary load-balancing loss.** To prevent the scoring head from
   collapsing to attending to a small set of "popular" positions, we add
   a small auxiliary loss penalizing the variance of selection frequency
   across positions in a batch.

The full attention block becomes: scoring → top-K mask → standard
softmax(QKᵀ/√d) over the masked logits → V projection. The rest of the
Transformer block (FFN, residuals, layer norm) is unchanged.

## Expected Contribution

1. A new content-adaptive sparse-attention mechanism that does not
   require hand-designed patterns.
2. Demonstration that quality at the K=64 setting matches dense
   attention on long-document QA while using ~25% of the FLOPs of dense
   self-attention at sequence length 4096.
3. A controllable quality–compute knob (K) that can be retuned at
   inference without retraining.
