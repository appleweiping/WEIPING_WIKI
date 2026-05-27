# CSATG-EDA Experiment Status

Last updated: 2026-05-25 22:00 CST

## Phase 6: Full Baseline Comparison (RUNNING)

Server: pony-rec-gpu (125.71.97.70:15302, user ajifang)
Main process: PID 2955335
Script: `run_full_baseline_comparison.sh`

### Progress

| Circuit | Done | Running | Remaining |
|---------|------|---------|-----------|
| OTA2 | random, cmaes, botorch, mace, autockt, turbo, ensemble, csatg_opt | — | saasbo |
| Folded Cascode | random, cmaes, botorch, mace, autockt, turbo, ensemble, csatg_opt | — | saasbo |
| LDO | random, cmaes, botorch, mace, autockt, turbo | ensemble (PID 4102722) | saasbo, csatg_opt |
| Bandgap | — | — | all 9 methods |

### Estimated Completion: ~01:00-02:00 CST May 26

### After Phase 6
1. PVT corner analysis (5×3=15 conditions)
2. Monte Carlo yield (500 runs)
3. Full per-metric analysis + p-values
4. Paper writing

## Core Rules
- 2-hour monitoring interval
- No toy baselines
- Every change: commit + push + memory update
- Report issues immediately
