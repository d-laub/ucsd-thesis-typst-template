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
// NOTE: `set page` must come before `counter(page).update` in the function body;
// reversing the order causes the numbering change to shadow the explicit update.
#let main-matter() = {
  set page(numbering: "1", footer: _footer, footer-descent: 0.5in)
  counter(page).update(1)
}

// Back matter: semantic marker only. Body and back matter share one continuous
// Arabic sequence, so this MUST NOT reset or alter the page counter.
#let back-matter() = {
}
