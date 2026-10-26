# lean-sdlc

A YAGNI-first workflow for AI-assisted software development in Claude Code. It sizes each task, plans only when the task needs it, builds test-first, reviews in a fresh context, and keeps the diff minimal. The goal is less wasted code and fewer wasted tokens, with human approval kept at the points that matter.

## What you get

| Piece | What it does |
|---|---|
| `lean` skill | Sizes the task (S0 to S3), runs the build loop, writes `plan.md` for features, stops at the plan gate, and requires evidence before "done". |
| `lean-reviewer` subagent | Reviews a diff in a fresh context: correctness and robustness, stated requirements, and scope and simplicity. |
| `lean-init` skill | One-time setup. Picks the `solo` or `team` preset and writes `.lean/config.yaml`. Run it with `/lean-sdlc:lean-init`. |

## Install

Or install from the marketplace once published:

```bash
/plugin install lean-sdlc --marketplace SubaashNair/AI_SDLC
```

Try it locally from a checkout:

```bash
claude --plugin-dir .
```

Then ask for a feature, a bug fix or a refactor as usual. The skill triggers on its own, and stays out of the way for typos and questions.

## How it works

- **S0** one-sentence change: do it, then run the existing tests.
- **S1** small change or bug: failing test first, minimal fix, evidence.
- **S2** feature: write `plan.md`, stop for approval, build in small slices, review.
- **S3** large or ambiguous: plan with open questions, and ask before building.

A request that contradicts a recorded decision always goes back to you. Trust boundaries such as input size, parse errors and ownership checks are always in scope.

## Testing

`evals/` holds 16 cases for `claude plugin eval`, each run with and without the plugin. On the last full run (3 runs per case) the plugin averaged 0.99 against 0.65 for the baseline, at about 1.4 times the cost. Most of the gap is on things a plain session does not do, such as plan gates, setup and review. On small tasks that a plain session already handles well, scores are equal and the plugin only adds cost. Run it yourself:

```bash
claude plugin eval . --scaffold --allow-tools Write Edit "Bash(node *)" "Bash(git *)"
```

## Limits

Results come from small synthetic projects and a few runs per case. The eval sandbox blocks `git`, so review cases pass the diff as a file.

## License

MIT
