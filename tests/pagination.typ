#import "../lib/template.typ": dissertation
#import "../lib/pagination.typ": front-matter, main-matter, back-matter

#show: dissertation

#front-matter()

// Title page (logical i) and copyright page (logical ii): counted, footer
// suppressed. The page counter must still advance, so the approval page lands
// on iii. (P2 supplies the real title/copyright pages the same way.)
#[
  #set page(footer: none)
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
#pagebreak()

#back-matter()

// Back matter continues the Arabic sequence with NO reset.
#context {
  let n = counter(page).get().first()
  assert(n == 3, message: "back-matter page should continue at 3 (no reset), got " + str(n))
  [Back matter page #metadata(n) <p-back-1>]
}

// ── Rendered-footer contract (verified by pdftotext sweep on build/pagination.pdf)
// Page 1 (title):     NO footer numeral  (set page(footer: none) suppresses it)
// Page 2 (copyright): NO footer numeral  (set page(footer: none) suppresses it)
// Page 3 (approval):  "iii"  — roman, state="front"
// Page 4 (prelim iv): "iv"   — roman, state="front"
// Page 5 (prelim v):  "v"    — roman, state="front"
// Page 6 (body 1):    "1"    — arabic, state="main", counter reset to 1
// Page 7 (body 2):    "2"    — arabic, state="main"
// Page 8 (back 1):    "3"    — arabic, state="back" (falls into else branch)
