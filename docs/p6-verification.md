# P6 Verification Report

**Date:** 2026-06-30
**Documents:** `examples/thesis.typ` (build/example.pdf), `thesis.typ` (build/thesis.pdf)
**Result:** both compile with zero warnings.

## Track A — in-document asserts (compile gate)

| Check | Mechanism | Result |
|---|---|---|
| Copyright counted ii (title i, unnumbered) | `assert.eq` at `<ucsd-copyright-page-end>` == 2 | PASS |
| Arabic restart at 1 | `assert.eq` first heading page == 1 | PASS |
| First figure numbered 1.1 | `assert.eq(numbering("1.1", chapter-counter.get().first(), counter(figure.where(kind: image)).get().first()), "1.1")` in `examples/chapters/01-introduction.typ` | PASS |

## Track B — visual diff vs formattingmanual.pdf

Manual sample pages are cited by the manual's **printed** page number, which runs
one ahead of the PDF-viewer index (e.g. the non-joint approval sample is printed
p.19 = PDF page 18; the joint variant is printed p.20). The non-joint variant is
always the one immediately before the joint variant.

Rendered-page index → content mapping (PNG pages 1–24; front matter i–xix = PNGs 1–19; Arabic 1–5 = PNGs 20–24):

| Rendered PNG | Arabic/Roman page | Manual sample | What was checked | Verdict |
|---|---|---|---|---|
| example-1.png | i (unnumbered) | p. 13 | "UNIVERSITY OF CALIFORNIA SAN DIEGO" caps at top; title; "A dissertation submitted…"; "in"; degree field; "by"; author; "Committee in charge:"; members indented; year "2026" at bottom; no page number | pass |
| example-2.png | ii (unnumbered) | p. 17 | three centered lines ("Copyright" / "Ada Lovelace, 2026" / "All rights reserved.") just above bottom margin; no page number | pass |
| example-3.png | iii | p. 19 (non-joint) | no header; approval statement left-justified at top; "University of California San Diego" + "2026" centered below; "iii" at bottom; matches manual non-joint sample p.19 — statement upper area, university/year lower-middle, blank bottom, content span centered ~48% | pass |
| example-17.png | xvii | vita sample (manual p. 31) | "VITA" heading centered; year-column entries (2018, 2020, 2026); "PUBLICATIONS" section; "FIELDS OF STUDY" section; "xvii" at bottom | pass |
| example-18.png | xviii | p. 33 | "ABSTRACT OF THE DISSERTATION" heading; heading starts ~2.5″ from top (measured ~375 px at 150 ppi on 11″ page); title / "by" / author / degree / university+year / chair structured header; double-spaced body begins | pass |
| example-6.png + example-7.png | vi–vii | pp. 26–27 | "TABLE OF CONTENTS" heading; dot leaders; roman numerals for front matter (iii–xix); Arabic numerals for main matter (1–5); "Chapter 1 Introduction", "Chapter 2 Methods", "Chapter 3 Results" titles; "APPENDIX A" and "Bibliography" in back matter | pass |
| example-11.png | xi | p. 26–27 (list sample) | "LIST OF FIGURES"; entries formatted "Figure N.M: caption...page" with dot leaders; Figure 3.2 shows abbreviated short caption in list; chapter-prefixed numbering (1.1, 2.1, 3.1, 3.2) | pass — page refs 1.1→1, 2.1→3, 3.1→4, 3.2→5 each match where the float renders (verified via pdftotext after the lib/lists.typ figure-location fix) |
| example-20.png | Arabic 1 | pp. 40–42 | Figure 1.1 caption below figure; Table 1.1 caption above table; page number "1" centered at bottom | pass |
| example-21.png | Arabic 2 | pp. 40–42 | Scheme 2.1 caption below scheme; Graph 2.1 caption above graph; Figure 2.1 facing-caption on this page (caption on p.2, figure on p.3) | pass |
| example-22.png | Arabic 3 | pp. 40–42 | Figure 2.1 tall placeholder occupying page; co-author acknowledgement at bottom; page "3" centered | pass |
| example-23.png | Arabic 4 | pp. 40–42 | Figure 3.1 landscape: figure box portrait-placed, caption rotated 90° along right edge; page "4" centered at bottom | pass |

## Abstract word count

Example abstract body (text inside `#abstract(meta)[…]`): **64 words** (< 350). PASS.

Word count command: `wc -w build/_abstract.txt` → `64`.

## Nature citation style

Added after the original P6 report, when `styles/nature-full-authors.csl` was
introduced alongside the bracketed default. Compiling `tests/citation-nature.typ`
clean is the automated gate; superscript rendering and reference format are not
expressible as in-document asserts, so they are verified from the PDF text layer:

    pixi run typst compile --font-path fonts --root . \
      tests/citation-nature.typ build/citation-nature.pdf
    pdftotext build/citation-nature.pdf -

