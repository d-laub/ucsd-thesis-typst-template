#import "../lib/template.typ": dissertation
#import "../lib/backmatter.typ": backmatter-rules, appendix

#show: dissertation
#show: backmatter-rules

The first claim is well established. @octuple2023 The second draws on classic
work. @taocp2020 @wc1953

#appendix("Supplementary Methods")[
  This appendix is single-spaced, as the manual permits for reproduced research
  materials and survey instruments. It runs long enough to wrap across several
  lines so the single spacing inside the appendix body is visually distinct from
  the double-spaced body of the dissertation.
]

#appendix("Supplementary Tables")[
  A second appendix, lettered B automatically by the appendix counter.
]

#context assert(
  counter("p5-appendix").get().first() == 2,
  message: "expected exactly two appendices (A, B)",
)

#bibliography("../references.bib", style: "../styles/ieee-full-authors.csl")
