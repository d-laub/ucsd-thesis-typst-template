#import "../lib/template.typ": dissertation
#import "../lib/pagination.typ": front-matter, main-matter
#import "../lib/frontmatter.typ": title-page

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
