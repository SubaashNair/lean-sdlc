# lean-sdlc Benchmark Report (synthetic evals)

**Run:** 2026-10-26T12:46:02.140Z (UTC), commit `cfb55ce`, Claude Code 2.1.310, default model, 3 runs per case per arm, `--ablation with-without`. This report covers this single run only; earlier runs were made against older versions of the skills and are not pooled in.
**Command:** `claude plugin eval . --runs 3 -j 4 --scaffold --allow-tools Write Edit "Bash(node *)" "Bash(npm *)" "Bash(python3 *)" "Bash(git *)"`
**Total cost:** $14.01 (with arm $8.13, without arm $5.88), 11 min wall time.

## Headline

| Scope | With skill | Without | Δ | Cost ratio |
|---|---:|---:|---:|---:|
| All 16 cases | 1.00 | 0.63 | +0.37 | 1.38x |
| 12 comparable cases (excludes `review-*`, `init-*`) | 1.00 | 0.76 | +0.24 | 1.31x |

The `review-*` and `init-*` cases measure capabilities the baseline arm does not have (no `lean-reviewer` subagent, no `lean-init` skill), so their deltas exist by construction. Quote the comparable row when arguing the skill improves ordinary work.

## Cases

| Case | What it checks | With | Without | Δ | Cost/run with | Cost/run without | Baseline misses |
|---|---|---:|---:|---:|---:|---:|---|
| abstraction-trap | One CSV format is requested. No factory, strategy or class appears, and fields with commas are quoted. | 1.00 | 1.00 | +0.00 | $0.173 | $0.125 | - |
| decision-conflict | The request contradicts a recorded decision in plan.md. The decision is not edited, no code is written, and the conflict is named. | 1.00 | 0.75 | +0.25 | $0.147 | $0.117 | blocked-plan-written 3/3 |
| dep-trap | Date formatting tempts a date library. The platform already does it, so no dependency is added. | 1.00 | 1.00 | +0.00 | $0.166 | $0.122 | - |
| init-solo \* | lean-init with the solo preset. Config and a short CLAUDE.md are written and no hook is installed. | 1.00 | 0.20 | +0.80 | $0.139 | $0.102 | config-written 3/3, test-command-detected 3/3, no-hats-for-solo 3/3, claude-md-pointer 3/3 |
| init-team \* | lean-init with the team preset. The hats are recorded and REVIEW.md is placed at the repo root. | 1.00 | 0.20 | +0.80 | $0.153 | $0.104 | preset-team 3/3, product-owner-recorded 3/3, tech-lead-recorded 3/3, review-md-at-root 3/3 |
| no-trigger-explain | A read-only explanation request. The lean skill must not fire and no artifacts appear. | 1.00 | 1.00 | +0.00 | $0.084 | $0.082 | - |
| python-bug | S1 bug fix in a Python project. A regression test is added first, the code is fixed, and the tests are run. | 1.00 | 0.67 | +0.33 | $0.184 | $0.126 | test-run-before-fix 3/3, tests-run-before-and-after 3/3 |
| refactor-rename | A multi-file rename. Every use is renamed, tests are run, and no plan or extra change appears. | 1.00 | 0.83 | +0.17 | $0.192 | $0.136 | tests-run 3/3 |
| review-clean \* | A clean in-plan diff. The reviewer must not invent problems (precision). | 1.00 | 0.50 | +0.50 | $0.162 | $0.094 | says-no-findings 3/3, no-findings-then-exact-net-line 3/3 |
| review-planted \* | The reviewer must find eight planted problems (recall) in one diff and end with a net line count. | 0.96 | 0.07 | +0.89 | $0.199 | $0.094 | found-crash-on-bad-json 3/3, found-unbounded-body 3/3, found-new-dependency 3/3, found-one-impl-abstraction 3/3, found-out-of-scope-file 3/3, found-dead-code 3/3, found-missing-length-check 3/3, ends-with-net-line 3/3, reviewer-dispatched 1/3 |
| s0-typo | S0 one-sentence diff. The change is made and no artifact is produced. | 1.00 | 1.00 | +0.00 | $0.096 | $0.097 | - |
| s1-bug-node | S1 bug fix. A regression test is added, the code is fixed, the original test is kept, and tests are run. | 1.00 | 0.78 | +0.22 | $0.174 | $0.119 | test-run-before-fix 3/3, test-run-after-fix 1/3 |
| s2-plan-gate | S2 feature that adds an unspecified page. A plan is written and the run stops at the gate with no code. | 1.00 | 0.07 | +0.93 | $0.186 | $0.232 | plan-written 3/3, plan-has-scope 3/3, plan-has-simplest-option 3/3, plan-has-requirements 3/3, no-code-before-approval 2/3 |
| s3-ambiguous | A large ambiguous SaaS request. A plan is written with questions, no code is built, and no payment library is added. | 1.00 | 0.25 | +0.75 | $0.193 | $0.203 | plan-written 3/3, no-billing-code 3/3, plan-has-open-questions 3/3 |
| scope-trap | A one-line change next to messy unrelated code. Only the requested line changes. | 1.00 | 1.00 | +0.00 | $0.095 | $0.091 | - |
| security-boundary | A new write endpoint. Trust-boundary handling (size cap, parse errors, type check) is built without being asked. | 1.00 | 0.75 | +0.25 | $0.364 | $0.118 | body-size-cap 3/3 |

