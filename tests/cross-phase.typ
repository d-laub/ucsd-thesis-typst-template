// cross-phase.typ — integration test locking the fix for the matter-state gating bug.
//
// Bug: floats-rules + backmatter-rules both active caused every level-1 heading
// (appendix, bibliography) to receive spurious "CHAPTER N" rendering and corrupt
// the chapter/float counters.
//
// Fix: a shared Typst state("ucsd-matter") (default "main") gates chapter
// rendering so only headings inside main matter get "CHAPTER N" treatment.

#import "../lib/floats.typ": floats-rules, chapter-counter, fig
#import "../lib/backmatter.typ": backmatter-rules, appendix
#import "../lib/pagination.typ": front-matter, main-matter, back-matter
#import "../lib/template.typ": dissertation

#show: dissertation
#show: floats-rules
#show: backmatter-rules

// ── Front matter ──────────────────────────────────────────────────────────────
#front-matter()
Preliminary material.
#pagebreak()

// ── Main matter ───────────────────────────────────────────────────────────────
#main-matter()

= Introduction

Body text for the introduction.

#fig(rect(width: 3cm, height: 2cm), caption: [The first figure.])

// Assert 1: chapter counter is 1 after the first (and only) main chapter.
#context assert.eq(
  chapter-counter.get().first(),
  1,
  message: "chapter counter should be 1 after Introduction; got "
    + str(chapter-counter.get().first()),
)

// Assert 2: figure numbered 1.1.
#context assert.eq(
  str(chapter-counter.get().first()) + "."
    + str(counter(figure.where(kind: image)).get().first()),
  "1.1",
  message: "first figure should be numbered 1.1",
)

// ── Back matter ───────────────────────────────────────────────────────────────
#back-matter()

#appendix("Supplementary Methods")[
  This appendix demonstrates that appendix headings do NOT trigger chapter
  rendering. Single-spaced body as permitted.
]

// Assert 3: chapter counter is UNCHANGED (still 1) after the appendix —
// the appendix heading must NOT have stepped chapter-counter.
#context assert.eq(
  chapter-counter.get().first(),
  1,
  message: "chapter counter must still be 1 after appendix (appendix must not step it); got "
    + str(chapter-counter.get().first()),
)

// Assert 4: figure counter is UNCHANGED (still 1) after the appendix —
// the appendix heading must NOT have reset the float counters.
#context assert.eq(
  counter(figure.where(kind: image)).get().first(),
  1,
  message: "figure counter must still be 1 after appendix (must not reset); got "
    + str(counter(figure.where(kind: image)).get().first()),
)

#bibliography("../references.bib", style: "../styles/ieee-full-authors.csl")

// Assert 5: chapter counter is UNCHANGED (still 1) after the bibliography —
// the bibliography's implicit level-1 heading must NOT step chapter-counter.
#context assert.eq(
  chapter-counter.get().first(),
  1,
  message: "chapter counter must still be 1 after bibliography; got "
    + str(chapter-counter.get().first()),
)
