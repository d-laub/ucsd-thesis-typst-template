// Body line leading, calibrated to 2.0x the native single advance (Task 3).
// = native-single-advance + 0.65em, expressed in em (size-independent).
// Measured: native single = 16.55pt, recommended-double-em = 2.029 at 12pt.
#let body-leading = 2.029em

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
