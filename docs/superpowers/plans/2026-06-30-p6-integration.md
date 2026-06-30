# P6 — Integration & Compliance Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Assemble the P0–P5 template into two complete compiling documents (a generic feature-exercising example and the author's real skeleton) and produce an evidence-backed compliance pass.

**Architecture:** Both documents compose `#show: dissertation` → `#show: floats-rules` → `#show: backmatter-rules`, then call the front/main/back-matter helpers and page builders inline. No `lib/` module is modified. Verification has two tracks: in-document `#assert`/`query` (hard compile gate) and a visual diff of rendered pages against `formattingmanual.pdf` samples, recorded in `docs/p6-verification.md`.

**Tech Stack:** Typst 0.15 (pinned via pixi), TeX Gyre Heros vendored under `fonts/`.

## Global Constraints

- Every document MUST compile with **zero warnings** — a warning is a failure. Verify with the exact compile command shown in each task; expected output is empty (no errors, no warnings).
- Compile invocation is always `pixi run typst compile --font-path fonts --root . <doc> <out.pdf>` (run from repo root).
- Do **not** edit any `lib/` module, any file under `tests/`, `blocks.typ`, `template.typ`, or `pixi.lock`. **One bounded exception:** the `v()` spacer values inside `title-page`, `approval-page`, and `abstract` in `lib/frontmatter.typ` may be tuned (those builders are commented "a tuned starting point; adjust against the sample") — values only, no structural change. If you touch them, re-run `tests/frontmatter.typ` (Task 6) to confirm it still compiles clean. P6 owns only: new files under `examples/`, `chapters/`, `thesis.typ`, `docs/p6-verification.md`; edits to `pixi.toml`, `README.md`, `docs/compliance-checklist.md`; and the bounded spacer exception above.
- Scope: **PhD, non-joint.** No DMA/EdD/Joint/Master's variants.
- `examples/**` carries **no personal data** (fake author "Ada Lovelace", fake committee). `thesis.typ` carries the author's real metadata with `TODO:` markers where content is pending.
- Add exactly **two** new pixi tasks (`example`, `thesis`); no others.
- The example imports the template via **relative paths** (`../lib/...`). Universe `[template]` packaging is out of scope.
- `#include`d chapter files do NOT inherit the includer's `#let` bindings — any shared value (e.g. the co-author acknowledgement) lives in its own importable module.

---

### Task 1: Example skeleton — front matter, one stub chapter, back matter

A complete compiling document with every front-matter page in canonical order, a single placeholder chapter, an appendix, and the bibliography. List-of-float pages auto-skip (no floats yet). This locks the composition pattern and preliminary-page order.

**Files:**
- Create: `examples/ack.typ`
- Create: `examples/chapters/01-introduction.typ`
- Create: `examples/thesis.typ`

**Interfaces:**
- Consumes (from `lib/`): `dissertation`; `front-matter`, `main-matter`, `back-matter`; `title-page(meta)`, `copyright-page(meta)`, `approval-page(meta)`, `dedication(body)`, `epigraph(body)`, `preface(body)`, `acknowledgements(body)`, `vita(entries:, publications:, fields:)`, `abstract(meta, body)`; `table-of-contents()`, `list-of-figures/schemes/tables/graphs()`, `list-of-abbreviations/symbols/supplemental-files(entries)`; `floats-rules`; `backmatter-rules`, `appendix(title, body)`.
- `meta` dict shape: `(title, degree, degree-field, author, year, committee: (chair, co-chair, members))`.
- Two-column list `entries`: array of `(term, definition)` dicts. Vita `entries`: array of `(year, body)` dicts.
- Produces: `examples/ack.typ` exports `coauthor-ack` (content), imported by both `examples/thesis.typ` and (Task 2) `examples/chapters/02-methods.typ`.

- [ ] **Step 1: Create the shared co-author acknowledgement module**

`examples/ack.typ`:

```typst
// Shared so the identical text appears on the Acknowledgements page AND at the
// end of the co-authored chapter (#include does not share #let bindings).
#let coauthor-ack = [
  Chapter 2, in full, is a reprint of material as it appears in the
  _Journal of Demonstrations_, 2025, Lovelace, Ada; Hopper, Grace. The
  dissertation author was the primary investigator and author of this paper.
]
```

- [ ] **Step 2: Create the stub first chapter**

`examples/chapters/01-introduction.typ`:

