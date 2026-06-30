# Spec: Phase 4 — Table of Contents & List-of Pages

**Date:** 2026-06-30
**Roadmap:** `docs/roadmaps/2026-06-26-ucsd-thesis-typst-roadmap.md` (Phase 4)
**Status:** Approved design; ready for `writing-plans`.
**Depends on:** P2 (front-matter pages), P3 (floats & headings).

## Goal

Implement the `TABLE OF CONTENTS` and the List-of pages (Figures, Schemes, Tables,
Graphs, Abbreviations, Symbols, Supplemental Files), matching the manual's sample
pages (pp. 25–27). After this phase the preliminary pages that index the document
render correctly and compliantly.

Output: `lib/lists.typ`, small additive edits to `lib/frontmatter.typ` and
`lib/floats.typ`, and `tests/lists.typ` — all compiling with **zero warnings**.

## Authoritative rules (from `formattingmanual.pdf`, §III pp. 25–27)

| Rule | Manual ref |
|---|---|
| TOC required; heading "TABLE OF CONTENTS" | p. 25, sample p. 26 |
| TOC lists preliminary pages (Approval → Abstract) with their roman page numbers, then body + back matter | sample p. 26 |
| Title page & copyright page are **not** listed in the TOC | sample p. 26 (list starts at Approval, iii) |
| The TOC itself and each List-of page **are** listed in the TOC | sample p. 26 |
| Section/header titles match the body exactly | p. 25 |
| Lists the page each section first appears on | p. 25 |
| Separate List of Figures / Schemes / Tables / Graphs when such items are scattered | p. 25, sample p. 27 |
| List of Supplemental Files when supplemental files submitted | p. 25 |
| List-of entries formatted "Figure 1.1: caption … page" with dot leaders | sample p. 27 |
| Literal "Figure"/"Table"/"Scheme"/"Graph" precedes each caption in the list | sample p. 27 (NOTE) |
| Captions longer than 4 lines abbreviated to ≤ 4 lines in the list | sample p. 27 (NOTE) |

## Decisions (locked)

1. **Full sample fidelity.** The TOC lists front-matter pages (Approval, Dedication,
   Epigraph, Table of Contents, each List-of page, Preface, Acknowledgements, Vita,
   Abstract) with their roman page numbers, then body chapters/sections, then back
   matter (appendices, references) with arabic page numbers. Title page and copyright
   page are not listed.
2. **TOC depth 3.** List chapters (level 1) + sections (level 2) + subsections
   (level 3). Main-matter chapter lines reconstructed as **"Chapter N  <title>"**
   (title-case label, matching the sample); sections/subsections show their title only,
   unnumbered (matching the body, where P3 made sections unnumbered).
3. **Manual, query-based TOC** — built by `query`, not Typst's `outline()`. Gives full
   control over the mixed front-matter / body / back-matter entry sources, the
   roman↔arabic page numbering, and the "Chapter N" reconstruction without depending on
   `outline.entry` quirks.
4. **Cross-module TOC-entry contract `<ucsd-toc-entry>`** (mirrors the existing
   `state("ucsd-matter")` pattern: cross-module by label, **no imports**). Every
   front-matter page that appears in the TOC emits
   `[#metadata((title: "<Title Case>")) <ucsd-toc-entry>]`. The Title-Case title is
   distinct from the all-caps page heading.
5. **Short-caption support via a `short:` param** on `fig`/`tbl`/`scheme`/`graph`
   (additive edit to P3 `floats.typ`). The List-of uses `short` when provided, else the
   full caption — this is the author's escape hatch for the ≤ 4-line rule. No automatic
   truncation.
6. **Unified float-entry marker `<ucsd-float-entry>`.** Every `_float` (regular *and*
   facing) emits one marker `[#metadata((kind, caption: short-or-full)) <ucsd-float-entry>]`.
   This replaces P3's facing-only `<ucsd-facing-caption>` marker, so facing floats
   (whose figure carries `caption: none`) still appear in the List-of.
7. **Reuse `prelim-heading`.** Export the currently-private `_prelim-heading` from
   `frontmatter.typ` so the TOC/List-of headings share the exact centered, all-caps,
   regular-weight style — one source of truth for "consistent preliminary headers".
8. **Inline-call builders, not a show bundle** — consistent with P2's front-matter
   composition (`#title-page(meta)` … `#abstract(meta)[…]`).
9. **Auto-skip empty lists.** Each List-of builder renders nothing (and registers no
   TOC entry) when its target set / entry list is empty, so the author may call them
   unconditionally.

## Architecture

```
lib/
  lists.typ          # NEW: table-of-contents() + 7 list-of builders; <ucsd-toc-entry> consumer
  frontmatter.typ    # EDIT (additive): export prelim-heading; register-toc(title) helper +
                     #   calls in approval/dedication/epigraph/preface/acknowledgements/vita/abstract
  floats.typ         # EDIT (additive): `short:` param on fig/tbl/scheme/graph; unified
                     #   <ucsd-float-entry> marker (replaces <ucsd-facing-caption>)
tests/
  lists.typ          # NEW: front matter + TOC + all list pages + multi-chapter body +
                     #   facing/short-caption floats + back matter; query/#assert; zero warnings
```

### `lib/lists.typ`

Public builders (inline calls, placed between `epigraph` and `preface` in checklist
order rows 6–13):