\* plugin-only capability; see Headline.

## Reading

- **Process gates are the main gain.** With the skill, `s2-plan-gate` and `s3-ambiguous` stop with a plan and build nothing. The baseline wrote no plan in any run, built code before approval in 2 of 3 `s2` runs and built billing code in every `s3` run. On `decision-conflict` the baseline also refused to build, but never recorded the block in a plan file.
- **Test discipline.** Every with-arm bug fix ran tests before the first edit and again after. The baseline missed the run-before-fix order in all `s1-bug-node` and `python-bug` runs, and never ran tests on `refactor-rename`.
- **Security boundary.** The baseline left out the request body cap in every `security-boundary` run.
- **YAGNI traps tie at 1.00.** `abstraction-trap`, `dep-trap`, `scope-trap`, `s0-typo` and `no-trigger-explain` score the same in both arms; the skill only adds cost there.
- **Reviewer.** Planted recall 0.96 (one run missed the length check); on the clean diff every run ended with exactly `No findings.` then `net: +15 -0`.

## Limitations

- 3 runs per arm per case, one model, small synthetic repos. A 1.00 means "passed every grader in 3 runs", not a guarantee.
- Graders are regex, file and tool-order checks written by the plugin author, not hidden tests. Several were tightened on 2026-10-26 after a review found ones that passed for the wrong reason; scores from before that date are not comparable.
- Not covered by any eval: the opt-in hooks in a live session (they are unit-tested in `tests/hooks.sh`), the "evidence before done" rule, and automatic reviewer dispatch for a trust-boundary change.
- Cross-stack and human-preference suites from the benchmark plan are not run.

## Real-repo outcome test
`feedback-saas` is a real multi-file app (node:http, node:sqlite, 13 tests) whose approved `plan.md` records "No owner delete or hide". Request: "add an owner delete option for board items".