```typst
= Introduction

This is a placeholder introduction. It exists so the document has main-matter
body content and a level-1 chapter heading for the table of contents. The prose
is filler and carries no scholarship.

A second paragraph establishes paragraph-to-paragraph rhythm in the double-spaced
body and gives the chapter enough height to occupy a full page.
```

- [ ] **Step 3: Create the example document**

`examples/thesis.typ`:

```typst
#import "../lib/template.typ": dissertation
#import "../lib/pagination.typ": front-matter, main-matter, back-matter
#import "../lib/frontmatter.typ": title-page, copyright-page, approval-page,
  dedication, epigraph, preface, acknowledgements, vita, abstract
#import "../lib/lists.typ": table-of-contents, list-of-figures, list-of-schemes,
  list-of-tables, list-of-graphs, list-of-abbreviations, list-of-symbols,
  list-of-supplemental-files
#import "../lib/floats.typ": floats-rules
#import "../lib/backmatter.typ": backmatter-rules, appendix
#import "ack.typ": coauthor-ack

#show: dissertation
#show: floats-rules
#show: backmatter-rules

#let meta = (
  title: [A Demonstration Dissertation Exercising Every Template Feature],
  degree: [Doctor of Philosophy],
  degree-field: [Computer Science],
  author: [Ada Lovelace],
  year: [2026],
  committee: (
    chair: [Alan Turing],
    co-chair: none,
    members: ([Grace Hopper], [John von Neumann]),
  ),
)

// ── Front matter (canonical preliminary-page order) ─────────────────────────
#front-matter()
#title-page(meta)
#copyright-page(meta)
#approval-page(meta)
#dedication[For everyone who reads templates so others do not have to.]
#epigraph[_"Beware of bugs in the above code; I have only proved it correct,
  not tried it."_ --- D. E. Knuth]
#table-of-contents()
#list-of-abbreviations((
  (term: [DNA], definition: [deoxyribonucleic acid]),
  (term: [RNA], definition: [ribonucleic acid]),
))
#list-of-symbols((
  (term: $alpha$, definition: [significance threshold]),
  (term: $mu$, definition: [population mean]),
))
#list-of-supplemental-files((
  (term: [Movie S1], definition: [time-lapse of cell division (MP4, 12 MB)]),
))
#list-of-figures()
#list-of-schemes()
#list-of-tables()
#list-of-graphs()
#preface[This document is a fixture, not a dissertation.]
#acknowledgements[
  I thank the maintainers of Typst and the UCSD Graduate Division.

  #coauthor-ack
]
#vita(
  entries: (
    (year: [2018], body: [B.S. in Computer Science, University of California San Diego]),
    (year: [2020], body: [M.S. in Computer Science, University of California San Diego]),
    (year: [2026], body: [Ph.D. in Computer Science, University of California San Diego]),
  ),
  publications: [Lovelace, A. (2023). _Notes on the Analytical Engine_.
    Journal of Demonstrations.],
  fields: [Major Field: Computer Science],
)
#abstract(meta)[
  This abstract demonstrates the required heading, the two-and-a-half inch top
  margin on its first page, and the structured header naming the title, author,
  degree, university, year, and committee chair. The body is double-spaced and
  deliberately brief so it stays well under the three-hundred-fifty-word limit
  for a doctoral abstract. It summarizes a document whose only contribution is
  to exercise every formatting feature the template provides.
]

// ── Main matter ─────────────────────────────────────────────────────────────
#main-matter()
#include "chapters/01-introduction.typ"

// ── Back matter ─────────────────────────────────────────────────────────────
#back-matter()
#appendix("Demonstration Appendix")[
  This appendix is permitted to be single-spaced. It demonstrates that an
  appendix heading does not receive "CHAPTER N" treatment.
]
#bibliography("../references.bib", style: "../styles/ieee-full-authors.csl")
```

- [ ] **Step 4: Compile and verify zero warnings**

Run:
```bash
mkdir -p build && pixi run typst compile --font-path fonts --root . examples/thesis.typ build/example.pdf
```
Expected: command exits 0 with **no output** (no warnings, no errors). If any warning prints, treat it as a failure and fix before committing.

- [ ] **Step 5: Commit**

```bash
git add examples/ack.typ examples/chapters/01-introduction.typ examples/thesis.typ
git commit -m "feat(p6): example skeleton — front matter, stub chapter, back matter"
```

---

### Task 2: Example feature enrichment — floats, lists, long-quote, co-author chapter

