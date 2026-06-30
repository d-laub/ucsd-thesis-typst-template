#import "../lib/template.typ": dissertation
#import "../lib/pagination.typ": front-matter, main-matter
#import "../lib/frontmatter.typ": title-page, blank-page, approval-page, vita, abstract

#let meta = (
  title: "A Minimal Dissertation",
  author: "Grace Hopper",
  degree: "Doctor of Philosophy",
  degree-field: "Mathematics",
  committee: (chair: "Solo Chair", co-chair: none, members: ("Member One",)),
  year: "2026",
)

#show: dissertation

#front-matter()

#title-page(meta)        // no co-chair: committee block omits the Co-Chair line
#blank-page()            // declined copyright notice: blank counted page ii
#approval-page(meta)
#vita(entries: ((year: "2026", body: "Doctor of Philosophy, UC San Diego"),))  // no publications/fields
#abstract(meta)[Abstract.] // chair-only chair line

#main-matter()
#context {
  let n = counter(page).get().first()
  assert(n == 1, message: "minimal: body should restart at 1, got " + str(n))
  [Body. #metadata(n) <p-body-min>]
}
