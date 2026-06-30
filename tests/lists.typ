#import "../lib/template.typ": dissertation
#import "../lib/pagination.typ": front-matter, main-matter, back-matter
#import "../lib/frontmatter.typ": title-page, copyright-page, approval-page, dedication, abstract
#import "../lib/floats.typ": floats-rules, fig, tbl
#import "../lib/backmatter.typ": backmatter-rules, appendix
#import "../lib/lists.typ": table-of-contents

#let meta = (
  title: "This Is the Title of My Dissertation",
  author: "Ada Lovelace",
  degree: "Doctor of Philosophy",
  degree-field: "Computer Science",
  committee: (chair: "Eta Theta", co-chair: none, members: ("Iota Mu",)),
  year: "2025",
)

#show: dissertation
#show: floats-rules
#show: backmatter-rules

#front-matter()
#title-page(meta)
#copyright-page(meta)
#approval-page(meta)
#dedication[Dedicated to curiosity.]
#table-of-contents()
#abstract(meta)[The abstract begins here.]

#main-matter()
= Introduction
== A section
#fig(rect(width: 2cm, height: 1cm), caption: [A figure in the intro.])
= Methods
#tbl(table(columns: 2, [a], [b], [c], [d]), caption: [A methods table.])

#back-matter()
#appendix("Supplementary Methods")[Appendix body.]
#bibliography("../references.bib", style: "../styles/ieee-full-authors.csl", title: "References")

// ── TOC content assertions (re-run the builder's own queries) ──
#context {
  let titles = query(<ucsd-toc-entry>).map(e => e.value.title)
  // Front-matter pages listed (incl. the TOC itself); title/copyright absent.
  for t in ("Dissertation/Thesis Approval Page", "Dedication", "Table of Contents", "Abstract of the Dissertation") {
    assert(t in titles, message: "TOC missing front entry: " + t + "; got " + repr(titles))
  }
  // Body: exactly two main-matter chapters; one back-matter "References".
  let hs = query(heading)
  let main-chapters = hs.filter(h => h.level == 1 and state("ucsd-matter").at(h.location()) == "main")
  assert(main-chapters.len() == 2, message: "expected 2 main chapters; got " + str(main-chapters.len()))
  let back-h1 = hs.filter(h => h.level == 1 and state("ucsd-matter").at(h.location()) == "back")
  assert(back-h1.any(h => h.body == [References]), message: "References must be a back-matter heading")
}
