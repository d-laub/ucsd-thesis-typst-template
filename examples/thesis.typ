#import "../lib/template.typ": dissertation
#import "../lib/pagination.typ": front-matter, main-matter, back-matter
#import "../lib/frontmatter.typ": title-page, copyright-page, approval-page, dedication, epigraph, preface, acknowledgements, vita, abstract
#import "../lib/lists.typ": table-of-contents, list-of-figures, list-of-schemes, list-of-tables, list-of-graphs, list-of-abbreviations, list-of-symbols, list-of-supplemental-files
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
