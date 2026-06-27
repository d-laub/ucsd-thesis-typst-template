# Spec: Phase 1 — Pagination Engine

**Date:** 2026-06-26
**Roadmap:** `docs/roadmaps/2026-06-26-ucsd-thesis-typst-roadmap.md` (Phase 1)
**Status:** Approved design; ready for `writing-plans`.
**Depends on:** P0.

## Goal

Implement the page-numbering engine: the front/main/back-matter transitions, the
roman→arabic restart, the counted-but-unnumbered title and copyright pages, and the
centered footer placed 0.5″ from the bottom paper edge. After this phase a document
can render the full pagination sequence the manual requires, verified against the
page numbers in the manual's sample TOC.

Output: `lib/pagination.typ` plus `tests/pagination.typ`, a stub document that walks
the whole sequence (i, ii hidden → iii shown → iv, v → arabic 1, 2 …) and compiles
with zero warnings.

## Authoritative rules (from `formattingmanual.pdf`)

| Rule | Manual ref |
|---|---|
| Title page numbered logically **i**, not displayed | §II p.10, §III p.12 |
| Copyright page numbered logically **ii**, not displayed | §III p.12 |
| Approval page is the first **displayed** number, **iii** | §III p.12 |
| Preliminary pages: lowercase roman (iii, iv, v, …) from the approval page | §II p.10 |
| Main body + back matter: Arabic, restart at **1**, continuous | §II p.10 |
| Page number centered at bottom, **0.5″ from the bottom paper edge** (text margin is 1″) | §II p.9–10 |
| No missing / blank / duplicate page numbers | §II p.10 |

## Decisions (locked)

1. **Inline marker functions** (chosen over a structured wrapper). The author calls,
   in body order: `#front-matter()`, then `#main-matter()`, then `#back-matter()`.
   Each is a `set`/`counter` statement block whose effect flows to the end of the
   document until the next marker overrides it. Idiomatic Typst; maximum flexibility.
   The accepted risk — forgetting a marker breaks pagination — is mitigated by the
   `tests/pagination.typ` golden sequence and the P6 compliance pass.
2. **`#front-matter()` owns the footer.** Rather than editing P0's `dissertation()`
   wrapper, `#front-matter()` installs the global footer via `set page(...)`. Because
   it is the first thing called in the body, the footer flows through the whole
   document. This keeps P1 to **new files only** — no edit to `lib/template.typ` — so
   P1/P3/P5 can be implemented in parallel without file collisions.
3. **Counted-but-unnumbered i/ii via `numbering: none` on those pages.** Roman
   numbering starts at `i` in `#front-matter()`. The title and copyright pages (built
   in P2) set `set page(numbering: none)` locally: the page counter still advances, so
   the approval page — the first page that does *not* suppress its number — displays
   **iii**. P1 proves this with stub pages; P2 supplies the real ones.
4. **Hardcoded numbering patterns.** `"i"` for prelims, `"1"` for body/back matter —
   the manual is unambiguous, so these are not parameterized.
5. **`#back-matter()` does not change numbering.** Body and back matter share one
   continuous Arabic sequence. The marker exists as a semantic hook (and for any
   future back-matter setup); it must NOT reset or alter the page counter.

## Architecture

```
lib/
  pagination.typ      # #front-matter(), #main-matter(), #back-matter()
tests/
  pagination.typ      # golden sequence: stub title/copyright/approval/prelim + body
```

### `lib/pagination.typ`

```typst
// Centered page number following the active page `numbering`.
#let _footer = context align(center, counter(page).display())

#let front-matter() = {
  set page(numbering: "i", footer: _footer, footer-descent: 0.5in)
}

#let main-matter() = {
  counter(page).update(1)
  set page(numbering: "1", footer: _footer, footer-descent: 0.5in)
}

#let back-matter() = {
  // Semantic marker only — Arabic numbering continues unbroken from main-matter.
}
```

- `footer-descent: 0.5in` lowers the footer baseline to 0.5″ from the bottom edge
  inside the 1″ bottom margin — exactly the manual's requirement.
- `counter(page).display()` with no explicit pattern renders using the page's current
  `numbering`, so one footer definition serves both roman and arabic phases.
- The title/copyright suppression lives in P2's page builders (`set page(numbering:
  none)`); P1 demonstrates it with stubs so the iii landing is proven here.

### `tests/pagination.typ`

A standalone document (imports P0 `dissertation` + P1 markers) that renders:
- `#front-matter()`
- stub title page with `set page(numbering: none)` → counts as i, no number shown
- stub copyright page with `set page(numbering: none)` → ii, no number shown
- stub approval page → **iii** shown
- two stub prelim pages → iv, v
- `#main-matter()`
- two stub body pages → **1**, 2
- `#back-matter()` + one stub page → 3 (continuous)

## Non-goals (deferred)

- Real front-matter page content (title/copyright/approval/…) → **P2**.
- Headings, floats → **P3**. TOC/lists → **P4**. Bibliography → **P5**.

## Verification

P1 is complete when:

1. `tests/pagination.typ` compiles with **zero warnings**.
2. The rendered PDF shows the exact sequence: title & copyright pages display **no**
   number but the approval page displays **iii**, prelims continue iv, v, the body
   restarts at Arabic **1**, and back matter continues (3) without a reset.
3. Every page number is **centered** and sits **0.5″ from the bottom edge** (measured),
   while body text stays within the 1″ margin.
4. These `compliance-checklist.md` **[P1]** rows are satisfied (checked off in P6):
   title/copyright counted-but-unnumbered; approval = iii; lowercase roman prelims;
   Arabic restart at 1; all numbers centered at bottom; page numbers 0.5″ from edge;
   nothing else intrudes into the margin.

## Open risks

- **Counter-suppression interaction:** confirm that `set page(numbering: none)` on a
  page still advances `counter(page)` (so iii lands correctly). If a Typst version
  zeroes the count instead, fall back to an explicit `counter(page).step()` on the
  unnumbered pages. Verify empirically in the stub before P2 depends on it.
- **`footer-descent` semantics:** verify the 0.5″ lands from the *paper* edge, not the
  margin edge, on US Letter. Measure the compiled PDF.
