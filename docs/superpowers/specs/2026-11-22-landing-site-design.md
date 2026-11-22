# Landing site design

**Intent:** a public page for the plugin with what the skill does, images of the eval results and the install commands. The README gets the same up-to-date story.

**Approaches considered** (mockups in the workspace, not committed)
- A, clean docs: light, card-based, closest to Noodle's site.
- B, terminal (picked): dark, hero shows a real run stopping on a recorded decision, S0 to S3 as a staircase, per-case eval chart.
- C, report: editorial serif, numbered sections.
B was picked because it shows the skill working rather than listing features, and matches the existing `docs/benchmark.html`.

**Design**
- One self-contained file, `docs/index.html` (inline CSS, SVG, a few lines of JS). No build, no dependencies.
- Hosted with GitHub Pages from `main` `/docs`: `https://subaashnair.github.io/lean-sdlc/`. `docs/benchmark.html` stays and is linked as the full report.
- Working copy button, real nav links, single column on narrow screens.
- Numbers come only from `docs/benchmark-report.md` (run 2026-10-26, commit `cfb55ce`) and its real-repo rerun.
- README: link to the site, an eval chart image (`docs/evals.svg`, static, also used by nothing else), the per-case table summary and the real-repo result.

**Non-goals:** docs pages, custom domain, analytics, renaming the plugin.
**Builder's calls:** exact copy, colors, and the SVG layout.
