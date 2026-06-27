#import "../lib/template.typ": body-leading

// Baseline-to-baseline advance for a given leading: height of two lines
// minus height of one line. measure() resolves em to pt at the active size.
#let advance(lead) = (
  measure({ set par(leading: lead); [a\ a] }).height
    - measure({ set par(leading: lead); [a] }).height
)

#set text(font: "TeX Gyre Heros", size: 12pt)

#context {
  let single = advance(0.65em)
  // double leading (pt) = single advance + native leading (0.65em @ 12pt)
  // such that advance(double_leading) == 2 × single. Float arithmetic via .pt()
  // because Typst 0.15 does not support dividing two lengths directly.
  let double_pt = single.pt() + 0.65 * 12.0 // target: advance == 2 x single
  let current = advance(body-leading)
  [
    #metadata((
      native-single-pt: single.pt(),
      recommended-double-em: double_pt / 12.0, // unitless em count at 12pt
      current-ratio: current.pt() / single.pt(),
    )) <calib>
  ]
  // Human-readable echo on the page:
  [native single advance: #single \
   recommended double leading: #(double_pt * 1pt) (#(double_pt / 12.0)em) \
   current ratio (body-leading / single): #(current.pt() / single.pt())]
}
