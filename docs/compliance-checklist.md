# UCSD Doctoral Dissertation — Compliance Checklist

Every hard requirement extracted from `formattingmanual.pdf` (UC San Diego
Preparation and Submission Manual, 2025–2026), scoped to **PhD, non-joint**. Each
row is verified by the phase noted in brackets. Page numbers refer to the manual.

## General specifications (§II, pp. 9–11)

- [x] Highly legible typeface, dark enough to reproduce, readable on microfilm [P0]
- [x] Margins: top/bottom/left/right all ≥ 1″ from the paper edge [P0]
- [x] Nothing intrudes into margins except page numbers [P0, P1]
- [x] Body font size ≥ 10pt (default 12pt); one of Arial, Century Gothic, Helvetica,
      Times New Roman → using Helvetica/Arial metric clone (TeX Gyre Heros) [P0]
- [x] Footnotes and captions font size ≥ 10pt [P0]
- [x] One consistent font throughout the entire manuscript [P0]
- [x] All text black (including web links); no colored text [P0]
- [x] Italics allowed for emphasis (single word/phrase); not for headings (non-MLA) [P0]
- [x] Page numbers centered at bottom, 0.5″ from the bottom edge [P1]
- [x] Body text double-spaced [P0]
- [x] First line of each paragraph indented one 0.5″ tab; block style not allowed [P0]
- [x] Long quotations (> 6 lines): single-spaced, indented additional 0.5″ on BOTH
      left and right, no quotation marks [P0/P3]
- [x] Captions may be single-spaced [P0/P3]
- [x] Survey instruments / reproduced research materials in appendix may be single-spaced [P5] — `#appendix` wraps its body in `single-spaced`; verified in tests/backmatter.typ (appendix body renders single-spaced, distinct from the double-spaced body)
- [x] Vita may be single-spaced [P2]

## Pagination (§II p. 10, §III p. 12)

- [x] Title page and blank/copyright page NOT numbered, but counted as i and ii [P1]
- [x] Approval page always numbered "iii" [P1]
- [x] Preliminary pages use lowercase roman numerals (iii, iv, v, …) starting on the
      approval page [P1]
- [x] Main body + back matter use Arabic numerals starting at "1" [P1]
- [x] All page numbers centered at the bottom [P1]
- [x] No missing, blank, or duplicate page numbers/pages [P6]

## Preliminary-page order (§III, pp. 12–35; sample TOC p. 26)

Order, with required/optional status:

- [x] 1. Title page (i, unnumbered) [P2]
- [x] 2. Copyright page (ii, unnumbered) — optional [P2]
- [x] 3. Dissertation/Thesis Approval Page (iii) — required [P2]
- [x] 4. Dedication — optional [P2]
- [x] 5. Epigraph — optional [P2]
- [x] 6. Table of Contents — required [P4]
- [x] 7. List of Abbreviations — optional [P4]
- [x] 8. List of Symbols — optional [P4]
- [x] 9. List of Supplemental Files — optional (required if files uploaded) [P4]
- [x] 10. List of Figures — required if figures in text [P4]
- [x] 11. List of Schemes — required if schemes in text [P4]
- [x] 12. List of Tables — required if tables in text [P4]
- [x] 13. List of Graphs — required if graphs in text [P4]
- [x] 14. Preface — optional [P2]
- [x] 15. Acknowledgements — optional (required if any co-authored/published text) [P2]
- [x] 16. Vita — required for doctoral [P2]
- [x] 17. Abstract of the Dissertation — required [P2]
- [x] All preliminary pages have consistent headers (text, size, caps, placement) [P2]
- [x] Title-page header and abstract header match each other [P2]

## Title page (§III p. 12, sample p. 13)

- [x] "UNIVERSITY OF CALIFORNIA SAN DIEGO" in all caps at top [P2]
- [x] Specific, descriptive title; words not symbols/formulas/Greek/superscripts [P2]
- [x] "A dissertation submitted in partial satisfaction of the requirements for the
      degree [Degree]" [P2]
- [x] "in" lowercase, alone on a line [P2]
- [x] Degree field/title [P2]
- [x] "by" lowercase, alone on a line [P2]
- [x] Author name (legal or lived, consistent throughout) [P2]
- [x] "Committee in charge:" with chair first, then alphabetical by last name; title
      "Professor"; double space between "Committee in charge" and chair; members
      single-spaced and indented 0.5″ [P2]
- [x] Degree year = year of the quarter of degree conferral [P2]
- [x] Title page itself unnumbered, counted as i [P1/P2]

## Copyright page (§III p. 16, sample p. 17; §IV p. 44)

