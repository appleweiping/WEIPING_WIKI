# CSATG-EDA Sky130 — CSATG-OPT Framework + Baseline Comparison

**Updated**: 2026-05-24 14:35 CST
**Tags**: CSATG-EDA, sky130, ngspice, conformal-prediction, analog-design, research, critical
**Status**: Phase 4 bandgap running, Phase 5+6 auto-queued

## Project Direction (Upgraded 2026-05-23)

Expanded from "trust gate only" to **CSATG-OPT**: a complete simulation-efficient optimization framework with formal safety guarantees. Comparing against 8 official EDA baselines end-to-end.

## Innovation

1. **Adaptive conformal recalibration** — sliding window maintains coverage under distribution shift during optimization
2. **Spec-aware acquisition** — vectorized trust gate scoring couples optimizer with conformal gate
3. **Plug-in architecture** — CSATG can be inserted into ANY existing optimizer as a safety layer
4. **Formal guarantee** — at most α fraction of trusted decisions are wrong, even under adaptive optimization

## Server Status (2026-05-24 14:35)

- **Phase 4** (trust gate ablation): OTA2 ✅, Folded Cascode ✅, LDO ✅, Bandgap 🔄 running (PID 2907437)
- **Phase 5** (simple BO+CSATG): auto-queued after Phase 4
- **Phase 6** (full baseline comparison): appended to run_experiments_after_data.sh, will auto-run
- **Server**: pony-rec-gpu (125.71.97.70:15302, user ajifang), load ~15.7
- **Estimated completion**: ~8-10h from 14:35 CST

## Phase 4 Results So Far

### OTA2 (10 seeds, α=0.10, n_cal=500)
| Gate | Skip Rate | FTR | Coverage |
|------|-----------|-----|----------|
| B0 (Always-SPICE) | 0% | 0 | — |
| B1 (Always-Surr.) | 100% | 31.1% | — |
| B2 (Heuristic) | 50.3% | 30.6% | — |
| B3 (Ensemble Var.) | 49.2% | 22.3% | — |
| B4 (Bonferroni) | 20.3% | 0 | 0.910 |
| B5 (CSATG) | 16.0% | 0 | 0.902 |

### LDO (10 seeds, α=0.10, n_cal=500)
- B5 (CSATG): coverage 0.856-0.938, skip 1.6-16.8%, FTR=0 across all seeds

Key insight: Real sky130 data is much harder than synthetic — B1 has 31% FTR on OTA2. CSATG correctly stays conservative (FTR=0). Skip rate is low (~16%) because surrogate error is high on real data, but safety is maintained.

## Calibrated Specs (from real data)

- OTA2: Gain≥15dB, UGF≥2MHz, PM_RAD≥0.70, Power≤0.7mW → 37.1% pass
- Folded Cascode: Gain≥10dB, UGF≥1MHz, PM_RAD≥-1.8, Power≤1mW → 2.1% pass (94.5% non-functional)
- LDO: Vout≥1.3V, Dropout≤0.3V, LDR≥0.7, Power≤2mW → 46.4% pass
- Bandgap: Vref≥1.5V, TC≤120ppm, Power≤60μW → 41.8% pass

## 8 External Baselines (code complete, on server)

1. Random Search — lower bound
2. CMA-ES — evolutionary strategy
3. BoTorch GP-EI — standard Bayesian optimization (needs torch/botorch)
4. MACE (ICML 2018) — batch GP-BO for analog circuits (needs GPy)
5. AutoCkt-RL (DATE 2020) — policy gradient
6. CPN-TabPFN (DAC 2025) — foundation model + DEI (needs tabpfn)
7. CSATG-OPT (Ours) — conformal-guided optimization
8. (TBD: Deep Ensemble or Turbo)

## Key Files (all on server + GitHub)

- `libs/optimization/adaptive_conformal.py` — adaptive conformal module
- `libs/optimization/csatg_opt.py` — CSATG-OPT framework
- `baselines/__init__.py` — unified BaselineOptimizer interface
- `baselines/simple_baselines.py` — Random + CMA-ES
- `baselines/botorch_wrapper.py` — BoTorch GP-EI
- `baselines/mace_wrapper.py` — MACE (ICML 2018)
- `baselines/autockt_wrapper.py` — AutoCkt-RL (DATE 2020)
- `baselines/cpn_wrapper.py` — CPN-TabPFN (DAC 2025)
- `baselines/csatg_opt_wrapper.py` — Our method (surrogate-guided + trust gate)
- `experiments/run_baseline_comparison.py` — unified comparison runner
- `experiments/run_plugin_experiment.py` — plug-in experiment
- `experiments/run_csatg_experiment.py` — trust gate ablation (Phase 4)
- `run_full_baseline_comparison.sh` — Phase 6 auto-run script
- `paper/main.tex` — paper structure updated for real sky130 + CSATG-OPT

## GitHub

- Repo: https://github.com/appleweiping/analog-agent
- Latest commit: `1e8422a` — "feat: CSATG-OPT framework + 6 external baselines"
- All code pushed, data files gitignored

## Technical Lessons

1. PM_RAD for folded_cascode is NEGATIVE (raw phase at UGF)
2. LDO uses LDR/LINE_REG metrics, NOT PSRR_DB
3. Bandgap has 3 metrics only (VREF_V, TC_PPM, POWER_W)
4. Worst-case fill needed for folded_cascode (94.5% non-functional)
5. XGBoost on server competes with Phase 4 for CPU — baseline comparison must wait
6. Vectorized trust gate scoring is essential for performance (no Python loop over candidates)
7. CSATG-OPT with 500 candidates/iter too slow under load — reduced to 200

## Next Steps

1. Wait for Phase 4+5+6 to finish (~8-10h from 14:35)
2. scp all results to local (`D:\Research\CSATG-EDA\outputs\`)
3. Analyze: is CSATG-OPT SOTA vs baselines?
4. If not → iterate (better surrogate, better acquisition, tune hyperparams)
5. If yes → write final paper with complete tables/figures
6. Paper target: DAC/ICCAD 2026
