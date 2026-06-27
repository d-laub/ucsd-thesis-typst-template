#import "../lib/floats.typ": floats-rules, chapter-counter, fig, tbl, scheme, graph

#show: floats-rules

= Introduction
== A section
=== A subsection
Body text under chapter one.

// --- Per-chapter numbering assertions (Task 3): chapter one figures ---
#fig(rect(width: 2cm, height: 1cm), caption: [First figure of chapter one.])
#context assert.eq(
  str(chapter-counter.get().first()) + "."
    + str(counter(figure.where(kind: image)).get().first()),
  "1.1", message: "first figure should be 1.1",
)
#fig(rect(width: 2cm, height: 1cm), caption: [Second figure of chapter one.])
#context assert.eq(
  str(chapter-counter.get().first()) + "."
    + str(counter(figure.where(kind: image)).get().first()),
  "1.2", message: "second figure should be 1.2",
)

// Task 2 floats: one of each kind with caption placement verification.
#tbl(table(columns: 2, [a], [b], [c], [d]), caption: [A table; caption above.])
#scheme(rect(width: 3cm, height: 2cm), caption: [A scheme; caption below.])
#graph(rect(width: 3cm, height: 2cm), caption: [A graph; caption above.])

= Methods
// --- chapter two: counter must RESET; first figure is 2.1, not 1.3 ---
#fig(rect(width: 2cm, height: 1cm), caption: [First figure of chapter two.])
#context assert.eq(
  str(chapter-counter.get().first()) + "."
    + str(counter(figure.where(kind: image)).get().first()),
  "2.1", message: "chapter two's first figure should reset to 2.1",
)

Body text under chapter two.

// Programmatic check: after two level-1 headings the chapter counter is 2.
#context assert.eq(
  chapter-counter.get().first(), 2,
  message: "chapter counter should be 2 after two chapters",
)

// Fill enough space so the facing caption page and float page are distinct.
#pagebreak()

= Results
// The facing float: caption on the page immediately before the float.
#fig(
  rect(width: 4cm, height: 3cm),
  caption: [A facing-caption figure; its caption is on the preceding page.],
  facing: true,
)
