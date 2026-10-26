#!/bin/bash
# Extracts the hook scripts embedded in skills/lean-init/SKILL.md and checks their exit codes.
# Usage: bash tests/hooks.sh [path/to/SKILL.md]
skill="${1:-$(dirname "$0")/../skills/lean-init/SKILL.md}"
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
dir="$tmp/proj dir"
mkdir -p "$dir/.lean"
awk -v t="$tmp" '/^```bash$/{n++; f=t (n==1?"/block.sh":"/gate.sh"); next} /^```$/{f=""} f{print > f}' "$skill"
chmod +x "$tmp/block.sh" "$tmp/gate.sh"
export CLAUDE_PROJECT_DIR="$dir"
fail=0
check() { # expected-exit description stdin command...
  local want=$1 desc=$2 in=$3; shift 3
  out=$(printf '%s' "$in" | "$@" 2>&1); got=$?
  if [[ $got == "$want" ]]; then echo "ok   $desc"; else echo "FAIL $desc (want $want got $got: $out)"; fail=1; fi
}
src='{"tool_input":{"file_path":"'"$dir"'/src/app.js"}}'
G=$tmp/gate.sh B=$tmp/block.sh
plan() { rm -f "$dir"/plan*.md; [[ -n "$1" ]] && printf '%b\n' "$1" > "$dir/plan.md"; }

plan "";                                               check 0 "no plan allows" "$src" $G
plan "# Plan: x\nSize: S2 | Date: 2026-10-26 | Status: draft"; check 2 "draft blocks" "$src" $G
plan "Size: S2 | Status: approved";                    check 0 "inline approved allows" "$src" $G
plan "Status: Approved";                               check 0 "capital Approved allows" "$src" $G
plan "**Status:** approved";                           check 0 "bold Status allows" "$src" $G
plan "Status: approved\n> user: yes, go ahead";        check 0 "approved plus quote allows" "$src" $G
plan "Status: ready for review";                       check 2 "ready blocks" "$src" $G
plan "Status: approved-pending-override";              check 2 "approved-pending blocks" "$src" $G
plan "Status: blocked (decision conflict)\nnotes: Status: approved later"; check 2 "first status wins" "$src" $G
plan "Status:";                                        check 2 "empty status blocks" "$src" $G
plan "# Plan without status";                          check 2 "missing status blocks" "$src" $G
plan "Git status: approved\nStatus: draft";            check 2 "git status: is not the status field" "$src" $G
plan "# Plan\nGit status: clean\nStatus: approved";    check 0 "git status: line skipped" "$src" $G
plan "Status: approved (not yet, conflict open)";      check 2 "qualified approved blocks" "$src" $G
plan "Status: Approved by user";                       check 2 "approved by user blocks" "$src" $G
plan "Status: approved.";                              check 0 "trailing period allows" "$src" $G
plan "Status: approved | Owner: me";                   check 0 "field ends at pipe" "$src" $G
plan "Status: approved"; printf 'Status: draft\n' > "$dir/plan-auth.md"; check 2 "draft named plan blocks" "$src" $G
plan ""; printf 'Status: blocked (decision conflict)\n' > "$dir/plan-del.md"; check 2 "named conflict plan alone blocks" "$src" $G
plan "Status: draft";                                  check 0 "editing plan.md allowed" '{"tool_input":{"file_path":"'"$dir"'/plan.md"}}' $G
check 0 "editing .lean allowed" '{"tool_input":{"file_path":"'"$dir"'/.lean/fixing"}}' $G
check 2 "notebook path checked" '{"tool_input":{"notebook_path":"'"$dir"'/a.ipynb"}}' $G
check 2 "bad json blocks" 'not json' $G
check 2 "empty stdin blocks" '' $G
check 2 "no jq blocks" "$src" env PATH=/nonexistent /bin/bash $G

# settings snippet: quoted command survives a project path with a space
cp $G "$dir/.lean/plan-gate.sh"
cmd=$(awk '/^```json$/{n++; if(n==2){getline; print; exit}}' "$skill" | jq -r '.hooks.PreToolUse[0].hooks[0].command')
check 2 "gate command runs from path with space ($cmd)" "$src" bash -c "$cmd"
plan ""

# test-edit hook
check 0 "no fixing flag allows test edit" '{"tool_input":{"file_path":"'"$dir"'/test/a.test.js"}}' $B
touch "$dir/.lean/fixing"
check 2 "fixing blocks *.test.*" '{"tool_input":{"file_path":"'"$dir"'/a.test.js"}}' $B
check 2 "fixing blocks absolute test_*" '{"tool_input":{"file_path":"'"$dir"'/src/test_foo.py"}}' $B
check 0 "fixing allows source" "$src" $B
check 2 "fixing + bad json blocks" 'not json' $B
check 2 "fixing + empty stdin blocks" '' $B
cp $B "$dir/.lean/block-test-edits.sh"
cmd=$(awk '/^```json$/{n++; if(n==1){getline; print; exit}}' "$skill" | jq -r '.hooks.PreToolUse[0].hooks[0].command')
check 2 "test-edit command runs from path with space ($cmd)" '{"tool_input":{"file_path":"'"$dir"'/a.test.js"}}' bash -c "$cmd"
check 2 "fixing + no jq blocks" "$src" env PATH=/nonexistent /bin/bash $B
exit $fail
