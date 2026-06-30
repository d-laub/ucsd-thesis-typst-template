// ============================================================================
// Front matter (UCSD formatting manual §III, PhD non-joint).
//
// Public builders take a plain `meta` dict (see plan / spec) and are pure
// functions of their inputs — NO global state.  Composed in a document as
// inline calls AFTER P1's #front-matter():
//   #show: dissertation
//   #front-matter()
//   #title-page(meta) ... #abstract(meta)[...]
//   #main-matter()
// This module does NOT edit dissertation(); it layers on top.
// ============================================================================

#import "blocks.typ": single-spaced

// ── Internal helpers (not part of the public API) ────────────────────────────

// Centered, regular-weight, all-caps section heading at the body size (12pt).
// NOT a `heading` element: floats-rules (P3) renders front-matter level-1
// headings plainly (default bold/left), which would fight this styling.  The
// title-page top line and the abstract heading both use this, so they match.
#let _prelim-heading(title) = {
  set par(first-line-indent: 0pt)
  align(center, text(weight: "regular", style: "normal", upper(title)))
}

// "Professor <name>".
#let _professor(name) = [Professor #name]

// Title-page committee block: chair, co-chair (if any), then members in the
// author-given order; left-justified label, members indented 0.5in,
// single-spaced. Manual: double space between the label and the chair.
#let _committee-block(committee) = {
  assert(committee.chair != none, message: "committee.chair is required")
  let lines = ([#_professor(committee.chair), Chair],)
  if committee.co-chair != none {
    lines.push([#_professor(committee.co-chair), Co-Chair])
  }
  for m in committee.members {
    lines.push([#_professor(m)])
  }
  align(left, single-spaced[
    Committee in charge:
    #v(1em)
    #pad(left: 0.5in, lines.join(linebreak()))
  ])
}

// ── Public builders ──────────────────────────────────────────────────────────

// Title page — counted i, number NOT displayed. Sample p.13. The v() gaps below
// are a tuned starting point; adjust against the sample in this task's Step 6.
#let title-page(meta) = page(numbering: none)[
  #set par(first-line-indent: 0pt)
  #set align(center)
  #_prelim-heading("University of California San Diego")
  #v(0.25in)
  #meta.title
  #v(0.3in)
  A dissertation submitted in partial satisfaction of the \
  requirements for the degree #meta.degree
  #v(0.5in)
  in
  #v(0.3in)
  #meta.degree-field
  #v(0.35in)
  by
  #v(0.3in)
  #meta.author
  #v(0.4in)
  #_committee-block(meta.committee)
  #v(1fr)
  #meta.year
]

// Copyright page — counted ii, number NOT displayed. Centered just above the
// bottom margin. Sample p.17. Optional notice; if declined, use blank-page()
// instead (page ii must still exist — manual p.16).
#let copyright-page(meta) = page(numbering: none)[
  #set par(first-line-indent: 0pt)
  #set align(center)
  #v(1fr)
  #single-spaced[
    Copyright

    #meta.author, #meta.year \
    All rights reserved.
  ]
]

// Empty counted page for the declined-copyright case (page ii, no number).
#let blank-page() = page(numbering: none)[]
