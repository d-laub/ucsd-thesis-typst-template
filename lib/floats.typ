#import "blocks.typ": single-spaced

// ── Matter-state contract ─────────────────────────────────────────────────────
// floats-rules reads state("ucsd-matter", "main") — set by lib/pagination.typ's
// front-matter() / main-matter() / back-matter() — to decide whether a level-1
// heading is a real chapter (main matter) or a back/front matter heading that
// must NOT receive "CHAPTER N" rendering and must NOT step/reset counters.
// Valid values: "front" | "main" | "back".  Default "main" ensures standalone
// test files (which do not call main-matter()) still render chapters correctly.
// ─────────────────────────────────────────────────────────────────────────────

// The chapter counter. A dedicated named counter so it is never stepped by
// back-matter headings (appendices, bibliography) or front-matter headings.
// Float numbering reads its first level via chapter-counter.get().first().
// Exported as `chapter-counter` because existing tests reference it by name.
#let chapter-counter = counter("ucsd-chapter")

// Per-chapter float numbering: chapter.n with the chapter read at the float's
// location. Evaluated in context when the caption displays, so .get() is valid.
#let chapter-float-numbering = n => numbering(
  "1.1",
  chapter-counter.get().first(),
  n,
)

// Internal constructor for all float kinds. facing/landscape wired in later tasks.
#let _float(body, caption: none, kind: none, supplement: none, facing: false, landscape: false) = {
  let make = cap => figure(
    body,
    caption: cap,
    kind: kind,
    supplement: supplement,
    numbering: chapter-float-numbering,
  )
  if facing {
    // Emit queryable metadata so P4's List-of-Figures can recover the caption
    // text for facing floats (where the figure itself has caption: none).
    // P4 should query <ucsd-facing-caption> and correlate by position/counter.
    [#metadata((kind: kind, caption: caption)) <ucsd-facing-caption>]
    // Caption-only page, vertically & horizontally centered, single-spaced.
    {
      set align(center + horizon)
      single-spaced[
        #context [
          #supplement~#numbering(
            "1.1",
            chapter-counter.get().first(),
            counter(figure.where(kind: kind)).get().first() + 1,
          ): #caption
        ]
      ]
    }
    pagebreak()
    // The float itself on the next page, no caption (shown on facing page),
    // still a real numbered figure for P4's List-of queries.
    let f = make(none)
    if landscape { rotate(-90deg, reflow: true, f) } else { f }
  } else {
    let f = make(caption)
    // -90deg => top edge along the LEFT margin (verified empirically).
    if landscape { rotate(-90deg, reflow: true, f) } else { f }
  }
}

// Public float constructors.
#let fig(body, caption: none, facing: false, landscape: false) = _float(
  body,
  caption: caption,
  kind: image,
  supplement: [Figure],
  facing: facing,
  landscape: landscape,
)

#let tbl(body, caption: none, facing: false, landscape: false) = _float(
  body,
  caption: caption,
  kind: table,
  supplement: [Table],
  facing: facing,
  landscape: landscape,
)

#let scheme(body, caption: none, facing: false, landscape: false) = _float(
  body,
  caption: caption,
  kind: "scheme",
  supplement: [Scheme],
  facing: facing,
  landscape: landscape,
)

#let graph(body, caption: none, facing: false, landscape: false) = _float(
  body,
  caption: caption,
  kind: "graph",
  supplement: [Graph],
  facing: facing,
  landscape: landscape,
)

// Applicable show bundle: #show: floats-rules
#let floats-rules(body) = {
  // Headings.
  //
  // Level-1 (chapter) treatment is gated on state("ucsd-matter", "main").
  // When in "main" matter: step chapter-counter, reset float counters, render
  // the two-line "CHAPTER N / title" block.
  // When in "front" or "back" matter (appendices, bibliography, etc.): render
  // the heading plainly without any chapter/float counter mutations.
  //
  // NOTE: the old `show heading.where(level:1): set heading(numbering:"1")` rule
  // has been removed. That rule unconditionally incremented counter(heading) for
  // every level-1 heading including appendix and bibliography headings — that was
  // the root cause of the cross-phase counter corruption bug.
  // counter("ucsd-chapter") is now stepped ONLY in main matter, explicitly below.
  show heading: it => {
    if it.level == 1 {
      context {
        if state("ucsd-matter", "main").get() == "main" {
          // Main matter: step dedicated chapter counter, reset float counters,
          // render two-line centered "CHAPTER N / title".
          chapter-counter.step()
          counter(figure.where(kind: image)).update(0)
          counter(figure.where(kind: table)).update(0)
          counter(figure.where(kind: "scheme")).update(0)
          counter(figure.where(kind: "graph")).update(0)
          // Two-line centered CHAPTER N / title, no italics, single-spaced pair.
          // chapter-counter was just stepped; a nested context reads the new value.
          set align(center)
          set text(style: "normal", weight: "bold")
          single-spaced(block(width: 100%, breakable: false)[
            CHAPTER #context chapter-counter.display("1") \
            #it.body
          ])
        } else {
          // Front/back matter (appendix, bibliography, etc.): plain render —
          // no "CHAPTER" text, no chapter-counter step, no float-counter reset.
          it
        }
      }
    } else {
      // Sections/subsections: defensive guard — guarantee unnumbered even if an
      // outer/global rule ever sets heading numbering for these levels.
      set heading(numbering: none)
      set text(style: "normal")
      it
    }
  }

  // Caption placement per kind: figure & scheme below; table & graph above.
  show figure.where(kind: image): set figure.caption(position: bottom)
  show figure.where(kind: table): set figure.caption(position: top)
  show figure.where(kind: "scheme"): set figure.caption(position: bottom)
  show figure.where(kind: "graph"): set figure.caption(position: top)

  // Captions single-spaced via the P0 primitive.
  show figure.caption: single-spaced

  body
}
