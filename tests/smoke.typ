#import "../lib/template.typ": dissertation

#show: dissertation

This is the first paragraph of the smoke test. Its first line must be indented
half an inch, like every other paragraph, and the body must be set in TeX Gyre
Heros at twelve points in solid black.

This is a second paragraph. It exists so we can see paragraph-to-paragraph
rhythm and confirm there is no extra blank line between paragraphs beyond the
line spacing itself.

#import "../lib/blocks.typ": long-quote

Here is a sentence that introduces a long quotation and also carries a
footnote.#footnote[This footnote must render at ten points and be single-spaced,
regardless of the double-spaced body around it.]

#long-quote[
  This is a long quotation of more than six lines. It must be single-spaced and
  indented an additional half inch on both the left and the right margins, with
  no quotation marks added by the template. It runs long enough to wrap across
  several lines so the single spacing inside the block is visually distinct from
  the double-spaced body text that surrounds it on the page here.
]

A trailing paragraph after the quotation, double-spaced and indented like the
rest of the body.
