#import "../lib/floats.typ": floats-rules, chapter-counter, fig, tbl, scheme, graph

#show: floats-rules

= Introduction
== A section
=== A subsection
Body text under chapter one.

#fig(rect(width: 3cm, height: 2cm), caption: [A figure; caption below.])
#tbl(table(columns: 2, [a], [b], [c], [d]), caption: [A table; caption above.])
#scheme(rect(width: 3cm, height: 2cm), caption: [A scheme; caption below.])
#graph(rect(width: 3cm, height: 2cm), caption: [A graph; caption above.])

= Methods
Body text under chapter two.

// Programmatic check: after two level-1 headings the chapter counter is 2.
#context assert.eq(
  chapter-counter.get().first(), 2,
  message: "chapter counter should be 2 after two chapters",
)
