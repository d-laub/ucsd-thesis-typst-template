#import "../lib/template.typ": dissertation
#import "../lib/pagination.typ": front-matter, main-matter
#import "../lib/frontmatter.typ": title-page, copyright-page, approval-page

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
