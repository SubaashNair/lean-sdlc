---
name: lean
description: YAGNI-first workflow for features, bug fixes (even one-line ones), refactors and renames across files. Skip for typos and cosmetic edits. Sizes the task, plans only when needed, builds test-first, reviews in fresh context, keeps the diff minimal.
---

# Lean

Do the least that satisfies confirmed requirements. A stage, artifact or gate exists only if skipping it has caused a failure. The preset (`solo` or `team`) is in `.lean/config.yaml`; with no file, assume `solo`.

## Principles

Follow YAGNI, KISS, DRY and SOLID where appropriate.

1. Implement only confirmed requirements.
2. Do not introduce speculative features.
3. Prefer the simplest maintainable solution.
4. Avoid unnecessary abstractions.
5. Do not optimize without evidence.
6. Keep changes within the requested scope.
7. Refactor and remove unused code when appropriate.

Before adding a dependency or architectural layer, explain in one sentence why the current requirements justify it. Tie-breaks: refactor or delete only inside files you already touch (larger cleanups go to `.lean/followups.md`); YAGNI beats DRY until a pattern appears a third time; SOLID is judgment, not a checklist.

## 1. Size it (state the size in one line)

| Size | Test | Do |
|---|---|---|
| S0 | The diff fits in one sentence | Do it, then run the existing tests if there are any. No artifact. |
| S1 | Small change or bug | Check first, build, show evidence. Intent lives in the PR or issue body. |
| S2 | Feature, several files, or anything that adds a page, endpoint or schema the user has not specified | `plan.md`, plan gate, tracer slices, review. |
| S3 | Large or ambiguous | `plan.md` plus a spec section, tickets that each fit one fresh context. |

When unsure between two sizes, pick the smaller and say so. Exception: if the request contradicts a recorded decision (in `plan.md`, an accepted risk or an ADR), it is S2 at least, and you do not build. Write `plan.md` naming the conflict and the decision it overwrites, ask for an explicit "yes, override the decision" (not ordinary approval), and stop. Until that answer comes, write the plan, stop and report its path; implement nothing, not even a trial. Never edit a decision to match the request.

## 2. Climb the ladder before writing code

Stop at the first rung that holds: needed at all? already in this codebase? stdlib? platform feature? installed dependency? one line? only then, the minimum code.

## 3. Build loop (S1 and up)

1. Check for a decision conflict: if the request contradicts a recorded decision (see "Size it"), stop and go to the plan gate. Do not write tests or code until it is resolved.
2. Write the check that proves the change. For a bug, reproduce it as a failing test first and see it fail for the expected reason. For a small addition, use the repo's existing test setup; if there is none, a one-line run is enough, and do not create a test harness.
2. For a bug fix, run the check and see it fail before you touch the source, then commit the failing test on a branch (create `fix/<name>` if you are on main or master). Then run `touch .lean/fixing`; the opt-in test-edit hook blocks test edits while that file exists, and it does nothing if the hook is absent. Delete the file when done. Never change a test to make it pass unless the test is wrong; if it is, say so and show it failing on the old code before recommitting.
3. Build the smallest slice that passes. Run the check often and the full suite at the end (every time, if it takes seconds).
4. Every changed line traces to the request. Touch only files named in the plan. Anything else you notice goes to `.lean/followups.md`, one line each (`file: what (why not now)`), not into the diff. Never park a correctness or security problem there.
5. Optimize only with a measurement. Cite it.
6. Trust boundaries are always in scope, even when unlisted: validate and cap input, handle errors so one bad request cannot crash the process, check auth and ownership. Label them `implied`.

## 4. Plan gate (S2 and up)

Write `plan.md` at the repo root (`plan-<name>.md` if a plan for other work exists), one page, in this shape:

```
# Plan: <name>
Size: S2 | Date: YYYY-MM-DD | Status: draft
## Intent
## Confirmed requirements
- R1: ...
## Open questions (never become tasks)
## Files that change (the scope)
## Simplest option, and what was rejected
## Added dependency or layer (omit if none)
## Order of work (tracer slices)
## Proof (the command that must pass)
```

A requirement a confirmed one cannot work without (sign-in for accounts, say) is `implied`: include it, label it, and name it at the gate. If the plan exists because of a decision conflict, the user's normal "approved" is not enough: require them to say they are overriding the recorded decision, and include that override sentence in the plan before any code. Show the plan path and ask for approval, then wait. No code before a yes. If you cannot ask (non-interactive run) or no answer has come, write the plan, stop, and report its path. Never pass this gate on your own.

## 5. Review

- **S2 and up, or any change that touches a trust boundary** (input parsing, auth, persistence, a new dependency) **or runs past about 60 changed lines:** dispatch the `lean-reviewer` subagent with the base commit and the plan path (or PR body). Fix Important findings; skip nits; at most two rounds. If the subagent cannot run, say so plainly and do the self-check below.
- **Everything else:** re-read the diff once. Does every line trace to the request? Can any input crash it or grow without limit? Is any file, dependency or abstraction unneeded? Fix what you find.

"The diff looks small" does not waive the review for a trust boundary.

## 6. Done

No "done" without fresh output of the check, build and lint (paste it). Merge is a human decision: in `solo` that is the user; in `team` a different person than the author (name the `tech_lead` from `.lean/config.yaml`). Final report: what changed, evidence, `net: +A -D lines`, follow-ups.

## Context hygiene

Hand off with file paths, not pasted content. Use a subagent for exploration and for verbose output. `/clear` between S3 tickets. Do not name a model in a skill; model switches break the cache.
