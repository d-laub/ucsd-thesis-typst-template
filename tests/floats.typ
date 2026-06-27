#import "../lib/floats.typ": floats-rules, chapter-counter

#show: floats-rules

= Introduction
== A section
=== A subsection
Body text under chapter one.

= Methods
Body text under chapter two.

// Programmatic check: after two level-1 headings the chapter counter is 2.
#context assert.eq(
  chapter-counter.get().first(), 2,
  message: "chapter counter should be 2 after two chapters",
)
