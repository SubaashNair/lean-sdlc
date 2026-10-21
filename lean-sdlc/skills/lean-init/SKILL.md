---
name: lean-init
description: One-time setup of lean-sdlc in a repo. Picks the solo or team preset, writes .lean/config.yaml and a short pointer in CLAUDE.md.
disable-model-invocation: true
---

# Lean init

Run once per repo. Explore, recommend, confirm, then write. Ask one question at a time and lead with the recommended answer. If the caller has already given the answers, use them and do not ask.

1. **Explore:** `git remote -v`, CLAUDE.md or AGENTS.md, build, test and lint commands (package.json, Makefile, pyproject), CODEOWNERS, existing `.lean/`. If `.lean/` exists, show it and ask before changing anything.
2. **Preset:** `solo` (recommended unless git log shows two or more authors) or `team`. For `team`, ask who is the product owner and the tech lead.
3. **Write `.lean/config.yaml`** with the detected commands, in this shape (omit `hats` for `solo`):

```yaml
preset: solo        # solo | team
commands:
  build: ""
  test: ""
  lint: ""
hats:               # team only
  product_owner: ""
  tech_lead: ""
```

4. **CLAUDE.md:** add the commands plus one line: "Use the lean skill." No copied rules; the principles live in the skill.
5. **Team only:** write `REVIEW.md` at the repo root:

```markdown
# Review instructions
## Passes
Tag each finding with its pass: Correctness and robustness; Requirements (the diff meets plan.md and builds nothing unconfirmed); Scope and simplicity (files outside the plan, speculative features, one-implementation abstractions, unjustified dependencies, unmeasured optimization, dead code, logic repeated three or more times).
## What Important means here
Findings that break behavior, leak data or breach scope. Style and naming are nits.
## Cap the nits
At most five per review; summarize the rest as a count.
## Do not report
Generated files and anything CI already enforces.
```

   Then print this checklist (do not perform it): branch protection needing one human approval, CODEOWNERS entries, the author never approves their own merge.
6. **Hook (opt in):** offer it in one line. Only on a yes, write `.lean/block-test-edits.sh` (make it executable, needs `jq`) and add the hook to `.claude/settings.json`.

```bash
#!/bin/bash
# Blocks edits to test files while .lean/fixing exists (a bug-fix task).
[ -f "${CLAUDE_PROJECT_DIR:-.}/.lean/fixing" ] || exit 0
f=$(jq -r '.tool_input.file_path // empty')
case "$f" in
  *_test.*|*.test.*|*.spec.*|*/test/*|*/tests/*|*/__tests__/*|test_*)
    echo "Fix task: fix the code, not the test. Delete .lean/fixing if the test itself is wrong." >&2
    exit 2 ;;
esac
exit 0
```

```json
{"hooks":{"PreToolUse":[{"matcher":"Edit|Write","hooks":[{"type":"command","command":"${CLAUDE_PROJECT_DIR}/.lean/block-test-edits.sh"}]}]}}
```

Switching presets later: rerun this skill and change only `preset` and the names.
