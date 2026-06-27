// Body line leading. Native single here; recalibrated to 2.0x in Task 3.
#let body-leading = 0.65em

#let dissertation(
  title: none,
  author: none,
  degree: none,
  year: none,
  body,
) = {
  set page(paper: "us-letter", margin: 1in)
  set text(font: "TeX Gyre Heros", size: 12pt, fill: black, lang: "en")
  set par(
    leading: body-leading,
    spacing: body-leading,
    first-line-indent: (amount: 0.5in, all: true),
    justify: false,
  )
  // Footnotes: >=10pt, single-spaced (overrides body spacing).
  show footnote.entry: it => {
    set text(size: 10pt)
    set par(leading: 0.65em, spacing: 0.65em)
    it
  }
  body
}
