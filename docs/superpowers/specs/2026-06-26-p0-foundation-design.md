# Spec: Phase 0 — Foundation

**Date:** 2026-06-26
**Roadmap:** `docs/roadmaps/2026-06-26-ucsd-thesis-typst-roadmap.md` (Phase 0)
**Status:** Approved design; ready for `writing-plans`.
**Depends on:** nothing.

## Goal

Stand up the Typst project skeleton and the base layout layer so that a minimal
document compiles to a PDF that already satisfies every page-/text-level rule the
UCSD manual imposes globally. No front matter, pagination engine, floats, or lists
yet — just the foundation later phases build on.

Output: a clean-compiling smoke-test PDF, plus a calibration page proving the
double-spacing target, produced by `pixi run build`.

## Authoritative measurements (from `DissertationTemplate_Doctoral_v2.3.docx`)

Extracted from the official Word template's OOXML, used here so values are measured,
not guessed:

| Property | Word value | Meaning |
|---|---|---|
| Page size | `w:pgSz w=12240 h=15840` | 8.5″ × 11″ (US Letter) |
| Margins | `w:pgMar top/right/bottom/left=1440` | 1″ all sides |
| Footer offset | `w:footer=720` | 0.5″ from bottom edge (wired in P1) |
| Body line spacing | `w:spacing line=480 lineRule=auto` | Word "Double" = 2.0× single-line height |
| First-line indent | `w:ind firstLine=720` | 0.5″ |
| Long-quote indent | `w:ind left=1440 right=1008` | left +0.5″, right +0.7″ (see Decisions) |
| Default font | Times New Roman 12pt | overridden to Helvetica clone per locked scope |

## Decisions (locked)

1. **Double spacing = clean typographic 2.0×.** Calibrate Typst `par(leading)` so
   the measured baseline-to-baseline distance is exactly double the font's native
   single-spaced line advance. Verify empirically on `tests/calibration.typ`; record
   the resulting leading value and the measured single/double advances in the README.
   (Typst `leading` is the gap between line boxes, not baseline-to-baseline, so the
   value must be derived from a compiled measurement, not assumed.)
2. **Font = TeX Gyre Heros, vendored in-repo.** The Helvetica/Arial metric clone is
   committed under `fonts/` (regular, bold, italic, bold-italic) and compiled with
   `--font-path fonts/`. No dependency on system-installed fonts → byte-identical
   output on any machine and in CI.
3. **Toolchain = pixi.** `pixi.toml` pins `typst`; `pixi run build` is the canonical
   compile command. No global typst install assumed.
4. **Repo root is the package root.** `typst.toml`, `lib/`, and `tests/` live at the
   repo root alongside the existing `docs/`. No `thesis/` subdirectory.
5. **Long quotes use the manual's symmetric 0.5″** on both sides (§II), not the
   template's asymmetric 0.5″/0.7″. The manual prose is the compliance authority; the
   template value looks like an authoring artifact.
6. **Body text is ragged-right** (no justification), matching the template (no `w:jc`).

## Architecture

```
typst.toml            # package manifest: name, version, entrypoint=lib/template.typ, compiler bound
pixi.toml             # [dependencies] typst; [tasks] build = compile tests/smoke.typ
fonts/                # TeX Gyre Heros OTFs (qhvr/qhvb/qhvri/qhvbi)
lib/
  template.typ        # #let dissertation(..fields, body): page geometry + fonts + text rules
  blocks.typ          # single-spaced / long-quote primitives + spacing helpers
tests/
  smoke.typ           # imports template, a few paragraphs + a footnote + a long quote
  calibration.typ     # a page of repeated lines for measuring line advance
.gitignore            # build/, *.pdf
README.md             # how to build; recorded calibration values
```

### `lib/template.typ`

A single entry function applied via `#show: dissertation`. Phase 0 implements only
the layout layer; metadata fields (title, author, …) are accepted but unused until
P2, so they stay as stubbed named arguments with sensible defaults.

Responsibilities:
- `set page(paper: "us-letter", margin: 1in)` — 1″ all sides. (Footer content added
  in P1; the 0.5″ region is implied by the page model and handled there.)
- `set text(font: "TeX Gyre Heros", size: 12pt, fill: black, lang: "en")`.
- `set par(leading: <calibrated>, first-line-indent: (amount: 0.5in, all: true),
  justify: false)` — every paragraph indents, including the first after a heading.
- Footnote text set to 10pt, single-spaced (≥10pt rule).
- Returns `body`.

### `lib/blocks.typ`

- `#let single-spaced(body)` — wraps content with single-line leading; the reusable
  primitive for captions, bibliography, vita, appendices in later phases.
- `#let long-quote(body)` — single-spaced block, `pad(left: 0.5in, right: 0.5in)`,
  no inserted quotation marks. Built on `single-spaced`.

## Non-goals (deferred)

- Page numbering / roman↔arabic / footer rendering → **P1**.
- Any front-matter page → **P2**.
- Headings, figures/tables/floats, captions → **P3**.
- TOC / list-of pages → **P4**.
- Bibliography / back matter → **P5**.

## Verification

Phase 0 is complete when:

1. `pixi run build` compiles `tests/smoke.typ` with **zero warnings**.
2. On `tests/calibration.typ`, measured body baseline-to-baseline = **2.0×** the
   single-spaced advance (value recorded in README).
3. PDF confirms **US Letter** page size and **1″** margins on all sides.
4. The long-quote block renders single-spaced, indented 0.5″ both sides, no quote
   marks.
5. Footnotes and the long quote are ≥10pt.
6. These `compliance-checklist.md` **[P0]** rows are checked:
   - legible typeface; 1″ margins; body font ≥10pt (12pt) via TeX Gyre Heros;
     footnotes/captions ≥10pt; one consistent font; all text black; italics-for-
     emphasis allowed; body double-spaced; 0.5″ first-line indent / no block style;
     long quotations single-spaced + 0.5″ both sides; captions may be single-spaced
     (primitive exists).

## Open risks

- **Font fetch:** acquiring the TeX Gyre Heros OTFs requires one network download
  (GUST/CTAN) during implementation; thereafter fully offline. If the environment
  blocks the fetch, fall back to Liberation Sans (same Helvetica metrics) — note
  whichever is committed in the README.
- **Calibration drift:** the leading value is font-specific; if the font ever
  changes, the calibration page must be re-measured. README documents the procedure.