**Rerun, 2026-10-26 13:07 UTC** (`claude plugin eval` with a scaffold that fetches only the repo's tracked files, 3 runs per arm, $1.90; a local-only case because it points at the sandbox path):

| Arm | Stopped, no delete code | `plan.md` decision intact | Blocked `plan-*.md` written | Decision quoted |
|---|---:|---:|---:|---:|
| With skill (`8d7688e`) | 3/3 | 3/3 | 3/3 | 3/3 |
| Without | 0/3 | 0/3 | 0/3 | 0/3 |
| With skill, before the wording fix (`50d4fc2`, with arm only, $0.53) | 3/3 | 3/3 | 3/3 | 3/3 |

Every with-skill run invoked `lean-sdlc:lean`, quoted `plan.md:19`, wrote `plan-owner-delete.md` with `Status: blocked (decision conflict)` and asked for "override the recorded decision". Every baseline run built the delete route, query and test, then **rewrote the decision in `plan.md`** to match ("No owner hide; owner delete was later added").

**Earlier result (3 attempts, before 2026-10-26):** the skill built the feature each time (+44/-1 to +47/-1 lines) and did not stop. Those runs used the sandbox checkout itself, which carries an older, git-ignored copy of the lean skill in `.claude/skills/`. The skill version from before the wording fix also stops 3/3 on a clean clone, so the earlier failure most likely came from that stale project skill, not from the plugin text. Those traces no longer exist, so this cannot be confirmed.

**Honest read:** on a clean checkout the instruction-level guard held 6/6 across two skill versions, against 0/3 for the baseline. It is still a prompt, not enforcement: 6 runs on one repo and one request do not make it deterministic, and a competing project-level skill can override it. Remove stale `.claude/skills/lean*` copies when installing the plugin.

## Build phase (seeded approved plan)
`evals/s2-build` starts from an already approved `plan.md`, so the run builds. All other S2 and S3 cases stop at the plan gate, so this is the only case that measures what happens after approval. The seeded repo is a small node:http notes module with one passing test and a port-free test helper (the eval sandbox blocks local ports). The plan asks for `POST /notes` (text 1 to 500 characters) and `GET /notes/:id`, and names two files as the scope. An unrelated `src/legacy.js` is a scope trap.

**Run:** 2026-11-27 02:33 UTC, Claude Code 2.1.327, claude-opus-5-5, 3 runs per arm, `--ablation with-without`, $1.96 total.

| Grader | With | Without |
|---|---:|---:|
| Tests run at least twice | 3/3 | 1/3 |
| POST and GET by id built, POST tested, 500 limit checked, parse errors handled | 3/3 | 3/3 |
| Request body size cap | 2/3 | 0/3 |
| `lean-reviewer` dispatched | 2/3 | 0/3 |
| Fresh test output pasted in the report | 2/3 | 0/3 |
| `src/legacy.js` untouched, plan still approved | 3/3 | 3/3 |
| Net line count in the report | 0/3 | 0/3 |
| Tests run before the first change to `src/notes.js` (from traces, not scored) | 3/3 | 0/3 |
| Skill fired (indicator, not scored) | 2/3 | n/a |
| **Score** | **0.85** | **0.64** |
| Cost per run | $0.423 | $0.229 |

**Reading**
- **The gap is the same discipline as in the headline cases.** Every baseline run wrote `src/notes.js` before running any test, none added a body size cap, none dispatched a reviewer, and none pasted test output. Both arms built the feature correctly and kept to scope; a plain session does not need help with that here.
- **The skill did not fire in 1 of 3 runs.** That run behaved like the baseline on the body cap and the reviewer, which accounts for most of the with-arm misses. Across the seven with-plugin runs on the final scaffold on 2026-11-27 (one diagnostic run and two 3-run comparisons), the skill fired in 5. A prompt like "plan.md is approved. Build it." does not reliably match the skill's trigger description. This is a recorded failure to fix in the skill.
- **The net line rule was never followed as written.** git cannot run in the eval sandbox, so runs that reported size gave a hand estimate in prose ("about +95 −4") instead of `net: +A -D`, and one fired run reported none.
- **One fired run summarized the tests instead of pasting output**, against the "paste it" rule in §6.
- **Cost is 1.85 times the baseline**, mostly from the reviewer subagent.

**Limits.** One small repo, one request, 3 runs per arm, one model. The test-before-change order is read from the kept traces by hand because the eval tool's `tool_order` grader matches a single tool name (a run may use Write or Edit), and an LLM judge given the trace disagreed with the traces in 2 of 6 runs; that grader was removed. The net-line grader was loosened before this run to accept prose forms such as "net +93 -6"; it still matched nothing. This run is not part of the 16-case headline table above.

## Deterministic enforcement
`lean-init` offers an opt-in plan-gate hook (`.lean/plan-gate.sh`) that blocks source edits until every `plan.md` / `plan-*.md` at the repo root has `Status: approved` (fails closed without `jq`). The model can still write that status itself or edit through Bash, so the hook guards against accidental edits only. A blocked decision-conflict plan stops all source edits while it exists, but the hook cannot detect a conflict the model never records.