- **`table-of-contents()`** — `prelim-heading("Table of Contents")`; register its own
  TOC entry; then two passes via a shared `_toc-line(indent, body, page, pattern)`
  helper (title + `box(width: 1fr, repeat[.])` dot leader + right-aligned page number):
  1. **Front-matter pass:** `query(<ucsd-toc-entry>)`; page = `counter(page).at(loc)`
     rendered roman (`"i"`); rendered in document order.
  2. **Body + back-matter pass:** `query(heading)` (front-matter pages use
     `prelim-heading`, not headings, so only body + back-matter headings match),
     filtered to depth ≤ 3, page rendered arabic (`"1"`):
     - Main-matter level-1 (`state("ucsd-matter").at(loc) == "main"`): "Chapter N
       <title>" with N from a **running counter incremented per main level-1 heading**
       (avoids `counter.at()` timing fragility).
     - Back-matter level-1 (appendix, bibliography): title verbatim.
     - Levels 2–3: title only, indented `(level − 1) × 0.3in`, unnumbered.
- **`list-of-figures()` / `list-of-schemes()` / `list-of-tables()` / `list-of-graphs()`**
  — `prelim-heading("List of …")`; if no floats of that kind, render nothing and stop;
  else register a TOC entry, then `query(<ucsd-float-entry>)` filtered by kind, each
  rendered `"<Supplement> <chap>.<n>: <list-caption> … <page>"` (literal supplement
  prefix; `chap.n` from chapter counter + per-kind figure counter at the marker
  location; `list-caption` = `short` if present else full caption; dot leader; page).
- **`list-of-abbreviations(entries)` / `list-of-symbols(entries)` /
  `list-of-supplemental-files(entries)`** — author-supplied two-column data
  (term → definition, symbol → definition, filename → description). If `entries` empty,
  render nothing; else `prelim-heading` + register TOC entry + single-spaced two-column
  grid. No page numbers (these reference no located document elements).

### `lib/frontmatter.typ` (additive edits)

- Rename `_prelim-heading` → exported `prelim-heading` (update internal call sites).
- Add `register-toc(title)` = `[#metadata((title: title)) <ucsd-toc-entry>]`.
- Call `register-toc("<Title Case>")` inside `approval-page` ("Dissertation/Thesis
  Approval Page"), `dedication`, `epigraph`, `preface`, `acknowledgements`, `vita`,
  `abstract` ("Abstract of the Dissertation"). Title page & copyright register nothing.
- Document the `<ucsd-toc-entry>` contract in a header comment (as the matter-state
  contract is documented).

### `lib/floats.typ` (additive edits)

- Add `short: none` param to `fig`/`tbl`/`scheme`/`graph` and thread it into `_float`.
- In `_float`, emit one unified marker for every float (regular and facing):
  `[#metadata((kind: kind, caption: if short != none { short } else { caption })) <ucsd-float-entry>]`.
  Remove the facing-only `<ucsd-facing-caption>` marker.
- Keep the matter-state contract and the cross-phase counter behavior unchanged.

## Non-goals (deferred)

- **Unnumbered body chapters** (a standalone "Introduction" before "Chapter 1" as in
  the sample) — our template numbers every main level-1 heading; a P3/P6 concern.
- **Automatic ≤ 4-line truncation** — author supplies `short:`.
- Per-kind "Continued"/multipage list handling beyond what P3 already does.

## Verification

P4 is complete when:

1. `tests/lists.typ` compiles with **zero warnings**, and `tests/floats.typ` /
   `tests/cross-phase.typ` still pass (the `<ucsd-float-entry>` change must not break
   P3's counter/facing behavior).
2. The TOC heading reads "TABLE OF CONTENTS"; preliminary pages Approval → Abstract are
   listed with their roman page numbers; the TOC and each List-of page list themselves;
   title/copyright are absent.
3. Main chapters render "Chapter N  <title>"; sections/subsections (levels 2–3) appear
   indented and unnumbered; back-matter headings (appendix, references) appear with
   their literal titles and arabic page numbers.
4. Each List-of entry reads "<Supplement> <chap>.<n>: <caption> … <page>" with dot
   leaders and the literal supplement prefix; a `short:` caption is used in place of the
   full caption; a `facing: true` float still appears.
5. These `compliance-checklist.md` **[P4]** rows are satisfied (checked off in P6):
   TOC heading; lists first-appearance pages; titles match body; separate
   Figures/Schemes/Tables/Graphs lists; Supplemental Files list; dot-leader entry
   format; ≤ 4-line abbreviation; literal "Figure"/"Table"/"Graph" prefix.

## Open risks

- **`counter("ucsd-chapter").at(loc)` timing for List-of float numbers** — the chapter
  step happens inside a show-rule `context` in P3. Verify the `chap.n` value with a
  `typst query` probe; if off-by-one, store the resolved number in the
  `<ucsd-float-entry>` marker instead of recomputing from counters.
- **Replacing `<ucsd-facing-caption>`** is a behavior change to P3 — confirm
  `tests/floats.typ` does not assert on that label and stays green; update it if it does.
- **Two-pass page-number patterns** — the front pass hardcodes roman and the body pass
  hardcodes arabic; confirm no front-matter heading leaks into the body `query(heading)`
  pass (it should not, since front matter uses `prelim-heading`, not `heading`).
