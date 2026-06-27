#import "../lib/template.typ": dissertation
#import "../lib/pagination.typ": front-matter, main-matter

#show: dissertation

#front-matter()

// Title page (logical i) and copyright page (logical ii): counted, number
// suppressed. The page counter must still advance, so the approval page lands
// on iii. (P2 supplies the real title/copyright pages the same way.)
#[
  #set page(numbering: none)
  #context {
    let n = counter(page).get().first()
    assert(n == 1, message: "title page should count 1, got " + str(n))
    [Title page (no number) #metadata(n) <p-title>]
  }
  #pagebreak()
  #context {
    let n = counter(page).get().first()
    assert(n == 2, message: "copyright page should count 2, got " + str(n))
    [Copyright page (no number) #metadata(n) <p-copyright>]
  }
]
#pagebreak()

// Approval page — first DISPLAYED number, iii.
#context {
  let n = counter(page).get().first()
  assert(n == 3, message: "approval page should display iii (count 3), got " + str(n))
  [Approval page #metadata(n) <p-approval>]
}
#pagebreak()

// Two more preliminary pages — iv, v.
#context {
  let n = counter(page).get().first()
  assert(n == 4, message: "prelim page should count 4, got " + str(n))
  [Prelim page #metadata(n) <p-iv>]
}
#pagebreak()

#context {
  let n = counter(page).get().first()
  assert(n == 5, message: "prelim page should count 5, got " + str(n))
  [Prelim page #metadata(n) <p-v>]
}

#main-matter()

// Body restarts at Arabic 1.
#context {
  let n = counter(page).get().first()
  assert(n == 1, message: "first body page should restart at 1, got " + str(n))
  [Body page #metadata(n) <p-body-1>]
}
#pagebreak()

#context {
  let n = counter(page).get().first()
  assert(n == 2, message: "second body page should count 2, got " + str(n))
  [Body page #metadata(n) <p-body-2>]
}