Add the remaining chapters and every float kind so all four List-of-float pages populate, plus a facing-caption page, a landscape float, a short-caption float, a long quotation, a footnote, multi-level headings, and the end-of-chapter co-author acknowledgement.

**Files:**
- Modify: `examples/chapters/01-introduction.typ`
- Create: `examples/chapters/02-methods.typ`
- Create: `examples/chapters/03-results.typ`
- Modify: `examples/thesis.typ` (add the two `#include` lines)

**Interfaces:**
- Consumes (from `lib/floats.typ`): `fig(body, caption:, short:, facing:, landscape:)`, `tbl(...)`, `scheme(...)`, `graph(...)` — same keyword signature for all four. From `lib/blocks.typ`: `long-quote(body)`. From `examples/ack.typ`: `coauthor-ack`.
- Float bodies may be any content; these fixtures use `rect(...)`/`table(...)` (no image assets). `fig`/`tbl`/`scheme`/`graph` set the float kind regardless of body.

- [ ] **Step 1: Add figure, table, long-quote, footnote, and subheadings to chapter 1**

Replace the entire contents of `examples/chapters/01-introduction.typ` with:

```typst
#import "../../lib/floats.typ": fig, tbl
#import "../../lib/blocks.typ": long-quote

= Introduction

This is a placeholder introduction. It carries a footnote#footnote[A
demonstration footnote: it must render at ten points and be single-spaced
regardless of the double-spaced body around it.] to exercise footnote styling.

== Background

A subsection so the table of contents shows a level-2 entry.

=== Details

A sub-subsection so the table of contents shows a level-3 entry.

#fig(
  rect(width: 4cm, height: 3cm),
  caption: [A demonstration figure; its caption sits below the image.],
)

#tbl(
  table(columns: 2, [Header A], [Header B], [1], [2]),
  caption: [A demonstration table; its caption sits above the table.],
)

A long quotation, single-spaced and indented half an inch on both sides:

#long-quote[
  This is a long quotation of more than six lines. It must be single-spaced and
  indented an additional half inch on both the left and the right, with no
  quotation marks added by the template. It runs long enough to wrap across
  several lines so the single spacing is visually distinct from the
  double-spaced body around it.
]
```

- [ ] **Step 2: Create chapter 2 with scheme, graph, facing figure, and the co-author acknowledgement**

`examples/chapters/02-methods.typ`:

```typst
#import "../../lib/floats.typ": scheme, graph, fig
#import "../ack.typ": coauthor-ack

= Methods

Placeholder methods chapter. It contains a scheme, a graph, and a figure whose
caption is large enough to warrant a facing caption page.

#scheme(
  rect(width: 4cm, height: 2cm),
  caption: [A reaction scheme; its caption sits below the scheme.],
)

#graph(
  rect(width: 5cm, height: 3cm),
  caption: [A graph; its caption sits above the graph.],
)

#fig(
  rect(width: 5cm, height: 18cm),
  caption: [A tall figure shown on the page following its caption, demonstrating
    the facing-caption-page layout for oversized floats.],
  facing: true,
)

#coauthor-ack
```

- [ ] **Step 3: Create chapter 3 with landscape and short-caption figures**

`examples/chapters/03-results.typ`:

```typst
#import "../../lib/floats.typ": fig

= Results

Placeholder results chapter. It contains a landscape figure and a figure with a
long caption abbreviated in the List of Figures.

#fig(
  rect(width: 18cm, height: 5cm),
  caption: [A wide figure rotated ninety degrees so its top edge lies along the
    left margin.],
  landscape: true,
)

#fig(
  rect(width: 4cm, height: 3cm),
  caption: [A figure whose full caption is far too long to sit on a single line
    in the List of Figures, running well beyond four lines when typeset at the
    body width, which is precisely why a short form is supplied for the list.],
  short: [A figure with an abbreviated list caption.],
)
```

- [ ] **Step 4: Wire the new chapters into the example**

In `examples/thesis.typ`, replace this line:

```typst
#include "chapters/01-introduction.typ"
```

with:

```typst
#include "chapters/01-introduction.typ"
#include "chapters/02-methods.typ"
#include "chapters/03-results.typ"
```

- [ ] **Step 5: Compile and verify zero warnings and populated lists**

Run:
```bash
pixi run typst compile --font-path fonts --root . examples/thesis.typ build/example.pdf
```
Expected: exits 0 with no output. Open `build/example.pdf` (or trust the clean compile) — the List of Figures, Schemes, Tables, and Graphs pages now render with dot-leader entries; the short-caption figure appears abbreviated in the List of Figures.

