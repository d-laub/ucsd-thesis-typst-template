# Spec: Phase 3 — Body Floats & Headings

**Date:** 2026-06-26
**Roadmap:** `docs/roadmaps/2026-06-26-ucsd-thesis-typst-roadmap.md` (Phase 3)
**Status:** Approved design; ready for `writing-plans`.
**Depends on:** P0.

## Goal

Implement chapter/section heading styles and the four float kinds (figure, table,
scheme, graph) with per-kind caption placement, per-chapter numbering, single-spaced
captions, facing-caption pages, and 90° landscape rotation. After this phase the body
of the dissertation renders correctly; P4 consumes these float definitions for its
List-of pages.

Output: `lib/floats.typ` plus `tests/floats.typ` exercising every heading level, all
four float kinds, a facing-caption float, and a landscape float — compiling with zero
warnings.

## Authoritative rules (from `formattingmanual.pdf`, §III pp.38–42)

| Rule | Manual ref |
|---|---|
| **Figure** caption **below** the figure | p.38 |
| **Table** caption **above** the table | p.39 |
| **Scheme** caption **below** the scheme | p.39 |
| **Graph** caption **above** the graph | p.39 |
| Captions **single-spaced**, consistent format throughout | p.38 |
| Literal prefix "Figure"/"Table"/"Scheme"/"Graph" precedes each caption | p.38 |
| Per-chapter numbering: chapter identification, e.g. `1.1`, `1.2` | p.38 |
| Facing caption page **precedes** the float when caption/float too large | p.38 |
| Landscape float rotated 90°, **top along the left margin** | p.40, sample p.41 |
| Continued multipage float caption states "Continued"; table headers repeat | p.38 |

The manual does **not** prescribe heading format beyond: italics not allowed for
headings (§ p.36, non-MLA), and TOC titles must match the body exactly (§ p.25).

## Decisions (locked)

1. **Chapter heading = two-line centered display:** `CHAPTER 1` on its own line, the
   chapter title below it. Implemented as a `show heading.where(level: 1)` rule.
2. **Sections/subsections (levels ≥ 2) are unnumbered display headings.** No `1.1`,
   `1.1.1` section numbers. Chapters themselves *are* numbered (the "CHAPTER 1" label),
   and that chapter counter still drives float numbering.
3. **Caption placement via show-set on `figure.caption.position`** — `bottom` for
   figure & scheme, `top` for table & graph — not by hand-assembling caption blocks.
4. **Per-chapter float numbering with reset at each chapter.** The level-1 heading show
   rule resets every float counter; each float's numbering function reads the chapter
   counter to produce `chapter.n` with the literal kind prefix.
5. **Facing-caption is an explicit `facing: true` flag**, not auto-detected. Layout
   overflow measurement is fragile; the author opts in per float. `facing: true` emits
   a caption-only page immediately preceding the float page.
6. **Landscape is an explicit `landscape: true` flag** → content rotated 90° so the
   float's top edge runs along the left margin. Exact rotation direction verified
   empirically against the manual's sample (p.41).
7. **Captions reuse P0's `single-spaced`** primitive from `lib/blocks.typ` — one source
   of truth for single spacing across captions, long quotes, footnotes, bibliography.
8. **Heading/float rules are exposed as an applicable show-rule bundle**
   (`#show: floats-rules`), NOT by editing `lib/template.typ` — keeps P3 to new files
   only so P1/P3/P5 stay parallelizable.

## Architecture

```
lib/
  floats.typ        # floats-rules show bundle; fig/tbl/scheme/graph; chapter counter
tests/
  floats.typ        # headings L1–L3, all four kinds, a facing float, a landscape float
```

### `lib/floats.typ`

Exposes:

- **`floats-rules(body)`** — a `#show: floats-rules` bundle that installs:
  - `show heading.where(level: 1)`: two-line `CHAPTER <n>` / title, centered; resets
    the figure/table/scheme/graph counters.
  - `show heading.where(level: >= 2)`: unnumbered display headings.
  - `show figure.where(kind: image): set figure.caption(position: bottom)`
  - `show figure.where(kind: table): set figure.caption(position: top)`
  - `show figure.where(kind: "scheme"): set figure.caption(position: bottom)`
  - `show figure.where(kind: "graph"): set figure.caption(position: top)`
  - `show figure.caption: single-spaced` (captions single-spaced).
- **Float constructors** `#fig`, `#tbl`, `#scheme`, `#graph` — thin wrappers over
  `figure(...)` that set `kind`, `supplement` (the literal prefix), the per-chapter
  `numbering` function (`chapter.n`), and forward `caption`, `facing`, `landscape`.
- **Chapter counter** keyed off level-1 headings; float numbering reads it via
  `numbering("1.1", chapter, n)`.
- **`facing: true`** path: `pagebreak()` + vertically-centered caption-only page +
  `pagebreak()` + the float.
- **`landscape: true`** path: rotate the float+caption 90° (`rotate`/`move` with the
  correct origin) so the top edge is on the left margin.

## Non-goals (deferred)

- TOC and List-of-Figures/Tables/Schemes/Graphs pages (consume these floats) → **P4**.
- Auto "Continued" handling for multipage floats → noted; minimal/manual in P3,
  refined in P6 if real content needs it.
- Pagination, front matter, bibliography → P1 / P2 / P5.

## Verification

P3 is complete when:

1. `tests/floats.typ` compiles with **zero warnings**.
2. A level-1 heading renders as two centered lines `CHAPTER 1` / title; levels ≥ 2 are
   unnumbered.
3. Figure & scheme captions render **below**; table & graph captions render **above**;
   all captions are single-spaced and carry the literal prefix + `chapter.n` number.
4. Float numbers reset per chapter (chapter 2's first figure is `2.1`).
5. A `facing: true` float places its caption on the preceding page.
6. A `landscape: true` float is rotated 90° with its top along the left margin.
7. These `compliance-checklist.md` **[P3]** rows are satisfied (checked off in P6):
   figure/scheme caption below; table/graph caption above; captions single-spaced;
   literal prefix; facing caption page; 90° landscape; chapter identification numbering.

## Open risks

- **Custom kinds "scheme"/"graph":** Typst figures key numbering/counters off `kind`;
  confirm string kinds (`kind: "scheme"`) integrate with the per-chapter counter reset
  and that P4's List-of queries can select them. Verify in the test.
- **Rotation direction:** "top along the left margin" fixes the sign of the rotation;
  confirm empirically against sample p.41 (a 90° error mirrors the float).
- **Counter reset timing:** ensure the level-1 reset fires *before* the chapter's first
  float numbers, not after — verify chapter 2 starts at 2.1, not 1.x continued.
