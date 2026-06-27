#import "blocks.typ": single-spaced

// The chapter counter key. Chapters are the level-1 heading counter; float
// numbering reads its first level via chapter-counter.get().first().
#let chapter-counter = counter(heading)

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
  // Enable numbering on level-1 headings only so counter(heading) increments
  // at each chapter. Sub-headings stay unnumbered.
  // The display is suppressed by the show rule below (we render "CHAPTER N" ourselves).
  show heading.where(level: 1): set heading(numbering: "1")

  // Headings.
  show heading: it => {
    if it.level == 1 {
      // Reset every float counter at the start of each chapter.
      counter(figure.where(kind: image)).update(0)
      counter(figure.where(kind: table)).update(0)
      counter(figure.where(kind: "scheme")).update(0)
      counter(figure.where(kind: "graph")).update(0)
      // Two-line centered CHAPTER N / title, no italics, single-spaced pair.
      set align(center)
      set text(style: "normal", weight: "bold")
      single-spaced(block(width: 100%, breakable: false)[
        CHAPTER #context counter(heading).display("1") \
        #it.body
      ])
    } else {
      // Sections/subsections: unnumbered display heading, no italics.
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
