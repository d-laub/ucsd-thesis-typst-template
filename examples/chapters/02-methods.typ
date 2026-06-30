#import "../../lib/floats.typ": scheme, graph, fig
#import "../ack.typ": coauthor-ack

= Methods

Placeholder methods chapter. It contains a scheme, a graph, and a figure whose
caption is large enough to warrant a facing caption page.

#scheme(
  rect(width: 4cm, height: 2cm),
  caption: [A reaction scheme; its caption sits below the scheme.],
)

#graph(
  rect(width: 5cm, height: 3cm),
  caption: [A graph; its caption sits above the graph.],
)

#fig(
  rect(width: 5cm, height: 18cm),
  caption: [A tall figure shown on the page following its caption, demonstrating
    the facing-caption-page layout for oversized floats.],
  facing: true,
)

#coauthor-ack
