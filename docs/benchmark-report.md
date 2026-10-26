# lean-sdlc Benchmark Report (synthetic evals)

Aggregated over completed runs in `evals/results/` (aborted/interrupted runs excluded).

## Suites / cases

| Case | Claim | With skill | Without | Δ | Avg cost/run |

|---|---|---:|---:|---:|---:|

| abstraction-trap | see README | 0.96 | 0.96 | +0.00 | $0.173 |
| decision-conflict | see README | 1.00 | 1.00 | +0.00 | $0.134 |
| dep-trap | see README | 1.00 | 1.00 | +0.00 | $0.147 |
| init-solo | see README | 0.83 | 0.20 | +0.63 | $0.131 |
| init-team | see README | 0.93 | 0.20 | +0.73 | $0.143 |
| no-trigger-explain | see README | 1.00 | 1.00 | +0.00 | $0.083 |
| python-bug | see README | 0.89 | 0.80 | +0.09 | $0.145 |
| refactor-rename | see README | 0.93 | 0.94 | -0.01 | $0.144 |
| review-clean | see README | 0.92 | 0.29 | +0.62 | $0.150 |
| review-planted | see README | 0.99 | 0.07 | +0.91 | $0.211 |
| s0-typo | see README | 1.00 | 1.00 | +0.00 | $0.096 |
| s1-bug-node | see README | 0.95 | 0.76 | +0.18 | $0.136 |
| s2-plan-gate | see README | 0.90 | 0.00 | +0.90 | $0.184 |
| s3-ambiguous | see README | 1.00 | 0.25 | +0.75 | $0.194 |
| scope-trap | see README | 1.00 | 1.00 | +0.00 | $0.092 |
| security-boundary | see README | 0.95 | 0.75 | +0.20 | $0.316 |

**Weighted mean score (with skill):** 0.95 across 196 completed with-runs. 
**Total observed run cost (with arm, summed):** $31.55.

## Reading

- Large, clean wins: plan gate, init, reviewer recall/precision, s3 ambiguity.

- YAGNI traps (abstraction, dep, scope, refactor) are ~1.00 both arms — baseline already avoids them; plugin adds process, not magic.

- Bug fixes show a modest test-first advantage (+0.09 python, +0.18 s1-node) but higher variance.

- Security boundary: +0.20; reviewer flags caps but baseline sometimes skips body cap.

## Limitations

- Small n per cell (mostly 7-19 runs, single model, synthetic repos).

- Real cross-stack and human-preference suites (B/E/F in the benchmark plan) are not yet executed.

- Scores are grader-driven; independent hidden tests pending in a follow-up.


## Real-repo outcome test (added)
Ran `feedback-saas`, a repo whose `plan.md` records "No owner delete or hide", with the request "add an owner delete option for board items".
- **Result (with skill, 3 attempts):** built the feature each time (+44/-1 to +47/-1 lines), wrote tests and passed review; did not stop-and-ask.
- **Implication:** the recorded-decision conflict guard is **advisory only** in real sessions, even with hard-gate wording. Synthetic eval `decision-conflict` still reports 1.00 because its grader checks output text, not actual file edits.
- **Honest read:** instruction-level rules help exploration and reporting, but durable enforcement requires a deterministic hook (`lean-init` offers one for test edits). Treat conflict-gated claims as probabilistic.
