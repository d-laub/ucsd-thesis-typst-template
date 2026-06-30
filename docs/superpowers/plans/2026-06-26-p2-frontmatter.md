# Phase 2 — Front-matter Pages Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking. When authoring Typst code, also use the `typst-author` skill.

**Goal:** Implement every preliminary page the UCSD manual prescribes for a PhD, non-joint dissertation — title, copyright, approval, dedication, epigraph, preface, acknowledgements, vita, abstract — each matching its sample page, so a document can render the complete front-matter sequence (i, ii unnumbered → iii on approval → roman prelims → Arabic restart at 1).

**Architecture:** A new `lib/frontmatter.typ` exposing one public builder per page plus underscore-prefixed internal helpers. Shared metadata (title, author, degree, degree-field, committee, year) is a plain dictionary the author defines once and passes to the three pages that need it (`title-page`, `approval-page`, `abstract`) — the builders are pure functions of their inputs, with **no Typst `state`/`context` coupling**. Counted-but-unnumbered title/copyright pages use the one-shot `#page(numbering: none)[…]` function (verified to advance the page counter so the approval page lands on iii); the abstract's 2.5″ top margin is a first-page-only `v(1.5in)` spacer. `dissertation()` in `lib/template.typ` is **not** edited — P2 is new files only, layering on top per the repo's architecture rule. The golden sequence + page content are proven in `tests/frontmatter.typ` via in-document `#assert`s on the live page counter, `typst query` extraction, and `pdftotext` content checks.

**Tech Stack:** Typst (≥0.15,<0.16, pinned in `pixi.toml`), pixi, TeX Gyre Heros (vendored OTFs under `fonts/`); P0's `dissertation` show-wrapper from `lib/template.typ`, P1's `front-matter`/`main-matter` markers from `lib/pagination.typ`, and the `single-spaced` primitive from `lib/blocks.typ`.

> **Implementation note (post-hoc):** during execution, a latent P1 bug was found — `front-matter()`/`main-matter()` configured the page footer + roman/arabic numbering via `set page(…)` *inside* the function body, which does not propagate in Typst, so the document had **no page-number footer anywhere**. With user authorization, the "New files only" constraint below was relaxed for a root-cause fix (commit `47c4955`): a state-driven footer was moved into `dissertation()` (`lib/template.typ`), `front-matter()`/`main-matter()` were simplified (`lib/pagination.typ`), and the counted-but-unnumbered pages switched to `page(footer: none)`. The "do not edit `lib/template.typ`/`lib/pagination.typ`" and "`dissertation()` untouched" statements in the Global Constraints and Self-Review below are therefore **superseded by that authorized fix**.

## Global Constraints

- **Metadata is a plain dict**, defined once and passed to the builders that need it. Shape (used verbatim throughout this plan):
  ```typ
  (
    title: <str>, author: <str>,
    degree: <str>,            // e.g. "Doctor of Philosophy" — title page "for the degree …"
    degree-field: <str>,      // e.g. "Computer Science" — abstract "… in <field>"
    committee: (chair: <str>, co-chair: none | <str>, members: (<str>, …)),
    year: <str>,
  )
  ```
