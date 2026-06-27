# Roadmap: UCSD Doctoral Dissertation — Typst Template

**Date:** 2026-06-26
**Status:** Approved (high-level design); phases to be specced individually.

## Goal

Adapt the UC San Diego *Preparation and Submission Manual for Doctoral
Dissertations and Master's Theses* (2025–2026) and the official Word template into
a reusable **Typst** template that produces a manuscript compliant with every hard
requirement in the manual, and author the dissertation in it.

## Scope decisions (locked)

| Decision | Choice |
|---|---|
| Deliverable | Reusable Typst template package (`lib/` + `#show` function) **plus** the actual `thesis.typ` content. The manual becomes machine-enforced layout, not prose. |
| Degree variants | **PhD only, non-joint.** Single title/approval/abstract variant. (YAGNI on DMA/EdD/Joint/Master's.) |
| Audience | **Mine first, clean structure.** Template layer parameterized with no hardcoded personal values, so it can be released to Typst Universe later. |
| Font | **Helvetica/Arial via metric-compatible free clone** (TeX Gyre Heros / Liberation Sans) so the document compiles identically on any machine and in CI. |

The manual permits 10/11/12pt; we default body to 12pt. Footnotes and captions ≥10pt.

## Reference material in repo

- `formattingmanual.pdf` — the authoritative 62-page manual (source of every rule).
- `DissertationTemplate_Doctoral_v2.3.docx` — the official Word fill-in skeleton.

No official UCSD Typst template exists. Patterns (front/main/back-matter show-rule
helpers, page-number resets) are borrowed from general Typst thesis templates
(`scholarly-epfl-thesis`, TUM AET) but the compliance layer is built from scratch.

## Architecture

```
thesis/
  typst.toml                 # package manifest (enables later Universe release)
  lib/
    template.typ             # master #show wrapper: page geometry, fonts, text rules
    pagination.typ           # front/main/back-matter transitions, roman↔arabic, footer
    frontmatter.typ          # title, copyright, approval, dedication, epigraph, ack, vita, abstract
    lists.typ                # TOC + List of Figures/Tables/Schemes/Graphs/Abbrev/Symbols
    floats.typ               # figure/table/scheme/graph kinds, caption placement, facing/landscape
    blocks.typ               # long-quote block, double-spacing primitives
  thesis.typ                 # YOUR thesis: imports template, fills metadata, includes chapters
  chapters/                  # 01-intro.typ, 02-..., your content
  figures/                   # image assets
  references.bib
  docs/
    roadmaps/                # this file
    compliance-checklist.md  # every MUST from the manual, checkbox per rule
    superpowers/specs/       # one design spec per phase
  README.md
```

The **compliance-checklist.md** is the project spine: every hard requirement from
the manual as a checkable row. Each phase verifies its work against the relevant
rows; Phase 6 does a final full pass. This keeps "compliant" objective.

## Compliance hotspots (the genuinely hard parts)

1. **Pagination.** Title + copyright are unnumbered but *counted* (i, ii); preliminary
   pages are lowercase roman starting at **iii** on the approval page; main body
   restarts at Arabic **1**. Page number centered, **0.5″ from the bottom edge**
   while the text margin is 1″.
2. **Double spacing.** Word "double" ≠ a guessed Typst `leading`. Calibrate
   `par(leading)` to a measured baseline-to-baseline target, with single-spacing
   carve-outs for captions, long quotes, the bibliography, vita, and appendices.
3. **Per-chapter float numbering + caption placement.** Figures/graphs/schemes vs.
   tables are captioned on opposite sides; numbered `chapter.n` (e.g. 1.1, 1.2);
   literal "Figure"/"Table" prefix; facing-caption pages and 90° landscape rotation
   for oversized floats.
4. **List-of pages.** `LIST OF FIGURES` etc. with dot leaders, captions abbreviated
   to ≤4 lines (short-caption support), titles matching the body exactly.

## Phases

Each phase gets its own brainstorming → spec (`docs/superpowers/specs/`) →
`writing-plans` plan → implementation cycle. Each is independently compilable and
verifiable against the checklist.

### P0 — Foundation
Repo scaffold, `typst.toml`, page geometry (US Letter, 1″ margins all sides), fonts
(TeX Gyre Heros), base text rules (12pt, black-only, **double-spacing calibration**,
0.5″ first-line indent on all paragraphs, no block style), long-quote block,
footnote/caption font sizing (≥10pt). Output: a minimal compiling document.
**Depends on:** nothing.

### P1 — Pagination engine
Front/main/back-matter helper functions, roman→arabic transition, title + copyright
counted-but-unnumbered, approval page = iii, footer placement (centered, 0.5″ from
bottom edge). Verified against the page numbers in the manual's sample TOC.
**Depends on:** P0.

### P2 — Front-matter pages
`title`, `copyright`, `approval`, `dedication` (opt), `epigraph` (opt),
`acknowledgements` (opt), `vita` (required for doctoral), `abstract` (350-word, 2.5″
top margin) — each matching its sample page in the manual.
**Depends on:** P0, P1.

### P3 — Body floats & headings
Chapter/section heading styles; `figure`/`table`/`scheme`/`graph` kinds with correct
caption placement (figure/scheme/graph caption below — table caption above) and
per-chapter numbering; facing-caption pages + 90° landscape; long-quote blocks wired
to `blocks.typ`.
**Depends on:** P0.

### P4 — TOC & List-of pages
`TABLE OF CONTENTS` outline + List of Figures / Tables / Schemes / Graphs /
Abbreviations / Symbols / Supplemental Files, with dot leaders, exact-title rule, and
≤4-line caption abbreviation.
**Depends on:** P2, P3.

### P5 — Back matter
Bibliography (single-spaced, double space between entries; no "et al." substitution),
reference-matter ordering (appendices → addenda → chronology → endnotes → glossary →
bibliography), appendices (may be single-spaced).
**Depends on:** P0.

### P6 — Integration & compliance
Assemble `thesis.typ`, plug in real metadata + chapters, full compile, and a final
verification pass over `compliance-checklist.md`.
**Depends on:** all prior phases.

## Notes

- P0 + P1 could merge, but pagination is intricate enough to isolate.
- P3 precedes P4 because the List-of pages consume the float definitions.
- Co-authored/published chapters require an acknowledgements paragraph and end-of-
  chapter acknowledgement (manual §III); relevant to the author's real content in P6.
