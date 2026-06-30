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

Rendered-page index → content mapping (PNG pages 1–24; front matter i–xix = PNGs 1–19; Arabic 1–5 = PNGs 20–24):

| Rendered PNG | Arabic/Roman page | Manual sample | What was checked | Verdict |
|---|---|---|---|---|
| example-1.png | i (unnumbered) | p. 13 | "UNIVERSITY OF CALIFORNIA SAN DIEGO" caps at top; title; "A dissertation submitted…"; "in"; degree field; "by"; author; "Committee in charge:"; members indented; year "2026" at bottom; no page number | pass |
| example-2.png | ii (unnumbered) | p. 17 | three centered lines ("Copyright" / "Ada Lovelace, 2026" / "All rights reserved.") just above bottom margin; no page number | pass |
| example-3.png | iii | p. 19 | no header; approval statement left-justified at top; "University of California San Diego" + "2026" centered below; "iii" at bottom; **finding:** content block is NOT vertically centered — approval text sits in the top quarter (~25% from top) and university/year block sits at ~65%, leaving ~35% blank below; content block center is ~45% from top, not 50% | fail (vertical centering) |
| example-17.png | xvii | vita sample (manual p. 30) | "VITA" heading centered; year-column entries (2018, 2020, 2026); "PUBLICATIONS" section; "FIELDS OF STUDY" section; "xvii" at bottom | pass |
| example-18.png | xviii | p. 33 | "ABSTRACT OF THE DISSERTATION" heading; heading starts ~2.5″ from top (measured ~375 px at 150 ppi on 11″ page); title / "by" / author / degree / university+year / chair structured header; double-spaced body begins | pass |
| example-6.png + example-7.png | vi–vii | pp. 26–27 | "TABLE OF CONTENTS" heading; dot leaders; roman numerals for front matter (iii–xix); Arabic numerals for main matter (1–5); "Chapter 1 Introduction", "Chapter 2 Methods", "Chapter 3 Results" titles; "APPENDIX A" and "Bibliography" in back matter | pass |
| example-11.png | xi | p. 26–27 (list sample) | "LIST OF FIGURES"; entries formatted "Figure N.M: caption...page" with dot leaders; Figure 3.2 shows abbreviated short caption in list; chapter-prefixed numbering (1.1, 2.1, 3.1, 3.2) | pass (format); **finding: Figure 3.1 LOF page reference shows 5, figure renders on page 4** — the `<ucsd-float-entry>` metadata marker trails the landscape figure body, so when the landscape figure exhausts page 4, the marker falls on page 5; off-by-one for landscape-only floats |
| example-20.png | Arabic 1 | pp. 40–42 | Figure 1.1 caption below figure; Table 1.1 caption above table; page number "1" centered at bottom | pass |
| example-21.png | Arabic 2 | pp. 40–42 | Scheme 2.1 caption below scheme; Graph 2.1 caption above graph; Figure 2.1 facing-caption on this page (caption on p.2, figure on p.3) | pass |
| example-22.png | Arabic 3 | pp. 40–42 | Figure 2.1 tall placeholder occupying page; co-author acknowledgement at bottom; page "3" centered | pass |
| example-23.png | Arabic 4 | pp. 40–42 | Figure 3.1 landscape: figure box portrait-placed, caption rotated 90° along right edge; page "4" centered at bottom | pass |

## Abstract word count

Example abstract body (text inside `#abstract(meta)[…]`): **64 words** (< 350). PASS.

Word count command: `wc -w build/_abstract.txt` → `64`.

## Spacer tuning

No spacer tuning was performed. All front-matter pages (title, copyright, approval, abstract) match the manual samples acceptably without adjustment to `lib/frontmatter.typ`.

## Findings

**Finding 1 — Figure 3.1 LOF page reference:** The List of Figures entry for Figure 3.1 shows page 5 rather than page 4 where the figure visually appears. Root cause: `lib/floats.typ` places the `<ucsd-float-entry>` metadata marker after the figure body in the document flow; when the landscape figure fills page 4, the marker falls on page 5. This does not cause a compile warning or assertion failure. The figure numbering (3.1) and caption text are correct; only the page cross-reference is off by one for landscape figures that are the last content on their page. This is a pre-existing implementation limitation; fixing it (moving the entry marker before the figure content) is out of scope for P6. Checklist row "Lists the page each section first appears on [P4]" is unticked.

**Finding 2 — Approval page not vertically centered:** Visual inspection of `build/example-3.png` vs manual p.19 reveals the approval content block is not vertically centered. The approval text begins at approximately 25% from the top of the page; the "University of California San Diego / 2026" closing block sits at approximately 65% down; this leaves roughly 35% of the page blank below the content vs approximately 25% above it. The block's visual center is approximately 45% from the top, not 50%. Comparison with the manual sample (p.19, Joint sample — the only published visual reference) confirms that vertical centering means equal white space above and below the entire approval block. This is a `lib/frontmatter.typ` issue outside P6 scope. Checklist row "All information centered vertically on the page [P2]" is unticked.
