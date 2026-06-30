# Spec: Phase 2 — Front-matter Pages

**Date:** 2026-06-26
**Roadmap:** `docs/roadmaps/2026-06-26-ucsd-thesis-typst-roadmap.md` (Phase 2)
**Status:** Approved design; ready for `writing-plans`.
**Depends on:** P0, P1.

## Goal

Implement every preliminary page the manual prescribes for a **PhD, non-joint**
dissertation — title, copyright, approval, dedication, epigraph, preface,
acknowledgements, vita, abstract — each matching its sample page in
`formattingmanual.pdf`. After this phase a document can render the complete
front-matter sequence (i, ii unnumbered → iii on approval → roman prelims → main
matter restart) with correct content, headings, and spacing.

Output: `lib/frontmatter.typ` (public builders + internal helpers) plus
`tests/frontmatter.typ`, a standalone document that walks every page and compiles
with **zero warnings**.

## Authoritative rules (from `formattingmanual.pdf`)

| Rule | Manual ref |
|---|---|
| Title page: "UNIVERSITY OF CALIFORNIA SAN DIEGO" caps at top; specific descriptive title; "A dissertation submitted in partial satisfaction of the / requirements for the degree [Degree]"; "in" alone; degree field; "by" alone; author; "Committee in charge:"; year | §III p.12, sample p.13 |
| Committee: chair first, then co-chair (if any), then members alphabetical by last name; title "Professor"; double space between "Committee in charge:" and chair; members single-spaced, indented 0.5″ | §III p.12, sample p.13 |
| Copyright page: centered just above bottom margin; "Copyright" / "[Name], [Year]" / "All rights reserved."; unnumbered (ii) | §III p.16, sample p.17 |
| A second page (ii) must exist even when no copyright notice is included — blank, no page number | §III p.16 |
| Approval page: no header; top text left- or fully-justified; bottom info centered; all info centered vertically; **no signature lines** (non-joint); "The dissertation of [Name] is approved, and it is acceptable in quality and form for publication on microfilm and electronically."; "University of California San Diego" + year at bottom; numbered iii | §III p.18, sample p.19 |
| All preliminary pages have consistent headers (text, size, caps, placement); title-page header and abstract header match each other and use only the sample format | §III p.22 |
| Dedication / epigraph: any format within margins; centered all-caps heading | §III p.22, samples |
| Acknowledgements: paragraphs double-spaced, first line indented 0.5″ | §III p.28 |
| Vita: heading "VITA"; year column + entries; optional "PUBLICATIONS" and "FIELDS OF STUDY" sections; use "Master" not "Masters"; may be single-spaced | §III p.30, sample p.31 |
| Abstract: heading "ABSTRACT OF THE DISSERTATION"; **top margin 2.5″**; includes title, "by", author, degree, "University of California San Diego, [year]", chair line; body double-spaced; ≤ 350 words (doctoral) | §III p.32, sample p.33 |

## Decisions (locked)

1. **Stateless `meta` dict.** Shared metadata needed by the title page, approval
   page, and abstract is passed as one dictionary, defined once by the author and
   handed to the builders that need it. The page builders are pure functions of
   their inputs — no Typst `state`/`context`, no multipass or set-before-read
   ordering pitfalls, and each is unit-testable by compiling with a literal dict.
   Rejected: a metadata `state` (more implicit, ordering-sensitive) and a single
   `frontmatter()` orchestrator (least flexible; name collides with P1's
   pagination `front-matter()`).

   ```typst
   #let meta = (
     title: "This is the Title of My Dissertation",
     author: "My Name",
     degree: "Doctor of Philosophy",        // title page: "for the degree …"
     degree-field: "Biomedical Sciences",   // abstract: "Doctor of Philosophy in …"
     committee: (
       chair: "Eta Theta",
       co-chair: none,                      // optional
       members: ("Iota Mu", "Epsilon Zeta"),
     ),
     year: "2025",
   )
   ```

   The manual distinguishes the **degree** ("Doctor of Philosophy") from the
   **degree field/title** ("Biomedical Sciences"); both are stored. `dissertation()`
   already accepts `title`/`author`/`degree`/`year` but **does not use them**
   (defaulting to `none`); the author leaves them defaulted, so there is no
   duplication and **no edit to `lib/template.typ`** is required — P2 is new files
   only, honoring the "`dissertation()` is the only master wrapper; layer on top"
   architecture rule.

