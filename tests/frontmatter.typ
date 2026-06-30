#import "../lib/template.typ": dissertation
#import "../lib/pagination.typ": front-matter, main-matter
#import "../lib/frontmatter.typ": title-page, copyright-page, approval-page, dedication, epigraph, preface, acknowledgements, vita, abstract

#let meta = (
  title: "This Is the Title of My Dissertation",
  author: "Ada Lovelace",
  degree: "Doctor of Philosophy",
  degree-field: "Computer Science",
  committee: (
    chair: "Eta Theta",
    co-chair: "Gamma Delta",
    members: ("Iota Mu", "Epsilon Zeta"),
  ),
  year: "2025",
)

#show: dissertation

#front-matter()

#title-page(meta)
#copyright-page(meta)
// <ucsd-copyright-page-end> is embedded inside copyright-page's page() call so
// the counter check is anchored to page ii regardless of what follows in the
// main flow.  Using .at(<label>) rather than .get() avoids the Typst layout
// quirk where a floating #context block in the main flow evaluates at page iii
// (the first main-flow page) once approval-page content follows.
#context assert(
  counter(page).at(<ucsd-copyright-page-end>).first() == 2,
  message: "title (i) + copyright (ii) must occupy exactly 2 counted pages; got "
    + str(counter(page).at(<ucsd-copyright-page-end>).first()),
)
#approval-page(meta)

#dedication[
  This dissertation is dedicated to curiosity.
  #context {
    let n = counter(page).get().first()
    assert(n == 4, message: "dedication should be page 4 (iv), got " + str(n))
    [#metadata(n) <p-ded>]
  }
]
#epigraph[
  "Begin at the beginning." \ — The King
  #context {
    let n = counter(page).get().first()
    assert(n == 5, message: "epigraph should be page 5 (v), got " + str(n))
    [#metadata(n) <p-epi>]
  }
]
#preface[
  This is the preface.
  #context {
    let n = counter(page).get().first()
    assert(n == 6, message: "preface should be page 6 (vi), got " + str(n))
    [#metadata(n) <p-pre>]
  }
]
#acknowledgements[
  I thank my committee for their guidance.
  #context {
    let n = counter(page).get().first()
    assert(n == 7, message: "acknowledgements should be page 7 (vii), got " + str(n))
    [#metadata(n) <p-ack>]
  }
]
#vita(
  entries: (
    (year: "2019", body: "Bachelor of Science, University of Somewhere"),
    (year: "2025", body: "Doctor of Philosophy, University of California San Diego"),
  ),
  publications: [
    A. Lovelace, "On the Analytical Engine," 1843.
    #context {
      let n = counter(page).get().first()
      assert(n == 8, message: "vita should be page 8 (viii), got " + str(n))
      [#metadata(n) <p-vita>]
    }
  ],
  fields: [
    Major Field: Computing
  ],
)

#abstract(meta)[
  The abstract begins here. It is a condensed summary of the work.
  #context {
    let n = counter(page).get().first()
    assert(n == 9, message: "abstract should be page 9 (ix), got " + str(n))
    [#metadata(n) <p-abs>]
  }
]

#main-matter()
#context {
  let n = counter(page).get().first()
  assert(n == 1, message: "first body page should restart at 1, got " + str(n))
  [Body text. #metadata(n) <p-body>]
}