| Check | Expected | Result |
|---|---|---|
| Compiles zero-warning | no output | PASS |
| No brackets around in-text numbers | `grep -c '\[[0-9]\]'` → `0` | PASS |
| Single citation | `1` after "sentence." | PASS |
| Adjacent pair comma-joined | `2,3` after "group." | PASS |
| Three consecutive collapse to a range | `1–3` after "list." | PASS |
| Nature reference format | `1. Watson, J. & Crick, F. Molecular Structure of Nucleic Acids. Nature 171, 737–738 (1953).` | PASS |
| `&` before final author, 8-author entry | `… Miller, G. & Davis, H.` | PASS |
| Italic journal, bold volume, italic book title | visual, `build/citation-nature.png` @150 ppi | PASS |
| Default style unaffected | `build/backmatter.pdf` still `[1] [2] [3]` | PASS |

**Bibliography spacing vs. the upstream CSL.** Upstream `nature.csl` sets
`line-spacing="2" entry-spacing="0"` on `<bibliography>`, which would conflict
with the manual's single-spaced-bibliography rule if honored. It is not:
`backmatter-rules`' Typst `par(leading: 0.65em, spacing: 1.3em)` governs. Measured
with `pdftotext -bbox` on `build/citation-nature.pdf` — within-entry line advance
**16.548 pt** (the native single advance) and between-entry advance **24.348 pt**,
i.e. single-spaced entries separated by a blank line, matching the default style.
The attributes are left in place so the diff against upstream stays minimal.

**Leading is undisturbed by the raised glyph.** Body lines sit at yMin 71.340 /
104.436 / 137.532 / 170.628 — a uniform **33.096 pt** advance across lines that do
and do not carry a citation, matching the calibrated double space (16.55 pt × 2.0).
Typst scales the superscript glyph rather than raising a full-size one.

## Full author lists (no "et al.") — regression

**This check previously failed.** Both styles set `et-al-min="99"
et-al-use-first="99"`, which reads as "never abbreviate" but is still a numeric
cap: a 105-author entry was truncated to the first author + "et al.", silently
dropping the rest. Large-consortium papers in genomics routinely exceed 99
authors, so this was reachable in practice, not theoretical.

**Fix:** both styles now omit `et-al-min`/`et-al-use-first` altogether. With
neither attribute set, CSL performs no truncation at any list length.

Guarded by `tests/consortium.bib` (one 105-author entry, deliberately above the
old 99 cap) cited from `tests/citation-full-authors.typ` (default style) and
`tests/citation-full-authors-nature.typ` (Nature style).

| Style | `grep -ci 'et al'` | `grep -c 'Surname105'` | Result |
|---|---|---|---|
| `ieee-full-authors.csl` before fix | `1` | `0` | FAIL (as found) |
| `ieee-full-authors.csl` after fix | `0` | `1` | PASS |
| `nature-full-authors.csl` | `0` | `1` | PASS |

## Spacer tuning

No spacer tuning was performed. All front-matter pages (title, copyright, approval, abstract) match the manual samples acceptably without adjustment to `lib/frontmatter.typ`.

## Findings

**Finding 1 — Figure 3.1 LOF page reference (RESOLVED in follow-up).** Previously the List of Figures showed Figure 3.1 at page 5 although the figure renders on page 4. Root cause: `lib/floats.typ` emits the `<ucsd-float-entry>` marker *after* the float body, so a page-filling landscape float pushed its trailing marker onto the next page, and `lib/lists.typ` read the page at the marker's location. **Fix:** `lib/lists.typ` now reads each float's number AND page at the **figure's own location** (pairing the i-th marker with the i-th figure of that kind, in document order), using the marker only for the caption text; the marker-placement comments in `lib/floats.typ` were updated to match. Verified via `pdftotext`: the List of Figures now reads 1.1→1, 2.1→3, 3.1→4, 3.2→5 — each matching where the float renders — and the Schemes/Tables/Graphs lists are unchanged (Scheme 2.1→2, Table 1.1→1, Graph 2.1→2). All `tests/*.typ` still compile zero-warning with their asserts passing. Checklist row "Lists the page each section first appears on [P4]" is now ticked.

**Approval page vertical centering — COMPLIANT (not a finding):** `build/example-3.png` was compared against the manual's NON-JOINT approval sample (formattingmanual.pdf printed p.19 = PDF page 18 — non-joint variant with no signature lines). The manual's non-joint sample places the approval statement in the upper area (~20% from top) and the "University of California San Diego / year" block in the lower-middle (~70–78%), with a large blank gap in the middle and blank space below. Our rendered example-3.png reproduces this same distribution faithfully; the content span midpoint is ~48%, matching the manual sample. The earlier "not centered" finding used an idealized 50%-centroid test rather than comparing against the manual sample, and is therefore withdrawn. Checklist row "All information centered vertically on the page [P2]" is ticked.
