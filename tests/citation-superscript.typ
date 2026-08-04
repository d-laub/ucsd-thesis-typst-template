// Exercises styles/ieee-full-authors-superscript.csl: superscript in-text
// numbers instead of the default bracketed "[n]".
//
// Compiling this file clean (zero warnings) is the automated half of the test.
// The rendered half -- that the numbers are actually raised, collapse into a
// range, and carry no brackets -- is verified with pdftotext; see
// docs/p6-verification.md, "Superscript citation style".
#import "../lib/template.typ": dissertation
#import "../lib/backmatter.typ": backmatter-rules

#show: dissertation
#show: backmatter-rules

A single citation attaches to the end of the sentence.@wc1953 Note that the
marker follows the terminal punctuation, which is the convention for superscript
numbering and the reason `.@ref` is written with no space.

Two adjacent citations render as one comma-joined superscript group.@taocp2020 @octuple2023

Three consecutive numbers collapse into a range rather than a list.@wc1953 @taocp2020 @octuple2023

#bibliography(
  "../references.bib",
  style: "../styles/ieee-full-authors-superscript.csl",
)