2. **Committee: structured + auto-decorate.** `committee` is a dict
   `(chair: <str>, co-chair: none | <str>, members: (<str>, …))` holding names
   only. The template prepends "Professor " and appends ", Chair" / ", Co-Chair";
   `chair` is required (`#assert`); `co-chair` optional; members are rendered in
   **author-given order** (no auto-sort — avoids mangling particled surnames; the
   author is responsible for alphabetical-by-last-name ordering). The title page
   derives the full list and the abstract derives the chair (+ co-chair) line from
   the same data, so the two are guaranteed consistent. Rejected: raw display
   strings (repetition, manual sync) and a flat role-tagged list (permits invalid
   states — two chairs, no chair).

3. **Vita: structured entries + free sections.**
   `vita(entries: (), publications: none, fields: none)`. `entries` is an array of
   `(year: <str>, body: <content/str>)` dicts laid out as a two-column grid
   (year left, entry right), single-spaced via `blocks.single-spaced`.
   `publications` and `fields` are optional free content rendered under centered
   "PUBLICATIONS" / "FIELDS OF STUDY" headings; omitted entirely when `none`.

4. **Per-page builders, optional pages opt-in.** Each preliminary page is its own
   function. The optional pages (dedication, epigraph, preface, acknowledgements)
   are simply not called when unwanted — no flags, no toggles. This matches the
   stateless-dict choice and keeps each unit small and independently testable.

