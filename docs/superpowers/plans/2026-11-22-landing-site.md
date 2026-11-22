# Landing Site Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Publish option B as `docs/index.html` on GitHub Pages and bring the README up to date with the eval results.

**Architecture:** One static HTML file with inline CSS and pre-rendered inline SVG; a few lines of JS only for the copy button. A static `docs/evals.svg` chart is shared by the README. Pages serves `main:/docs`.

**Tech Stack:** HTML, CSS, SVG, bash checks (same style as `tests/hooks.sh`).

**Spec:** `docs/superpowers/specs/2026-11-22-landing-site-design.md`

## Global Constraints

- No build step, no dependencies, no external scripts, fonts or images (works offline and under the `/lean-sdlc/` base path).
- Every number comes from `docs/benchmark-report.md`: 1.00 / 0.63 (16 cases), 1.00 / 0.76 (12 comparable), 1.38x cost, $14.01, 96 runs, real repo 6/6 vs 0/3, run 2026-10-26 commit `cfb55ce`.
- Install lines exactly: `/plugin marketplace add SubaashNair/lean-sdlc` and `/plugin install lean-sdlc@lean-sdlc`.
- Site URL: `https://subaashnair.github.io/lean-sdlc/`.
- Prose has no dashes used as punctuation.

## Review Focus

1. JavaScript disabled: all text and charts still show (charts are inline SVG, not JS-rendered).
2. Clipboard API missing (http or old browser): Copy selects the text instead of failing silently.
3. Narrow screen (375px): hero, staircase and eval grid stack to one column with no horizontal scroll.
4. Links under the `/lean-sdlc/` base path: relative `benchmark.html`, absolute GitHub URLs; none start with `/`.
5. Number drift: the check script compares the page's headline numbers against `docs/benchmark-report.md`.

---

### Task 1: Landing page

**Files:**
- Create: `docs/index.html`, `docs/icon.png` (copy of `.claude-plugin/icon.png`)
- Create: `tests/site.sh`

- [ ] **Step 1: Write `tests/site.sh`** that exits non-zero on the first failure and asserts, with `grep -F` on `docs/index.html`:
  - both install lines from Global Constraints;
  - `1.00`, `0.63`, `0.76`, `1.38`, `6/6`, `0/3`, and each of the 16 case names in the report's Cases table;
  - each headline number also appears in `docs/benchmark-report.md`;
  - no `<script src=`, no `http` in `src=`/`href=` except `https://github.com/SubaashNair/lean-sdlc`, no `href="/`;
  - `<meta name="viewport"` present.
- [ ] **Step 2: Run** `bash tests/site.sh`. Expected: FAIL, `docs/index.html` missing.
- [ ] **Step 3: Build `docs/index.html`** from `.context/mockups/b.html`, with charts written out as static SVG (no `renderCaseBars`), copy button using `navigator.clipboard.writeText` with a select-text fallback, nav links: GitHub repo, README (`https://github.com/SubaashNair/lean-sdlc#readme`), `benchmark.html`; `@media (max-width:760px)` single column; `<title>`, description meta, favicon `icon.png`.
- [ ] **Step 4: Run** `bash tests/site.sh`. Expected: PASS. Screenshot at 1280 and 375 widths with headless Chrome and check by eye.
- [ ] **Step 5: Commit** `feat: landing page for GitHub Pages`.

### Task 2: Eval chart and README

**Files:**
- Create: `docs/evals.svg`
- Modify: `README.md`, `tests/site.sh`

- [ ] **Step 1: Extend `tests/site.sh`**: `docs/evals.svg` exists, has `xmlns`, contains all 16 case names; `README.md` contains the site URL, `docs/evals.svg`, `6/6` and `0/3`.
- [ ] **Step 2: Run** it. Expected: FAIL on `docs/evals.svg`.
- [ ] **Step 3: Write `docs/evals.svg`** (same paired bars as the page, dark background so it reads on both GitHub themes) and update `README.md`: site link under the title; Testing section becomes "Evaluations" with the headline table (all 16, comparable 12, cost), the chart image, the real-repo decision result (6/6 vs 0/3, baseline rewrote the decision), and links to `docs/benchmark-report.md` and the site. Keep Install, How it works and Limits accurate.
- [ ] **Step 4: Run** `bash tests/site.sh` and `bash tests/hooks.sh`. Expected: both PASS.
- [ ] **Step 5: Commit** `docs: README with eval chart and site link`.

### Task 3: Publish

- [ ] **Step 1:** Fresh-context review of the branch diff; fix CRITICAL/HIGH.
- [ ] **Step 2:** `git push -u origin feat/landing-site`, `gh pr create --base main`.
- [ ] **Step 3 (after merge):** `gh api -X POST repos/SubaashNair/lean-sdlc/pages -f 'source[branch]=main' -f 'source[path]=/docs'`, set the repo homepage to the site URL, then `curl -sI https://subaashnair.github.io/lean-sdlc/` returns 200.
