---
name: experiment-bridge
description: Bridge from experiment plan to executable code. Translates the experiment plan into runnable scripts, configs, and infrastructure. Use when user says "experiment-bridge", "实验桥接", "bridge to code", "implement the experiment", or after experiment-plan is complete and reviewed.
---

# Experiment Bridge

Turn the experiment plan into code that runs. No hand-waving, no "TODO: implement later."

## Decision Gate

Before running:
- [ ] `refine-logs/EXPERIMENT_PLAN.md` exists and was reviewed by Codex (score ≥6 on all dimensions)
- [ ] `refine-logs/EXPERIMENT_TRACKER.md` exists
- [ ] Compute resources are confirmed accessible (SSH to server works)
- [ ] Dataset paths are verified

## Phase 1 — Code Architecture

1. **Survey existing code** in the project directory
2. **Design the experiment runner** structure:
   ```
   experiments/
     configs/          # YAML configs per block/baseline
     scripts/          # Run scripts (train, eval, analyze)
     baselines/        # Baseline implementations or wrappers
     results/          # Output directory (gitignored)
     analysis/         # Post-hoc analysis scripts
   ```
3. **Identify reusable components** from existing code
4. **Define the config schema** (dataset, model, hyperparams, seeds, output_dir)

Output: Architecture doc in `experiments/README.md`

## Phase 2 — Baseline Implementation

For each of the 8+ baselines:
1. **Official implementation available?** → Write a wrapper script
2. **Need reimplementation?** → Implement from paper, verify on reported numbers
3. **Create unified evaluation interface** — all baselines produce same output format

Quality check: Each baseline must reproduce reported numbers within 5% (or document why not).

## Phase 3 — Our Method Implementation

1. **Core algorithm** — implement the novel component
2. **Integration** — connect to data pipeline and evaluation
3. **Sanity check** — run on tiny subset, verify no crashes, output format correct
4. **Config files** — one per experiment block × baseline × seed

## Phase 4 — Run Infrastructure

1. **Launcher script** — handles seed loops, GPU allocation, logging
2. **Monitoring** — progress bars, estimated time, early stopping
3. **Result collection** — auto-aggregate across seeds into summary tables
4. **Checkpoint strategy** — save intermediate results for crash recovery

Example launcher:
```bash
#!/bin/bash
for seed in $(seq 1 $NUM_SEEDS); do
  for config in configs/block_${BLOCK}/*.yaml; do
    python run.py --config $config --seed $seed --output results/
  done
done
```

## Phase 5 — Validation Run

1. **M0 sanity milestone**: Run Block 1 with 3 seeds
2. **Verify**: Results are reasonable, no NaN/Inf, metrics in expected range
3. **Timing**: Measure wall-clock per run, extrapolate total compute
4. **Fix issues** before scaling up

Quality check: M0 must pass before proceeding to full runs.

## Handoff

- Output: `experiments/` directory with all code, configs, scripts
- Update `refine-logs/EXPERIMENT_TRACKER.md` (M0 status)
- Update `memory/facts/<project>-status.md`
- Next ARIS step: **run-experiment** → **monitor**
- Handoff to: OpenCode (executor) for running, or user for GPU submission

## Hard Rules

- No mock implementations — every baseline must actually run
- Config-driven: changing an experiment should only require editing a YAML file
- Reproducibility: same config + same seed = same result (set all random seeds)
- All results go to `results/` (gitignored), never committed to repo
- Evidence labels: M0 outputs are "diagnostic" until full seeds complete
