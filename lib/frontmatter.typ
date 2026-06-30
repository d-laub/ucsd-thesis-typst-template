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
// <ucsd-copyright-page-end> anchors the page-ii counter check in tests without
// depending on the floating position of a #context block in the main flow.
#let copyright-page(meta) = page(numbering: none)[
  #set par(first-line-indent: 0pt)
  #set align(center)
  #v(1fr)
  #single-spaced[
    Copyright

    #meta.author, #meta.year \
    All rights reserved.
  ]
  #[] <ucsd-copyright-page-end>
]

// Empty counted page for the declined-copyright case (page ii, no number).
#let blank-page() = page(numbering: none)[]

// Approval page — first DISPLAYED roman number (iii). No section heading. The
// approval statement is left-justified at the top; the university + year are
// centered below; the whole block is centered vertically. No signature lines
// (non-joint — signatures are collected on the Final Report Form). Sample p.19.
// The fractional spacers are a tuned starting point; adjust against the sample.
//
// Uses page() like the other front-matter builders so it:
//   (a) inherits US-Letter/1-in margins from dissertation() via the active
//       set-page context, and
//   (b) explicitly sets numbering: "i" — the front-matter() set-page rule does
//       not propagate into explicit page() calls, so the numbering and footer
//       must be set here to get the correct roman display ("iii").
#let approval-page(meta) = page(
  numbering: "i",
  footer: context align(center, counter(page).display()),
  footer-descent: 0.5in,
)[
  #set par(first-line-indent: 0pt)
  #v(1fr)
  #align(left)[
    The dissertation of #meta.author is approved, and it is acceptable in quality
    and form for publication on microfilm and electronically.
  ]
  #v(3fr)
  #align(center, single-spaced[
    University of California San Diego \
    #meta.year
  ])
  #v(2fr)
]