- [x] Centered just above the bottom margin [P2]
- [x] Three lines: "Copyright" / "[Name], [Year]" / "All rights reserved." [P2]
- [x] Unnumbered, counted as ii [P1/P2]

## Approval page (§III p. 18, sample p. 19)

- [x] No header on this page [P2]
- [x] Top text left-justified or fully justified; bottom info centered [P2]
- [x] All information centered vertically on the page [P2] — matches the manual non-joint sample (p.18): approval statement in the upper area, "University of California San Diego" + year in the lower-middle, blank bottom; content span centered ~48% on the page. See docs/p6-verification.md.
- [x] No signature lines (non-joint UCSD — signatures collected on Final Report Form) [P2]
- [x] "The dissertation of [Name] is approved, and it is acceptable in quality and
      form for publication on microfilm and electronically." [P2]
- [x] "University of California San Diego" + year at bottom [P2]
- [x] Numbered iii [P1]

## Abstract (§III p. 32, sample p. 33)

- [x] Heading "ABSTRACT OF THE DISSERTATION" [P2]
- [x] Top margin 2.5″ [P2]
- [x] ≤ 350 words (doctoral) [P2/P6]
- [x] Includes title, "by", author name, degree, "University of California San Diego,
      [year]", chair line [P2]
- [x] Body double-spaced, consistent with the rest of the manuscript [P2]

## Vita (§III p. 30, sample p. 31)

- [x] Heading "VITA" [P2]
- [x] Year column + entries (degrees, appointments) [P2]
- [x] "PUBLICATIONS" section (optional content) [P2]
- [x] "FIELDS OF STUDY" section (optional content) [P2]
- [x] Use "Master" not "Masters" in degree titles [P2]

## Table of Contents & List pages (§III p. 25, samples pp. 26–27)

- [x] TOC required; heading "TABLE OF CONTENTS" [P4]
- [x] Lists the page each section first appears on [P4] — TOC + all List-of pages; verified the landscape-float page reference (List of Figures Fig 3.1 → p.4) after the lib/lists.typ figure-location fix; see docs/p6-verification.md
- [x] Section/header titles match the body exactly (e.g. "Chapter" if used in text) [P4]
- [x] Separate List of Figures/Tables/Graphs/Schemes when such items are scattered [P4]
- [x] List of Supplemental Files when supplemental files submitted [P4]
- [x] List-of entries formatted "Figure 1.1: caption … page" with dot leaders [P4]
- [x] Captions > 4 lines abbreviated to ≤ 4 lines in the list [P4]
- [x] The word "Figure"/"Table"/"Graph" precedes each caption in list and in text [P3/P4]

## Captions & floats (§III pp. 38–42, samples pp. 40–42)

- [x] Figure captions placed below the figure [P3]
- [x] Table captions placed above the table [P3]
- [x] Scheme captions placed below the scheme [P3]
- [x] Graph captions placed above the graph [P3]
- [x] Captions single-spaced; consistent format throughout [P3]
- [x] Facing caption page precedes the figure/table when caption/float too large [P3]
- [x] Landscape floats rotated 90° with the top along the left margin [P3]
- [x] Figures/tables/appendices carry chapter identification or consecutive numbering [P3]

## Back matter (§III p. 43)

- [x] Reference-matter order: Appendices → Addenda → Chronology → Endnotes → Glossary
      → Bibliography/References/Works Cited [P5]
- [x] Appendices may be single-spaced [P5]
- [x] Bibliography single-spaced with a double space between entries [P5] — `backmatter-rules` sets `par(leading: 0.65em, spacing: 1.3em)` on `bibliography`; layout dump confirms single-spaced wrapped lines within an entry and one blank line between entries
- [x] Bibliography is the last entry in each chapter or in the manuscript [P5]
- [x] Non-primary authors not depersonalized as "et al." in the bibliography [P5] — custom `styles/ieee-full-authors.csl` sets `et-al-min="99" et-al-use-first="99"`; the 8-author `octuple2023` entry prints all authors (last author "Davis" present, `grep -c "et al" == 0`)
- [x] Consistent citation/reference style throughout [P5] — a single numeric CSL drives both in-text `[n]` citations and the bibliography (verified: `[1]`–`[3]` in body, numbered reference list)

## Acknowledgements — co-authored/published material (§III p. 28, sample p. 29)

- [x] If any text is co-authored/published/submitted/in-prep: acknowledgements
      paragraph naming co-authors and publishers [P2/P6]
- [x] Same acknowledgement as the last paragraph at the end of each such chapter [P6]
- [x] Acknowledgements paragraphs double-spaced, 0.5″ first-line indent [P2]
