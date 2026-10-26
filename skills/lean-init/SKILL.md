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
6. **Hook (opt in):** offer it in one line. Only on a yes, write `.lean/block-test-edits.sh` (make it executable, needs `jq`), add `.lean/fixing` to `.gitignore`, and add the hook to `.claude/settings.json`, keeping `${CLAUDE_PROJECT_DIR}` literal and quoted as in the snippet (never an absolute path, since the file is shared). If the settings write is denied, say so and print the snippet for the user to add.

```bash
#!/bin/bash
# Blocks edits to test files while .lean/fixing exists (a bug-fix task). Fails closed without jq.
[ -f "${CLAUDE_PROJECT_DIR:-.}/.lean/fixing" ] || exit 0
command -v jq >/dev/null || { echo "Test-edit hook: jq is required; install it or remove the hook." >&2; exit 2; }
input=$(cat)
f=$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_input.notebook_path // empty') && [[ -n "$input" ]] || { echo "Test-edit hook: unreadable hook input." >&2; exit 2; }
case "$f" in
  *_test.*|*.test.*|*.spec.*|*/test/*|*/tests/*|*/__tests__/*|test_*|*/test_*)
    echo "Fix task: fix the code, not the test. Delete .lean/fixing if the test itself is wrong." >&2
    exit 2 ;;
esac
exit 0
```

```json
{"hooks":{"PreToolUse":[{"matcher":"Edit|MultiEdit|Write|NotebookEdit","hooks":[{"type":"command","command":"\"${CLAUDE_PROJECT_DIR}\"/.lean/block-test-edits.sh"}]}]}}
```

7. **Plan-gate hook (opt in):** offer it in one line ("Block source edits until every plan file has an approved status?"). Only on a yes, write `.lean/plan-gate.sh` (make it executable, needs `jq`), **merge** this hook into the existing `.claude/settings.json` `hooks.PreToolUse` (do not overwrite the test-edit entry), keeping `${CLAUDE_PROJECT_DIR}` literal and quoted. If the settings write is denied, say so and print the snippet. It blocks edits while any `plan.md` or `plan-*.md` at the repo root lacks `Status: approved`, so a blocked decision-conflict plan stops all source edits. Say its limits when offering it: it checks a status line, not who wrote it, and it does not see writes made through Bash.

```bash
#!/bin/bash
# Blocks source edits until every plan.md / plan-*.md at the repo root says Status: approved. No plan -> allow (not a lean task).
# Fails closed: a missing jq or unreadable input blocks the edit.
command -v jq >/dev/null || { echo "Plan gate: jq is required; install it or remove the hook." >&2; exit 2; }
input=$(cat)
f=$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_input.notebook_path // empty') && [[ -n "$input" ]] || { echo "Plan gate: unreadable hook input." >&2; exit 2; }
[[ -z "$f" ]] && exit 0
case "$f" in
  plan.md|*/plan.md|plan-*.md|*/plan-*.md|.lean/*|*/.lean/*) exit 0 ;;
esac
for plan in "${CLAUDE_PROJECT_DIR:-.}"/plan.md "${CLAUDE_PROJECT_DIR:-.}"/plan-*.md; do
  [[ -f "$plan" ]] || continue
  # Only the first Status: field (at line start or after "|", up to the next "|") counts; it must be exactly "approved" (any case).
  status=$(awk '{ l = tolower($0); if (match(l, /(^|[|])[ \t*#>-]*status:/)) { v = substr(l, RSTART + RLENGTH); sub(/[|].*/, "", v); sub(/^[ \t*]+/, "", v); sub(/[ \t*.]+$/, "", v); print v; exit } }' "$plan")
  if [[ "$status" != approved ]]; then
    echo "Plan gate: $(basename "$plan") has status '${status:-none}', not approved. Ask the user for approval and stop before editing code." >&2
    exit 2
  fi
done
exit 0
```

```json
{"hooks":{"PreToolUse":[{"matcher":"Edit|MultiEdit|Write|NotebookEdit","hooks":[{"type":"command","command":"\"${CLAUDE_PROJECT_DIR}\"/.lean/plan-gate.sh"}]}]}}
```

Switching presets later: rerun this skill and change only `preset` and the names.
