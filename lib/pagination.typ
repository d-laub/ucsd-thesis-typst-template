// Centered page number following the active page `numbering`.
// `display()` with no pattern renders using the page's current numbering,
// so this one definition serves both the roman and arabic phases.
#let _footer = context align(center, counter(page).display())

// Front matter: install the global footer and start lowercase-roman numbering.
// Called first in the body, so this `set page` flows to the end of the document
// until `main-matter()` overrides it. `footer-descent: 0.5in` lowers the footer
// baseline to 0.5in above the bottom paper edge (inside the 1in bottom margin).
#let front-matter() = {
  set page(numbering: "i", footer: _footer, footer-descent: 0.5in)
}

// Main matter: restart the page counter at Arabic 1, same centered footer.
// This `set page` overrides front-matter's from here to the end of the document.
//
// ORDERING NOTE: `set page` MUST come before `counter(page).update(1)`.
// In Typst 0.15, a `set page` that changes the `numbering` parameter triggers a
// new page-layout context. If the counter update were placed first, the subsequent
// `set page` event would clobber it (resetting the counter to its default start
// value of 2 for the second logical page), yielding page 2 instead of 1. By
// placing `set page` first, the new context is established before the explicit
// update, so the counter correctly reads 1 on the first body page.
#let main-matter() = {
  set page(numbering: "1", footer: _footer, footer-descent: 0.5in)
  counter(page).update(1)
}

// Back matter: semantic marker only. Body and back matter share one continuous
// Arabic sequence, so this MUST NOT reset or alter the page counter.
#let back-matter() = {
}
