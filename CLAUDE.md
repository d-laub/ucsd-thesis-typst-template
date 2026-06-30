# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

A reusable **Typst** template for a UC San Diego **doctoral (PhD, non-joint)**
dissertation, built to satisfy every hard requirement in the 2025–2026 UCSD
*Preparation and Submission Manual*. The template layer (`lib/`) carries no
personal values so it can be released to Typst Universe later; the author's
actual thesis content is assembled on top of it.

## Commands

Everything runs through `pixi` (pins Typst 0.15 + the vendored font, so output is
machine-identical):

```
pixi run build        # compile tests/smoke.typ -> build/smoke.pdf
pixi run calibrate    # print line-spacing calibration metadata (query <calib>)
pixi run fonts        # list fonts discoverable under fonts/
```

There is **no test runner and no pytest**. Each file under `tests/` is a
self-contained Typst document; the "test" is compiling it, and a failure is a
compile error, a compile *warning*, or a failing in-document `#assert`. Compile a
single test directly (the pixi tasks only build `smoke.typ`):

```
mkdir -p build && pixi run typst compile --font-path fonts --root . tests/<name>.typ build/<name>.pdf
```

`pixi run typst query --font-path fonts --root . tests/<name>.typ "<label>" --field value`
inspects emitted `#metadata`/labels (e.g. `<calib>`, float caption positions) for
assertions a PDF can't express. A passing test compiles clean with **zero
warnings** — treat warnings as failures.

## Architecture

Each `lib/` module exposes show-rule bundles (`#show: <name>-rules`) and helper
functions; **`dissertation()` in `template.typ` is the only master wrapper** and
the others layer on top via `#show` in the document, not by editing
`dissertation()`. Composition order in a real document is:
`#show: dissertation` → `#show: floats-rules` → `#show: backmatter-rules`, then
`front-matter()` … `main-matter()` … `back-matter()` as inline calls.

- **`lib/template.typ`** — page geometry (US Letter, 1″ margins), font (TeX Gyre
  Heros 12pt black), double-spaced body via the calibrated `body-leading`, 0.5″
  first-line indent on every paragraph, single-spaced ≥10pt footnotes.
- **`lib/pagination.typ`** — `front-matter()` (roman `i`), `main-matter()`
  (restart Arabic `1`), `back-matter()`; centered footer 0.5″ from the bottom
  edge.
- **`lib/floats.typ`** — `fig`/`tbl`/`scheme`/`graph` constructors and
  `floats-rules`: per-chapter `chapter.n` numbering, caption placement (figure &
  scheme below; table & graph above), facing-caption pages, 90° landscape.
- **`lib/backmatter.typ`** — `backmatter-rules` (single-spaced bibliography,
  blank line between entries) and the auto-lettered `appendix(title, body)`.
- **`lib/blocks.typ`** — the `single-spaced` primitive (0.65em leading) reused by
  every single-spacing carve-out, and `long-quote`.

### The matter-state contract (read before touching headings/counters)

`lib/pagination.typ` and `lib/floats.typ` communicate through a global
`state("ucsd-matter")` keyed by string — **no import between them**; Typst state
is global and keyed by name. Values: `"front" | "main" | "back"` (default
`"main"` so standalone test files still render chapters). `floats-rules` steps the
dedicated `counter("ucsd-chapter")`, resets float counters, and renders
"CHAPTER N" **only when the state reads `"main"`**. This gating is what stops
appendix and bibliography level-1 headings from being treated as chapters — the
exact bug locked by `tests/cross-phase.typ`. When editing heading or counter
logic, keep that test passing and respect this contract.

Two spacing constants are intentionally duplicated as literals: `0.65em` (single
leading) appears in `blocks.typ` and `backmatter.typ`'s `bib-leading`. Keep them
in sync if either changes.

## Compliance & process

- **`docs/compliance-checklist.md` is the project spine** — every MUST from the
  manual as a checkable row tagged with the phase that owns it. When you implement
  or verify a rule, update its checkbox; "compliant" means rows are objectively
  satisfied, not asserted.
- Source-of-truth references live in the repo: `formattingmanual.pdf` (the
  authoritative manual; cite page numbers) and
  `DissertationTemplate_Doctoral_v2.3.docx` (official Word skeleton).
- Work is organized into phases P0–P6 (`docs/roadmaps/`,
  `docs/superpowers/specs/`, `docs/superpowers/plans/`). Phases are built to be
  independently compilable and parallel-safe — each plan touches only its own new
  files and avoids editing shared files (`template.typ`, `blocks.typ`,
  `pixi.toml`, `smoke.typ`, the checklist), and adds **no pixi tasks**.

For Typst syntax/reference questions and idiomatic `.typ` authoring, use the
`typst-author` skill (vendored under `.claude/skills/`).
