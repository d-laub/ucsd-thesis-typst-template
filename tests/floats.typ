#import "../lib/floats.typ": floats-rules, chapter-counter, fig, tbl, scheme, graph

#show: floats-rules

= Introduction
== A section
=== A subsection
Body text under chapter one.

// Fix 1 guard: level-2 headings must have no numbering even if a global rule
// were to set one. Query the first level-2 heading and assert its .numbering
// field is none. (If numbering were applied, h.numbering would be a non-none
// string/function and this assert would fail.)
#context {
  let h2s = query(heading.where(level: 2))
  assert(h2s.len() > 0, message: "expected at least one level-2 heading to check")
  assert(
    h2s.at(0).numbering == none,
    message: "level-2 heading must have no numbering; got: " + repr(h2s.at(0).numbering),
  )
}

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

= Discussion
#graph(
  rect(width: 14cm, height: 7cm),
  caption: [A wide landscape graph rotated 90 degrees.],
  landscape: true,
)