5. **Counted-but-unnumbered pages via one-shot `#page(...)`.** The title and
   copyright pages use `#page(numbering: none)[…]` (the `page` *function*, a
   one-page override) rather than a `set page` rule, so the suppression applies to
   exactly that page and the counter still advances — the approval page, the first
   page that does not suppress its number, lands on **iii**. The shared centered
   footer (installed by P1's `front-matter()`) renders empty on these pages because
   `counter(page).display()` with `numbering: none` yields nothing. The abstract's
   2.5″ top margin is likewise a one-shot `#page(margin: (top: 2.5in))[…]` override.

6. **Consistent headings via an internal helper.** `_prelim-heading(text)` renders
   the centered, all-caps, 12pt heading at a consistent top placement. Both the
   title page's "UNIVERSITY OF CALIFORNIA SAN DIEGO" line and the abstract's
   "ABSTRACT OF THE DISSERTATION" heading go through it, satisfying the
   "title-page and abstract headers match" rule by construction.

## Architecture

```
lib/
  frontmatter.typ     # public builders + internal helpers (new)
tests/
  frontmatter.typ     # golden sequence: every front page + main-matter landing (new)
```

### `lib/frontmatter.typ` — public API

```typst
#import "blocks.typ": single-spaced

#let title-page(meta)            // page i, unnumbered (one-shot #page)
#let copyright-page(meta)        // page ii, unnumbered
#let blank-page()                // ii alternative when no copyright notice
#let approval-page(meta)         // page iii (first displayed number)
#let dedication(body)            // optional
#let epigraph(body)              // optional
#let preface(body)               // optional
#let acknowledgements(body)      // optional (required if co-authored/published)
#let vita(entries: (), publications: none, fields: none)   // required (doctoral)
#let abstract(meta, body)        // 2.5in top margin
```

- **`title-page(meta)`** — sample p.13. `#page(numbering: none)[…]` containing, all
  centered except the committee block: "UNIVERSITY OF CALIFORNIA SAN DIEGO"
  (`_prelim-heading`), title, "A dissertation submitted in partial satisfaction of
  the / requirements for the degree #meta.degree", "in", `meta.degree-field`,
  "by", `meta.author`, then a **left-justified** "Committee in charge:" with the
  committee list indented 0.5″ and single-spaced (double space between the label
  and the chair), and `meta.year` near the bottom. Fixed `v()` gaps tuned to the
  sample.
- **`copyright-page(meta)`** — sample p.17. `#page(numbering: none)[…]`; three lines
  centered just above the bottom margin: "Copyright", "#meta.author, #meta.year",
  "All rights reserved." `blank-page()` emits an empty `#page(numbering: none)[]`
  for authors who decline the notice (page ii must still exist, manual p.16).
- **`approval-page(meta)`** — sample p.19. No header. Approval statement
  ("The dissertation of #meta.author is approved, and it is acceptable in quality
  and form for publication on microfilm and electronically.") top, left-justified;
  "University of California San Diego" and `meta.year` centered below; the whole
  block vertically centered with fractional spacers. No signature lines. This is
  the first page whose number is displayed → **iii**.
- **`dedication` / `epigraph` / `preface`** — `_prelim-heading` ("DEDICATION" /
  "EPIGRAPH" / "PREFACE") then the author's `body` with no imposed formatting
  ("any format" per manual), each on its own page.
- **`acknowledgements(body)`** — `_prelim-heading("ACKNOWLEDGEMENTS")` then `body`;
  paragraphs inherit the double-spaced, 0.5″ first-line-indent body defaults from
  P0's `dissertation()`.
- **`vita(...)`** — `_prelim-heading("VITA")`; `entries` rendered as a two-column
  `grid` (year column auto width, body column 1fr), single-spaced; then, when
  provided, centered "PUBLICATIONS" / "FIELDS OF STUDY" headings followed by the
  respective free content.
- **`abstract(meta, body)`** — `#page(margin: (top: 2.5in))[…]`;
  `_prelim-heading("ABSTRACT OF THE DISSERTATION")`; structured centered header
  block: title, "by", author, "#meta.degree in #meta.degree-field",
  "University of California San Diego, #meta.year", and the chair line(s) derived
  from `meta.committee`; then `body`, double-spaced (inherits body defaults).

### Internal helpers (underscore-prefixed; not part of the public API)

- `_prelim-heading(text)` — centered, all-caps, consistent top placement.
- `_professor(name)` → `"Professor " + name`.
- `_committee-block(committee)` — builds the title-page list: chair (", Chair"),
  co-chair if present (", Co-Chair"), then members, each via `_professor`,
  single-spaced and indented 0.5″.
- `_chair-line(committee)` — the abstract's chair (+ co-chair) line(s).

`_committee-block` and `_chair-line` both `#assert(committee.chair != none)` so a
missing chair fails at compile time.

### `tests/frontmatter.typ`

A standalone document (imports P0 `dissertation`, P1 markers, P2 builders) that
defines a literal `meta` and renders, in order:

- `#front-matter()`
- `#title-page(meta)` → page i, no number shown
- `#copyright-page(meta)` → ii, no number shown
- `#approval-page(meta)` → **iii** shown
- `#dedication[…]`, `#epigraph[…]`, `#preface[…]`, `#acknowledgements[…]` → iv, v, …
- `#vita(entries: (…), publications: […], fields: […])`
- `#abstract(meta)[…]`
- `#main-matter()` + one stub body page → Arabic **1**

Plus a second, minimal render exercising the optional paths: `co-chair: none`,
`blank-page()` in place of the copyright notice, and a `vita` with
`publications: none` / `fields: none` — to prove those branches compile.

## Composition in a real document

```typst
#show: dissertation
#front-matter()            // P1: roman numbering + footer
#title-page(meta)
#copyright-page(meta)
#approval-page(meta)
#dedication[…]             // optional pages, as desired
#vita(entries: (…), publications: […])
#abstract(meta)[…]
#main-matter()             // P1: Arabic restart at 1
```

## Non-goals (deferred)

- **350-word abstract limit** → **P6**. Reliable word-counting is not feasible in
  Typst layout; the manual limit is verified at integration.
- **TOC / List-of pages** → **P4** (they consume these pages' page numbers and the
  exact-title rule).
- **Co-authored end-of-chapter acknowledgement paragraphs** and the co-authorship
  acknowledgements *content* → **P6** (chapter content; P2 supplies the page).
- **Joint / DMA / EdD / Master's variants** → out of scope (roadmap: PhD non-joint
  only).

## Verification

P2 is complete when:

1. `tests/frontmatter.typ` compiles with **zero warnings**.
2. The rendered PDF shows the exact pagination: title and copyright display **no**
   number; the approval page displays **iii**; optional prelims continue iv, v, …;
   `#main-matter()` lands Arabic **1**.
3. Each page visually matches its manual sample (pp. 13, 17, 19, 21, 31, 33):
   headings, caps, centering, the left-justified committee block with 0.5″ indent,
   the copyright block just above the bottom margin, the vertically-centered
   no-header approval page, the vita year-column grid, and the abstract's 2.5″ top
   margin and structured header.
4. A missing `committee.chair` fails the build (`#assert`).
5. These `compliance-checklist.md` **[P2]** rows are satisfied (checked off in P6):
   all preliminary-page-order rows; every title-page, copyright-page, approval-page,
   abstract, and vita row; the consistent-headers and matching title/abstract
   header rows; and "vita may be single-spaced".

## Open risks

- **`#page()` one-shot vs. global footer.** Confirm a `#page(numbering: none)[…]`
  page still advances `counter(page)` (so iii lands) and that the inherited footer
  renders empty rather than showing a stray glyph. Verify in the stub before
  relying on it (this also de-risks the P1 assumption).
- **Abstract 2.5″ top-margin override.** Confirm `#page(margin: (top: 2.5in))`
  overrides only the top margin and leaves the 1″ left/right/bottom and the footer
  intact, and that the page still numbers correctly in the roman sequence.
- **Vertical centering on the approval page.** Match the sample's "all info
  centered vertically" with fractional spacers; verify the statement does not
  collide with the centered bottom block on a short page.
- **Committee block alignment.** The "Committee in charge:" label is left-justified
  while most of the page is centered; verify the 0.5″ member indent and the double
  space below the label match the sample within the 1″ margins.
