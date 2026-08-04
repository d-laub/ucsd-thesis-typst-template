// Regression guard for the UCSD rule that non-primary authors must never be
// depersonalized as "et al." (formattingmanual.pdf SIII p.43).
//
// Both shipped styles omit et-al-min/et-al-use-first entirely, so CSL never
// abbreviates. They previously set et-al-min="99", which looked like "never" but
// still truncated a 105-author consortium paper and dropped the trailing
// authors -- realistic for genomics, where large-consortium papers routinely
// exceed 99 authors.
//
// tests/consortium.bib holds one 105-author entry. This file cites it under the
// DEFAULT style; tests/citation-full-authors-nature.typ is the identical check
// for the Nature style (a Typst document takes only one bibliography, so the two
// styles need two files). Compiling clean is the automated half; the assertion
// that no author is dropped is a pdftotext check, since the CSL-rendered author
// list is not reachable from Typst -- see docs/p6-verification.md, "Full author
// lists".
#import "../lib/template.typ": dissertation
#import "../lib/backmatter.typ": backmatter-rules

#show: dissertation
#show: backmatter-rules

A large-consortium paper with more authors than any plausible et-al
threshold.@consortium2024

#bibliography("consortium.bib", style: "../styles/ieee-full-authors.csl")
