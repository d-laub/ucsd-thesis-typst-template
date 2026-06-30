#import "../../lib/floats.typ": fig

= Results

Placeholder results chapter. It contains a landscape figure and a figure with a
long caption abbreviated in the List of Figures.

#fig(
  rect(width: 18cm, height: 5cm),
  caption: [A wide figure rotated ninety degrees so its top edge lies along the
    left margin.],
  landscape: true,
)

#fig(
  rect(width: 4cm, height: 3cm),
  caption: [A figure whose full caption is far too long to sit on a single line
    in the List of Figures, running well beyond four lines when typeset at the
    body width, which is precisely why a short form is supplied for the list.],
  short: [A figure with an abbreviated list caption.],
)
