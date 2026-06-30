# P6 — Integration & Compliance — Design Spec

**Date:** 2026-06-30
**Phase:** P6 (final integration & compliance pass)
**Depends on:** P0–P5 (all complete and merged).
**Status:** Approved design; ready for `writing-plans`.

## Goal

Assemble the P0–P5 template layer into complete, compiling documents and prove
the manuscript satisfies every hard requirement in `formattingmanual.pdf`. P6
produces **two** documents and a verification report; it does **not** write real
dissertation prose, and it does **not** redesign any `lib/` module.

## Deliverables

Two Typst documents, both compiling clean (**zero warnings** — warnings are
failures, per CLAUDE.md) under the existing invocation
`typst compile --font-path fonts --root . <doc> <out.pdf>`:

```
thesis.typ                 # author's real skeleton: real metadata, placeholder chapter bodies
chapters/
  01-introduction.typ
  02-....typ               # author's outline as stubs (count/titles are placeholders)
examples/
  thesis.typ              # generic, self-contained, NO personal data; exercises EVERY feature
  chapters/
    01-....typ … 03-....typ
docs/
  p6-verification.md       # NEW: compliance evidence report
  compliance-checklist.md  # EDITED: every box ticked with evidence
```

Plus edits: `pixi.toml` (two new build tasks), `README.md` (document the new
build targets). No edits to any `lib/` module, `tests/`, `blocks.typ`, or
`template.typ`.

### Approach decision: example placement

The generic example lives under `examples/` and imports the template via
**relative paths** (`#import "../lib/template.typ": ...`), exactly like the test
files. Rationale: it compiles in-repo under the same `--root .` gate and stays
inside the zero-warning compile check.

A Universe-style `template/main.typ` that imports `@preview/ucsd-dissertation`
is **explicitly out of scope** for P6. The `[template]` manifest block, the
`@preview` import swap, and the thumbnail are a release chore, tracked as a
follow-up — not part of integration/compliance.

## Composition pattern (canonical, both documents)

`dissertation()` remains the only master `#show` wrapper; the other modules layer
on top via `#show` in the document (never by editing `dissertation()`). Both
documents open identically:

```typst
#import "<lib>/template.typ": dissertation
#import "<lib>/pagination.typ": front-matter, main-matter, back-matter
#import "<lib>/frontmatter.typ": title-page, copyright-page, approval-page,
  dedication, epigraph, preface, acknowledgements, vita, abstract
#import "<lib>/lists.typ": table-of-contents, list-of-figures, list-of-schemes,
  list-of-tables, list-of-graphs, list-of-abbreviations, list-of-symbols,
  list-of-supplemental-files
#import "<lib>/floats.typ": floats-rules, fig, tbl, scheme, graph
#import "<lib>/backmatter.typ": backmatter-rules, appendix

#show: dissertation
#show: floats-rules
#show: backmatter-rules

#let meta = (
  title: [...],
  degree: [Doctor of Philosophy],
  degree-field: [...],
  author: [...],
  year: [2026],
  committee: (chair: [...], co-chair: none, members: ([...], [...])),
)
```

`<lib>` is `lib` for `thesis.typ` (repo root) and `../lib` for
`examples/thesis.typ`.

### `meta` dict shape (consumed by frontmatter builders)

| Field          | Type                              | Used by                         |
|----------------|-----------------------------------|---------------------------------|
| `title`        | content                           | title, abstract                 |
| `degree`       | content (`[Doctor of Philosophy]`)| title, abstract                 |
| `degree-field` | content                           | title, abstract                 |
| `author`       | content                           | title, copyright, approval, abstract |
| `year`         | content                           | title, copyright, approval, abstract |
| `committee`    | dict: `chair`, `co-chair` (or `none`), `members` (array) | title, abstract |

Note: `dissertation()` declares `title/author/degree/year` params but does not
consume them (the footer is state-driven). They stay as-is — left at their `none`
defaults via the bare `#show: dissertation`. No rewiring in P6.

### Canonical preliminary-page order (checklist rows 41–57)

Emitted in this exact order between `#front-matter()` and `#main-matter()`. Each
optional page is included in the example and present-or-omitted as appropriate in
the real skeleton. List-of pages auto-skip when their kind is absent.

1. `title-page(meta)` — i, unnumbered
2. `copyright-page(meta)` — ii, unnumbered (or `blank-page()` if declined)
3. `approval-page(meta)` — iii, first displayed roman
4. `dedication[...]` — optional
5. `epigraph[...]` — optional
6. `table-of-contents()` — required
7. `list-of-abbreviations(...)` — optional
8. `list-of-symbols(...)` — optional
9. `list-of-supplemental-files(...)` — optional
10. `list-of-figures()` — required if figures present
11. `list-of-schemes()` — required if schemes present
12. `list-of-tables()` — required if tables present
13. `list-of-graphs()` — required if graphs present
14. `preface[...]` — optional
15. `acknowledgements[...]` — optional (required if co-authored material)
16. `vita(...)` — required (doctoral)
17. `abstract(meta)[...]` — required

Then `#main-matter()`, `#include` chapters, `#back-matter()`, appendices,
`#bibliography(...)`.

### Co-authored-chapter acknowledgement (no new lib code)

Handled by **composition**, not a helper (YAGNI). The author stores the
acknowledgement once and reuses it:

```typst
#let coauthor-ack = [Chapter 2, in full, is a reprint of ... The dissertation
  author was the primary investigator and author of this material.]
```

