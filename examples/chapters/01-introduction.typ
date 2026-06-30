#import "../../lib/floats.typ": fig, tbl, chapter-counter
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

#context assert.eq(
  numbering(
    "1.1",
    chapter-counter.get().first(),
    counter(figure.where(kind: image)).get().first(),
  ),
  "1.1",
  message: "first figure in chapter 1 should be numbered 1.1",
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
