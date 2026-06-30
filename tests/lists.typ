#import "../lib/template.typ": dissertation
#import "../lib/pagination.typ": front-matter, main-matter, back-matter
#import "../lib/frontmatter.typ": title-page, copyright-page, approval-page, dedication, abstract
#import "../lib/floats.typ": floats-rules, fig, tbl
#import "../lib/backmatter.typ": backmatter-rules, appendix
#import "../lib/lists.typ": table-of-contents, list-of-figures, list-of-schemes, list-of-tables, list-of-graphs, list-of-abbreviations, list-of-symbols, list-of-supplemental-files

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
#list-of-abbreviations((
  (term: [DNA], definition: [deoxyribonucleic acid]),
  (term: [RNA], definition: [ribonucleic acid]),
))
#list-of-symbols(())  // empty -> must auto-skip
#list-of-supplemental-files((
  (term: [dataset.csv], definition: [Raw measurements for Chapter 2.]),
))
#list-of-figures()
#list-of-schemes()  // no schemes in this doc -> must auto-skip
#list-of-tables()
#list-of-graphs()   // no graphs in this doc -> must auto-skip
#abstract(meta)[The abstract begins here.]

#main-matter()
= Introduction
== A section
#fig(
  rect(width: 2cm, height: 1cm),
  caption: [A deliberately long figure caption that would exceed four lines in the list and therefore needs a short form.],
  short: [A short figure caption.],
)
= Methods
#tbl(table(columns: 2, [a], [b], [c], [d]), caption: [A methods table.])
#fig(
  rect(width: 4cm, height: 3cm),
  caption: [A facing-caption figure in chapter two.],
  facing: true,
)

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

// ── List-of-float assertions ──
#context {
  let toc = query(<ucsd-toc-entry>).map(e => e.value.title)
  // Figures & Tables lists are present; Schemes & Graphs auto-skipped.
  assert("List of Figures" in toc, message: "List of Figures must register")
  assert("List of Tables" in toc, message: "List of Tables must register")
  assert(not ("List of Schemes" in toc), message: "empty List of Schemes must auto-skip (not register)")
  assert(not ("List of Graphs" in toc), message: "empty List of Graphs must auto-skip (not register)")

  // Two image floats: the in-flow one (1.1, short caption) and the facing one (2.1).
  let imgs = query(<ucsd-float-entry>).filter(m => m.value.kind == image)
  assert(imgs.len() == 2, message: "expected 2 image floats; got " + str(imgs.len()))
  assert(imgs.at(0).value.caption == [A short figure caption.], message: "list must use the SHORT caption")
  // chap.n at the first image marker is 1.1; at the facing marker is 2.1.
  let m0 = imgs.at(0)
  let num0 = numbering(
    "1.1",
    counter("ucsd-chapter").at(m0.location()).first(),
    counter(figure.where(kind: image)).at(m0.location()).first(),
  )
  assert(num0 == "1.1", message: "first figure list number should be 1.1; got " + num0)
}

// ── Author-supplied list assertions ──
#context {
  let toc = query(<ucsd-toc-entry>).map(e => e.value.title)
  assert("List of Abbreviations" in toc, message: "populated abbreviations list must register")
  assert("List of Supplemental Files" in toc, message: "populated supplemental-files list must register")
  assert(not ("List of Symbols" in toc), message: "empty symbols list must auto-skip")
}
