#import "../lib/template.typ": dissertation
#import "../lib/pagination.typ": front-matter

#show: dissertation

#front-matter()

#context {
  let n = counter(page).get().first()
  assert(n == 1, message: "first prelim page should count 1, got " + str(n))
  [Prelim page #metadata(n) <p-1>]
}
#pagebreak()

#context {
  let n = counter(page).get().first()
  assert(n == 2, message: "second prelim page should count 2, got " + str(n))
  [Prelim page #metadata(n) <p-2>]
}
#pagebreak()

#context {
  let n = counter(page).get().first()
  assert(n == 3, message: "third prelim page should count 3, got " + str(n))
  [Prelim page #metadata(n) <p-3>]
}
