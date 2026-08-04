// Nature-style half of the no-"et al." regression guard; see
// tests/citation-full-authors.typ for the rationale and the default-style half.
// A Typst document takes only one bibliography, so each style needs its own file.
#import "../lib/template.typ": dissertation
#import "../lib/backmatter.typ": backmatter-rules

#show: dissertation
#show: backmatter-rules

A large-consortium paper with more authors than any plausible et-al
threshold.@consortium2024

#bibliography("consortium.bib", style: "../styles/nature-full-authors.csl")