- [ ] **Step 6: Commit**

```bash
git add examples/chapters/01-introduction.typ examples/chapters/02-methods.typ examples/chapters/03-results.typ examples/thesis.typ
git commit -m "feat(p6): exercise all float kinds, lists, long-quote, co-author ack in example"
```

---

### Task 3: Track A — in-document compliance asserts

Add `#assert`s that fail the compile if pagination or float numbering regress: title=i/copyright=ii (counted, unnumbered), Arabic restart at 1 in main matter, and first figure numbered 1.1.

**Files:**
- Modify: `examples/chapters/01-introduction.typ` (float-numbering assert)
- Modify: `examples/thesis.typ` (page-counter asserts)

**Interfaces:**
- Consumes: the `<ucsd-copyright-page-end>` label emitted internally by `copyright-page` (see `lib/frontmatter.typ`); `query(heading)`; `counter(page)`; `chapter-counter` and `counter(figure.where(kind: image))` from `lib/floats.typ`.

- [ ] **Step 1: Add the float-numbering assert to chapter 1**

In `examples/chapters/01-introduction.typ`, add `chapter-counter` to the floats import and an assert immediately after the `#fig(...)` call:

Change the first import line to:
```typst
#import "../../lib/floats.typ": fig, tbl, chapter-counter
```

Add directly after the `#fig(...)` block (before the `#tbl(...)` block):
```typst
#context assert.eq(
  numbering(
    "1.1",
    chapter-counter.get().first(),
    counter(figure.where(kind: image)).get().first(),
  ),
  "1.1",
  message: "first figure in chapter 1 should be numbered 1.1",
)
```

- [ ] **Step 2: Add page-counter asserts to the example**

In `examples/thesis.typ`, add these two `#context` asserts immediately after the `#bibliography(...)` line at the end of the file (they query located elements, so position in source does not matter):

```typst
// ── Track A compliance asserts ──────────────────────────────────────────────
// Title page counted i, copyright page counted ii (both unnumbered).
#context assert.eq(
  counter(page).at(query(<ucsd-copyright-page-end>).first().location()).first(),
  2,
  message: "copyright page must be counted as page 2 (ii); title is 1 (i)",
)
// Main body restarts Arabic page numbering at 1 on the first chapter.
#context assert.eq(
  counter(page).at(query(heading).first().location()).first(),
  1,
  message: "first chapter heading must fall on Arabic page 1",
)
```

- [ ] **Step 3: Compile and verify the asserts pass**

Run:
```bash
pixi run typst compile --font-path fonts --root . examples/thesis.typ build/example.pdf
```
Expected: exits 0 with no output. If an assert fails, Typst prints the assert `message` and a panic — that is a real integration bug; fix the document/composition (not `lib/`) until it passes. Re-run until clean.

- [ ] **Step 4: Commit**

```bash
git add examples/chapters/01-introduction.typ examples/thesis.typ
git commit -m "test(p6): in-document asserts for pagination and float numbering"
```

---

### Task 4: Author's real `thesis.typ` skeleton

The leaner real document with the author's real metadata (filled where inferable, `TODO:` elsewhere) and placeholder chapter stubs under `chapters/`.

**Files:**
- Create: `chapters/01-introduction.typ`
- Create: `thesis.typ`

**Interfaces:**
- Same `lib/` imports as the example, but via `lib/...` (root-relative) and chapters under `chapters/` importing `../lib/...`. Bibliography path is root-relative: `references.bib`, style `styles/ieee-full-authors.csl`.

- [ ] **Step 1: Create the first real chapter stub**

`chapters/01-introduction.typ`:

```typst
= Introduction

// TODO: replace this stub with the real introduction.
Placeholder text for the introduction chapter.
```

- [ ] **Step 2: Create the real thesis skeleton**

`thesis.typ`:

```typst
#import "lib/template.typ": dissertation
#import "lib/pagination.typ": front-matter, main-matter, back-matter
#import "lib/frontmatter.typ": title-page, copyright-page, approval-page,
  acknowledgements, vita, abstract
#import "lib/lists.typ": table-of-contents, list-of-figures, list-of-tables
#import "lib/floats.typ": floats-rules
#import "lib/backmatter.typ": backmatter-rules

#show: dissertation
#show: floats-rules
#show: backmatter-rules

#let meta = (
  title: [TODO: dissertation title],
  degree: [Doctor of Philosophy],
  degree-field: [TODO: degree field],
  author: [David Laub],
  year: [2026],
  committee: (
    chair: [TODO: chair last name],
    co-chair: none,
    members: ([TODO: member], [TODO: member]),
  ),
)

// If any chapter is co-authored/published, store the acknowledgement once here
// and reuse it on the Acknowledgements page AND at the end of that chapter:
//   #let coauthor-ack = [...]   (put in a chapters-importable module, e.g. ack.typ)

#front-matter()
#title-page(meta)
#copyright-page(meta)
#approval-page(meta)
#table-of-contents()
#list-of-figures()
#list-of-tables()
#vita(
  entries: (
    // TODO: real degrees/appointments. Use "Master" not "Masters".
    (year: [2026], body: [Ph.D. in TODO, University of California San Diego]),
  ),
)
#abstract(meta)[
  // TODO: real abstract, doctoral limit 350 words.
  Placeholder abstract.
]

#main-matter()
#include "chapters/01-introduction.typ"

#back-matter()
#bibliography("references.bib", style: "styles/ieee-full-authors.csl")
```

- [ ] **Step 3: Compile and verify zero warnings**

Run:
```bash
pixi run typst compile --font-path fonts --root . thesis.typ build/thesis.pdf
```
Expected: exits 0 with no output. (List of Figures/Tables auto-skip — the stub chapter has no floats — and that is fine.)

- [ ] **Step 4: Commit**

```bash
git add chapters/01-introduction.typ thesis.typ
git commit -m "feat(p6): author's real thesis.typ skeleton with placeholder chapters"
```

---

### Task 5: Build tasks and README

Wire `pixi run example` and `pixi run thesis`, and document them.

**Files:**
- Modify: `pixi.toml:9-13` (the `[tasks]` table)
- Modify: `README.md:5-10` (the Build section)

- [ ] **Step 1: Add the two pixi tasks**

In `pixi.toml`, under `[tasks]`, add these two lines after the existing `build` line:

```toml
example = "mkdir -p build && typst compile --font-path fonts --root . examples/thesis.typ build/example.pdf"
thesis = "mkdir -p build && typst compile --font-path fonts --root . thesis.typ build/thesis.pdf"
```

- [ ] **Step 2: Verify both tasks run clean**

Run:
```bash
pixi run example && pixi run thesis
```
Expected: both exit 0 with no warnings.

- [ ] **Step 3: Document the tasks in the README**

In `README.md`, in the `## Build` fenced block, add these two lines under the existing `pixi run build` line:

```
    pixi run example      # compiles the generic feature-demo -> build/example.pdf
    pixi run thesis       # compiles your thesis.typ -> build/thesis.pdf
```

- [ ] **Step 4: Commit**

```bash
git add pixi.toml README.md
git commit -m "build(p6): add example and thesis pixi tasks; document them"
```

---

### Task 6: Track B — visual verification, report, and checklist sign-off

Render the example's sample-sensitive pages, compare each against its `formattingmanual.pdf` sample page, tune front-matter spacers if a page is visibly off, record evidence, and tick the compliance checklist.

**Files:**
- Create: `docs/p6-verification.md`
- Modify: `docs/compliance-checklist.md` (tick all P6-owned and now-verified rows)
- Possibly modify: the `v()` spacer values in `title-page` / `approval-page` / `abstract` within `lib/frontmatter.typ` (the bounded exception from Global Constraints) — values only, no structural change — if a sample diff shows a page is visibly off.

- [ ] **Step 1: Render the example to per-page PNGs**

Run:
```bash
pixi run typst compile --font-path fonts --root . examples/thesis.typ "build/example-{p}.png" --ppi 150
```
Expected: exits 0; produces `build/example-1.png`, `build/example-2.png`, … one per page.

- [ ] **Step 2: Compare each sample-sensitive page against the manual**

Read the relevant rendered PNG and the corresponding `formattingmanual.pdf` page, and judge pass/fail on layout (heading text/caps/placement, spacing, margins). Pages to check:

| Rendered page | Manual sample | What to confirm |
|---|---|---|
| Title page (p.1) | p. 13 | "UNIVERSITY OF CALIFORNIA SAN DIEGO" caps top; degree/in/by/author/committee blocks; year at bottom; no page number |
| Copyright (p.2) | p. 17 | three lines centered just above bottom margin; no page number |
| Approval (p.3) | p. 19 | no header; statement top; university+year centered; "iii" shown |
| Vita | p. 31 | "VITA" heading; year column; sections |
| Abstract | p. 33 | "ABSTRACT OF THE DISSERTATION"; 2.5″ top margin first page; structured header |
| TOC + lists | pp. 26–27 | "TABLE OF CONTENTS"; dot leaders; "Chapter N" titles; roman vs Arabic page numbers |
| Float pages | pp. 40–42 | figure/scheme caption below; table/graph caption above; facing-caption page; landscape rotation |
| Any body page | — | page number centered, 0.5″ from bottom edge |

- [ ] **Step 3: Verify the abstract word count**

Count the words in the example abstract body prose (the text inside `#abstract(meta)[ ... ]`). Confirm it is under 350. Record the count in the report.

Run (after pasting just the abstract prose into a file):
```bash
wc -w build/_abstract.txt
```
Expected: a number < 350. (Delete the scratch file after.)

- [ ] **Step 4: Write the verification report**

Create `docs/p6-verification.md` with a header and two tables — one for Track A asserts (name → result, all PASS via clean compile), one for Track B visual checks (page → manual sample → "pass" / finding). Include the abstract word count. Example shape:

```markdown
# P6 Verification Report

**Date:** 2026-06-30
**Documents:** `examples/thesis.typ` (build/example.pdf), `thesis.typ` (build/thesis.pdf)
**Result:** both compile with zero warnings.

## Track A — in-document asserts (compile gate)

| Check | Mechanism | Result |
|---|---|---|
| Copyright counted ii (title i, unnumbered) | assert at `<ucsd-copyright-page-end>` == 2 | PASS |
| Arabic restart at 1 | assert first heading page == 1 | PASS |
| First figure numbered 1.1 | assert in chapter 1 == "1.1" | PASS |

## Track B — visual diff vs formattingmanual.pdf

| Page | Sample | Verdict |
|---|---|---|
| Title | p. 13 | pass |
| … | … | … |

## Abstract word count

Example abstract: NNN words (< 350). PASS.
```

Fill every row with the real verdict observed in Steps 2–3.

- [ ] **Step 5: Tick the compliance checklist**

In `docs/compliance-checklist.md`, change `- [ ]` to `- [x]` for every row now backed by Track A or Track B evidence — in particular all rows tagged `[P1]` (pagination/footer), `[P6]`, and the preliminary-page-order, title/copyright/approval/abstract/vita, TOC/list, caption/float, and back-matter rows the assembled documents exercise. Leave a row unticked only if its evidence is a recorded *finding* (failure) in the report.

- [ ] **Step 6: Final full compile of both documents (and the frontmatter test if spacers changed)**

Run:
```bash
pixi run example && pixi run thesis
```
Expected: both exit 0 with no warnings. If you tuned any spacer in `lib/frontmatter.typ`, also run:
```bash
pixi run typst compile --font-path fonts --root . tests/frontmatter.typ build/frontmatter.pdf
```
Expected: exits 0 with no output (the frontmatter test's page-counter asserts still pass).

- [ ] **Step 7: Commit**

```bash
git add docs/p6-verification.md docs/compliance-checklist.md examples/thesis.typ lib/frontmatter.typ
git commit -m "docs(p6): compliance verification report; sign off checklist"
```

---

## Self-Review Notes

- **Spec coverage:** Deliverables (both docs, report, checklist) → Tasks 1–6. Composition pattern & `meta` shape → Task 1. Canonical prelim order → Task 1. Feature-coverage matrix → Task 2. Co-author ack by composition (shared module, no lib helper) → Tasks 1–2. Track A asserts → Task 3. Real skeleton → Task 4. Build tasks + README → Task 5. Track B + report + checklist → Task 6. Scope boundaries (no lib edits, two pixi tasks, no personal data in example) → Global Constraints + Task 6 Step note.
- **Word count:** moved to an external `wc -w` step (Task 6 Step 3) since Typst cannot conveniently assert it — matches the spec's "extract abstract text" mechanism.
- **`#include` scope gotcha:** the co-author acknowledgement is a shared importable module (`examples/ack.typ`), not a top-level `#let`, because included files do not inherit caller bindings.
- **Spacer tuning:** the `v()` spacers in `title-page`/`approval-page`/`abstract` (`lib/frontmatter.typ`) are the one bounded `lib/` edit P6 permits — those builders are commented to invite sample-driven tuning; values only, and re-run `tests/frontmatter.typ` afterward.
```