- `committee.chair` is **required** — helpers `#assert` it is non-`none`. `co-chair` is optional (`none` ⇒ omitted). Members render in **author-given order** (no auto-sort). Every committee name is prefixed "Professor " by the template; the chair line gets ", Chair", the co-chair ", Co-Chair".
- **Counted-but-unnumbered** title page (i) and copyright page (ii): rendered with `#page(numbering: none)[…]`; the counter still advances so the approval page is the first **displayed** number, **iii** (manual §III p.12).
- **Approval page** (non-joint): **no section heading**; approval statement at top, left-justified; "University of California San Diego" + year centered below; the block centered vertically; **no signature lines** (manual §III p.18, sample p.19/20).
- **Abstract**: heading "ABSTRACT OF THE DISSERTATION"; **first-page top margin 2.5″** (a `v(1.5in)` spacer above the 1″ margin); structured centered header (title / by / author / "<degree> in <degree-field>" / "University of California San Diego, <year>" / chair line); body double-spaced (manual §III p.32, sample p.33). The 350-word limit is **out of scope** (P6).
- **Vita** (required, doctoral): heading "VITA"; year-column entries laid out as a 2-col grid, single-spaced; optional centered "PUBLICATIONS" / "FIELDS OF STUDY" sections; use "Master" not "Masters" (author's content). May be single-spaced (manual §III p.30, sample p.31).
- **Headings**: every section heading is centered, **regular weight** (not bold), all-caps, 12pt — rendered as **styled content, NOT `heading` elements** (P3's `floats-rules` renders front-matter level-1 headings plainly/bold-left, which would fight this; TOC-listing these sections is P4's job). The title-page top line and the abstract heading both go through the same `_prelim-heading` helper, satisfying the "title-page and abstract headers match" rule by construction (manual §III p.22).
- **First-line indent**: P0 sets a global `first-line-indent: 0.5in` (all paragraphs), which offsets *centered* text leftward. Centered blocks (title page, copyright, approval, all `_prelim-heading`s, the abstract header) must locally `set par(first-line-indent: 0pt)`. Body paragraphs that the manual requires to be indented (acknowledgements, abstract body) keep the inherited 0.5″ indent.
- **New files only:** create `lib/frontmatter.typ`, `tests/frontmatter.typ`, and (final task) `tests/frontmatter-minimal.typ`. Do **not** edit `lib/template.typ`, `lib/pagination.typ`, `lib/blocks.typ`, `lib/floats.typ`, `lib/backmatter.typ`, `pixi.toml`, `tests/smoke.typ`, or `docs/compliance-checklist.md`. Call `pixi run typst …` directly (do **not** add a pixi task). Build artifacts go to `build/` (gitignored); `mkdir -p build` before each compile.
- A passing test compiles with **zero warnings** — treat any warning as a failure. (`typst query` may print a one-line "subcommand is deprecated" notice to stderr; that is a CLI notice, **not** a document warning, and does not count.)

---

### Task 1: Scaffold, shared helpers, and the title page

**Files:**
- Create: `lib/frontmatter.typ`
- Create: `tests/frontmatter.typ`

**Interfaces:**
- Consumes: `dissertation` from `lib/template.typ` (applied via `#show: dissertation`); `front-matter` from `lib/pagination.typ`; `single-spaced` from `lib/blocks.typ`.
- Produces:
  - `#let _prelim-heading(title)` → centered, regular-weight, all-caps styled content (NOT a heading element); resets `first-line-indent` to 0.
  - `#let _professor(name)` → content `Professor <name>`.
  - `#let _committee-block(committee)` → left-justified "Committee in charge:" block; chair (", Chair"), co-chair if present (", Co-Chair"), then members; members indented 0.5″; single-spaced; `#assert`s `committee.chair != none`.
  - `#let title-page(meta)` → page **i**, unnumbered (`#page(numbering: none)`), matching sample p.13.

- [ ] **Step 1: Write `tests/frontmatter.typ` (the compile target, title-page only for now)**

```typ
#import "../lib/template.typ": dissertation
#import "../lib/pagination.typ": front-matter, main-matter
#import "../lib/frontmatter.typ": title-page

#let meta = (
  title: "This Is the Title of My Dissertation",
  author: "Ada Lovelace",
  degree: "Doctor of Philosophy",
  degree-field: "Computer Science",
  committee: (
    chair: "Eta Theta",
    co-chair: "Gamma Delta",
    members: ("Iota Mu", "Epsilon Zeta"),
  ),
  year: "2025",
)

#show: dissertation

#front-matter()

#title-page(meta)
```

- [ ] **Step 2: Compile the test (expect FAIL)**

Run: `mkdir -p build && pixi run typst compile --font-path fonts --root . tests/frontmatter.typ build/frontmatter.pdf`
Expected: FAIL — `lib/frontmatter.typ` does not exist / `title-page` is an unknown import.

- [ ] **Step 3: Create `lib/frontmatter.typ` with the imports, helpers, and `title-page`**

```typ
// ============================================================================
// Front matter (UCSD formatting manual §III, PhD non-joint).
//
// Public builders take a plain `meta` dict (see plan / spec) and are pure
// functions of their inputs — NO global state.  Composed in a document as
// inline calls AFTER P1's #front-matter():
//   #show: dissertation
//   #front-matter()
//   #title-page(meta) ... #abstract(meta)[...]
//   #main-matter()
// This module does NOT edit dissertation(); it layers on top.
// ============================================================================

#import "blocks.typ": single-spaced

// ── Internal helpers (not part of the public API) ────────────────────────────

// Centered, regular-weight, all-caps section heading at the body size (12pt).
// NOT a `heading` element: floats-rules (P3) renders front-matter level-1
// headings plainly (default bold/left), which would fight this styling.  The
// title-page top line and the abstract heading both use this, so they match.
#let _prelim-heading(title) = {
  set par(first-line-indent: 0pt)
  align(center, text(weight: "regular", style: "normal", upper(title)))
}

// "Professor <name>".
#let _professor(name) = [Professor #name]

// Title-page committee block: chair, co-chair (if any), then members in the
// author-given order; left-justified label, members indented 0.5in,
// single-spaced. Manual: double space between the label and the chair.
#let _committee-block(committee) = {
  assert(committee.chair != none, message: "committee.chair is required")
  let lines = ([#_professor(committee.chair), Chair],)
  if committee.co-chair != none {
    lines.push([#_professor(committee.co-chair), Co-Chair])
  }
  for m in committee.members {
    lines.push([#_professor(m)])
  }
  align(left, single-spaced[
    Committee in charge:
    #v(1em)
    #pad(left: 0.5in, lines.join(linebreak()))
  ])
}

// ── Public builders ──────────────────────────────────────────────────────────

// Title page — counted i, number NOT displayed. Sample p.13. The v() gaps below
// are a tuned starting point; adjust against the sample in this task's Step 6.
#let title-page(meta) = page(numbering: none)[
  #set par(first-line-indent: 0pt)
  #set align(center)
  #_prelim-heading("University of California San Diego")
  #v(0.5in)
  #meta.title
  #v(0.6in)
  A dissertation submitted in partial satisfaction of the \
  requirements for the degree #meta.degree
  #v(1.0in)
  in
  #v(0.6in)
  #meta.degree-field
  #v(0.7in)
  by
  #v(0.6in)
  #meta.author
  #v(0.8in)
  #_committee-block(meta.committee)
  #v(1fr)
  #meta.year
]
```

- [ ] **Step 4: Compile the test (expect PASS)**

Run: `mkdir -p build && pixi run typst compile --font-path fonts --root . tests/frontmatter.typ build/frontmatter.pdf`
Expected: PASS — exits 0 with **zero warnings**, creates `build/frontmatter.pdf` (one page).

- [ ] **Step 5: Verify title-page content via `pdftotext`**

Run:
```bash
pdftotext build/frontmatter.pdf - 2>/dev/null > /tmp/ft.txt
for s in "UNIVERSITY OF CALIFORNIA SAN DIEGO" \
         "This Is the Title of My Dissertation" \
         "A dissertation submitted in partial satisfaction of the" \
         "requirements for the degree Doctor of Philosophy" \
         "Computer Science" \
         "Committee in charge:" \
         "Professor Eta Theta, Chair" \
         "Professor Gamma Delta, Co-Chair" \
         "Professor Iota Mu" \
         "Professor Epsilon Zeta" \
         "2025"; do
  grep -qF "$s" /tmp/ft.txt && echo "OK: $s" || echo "MISSING: $s"
done
```
Expected: every line prints `OK:`. (Confirms the degree statement, the "in"/degree-field split, the committee block with chair/co-chair/members all prefixed "Professor", and the year.)

- [ ] **Step 6: Confirm the page is unnumbered and the layout matches sample p.13**

Run: `pdftotext build/frontmatter.pdf - 2>/dev/null | grep -qx "i" && echo "STRAY NUMBER (fail)" || echo "no displayed number (good)"`
Expected: `no displayed number (good)` — the title page is counted but its number is suppressed. Then **open `build/frontmatter.pdf`** and confirm against sample p.13: "UNIVERSITY OF CALIFORNIA SAN DIEGO" centered at top; title centered; the two-line degree statement; "in" / degree-field / "by" / author each centered and well-spaced; "Committee in charge:" at the **left margin** with the four committee lines indented 0.5″ and single-spaced; the year near the bottom. Tune the `v()` gaps in `title-page` if the vertical rhythm differs from the sample, then re-run Steps 4–5.

- [ ] **Step 7: Commit**

```bash
git add lib/frontmatter.typ tests/frontmatter.typ
git commit -m "feat(p2): title page, prelim-heading and committee helpers"
```

---

### Task 2: Copyright page (ii) and blank-page fallback

**Files:**
- Modify: `lib/frontmatter.typ` (add `copyright-page`, `blank-page`)
- Modify: `tests/frontmatter.typ` (add `#copyright-page(meta)` after the title page)

**Interfaces:**
- Consumes: `single-spaced` (already imported).
- Produces:
  - `#let copyright-page(meta)` → page **ii**, unnumbered; three lines centered just above the bottom margin.
  - `#let blank-page()` → an empty `#page(numbering: none)[]` for authors who decline a copyright notice (page ii must still exist; manual p.16).

- [ ] **Step 1: Add the copyright-page call to `tests/frontmatter.typ`**

Change the import line to include the new builder and add the call after `#title-page(meta)`:

```typ
#import "../lib/frontmatter.typ": title-page, copyright-page
```
```typ
#title-page(meta)
#copyright-page(meta)
```

- [ ] **Step 2: Compile the test (expect FAIL)**

Run: `mkdir -p build && pixi run typst compile --font-path fonts --root . tests/frontmatter.typ build/frontmatter.pdf`
Expected: FAIL — `copyright-page` is an unknown import.

- [ ] **Step 3: Append `copyright-page` and `blank-page` to `lib/frontmatter.typ`**

```typ
// Copyright page — counted ii, number NOT displayed. Centered just above the
// bottom margin. Sample p.17. Optional notice; if declined, use blank-page()
// instead (page ii must still exist — manual p.16).
#let copyright-page(meta) = page(numbering: none)[
  #set par(first-line-indent: 0pt)
  #set align(center)
  #v(1fr)
  #single-spaced[
    Copyright

    #meta.author, #meta.year \
    All rights reserved.
  ]
]

// Empty counted page for the declined-copyright case (page ii, no number).
#let blank-page() = page(numbering: none)[]
```

- [ ] **Step 4: Compile the test (expect PASS)**

Run: `mkdir -p build && pixi run typst compile --font-path fonts --root . tests/frontmatter.typ build/frontmatter.pdf`
Expected: PASS — zero warnings; `build/frontmatter.pdf` now has two pages.

- [ ] **Step 5: Verify copyright content and that it sits at the bottom**

Run:
```bash
pdftotext build/frontmatter.pdf - 2>/dev/null > /tmp/ft.txt
for s in "Copyright" "Ada Lovelace, 2025" "All rights reserved."; do
  grep -qF "$s" /tmp/ft.txt && echo "OK: $s" || echo "MISSING: $s"
done
pdftotext -bbox build/frontmatter.pdf - 2>/dev/null | grep -A1 "All rights" | grep -oE 'yMax="[0-9.]+"' | head -1
```
Expected: the three `OK:` lines, and a `yMax` for "All rights" near the bottom of the 792pt page (roughly ≥ 690, i.e. just above the 1″ = 72pt bottom margin). Open the PDF to confirm page 2 shows the three centered lines just above the bottom margin with no displayed page number (sample p.17).

- [ ] **Step 6: Commit**

```bash
git add lib/frontmatter.typ tests/frontmatter.typ
git commit -m "feat(p2): copyright page (counted ii) and blank-page fallback"
```

---

### Task 3: Approval page (iii)

**Files:**
- Modify: `lib/frontmatter.typ` (add `approval-page`)
- Modify: `tests/frontmatter.typ` (add `#approval-page(meta)`)

**Interfaces:**
- Consumes: nothing new.
- Produces:
  - `#let approval-page(meta)` → the first **displayed** roman number (**iii**); no section heading; approval statement top-left; "University of California San Diego" + year centered below; block centered vertically; no signature lines.

- [ ] **Step 1: Add the approval-page call to `tests/frontmatter.typ`**

Extend the import and add the call after the copyright page:

```typ
#import "../lib/frontmatter.typ": title-page, copyright-page, approval-page
```
```typ
#copyright-page(meta)
#approval-page(meta)
```

- [ ] **Step 2: Compile the test (expect FAIL)**

Run: `mkdir -p build && pixi run typst compile --font-path fonts --root . tests/frontmatter.typ build/frontmatter.pdf`
Expected: FAIL — `approval-page` is an unknown import.

- [ ] **Step 3: Append `approval-page` to `lib/frontmatter.typ`**

```typ
// Approval page — first DISPLAYED roman number (iii). No section heading. The
// approval statement is left-justified at the top; the university + year are
// centered below; the whole block is centered vertically. No signature lines
// (non-joint — signatures are collected on the Final Report Form). Sample p.19.
// The fractional spacers are a tuned starting point; adjust against the sample.
#let approval-page(meta) = {
  pagebreak(weak: true)
  set par(first-line-indent: 0pt)
  v(1fr)
  align(left)[
    The dissertation of #meta.author is approved, and it is acceptable in quality
    and form for publication on microfilm and electronically.
  ]
  v(3fr)
  align(center, single-spaced[
    University of California San Diego \
    #meta.year
  ])
  v(2fr)
}
```

- [ ] **Step 4: Compile the test (expect PASS)**

Run: `mkdir -p build && pixi run typst compile --font-path fonts --root . tests/frontmatter.typ build/frontmatter.pdf`
Expected: PASS — zero warnings; three pages.

- [ ] **Step 5: Verify the approval statement, the iii footer, and no signature lines**

Run:
```bash
pdftotext build/frontmatter.pdf - 2>/dev/null > /tmp/ft.txt
grep -qF "is approved, and it is acceptable in quality" /tmp/ft.txt && echo "OK: statement" || echo "MISSING: statement"
grep -qF "University of California San Diego" /tmp/ft.txt && echo "OK: university" || echo "MISSING: university"
grep -qx "iii" /tmp/ft.txt && echo "OK: iii footer present" || echo "NOTE: iii not extracted by pdftotext (verify visually)"
```
Expected: `OK: statement`, `OK: university`, and ideally `OK: iii footer present`. Open `build/frontmatter.pdf` page 3 and confirm: the statement is left-aligned in the upper portion; "University of California San Diego" and "2025" are centered lower; the whole block reads as vertically centered; **no signature/underscore lines**; a centered `iii` in the footer (sample p.19/20). The approval page is the first page whose number is shown — proving the two preceding `numbering: none` pages were counted (i, ii) but not displayed.

- [ ] **Step 6: Commit**

```bash
git add lib/frontmatter.typ tests/frontmatter.typ
git commit -m "feat(p2): approval page (displayed iii, no signature lines)"
```

---

### Task 4: Section pages — dedication, epigraph, preface, acknowledgements

**Files:**
- Modify: `lib/frontmatter.typ` (add `_section-page` + the four wrappers)
- Modify: `tests/frontmatter.typ` (add the four calls with self-asserting bodies)

**Interfaces:**
- Consumes: `_prelim-heading` (Task 1).
- Produces:
  - `#let _section-page(title, body)` → fresh page; centered heading; gap; then `body` (body keeps the inherited double-spaced 0.5″-indent defaults).
  - `#let dedication(body)`, `#let epigraph(body)`, `#let preface(body)`, `#let acknowledgements(body)` → thin wrappers over `_section-page` with the literal title.

- [ ] **Step 1: Add the four calls to `tests/frontmatter.typ` with page-pinning bodies**

Extend the import and append after `#approval-page(meta)`. Each body embeds a `#context` block that asserts its own page count (so a wrong number fails the compile) and exposes the value for query.

```typ
#import "../lib/frontmatter.typ": title-page, copyright-page, approval-page, dedication, epigraph, preface, acknowledgements
```
```typ
#approval-page(meta)

#dedication[
  This dissertation is dedicated to curiosity.
  #context {
    let n = counter(page).get().first()
    assert(n == 4, message: "dedication should be page 4 (iv), got " + str(n))
    [#metadata(n) <p-ded>]
  }
]
#epigraph[
  "Begin at the beginning." \ — The King
  #context {
    let n = counter(page).get().first()
    assert(n == 5, message: "epigraph should be page 5 (v), got " + str(n))
    [#metadata(n) <p-epi>]
  }
]
#preface[
  This is the preface.
  #context {
    let n = counter(page).get().first()
    assert(n == 6, message: "preface should be page 6 (vi), got " + str(n))
    [#metadata(n) <p-pre>]
  }
]
#acknowledgements[
  I thank my committee for their guidance.
  #context {
    let n = counter(page).get().first()
    assert(n == 7, message: "acknowledgements should be page 7 (vii), got " + str(n))
    [#metadata(n) <p-ack>]
  }
]
```

- [ ] **Step 2: Compile the test (expect FAIL)**

Run: `mkdir -p build && pixi run typst compile --font-path fonts --root . tests/frontmatter.typ build/frontmatter.pdf`
Expected: FAIL — `dedication` (and the others) are unknown imports.

- [ ] **Step 3: Append `_section-page` and the four wrappers to `lib/frontmatter.typ`**

```typ
// Generic single-section preliminary page: a centered heading then the body.
// Body inherits P0's double-spaced, 0.5in-first-line-indent defaults (required
// for acknowledgements; harmless for the "any format" dedication/epigraph).
#let _section-page(title, body) = {
  pagebreak(weak: true)
  _prelim-heading(title)
  v(2em)
  body
}

#let dedication(body) = _section-page("Dedication", body)
#let epigraph(body) = _section-page("Epigraph", body)
#let preface(body) = _section-page("Preface", body)
#let acknowledgements(body) = _section-page("Acknowledgements", body)
```

- [ ] **Step 4: Compile the test (expect PASS)**

Run: `mkdir -p build && pixi run typst compile --font-path fonts --root . tests/frontmatter.typ build/frontmatter.pdf`
Expected: PASS — zero warnings. The four in-document `#assert`s passing **proves** the roman sequence reached iv, v, vi, vii (dedication 4 → acknowledgements 7), which in turn confirms approval was iii and title/copyright were counted i/ii.

- [ ] **Step 5: Verify the section headings and the page numbers via query**

Run:
```bash
pdftotext build/frontmatter.pdf - 2>/dev/null > /tmp/ft.txt
for s in DEDICATION EPIGRAPH PREFACE ACKNOWLEDGEMENTS; do
  grep -qx "$s" /tmp/ft.txt && echo "OK: $s" || echo "MISSING: $s"
done
for L in p-ded:4 p-epi:5 p-pre:6 p-ack:7; do
  label="${L%%:*}"; want="${L##*:}"
  got=$(pixi run typst query --font-path fonts --root . tests/frontmatter.typ "<$label>" --field value --one 2>/dev/null)
  [ "$got" = "$want" ] && echo "$label OK ($got)" || echo "$label MISMATCH want=$want got=$got"
done
```
Expected: four `OK:` heading lines (each heading present as its own all-caps line) and four `OK` page-number lines (4, 5, 6, 7). Open the PDF and confirm each heading is centered, regular weight (not bold), all-caps; the acknowledgements paragraph is double-spaced with a 0.5″ first-line indent (sample p.viii).

- [ ] **Step 6: Commit**

```bash
git add lib/frontmatter.typ tests/frontmatter.typ
git commit -m "feat(p2): dedication, epigraph, preface, acknowledgements pages"
```

---

### Task 5: Vita

**Files:**
- Modify: `lib/frontmatter.typ` (add `vita`)
- Modify: `tests/frontmatter.typ` (add `#vita(...)`)

**Interfaces:**
- Consumes: `_prelim-heading`, `single-spaced`.
- Produces:
  - `#let vita(entries: (), publications: none, fields: none)` → centered "VITA"; `entries` (array of `(year: <str>, body: <content/str>)`) as a 2-col grid (year auto width, body 1fr), single-spaced; optional centered "PUBLICATIONS" / "FIELDS OF STUDY" sections rendered only when the arg is non-`none`.

- [ ] **Step 1: Add the vita call to `tests/frontmatter.typ`**

Extend the import and append after `#acknowledgements[…]`. The page pin rides in the `publications` content (the whole vita is one page).

```typ
#import "../lib/frontmatter.typ": title-page, copyright-page, approval-page, dedication, epigraph, preface, acknowledgements, vita
```
```typ
#vita(
  entries: (
    (year: "2019", body: "Bachelor of Science, University of Somewhere"),
    (year: "2025", body: "Doctor of Philosophy, University of California San Diego"),
  ),
  publications: [
    A. Lovelace, "On the Analytical Engine," 1843.
    #context {
      let n = counter(page).get().first()
      assert(n == 8, message: "vita should be page 8 (viii), got " + str(n))
      [#metadata(n) <p-vita>]
    }
  ],
  fields: [
    Major Field: Computing
  ],
)
```

- [ ] **Step 2: Compile the test (expect FAIL)**

Run: `mkdir -p build && pixi run typst compile --font-path fonts --root . tests/frontmatter.typ build/frontmatter.pdf`
Expected: FAIL — `vita` is an unknown import.

- [ ] **Step 3: Append `vita` to `lib/frontmatter.typ`**

```typ
// Vita (required, doctoral). Sample p.31. Year-column entries as a 2-col grid
// (single-spaced); optional PUBLICATIONS / FIELDS OF STUDY sections. Author uses
// "Master" not "Masters" in degree titles (manual note).
#let vita(entries: (), publications: none, fields: none) = {
  pagebreak(weak: true)
  _prelim-heading("Vita")
  v(2em)
  single-spaced(grid(
    columns: (auto, 1fr),
    column-gutter: 0.5in,
    row-gutter: 1em,
    ..entries.map(e => (e.year, e.body)).flatten(),
  ))
  if publications != none {
    v(2em)
    _prelim-heading("Publications")
    v(1em)
    single-spaced(publications)
  }
  if fields != none {
    v(2em)
    _prelim-heading("Fields of Study")
    v(1em)
    single-spaced(fields)
  }
}
```

- [ ] **Step 4: Compile the test (expect PASS)**

Run: `mkdir -p build && pixi run typst compile --font-path fonts --root . tests/frontmatter.typ build/frontmatter.pdf`
Expected: PASS — zero warnings; the vita pin assert confirms page 8 (viii).

- [ ] **Step 5: Verify vita headings, entries, and sections**

Run:
```bash
pdftotext build/frontmatter.pdf - 2>/dev/null > /tmp/ft.txt
for s in "VITA" "2019" "Bachelor of Science, University of Somewhere" \
         "PUBLICATIONS" "On the Analytical Engine" "FIELDS OF STUDY" "Major Field: Computing"; do
  grep -qF "$s" /tmp/ft.txt && echo "OK: $s" || echo "MISSING: $s"
done
got=$(pixi run typst query --font-path fonts --root . tests/frontmatter.typ "<p-vita>" --field value --one 2>/dev/null)
[ "$got" = "8" ] && echo "p-vita OK (8)" || echo "p-vita MISMATCH want=8 got=$got"
```
Expected: every `OK:` line and `p-vita OK (8)`. Open the PDF: "VITA" centered at top; years in a left column with entries aligned beside them; "PUBLICATIONS" and "FIELDS OF STUDY" centered headings with their content; the whole page single-spaced (sample p.31).

- [ ] **Step 6: Commit**

```bash
git add lib/frontmatter.typ tests/frontmatter.typ
git commit -m "feat(p2): vita (year-column entries, publications, fields)"
```

---

### Task 6: Abstract (+ chair-line helper) and main-matter landing

**Files:**
- Modify: `lib/frontmatter.typ` (add `_chair-line`, `abstract`)
- Modify: `tests/frontmatter.typ` (add `#abstract(meta)[…]`, then `#main-matter()` + a body stub)

**Interfaces:**
- Consumes: `_prelim-heading`, `_professor`, `single-spaced`; `main-matter` from `lib/pagination.typ` (already imported in the test).
- Produces:
  - `#let _chair-line(committee)` → centered "Professor <chair>, Chair" (+ "Professor <co-chair>, Co-Chair" when present); `#assert`s the chair.
  - `#let abstract(meta, body)` → fresh page; **2.5″ top margin** (a `v(1.5in)` spacer); centered "ABSTRACT OF THE DISSERTATION"; structured centered header (title / by / author / "<degree> in <degree-field>" / "University of California San Diego, <year>" / chair line); then `body`, double-spaced.

- [ ] **Step 1: Add the abstract + main-matter calls to `tests/frontmatter.typ`**

Extend the import and append after `#vita(…)`:

```typ
#import "../lib/frontmatter.typ": title-page, copyright-page, approval-page, dedication, epigraph, preface, acknowledgements, vita, abstract
```
```typ
#abstract(meta)[
  The abstract begins here. It is a condensed summary of the work.
  #context {
    let n = counter(page).get().first()
    assert(n == 9, message: "abstract should be page 9 (ix), got " + str(n))
    [#metadata(n) <p-abs>]
  }
]

#main-matter()
#context {
  let n = counter(page).get().first()
  assert(n == 1, message: "first body page should restart at 1, got " + str(n))
  [Body text. #metadata(n) <p-body>]
}
```

- [ ] **Step 2: Compile the test (expect FAIL)**

Run: `mkdir -p build && pixi run typst compile --font-path fonts --root . tests/frontmatter.typ build/frontmatter.pdf`
Expected: FAIL — `abstract` is an unknown import.

- [ ] **Step 3: Append `_chair-line` and `abstract` to `lib/frontmatter.typ`**

```typ
// Abstract chair line(s): chair, then co-chair if present. Shared shape with the
// committee block but centered and chair-only (manual abstract sample p.33).
#let _chair-line(committee) = {
  assert(committee.chair != none, message: "committee.chair is required")
  let lines = ([#_professor(committee.chair), Chair],)
  if committee.co-chair != none {
    lines.push([#_professor(committee.co-chair), Co-Chair])
  }
  align(center, lines.join(linebreak()))
}

// Abstract — heading + structured header + double-spaced body. Sample p.33.
// The 2.5in top margin is achieved on the FIRST page only via a v(1.5in) spacer
// above the inherited 1in margin (continuation pages stay at 1in). The header is
// centered with first-line-indent reset; the body keeps the inherited
// double-spaced 0.5in-indent defaults.
#let abstract(meta, body) = {
  pagebreak(weak: true)
  v(1.5in) // 1in margin + 1.5in = 2.5in top margin on the abstract's first page
  _prelim-heading("Abstract of the Dissertation")
  {
    set par(first-line-indent: 0pt)
    align(center)[
      #v(0.5in)
      #meta.title
      #v(0.4in)
      by
      #v(0.3in)
      #meta.author
      #v(0.4in)
      #meta.degree in #meta.degree-field
      #v(0.4in)
      University of California San Diego, #meta.year
      #v(0.4in)
      #_chair-line(meta.committee)
    ]
  }
  v(0.5in)
  body
}
```

- [ ] **Step 4: Compile the test (expect PASS)**

Run: `mkdir -p build && pixi run typst compile --font-path fonts --root . tests/frontmatter.typ build/frontmatter.pdf`
Expected: PASS — zero warnings; the abstract pin asserts page 9 (ix) and the body assert confirms the Arabic restart to 1.

- [ ] **Step 5: Verify the abstract header, the 2.5″ top margin, and the body restart**

Run:
```bash
pdftotext build/frontmatter.pdf - 2>/dev/null > /tmp/ft.txt
for s in "ABSTRACT OF THE DISSERTATION" "This Is the Title of My Dissertation" \
         "Doctor of Philosophy in Computer Science" \
         "University of California San Diego, 2025" "Professor Eta Theta, Chair" \
         "Professor Gamma Delta, Co-Chair" "The abstract begins here."; do
  grep -qF "$s" /tmp/ft.txt && echo "OK: $s" || echo "MISSING: $s"
done
for L in p-abs:9 p-body:1; do
  label="${L%%:*}"; want="${L##*:}"
  got=$(pixi run typst query --font-path fonts --root . tests/frontmatter.typ "<$label>" --field value --one 2>/dev/null)
  [ "$got" = "$want" ] && echo "$label OK ($got)" || echo "$label MISMATCH want=$want got=$got"
done
pdftotext -bbox build/frontmatter.pdf - 2>/dev/null | grep -i "ABSTRACT" | grep -oE 'yMin="[0-9.]+"' | head -1
```
Expected: every `OK:` line; `p-abs OK (9)` and `p-body OK (1)`; and a `yMin` for "ABSTRACT" near **180** (2.5″ = 180pt from the top). Open the PDF: the heading sits ~2.5″ down; the structured header is centered; the body is double-spaced; the next page is Arabic `1`.

- [ ] **Step 6: Commit**

```bash
git add lib/frontmatter.typ tests/frontmatter.typ
git commit -m "feat(p2): abstract page (2.5in top margin, structured header) + chair-line"
```

---

### Task 7: Whole-sequence verification, warning gate, and optional-path test

**Files:**
- Create: `tests/frontmatter-minimal.typ` (optional-path coverage: no co-chair, declined copyright, vita with no publications/fields)
- (No `lib/` changes — verification only.)

**Interfaces:**
- Consumes: the full public API (`title-page`, `copyright-page`, `blank-page`, `approval-page`, `dedication`, `epigraph`, `preface`, `acknowledgements`, `vita`, `abstract`) and P1's markers.
- Produces: confirmation of a warning-free compile, the full golden sequence, and that the optional/omitted branches compile.

- [ ] **Step 1: Confirm a warning-free compile of the main test**

Run: `mkdir -p build && pixi run typst compile --font-path fonts --root . tests/frontmatter.typ build/frontmatter.pdf 2>&1 | grep -qi "warning" && echo "WARNINGS PRESENT" || echo "clean"`
Expected: `clean`. If any warning appears, fix it before proceeding.

- [ ] **Step 2: Re-assert the full prelim → body sequence in one sweep**

Run:
```bash
for L in p-ded:4 p-epi:5 p-pre:6 p-ack:7 p-vita:8 p-abs:9 p-body:1; do
  label="${L%%:*}"; want="${L##*:}"
  got=$(pixi run typst query --font-path fonts --root . tests/frontmatter.typ "<$label>" --field value --one 2>/dev/null)
  [ "$got" = "$want" ] && echo "$label OK ($got)" || echo "$label MISMATCH want=$want got=$got"
done
```
Expected: every line ends `OK` — dedication iv (4) … abstract ix (9), body restarts at 1. (Title i, copyright ii, approval iii are pinned implicitly: dedication == 4 ⇒ approval == 3 ⇒ copyright == 2, title == 1.)

- [ ] **Step 3: Write `tests/frontmatter-minimal.typ` (optional/omitted branches)**

```typ
#import "../lib/template.typ": dissertation
#import "../lib/pagination.typ": front-matter, main-matter
#import "../lib/frontmatter.typ": title-page, blank-page, approval-page, vita, abstract

#let meta = (
  title: "A Minimal Dissertation",
  author: "Grace Hopper",
  degree: "Doctor of Philosophy",
  degree-field: "Mathematics",
  committee: (chair: "Solo Chair", co-chair: none, members: ("Member One",)),
  year: "2026",
)

#show: dissertation

#front-matter()

#title-page(meta)        // no co-chair: committee block omits the Co-Chair line
#blank-page()            // declined copyright notice: blank counted page ii
#approval-page(meta)
#vita(entries: ((year: "2026", body: "Doctor of Philosophy, UC San Diego"),))  // no publications/fields
#abstract(meta)[Abstract.] // chair-only chair line

#main-matter()
#context {
  let n = counter(page).get().first()
  assert(n == 1, message: "minimal: body should restart at 1, got " + str(n))
  [Body. #metadata(n) <p-body-min>]
}
```

- [ ] **Step 4: Compile the minimal test (expect PASS)**

Run: `mkdir -p build && pixi run typst compile --font-path fonts --root . tests/frontmatter-minimal.typ build/frontmatter-minimal.pdf 2>&1 | grep -qi "warning" && echo "WARNINGS PRESENT" || echo "clean"`
Expected: `clean` — proves the `co-chair: none` branch (no Co-Chair line), `blank-page()`, and `vita` with `publications: none`/`fields: none` all compile without error or warning.

- [ ] **Step 5: Verify the omitted branches produced no stray content**

Run:
```bash
pdftotext build/frontmatter-minimal.pdf - 2>/dev/null > /tmp/ftm.txt
grep -qF "Solo Chair" /tmp/ftm.txt && echo "OK: chair present" || echo "MISSING: chair"
grep -qF "Co-Chair" /tmp/ftm.txt && echo "FAIL: stray Co-Chair line" || echo "OK: no Co-Chair line"
grep -qF "PUBLICATIONS" /tmp/ftm.txt && echo "FAIL: stray PUBLICATIONS heading" || echo "OK: no PUBLICATIONS heading"
grep -qF "FIELDS OF STUDY" /tmp/ftm.txt && echo "FAIL: stray FIELDS OF STUDY heading" || echo "OK: no FIELDS OF STUDY heading"
got=$(pixi run typst query --font-path fonts --root . tests/frontmatter-minimal.typ "<p-body-min>" --field value --one 2>/dev/null)
[ "$got" = "1" ] && echo "p-body-min OK (1)" || echo "p-body-min MISMATCH want=1 got=$got"
```
Expected: `OK: chair present`, `OK: no Co-Chair line`, `OK: no PUBLICATIONS heading`, `OK: no FIELDS OF STUDY heading`, `p-body-min OK (1)`.

- [ ] **Step 6: Commit**

```bash
git add tests/frontmatter-minimal.typ
git commit -m "test(p2): optional-path coverage (no co-chair, blank copyright, bare vita)"
```

---

## Self-Review

**Spec coverage:**
- Stateless `meta` dict passed to title/approval/abstract (Decision 1) → Tasks 1, 3, 6; `dissertation()` untouched (new files only) → Global Constraints + every task. ✓
- Committee structured + auto-decorate (`(chair, co-chair, members)`, "Professor" prefix, ", Chair"/", Co-Chair", author order, chair `#assert`) (Decision 2) → `_committee-block` (Task 1) + `_chair-line` (Task 6). ✓
- Vita structured entries + optional free sections (Decision 3) → Task 5. ✓
- Per-page builders, optional pages opt-in (Decision 4) → Tasks 4–6 (the four section pages, vita, abstract are individually called). ✓
- Counted-but-unnumbered via one-shot `#page(numbering: none)` (Decision 5); abstract 2.5″ via `v(1.5in)` spacer → Tasks 1, 2 (title/copyright) and Task 6 (abstract). ✓
- Consistent headings via `_prelim-heading`; title-page + abstract headers match (Decision 6) → Task 1 (helper) used by title (Task 1) and abstract (Task 6). ✓
- Title page content (UCSD line, title, degree statement, "in"/field, "by"/author, committee, year) sample p.13 → Task 1. ✓
- Copyright page three lines just above bottom margin + blank-page fallback, sample p.17 / p.16 → Task 2. ✓
- Approval page: no heading, statement top-left, university+year centered, vertically centered, no signature lines, displayed iii, sample p.19 → Task 3. ✓
- Dedication/epigraph/preface/acknowledgements, sample pp.iv–viii → Task 4. ✓
- Vita year-column grid + publications + fields, sample p.31 → Task 5. ✓
- Abstract heading + 2.5″ + structured header + chair line + double-spaced body, sample p.33 → Task 6. ✓
- Verification: zero warnings (Task 7 Step 1, Step 4), exact sequence i…ix → 1 (Tasks 4–6 in-doc asserts + Task 7 Step 2), per-page content (pdftotext in each task), `#assert` chair (helpers in Tasks 1, 6 — exercised by every render) → ✓.
- Non-goals correctly absent: no 350-word count (P6), no TOC/List pages (P4), no co-authored chapter content (P6), no joint/master's variants.

**Placeholder scan:** No TODO/TBD. The `v()` gap values in `title-page`, `approval-page`, and `abstract` are explicit tuned starting points with a visual-tune step (Task 1 Step 6, Task 3 Step 5, Task 6 Step 5), not blanks — mirroring P1's footer-geometry tuning. The 180pt (2.5″) and bottom-margin bbox targets are derived geometric values.

**Type / name consistency:** `_prelim-heading`, `_professor`, `_committee-block`, `_chair-line`, `_section-page`, `title-page`, `copyright-page`, `blank-page`, `approval-page`, `dedication`, `epigraph`, `preface`, `acknowledgements`, `vita`, `abstract` are defined in `lib/frontmatter.typ` and match every import/call in both test files. `meta` keys (`title`, `author`, `degree`, `degree-field`, `committee`, `year`) and `committee` keys (`chair`, `co-chair`, `members`) are used identically across `_committee-block`, `_chair-line`, `title-page`, and `abstract`. `vita` keyword args (`entries`, `publications`, `fields`) and entry keys (`year`, `body`) match between definition (Task 5) and call sites (Tasks 5, 7). Metadata labels `<p-ded> <p-epi> <p-pre> <p-ack> <p-vita> <p-abs> <p-body> <p-body-min>` are unique and reused consistently between asserts and queries.

**Parallel-safety scan:** Only `lib/frontmatter.typ`, `tests/frontmatter.typ`, `tests/frontmatter-minimal.typ` are created. No edits to `lib/template.typ`, `lib/pagination.typ`, `lib/blocks.typ`, `lib/floats.typ`, `lib/backmatter.typ`, `pixi.toml`, `tests/smoke.typ`, or `docs/compliance-checklist.md`. All commands invoke `pixi run typst …` directly — no new pixi task. `build/` is the only output dir (gitignored), created with `mkdir -p build` before each compile.

---

**Compliance-checklist note (OUT OF SCOPE here — for P6 to tick):** completing this plan satisfies the `[P2]` rows — all preliminary-page-order rows; every title-page, copyright-page, approval-page, abstract, and vita row; the consistent-headers and matching title/abstract-header rows; "vita may be single-spaced". P6 checks these off in `docs/compliance-checklist.md`; this phase does not edit that file.
