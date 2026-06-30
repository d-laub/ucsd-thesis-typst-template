// ============================================================================
// Table of Contents & List-of pages (UCSD formatting manual §III pp. 25-27).
//
// Inline-call builders (composed like P2's front-matter pages, NOT a show
// bundle), placed in the front matter between epigraph and preface.
//
// CROSS-MODULE CONTRACTS (by label / string — no imports, like ucsd-matter):
//   <ucsd-toc-entry>  : front-matter pages register their Title-Case title here
//                       (see lib/frontmatter.typ). The TOC's front pass lists them.
//   <ucsd-float-entry>: every float registers (kind, list-caption) here
//                       (see lib/floats.typ). The List-of-float pages consume it.
//   state("ucsd-matter") / counter("ucsd-chapter") : read by string to tell
//                       main-matter chapters from back-matter headings and to
//                       reconstruct "Chapter N" / float numbers.
// ============================================================================

#import "blocks.typ": single-spaced
#import "frontmatter.typ": prelim-heading, register-toc

// One dot-leader line: title … page. Single-spaced internally (so a wrapped
// entry stays single), with the inherited body spacing separating entries.
// first-line-indent reset so the 0.5in body indent does not push entries right.
#let _toc-line(title, page, indent: 0pt) = {
  set par(leading: 0.65em, first-line-indent: 0pt)
  pad(left: indent)[#title#box(width: 1fr, repeat[.])#page]
}

// TABLE OF CONTENTS — manual, query-based (not outline()).
#let table-of-contents() = {
  pagebreak(weak: true)
  prelim-heading("Table of Contents")
  register-toc("Table of Contents")
  v(2em)
  context {
    // Front-matter pass: registered markers, roman page numbers, document order.
    for e in query(<ucsd-toc-entry>) {
      _toc-line(e.value.title, numbering("i", ..counter(page).at(e.location())))
    }
    // Body + back-matter pass: query(heading) returns ONLY body/back headings
    // (front matter uses prelim-heading, not heading). Arabic page numbers.
    let chap = 0
    for hd in query(heading) {
      if hd.level > 3 { continue }
      let pg = numbering("1", ..counter(page).at(hd.location()))
      if hd.level == 1 and state("ucsd-matter").at(hd.location()) == "main" {
        // Main chapter: reconstruct "Chapter N  <title>" with a running count
        // (sidesteps any counter.at timing concern).
        chap += 1
        _toc-line([Chapter #chap#h(1em)#hd.body], pg)
      } else {
        // Sections/subsections (unnumbered, indented) and back-matter level-1
        // headings (appendix, bibliography) — title verbatim.
        _toc-line(hd.body, pg, indent: (hd.level - 1) * 0.3in)
      }
    }
  }
}