Used in two places: passed to the front-matter `acknowledgements[coauthor-ack]`
page, and emitted as the last paragraph of the co-authored chapter (double-spaced,
0.5″ first-line indent — inherits body defaults; checklist rows 145–148). The
example demonstrates this pair; the real skeleton includes a commented stub.

## The example document — feature-coverage matrix

`examples/thesis.typ` exists to give the compliance pass something to verify, so
it exercises every checklist-relevant feature at least once:

- **Front matter:** every page in the canonical order, including all optional
  pages, a vita with `publications` + `fields`, an abstract whose body is < 350
  words by construction.
- **Floats (across ≥2 chapters):** `fig` (caption below), `tbl` (caption above),
  `scheme` (caption below), `graph` (caption above); one `fig(..., facing: true)`
  facing-caption page; one `fig(..., landscape: true)` 90° float; a float with a
  `short:` caption to exercise List-of abbreviation.
- **Lists:** all 7 List-of pages populated (figures/schemes/tables/graphs from the
  floats; abbreviations/symbols/supplemental-files from author-supplied entries).
- **Body primitives:** a `long-quote`, a `footnote`, multi-level headings
  (chapter → section → subsection) for TOC depth.
- **Co-authored chapter:** the `coauthor-ack` composition pattern.
- **Back matter:** one `appendix(...)`, then `bibliography(...)` using
  `references.bib` + `styles/ieee-full-authors.csl`.

Chapters are 2–3 short placeholder bodies (lorem-style filler) carrying the
floats; no real scholarship.

## The real `thesis.typ` skeleton

Leaner — only the pages the author will actually use. Metadata fields present and
filled where inferable: `author: [David Laub]`, `degree: [Doctor of Philosophy]`,
`year: [2026]`, university constant baked into the builders. `TODO:` markers for
`title`, `degree-field`, `committee`, and vita content. Chapter files under
`chapters/` are stubs (heading + one placeholder paragraph) the author replaces
while writing. Includes the co-author-acknowledgement stub (commented) so the
mechanism is ready when needed.

## Compliance verification — two tracks

### Track A — machine (hard gate, in-document)

Verified by `#assert` inside the example and/or `typst query` against emitted
labels/metadata. A failure is a compile error or a non-matching query value.

| Requirement | Mechanism |
|---|---|
| Title counted i, copyright ii (unnumbered) | `counter(page).at(<ucsd-copyright-page-end>)` query → `(2,)` |
| Approval displayed iii; prelims roman | query `counter(page)` at approval label → `3`; footer pattern check |
| Main body restarts at Arabic 1 | `counter(page)` at first chapter heading location → `1` |
| Per-chapter float numbering `chapter.n` | assert via `chapter-counter` + `counter(figure.where(kind:…))` (pattern from `cross-phase.typ`) |
| Caption placement per kind | assert `figure.caption.position` per kind, or visual (Track B) |
| Abstract ≤ 350 words | extract abstract source text, `wc -w` < 350 (recorded in report) |
| Zero compile warnings | both docs compile with no warning output |

Where a numeric assert needs a stable anchor, add a `<label>` next to the element
(same technique as the existing `<ucsd-copyright-page-end>`), placed in the
**example** only (never in `lib/`).

### Track B — visual (sample-page diff)

Render each sample-sensitive page of the example to PNG and compare against the
corresponding `formattingmanual.pdf` page; record a pass/fail judgment with the
page reference.

| Page | Manual sample |
|---|---|
| Title page | p. 13 |
| Copyright page | p. 17 |
| Approval page | p. 19 |
| Vita | p. 31 |
| Abstract (2.5″ top margin, header) | p. 33 |
| TOC + List-of (dot leaders, titles) | pp. 26–27 |
| Captions / facing / landscape | pp. 40–42 |
| Page-number position (centered, 0.5″ from edge) | any body page |

Tuned `v()` spacers in `title-page` / `approval-page` / `abstract` (flagged in
`frontmatter.typ` as "adjust against the sample") are finalized here against the
samples.

### Output

`docs/p6-verification.md` lists every checklist row touched by P6 with its
evidence: the assert name, the query value, or "visual vs p.N: pass". Then the
boxes in `compliance-checklist.md` are ticked. A row is "compliant" only when
objectively backed by an entry in the report — including the rows previously
marked `[P1]`/`[P6]` that no document had yet exercised end-to-end.

## Build tasks

Add to `pixi.toml` (P6 is the integration phase; editing `pixi.toml`,
`compliance-checklist.md`, and `README.md` is in-bounds):

```
thesis  = "mkdir -p build && typst compile --font-path fonts --root . thesis.typ build/thesis.pdf"
example = "mkdir -p build && typst compile --font-path fonts --root . examples/thesis.typ build/example.pdf"
```

Document both in `README.md`.

## Scope boundaries (out of scope for P6)

- Real chapter prose / real scholarship.
- Universe `[template]` manifest block, `@preview` import swap, thumbnail image.
- Any redesign of `dissertation()` or other `lib/` modules (including wiring the
  unused `dissertation()` metadata params into `set document(...)`).
- New pixi tasks beyond the two build targets above.

## Acceptance criteria

1. `pixi run thesis` and `pixi run example` both compile with zero warnings.
2. Every Track-A assert passes; abstract word count recorded < 350.
3. Every Track-B page judged pass against its manual sample (spacers tuned as
   needed).
4. `docs/p6-verification.md` exists and backs every P6-owned checklist row.
5. Every box in `compliance-checklist.md` is checked, each with report evidence.
6. The example contains no personal data; `thesis.typ` carries the author's real
   metadata with `TODO:` markers where content is pending.
