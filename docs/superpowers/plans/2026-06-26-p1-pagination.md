# Phase 1 — Pagination Engine Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking. When authoring Typst code, also use the `typst-author` skill.

**Goal:** Implement the page-numbering engine — the front/main/back-matter transitions, the roman→arabic restart, the counted-but-unnumbered title and copyright pages, and the centered footer placed 0.5″ from the bottom paper edge — so a document can render the exact pagination sequence the UCSD manual requires (i, ii hidden → iii shown → iv, v → arabic 1, 2 → back matter 3, continuous).

**Architecture:** Three inline marker functions in a new `lib/pagination.typ`, called in body order (`#front-matter()`, `#main-matter()`, `#back-matter()`); each is a `set page` / `counter(page)` block whose effect flows to the end of the document until the next marker overrides it. `#front-matter()` owns the global footer (installed via `set page(footer: …, footer-descent: 0.5in)`), so P0's `dissertation()` wrapper is **not** edited and P1 stays new-files-only. The golden sequence is proven in `tests/pagination.typ`, a stub document that walks the whole sequence and is checked both programmatically (`typst query` on labelled `metadata` capturing the live page counter, plus in-document `#assert`s) and structurally (`pdftotext` / visual).

**Tech Stack:** Typst (≥0.15,<0.16, pinned in `pixi.toml`), pixi, TeX Gyre Heros (vendored OTFs under `fonts/`); P0's `dissertation` show-wrapper and `body-leading` from `lib/template.typ`.

## Global Constraints

- Title page is counted logically **i**, number **not displayed** (manual §II p.10, §III p.12).
- Copyright page is counted logically **ii**, number **not displayed** (manual §III p.12).
- Approval page is the first **displayed** number, **iii** (manual §III p.12).
- Preliminary pages: lowercase roman (iii, iv, v, …) from the approval page (manual §II p.10).
- Main body + back matter: Arabic, **restart at 1**, continuous (manual §II p.10).
- Footer is **centered** at the bottom, **0.5″ from the bottom paper edge** (text margin is 1″) (manual §II p.9–10).
- Hardcoded numbering patterns: `"i"` for prelims, `"1"` for body/back matter — not parameterized (manual is unambiguous).
- `#back-matter()` **does not** reset or alter the page counter — body and back matter share one continuous Arabic sequence; the marker is a semantic hook only.
- No missing / blank / duplicate page numbers (manual §II p.10).
- **New files only:** create `lib/pagination.typ` and `tests/pagination.typ`; do **not** edit `lib/template.typ`, `lib/blocks.typ`, `pixi.toml`, `tests/smoke.typ`, or `docs/compliance-checklist.md`. Call `pixi run typst …` directly (do **not** add a pixi task). Build artifacts go to `build/` (gitignored).

---

### Task 1: Footer helper & `front-matter()` (roman prelims)

**Files:**
- Create: `lib/pagination.typ`
- Create: `tests/pagination.typ`

**Interfaces:**
- Consumes: `dissertation` from `lib/template.typ` (the P0 show-wrapper, applied via `#show: dissertation`).
- Produces:
  - `#let _footer = context align(center, counter(page).display())` — the footer **content** (not a function): a centered page number that follows whatever `numbering` the active page set rule defines, so one definition serves both the roman and arabic phases. `display()` with no explicit pattern renders using the page's current `numbering`.
  - `#let front-matter() = { set page(numbering: "i", footer: _footer, footer-descent: 0.5in) }` — installs the global footer and starts lowercase-roman numbering. Called first in the body, so its `set page` flows to document end until `main-matter()` overrides it.

- [ ] **Step 1: Write the first `tests/pagination.typ` (the compile target)**

A standalone document that applies P0's wrapper, calls `#front-matter()`, and lays down three numbered prelim stub pages. Each page captures the live page counter into a labelled `metadata` (queryable from the CLI) and `#assert`s the expected value (so a wrong counter fails the compile itself). No suppression yet — all three pages are numbered i, ii, iii at this stage.

```typ
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
```

- [ ] **Step 2: Compile the test (expect FAIL)**

Run: `pixi run typst compile --font-path fonts --root . tests/pagination.typ build/pagination.pdf`
Expected: FAIL — `lib/pagination.typ` does not exist / `front-matter` is an unknown import. (If `build/` is missing, the error is the missing import, not the directory — later steps `mkdir -p build` before compiling.)

- [ ] **Step 3: Write `lib/pagination.typ` with `_footer` + `front-matter()` only**

```typ
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
```

- [ ] **Step 4: Compile the test (expect PASS)**

Run: `mkdir -p build && pixi run typst compile --font-path fonts --root . tests/pagination.typ build/pagination.pdf`
Expected: PASS — exits 0 with **zero warnings**, creates `build/pagination.pdf`. (The three `#assert`s passed, so the counter ran 1, 2, 3.)

- [ ] **Step 5: Verify the counter values programmatically via `typst query`**

Run:
```bash
for L in p-1 p-2 p-3; do
  pixi run typst query --font-path fonts --root . tests/pagination.typ "<$L>" --field value --one
done
```
Expected: prints `1`, `2`, `3` (one per line). This is the same query pattern P0 used for calibration metadata; it confirms the page counter, independent of rendering.

- [ ] **Step 6: Confirm the footer renders a roman number, centered**

Run: `pdftotext build/pagination.pdf - 2>/dev/null | grep -qx "iii" && echo FOUND || echo "pdftotext unavailable or not found"`
Expected: `FOUND` — the third prelim page's footer shows `iii` (roman), confirming `numbering: "i"` is active and `_footer` renders it. If `pdftotext` is unavailable, open `build/pagination.pdf` and confirm each page shows a centered roman numeral (i, ii, iii) at the bottom.

- [ ] **Step 7: Commit**

```bash
git add lib/pagination.typ tests/pagination.typ
git commit -m "feat: pagination footer helper and front-matter roman numbering"
```

---

### Task 2: Counted-but-unnumbered title & copyright pages (iii landing)

**Files:**
- Modify: `tests/pagination.typ` (prepend stub title/copyright pages with `set page(numbering: none)`)

**Interfaces:**
- Consumes: `front-matter` + `_footer` from Task 1. No new `lib/` function — counted-but-unnumbered is a *property* of the title/copyright pages (P2 supplies the real ones via `set page(numbering: none)`); P1 demonstrates it with stubs so the **iii** landing is proven here.
- Produces: nothing new in `lib/`; proves the open-risk behaviour "`set page(numbering: none)` still advances `counter(page)`."

- [ ] **Step 1: Prepend suppressed title & copyright stubs to `tests/pagination.typ`**

Insert, immediately after `#front-matter()` and **before** the first prelim page, a scoped block whose `set page(numbering: none)` suppresses the displayed number on the title and copyright pages while the counter keeps advancing. Re-label the now-third page as the approval page and assert it lands at 3 (displayed iii); renumber the trailing prelims to iv, v. The full prelim region becomes:

```typ
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
```

Remove the old `<p-1>` / `<p-2>` / `<p-3>` prelim blocks from Task 1 (they are superseded by the labelled sequence above).

- [ ] **Step 2: Compile the test (expect PASS — or a counter-suppression FAIL to act on)**

Run: `mkdir -p build && pixi run typst compile --font-path fonts --root . tests/pagination.typ build/pagination.pdf`
Expected: PASS — zero warnings; the `<p-approval>` assert confirms the counter advanced **through** the two suppressed pages to land at 3.
**If it FAILS** with the approval assert reporting `1` (a Typst version that zeroes the count under `numbering: none`): apply the spec's documented fallback — add an explicit `counter(page).step()` to each suppressed stub page (inside the block, after the `metadata`) — and re-run until the approval page reports 3. Record which path was taken in the commit message.

- [ ] **Step 3: Verify the prelim sequence programmatically**

Run:
```bash
for L in p-title p-copyright p-approval p-iv p-v; do
  pixi run typst query --font-path fonts --root . tests/pagination.typ "<$L>" --field value --one
done
```
Expected: prints `1`, `2`, `3`, `4`, `5`. This proves the title/copyright pages are *counted* (1, 2) even though unnumbered, and that the approval page is logical 3 → displayed iii.

- [ ] **Step 4: Confirm title & copyright show NO number but approval shows iii**

Run: `pdftotext build/pagination.pdf - 2>/dev/null | grep -c "Title page (no number)" ; pdftotext build/pagination.pdf - 2>/dev/null | grep -qx "iii" && echo "iii FOUND" || echo "iii not found"`
Expected: the count line is `1` and `iii FOUND`. To confirm the *absence* of a number on the first two pages, open `build/pagination.pdf` and verify pages 1–2 have a blank footer and page 3 shows a centered `iii`. (`pdftotext` cannot prove a glyph is absent; the visual check is authoritative here, as in P0.)

- [ ] **Step 5: Commit**

```bash
git add tests/pagination.typ
git commit -m "test: prove title/copyright counted-but-unnumbered, approval lands on iii"
```

---

### Task 3: `main-matter()` — Arabic restart at 1

**Files:**
- Modify: `lib/pagination.typ` (add `main-matter()`)
- Modify: `tests/pagination.typ` (add `#main-matter()` + two body stub pages)

**Interfaces:**
- Consumes: `_footer` from Task 1.
- Produces:
  - `#let main-matter() = { counter(page).update(1); set page(numbering: "1", footer: _footer, footer-descent: 0.5in) }` — resets the page counter to 1 and switches to Arabic numbering, keeping the same centered footer and 0.5″ descent. Its `set page` overrides `front-matter()`'s from this point to document end.

- [ ] **Step 1: Append `#main-matter()` + two body stubs to `tests/pagination.typ`**

After the `<p-v>` block, append:

```typ
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
```

- [ ] **Step 2: Compile the test (expect FAIL)**

Run: `mkdir -p build && pixi run typst compile --font-path fonts --root . tests/pagination.typ build/pagination.pdf`
Expected: FAIL — `main-matter` is an unknown import (not yet in `lib/pagination.typ`).

- [ ] **Step 3: Add `main-matter()` to `lib/pagination.typ`**

```typ
// Main matter: restart the page counter at Arabic 1, same centered footer.
// This `set page` overrides front-matter's from here to the end of the document.
#let main-matter() = {
  counter(page).update(1)
  set page(numbering: "1", footer: _footer, footer-descent: 0.5in)
}
```

- [ ] **Step 4: Compile the test (expect PASS)**

Run: `mkdir -p build && pixi run typst compile --font-path fonts --root . tests/pagination.typ build/pagination.pdf`
Expected: PASS — zero warnings; the body asserts confirm the restart to 1, 2.

- [ ] **Step 5: Verify the Arabic restart programmatically**

Run:
```bash
for L in p-body-1 p-body-2; do
  pixi run typst query --font-path fonts --root . tests/pagination.typ "<$L>" --field value --one
done
```
Expected: prints `1`, `2` — the counter restarted at 1 after five prelim pages.

- [ ] **Step 6: Confirm the body footer renders Arabic `1`**

Run: `pdftotext build/pagination.pdf - 2>/dev/null | grep -qx "1" && echo "arabic 1 FOUND" || echo "pdftotext unavailable or not found"`
Expected: `arabic 1 FOUND` — confirming `numbering: "1"` is active on the body pages. If `pdftotext` is unavailable, open the PDF and confirm the first body page footer shows a centered `1`.

- [ ] **Step 7: Commit**

```bash
git add lib/pagination.typ tests/pagination.typ
git commit -m "feat: main-matter marker restarts arabic page numbering at 1"
```

---

### Task 4: `back-matter()` — continuous, no reset

**Files:**
- Modify: `lib/pagination.typ` (add the no-op `back-matter()`)
- Modify: `tests/pagination.typ` (add `#back-matter()` + one stub page)

**Interfaces:**
- Consumes: nothing — `back-matter()` deliberately touches neither the counter nor the page set rule.
- Produces:
  - `#let back-matter() = { }` — a semantic marker only; Arabic numbering continues unbroken from `main-matter()`. It MUST NOT reset or alter `counter(page)`.

- [ ] **Step 1: Append `#back-matter()` + one stub page to `tests/pagination.typ`**

After the `<p-body-2>` block, append:

```typ
#back-matter()

// Back matter continues the Arabic sequence with NO reset.
#context {
  let n = counter(page).get().first()
  assert(n == 3, message: "back-matter page should continue at 3 (no reset), got " + str(n))
  [Back matter page #metadata(n) <p-back-1>]
}
```

- [ ] **Step 2: Compile the test (expect FAIL)**

Run: `mkdir -p build && pixi run typst compile --font-path fonts --root . tests/pagination.typ build/pagination.pdf`
Expected: FAIL — `back-matter` is an unknown import.

- [ ] **Step 3: Add the no-op `back-matter()` to `lib/pagination.typ`**

```typ
// Back matter: semantic marker only. Body and back matter share one continuous
// Arabic sequence, so this MUST NOT reset or alter the page counter.
#let back-matter() = {
}
```

- [ ] **Step 4: Compile the test (expect PASS)**

Run: `mkdir -p build && pixi run typst compile --font-path fonts --root . tests/pagination.typ build/pagination.pdf`
Expected: PASS — zero warnings; the back-matter assert confirms the page is 3 (continuous from body 1, 2 with no reset).

- [ ] **Step 5: Verify continuity programmatically**

Run: `pixi run typst query --font-path fonts --root . tests/pagination.typ "<p-back-1>" --field value --one`
Expected: prints `3` — the back-matter page continues the body's Arabic sequence (1, 2, 3) with no reset.

- [ ] **Step 6: Commit**

```bash
git add lib/pagination.typ tests/pagination.typ
git commit -m "feat: back-matter semantic marker (continuous arabic, no reset)"
```

---

### Task 5: Footer geometry & whole-sequence verification

**Files:**
- (No file changes — verification only against the completed `lib/pagination.typ` + `tests/pagination.typ`.)

**Interfaces:**
- Consumes: the full engine (`front-matter`, `main-matter`, `back-matter`, `_footer`) and the golden stub document from Tasks 1–4.
- Produces: confirmation that the footer is centered and sits 0.5″ from the bottom **paper** edge, that the whole sequence is correct, and that the compile is warning-free.

- [ ] **Step 1: Rebuild and confirm a clean compile**

Run: `mkdir -p build && pixi run typst compile --font-path fonts --root . tests/pagination.typ build/pagination.pdf 2>&1 | tee /dev/stderr | grep -qi "warning" && echo "WARNINGS PRESENT" || echo "clean"`
Expected: `clean` — exits with no `warning` lines (Verification item 1: zero warnings). If any warning appears, fix it before proceeding.

- [ ] **Step 2: Re-assert the full golden sequence in one sweep**

Run:
```bash
for L in p-title:1 p-copyright:2 p-approval:3 p-iv:4 p-v:5 p-body-1:1 p-body-2:2 p-back-1:3; do
  label="${L%%:*}"; want="${L##*:}"
  got=$(pixi run typst query --font-path fonts --root . tests/pagination.typ "<$label>" --field value --one)
  [ "$got" = "$want" ] && echo "$label OK ($got)" || echo "$label MISMATCH want=$want got=$got"
done
```
Expected: every line ends `OK` — title 1, copyright 2, approval 3, iv 4, v 5, body 1, body 2, back 3. Any `MISMATCH` is a regression in the engine.

- [ ] **Step 3: Confirm the footer sits 0.5″ from the bottom paper edge**

US Letter is 792pt (11″) tall; 0.5″ from the bottom edge is y ≈ 756pt from the top. Try a programmatic bounding-box read:

Run: `pdftotext -bbox build/pagination.pdf - 2>/dev/null | grep -A1 'iii' | grep -oE 'yMax="[0-9.]+"' | head -1 || echo "pdftotext -bbox unavailable"`
Expected: a `yMax` near **756** (10.5″) for the `iii` footer word — i.e. the baseline is ~0.5″ above the 792pt bottom edge, inside the 1″ bottom margin and clear of the 1″ text region. If `pdftotext -bbox` is unavailable or the value is ambiguous, open `build/pagination.pdf` and confirm: the page number is horizontally **centered** and sits roughly halfway between the bottom edge and the lowest body text (0.5″ up from the paper edge), with body text never intruding below the 1″ margin. (This `footer-descent: 0.5in` lowers the footer into the 1″ bottom margin to land 0.5″ from the paper edge.)

- [ ] **Step 4: Confirm roman→arabic rendering across the whole document**

Run: `pdftotext build/pagination.pdf - 2>/dev/null | grep -Ec '^(iii|iv|v|1|2|3)$' || echo "pdftotext unavailable"`
Expected: a count ≥ 6 — the displayed footers `iii`, `iv`, `v` (roman prelims) and `1`, `2`, `3` (arabic body + back matter) all appear, while pages 1–2 contribute none. If `pdftotext` is unavailable, confirm visually that prelims are roman and body/back matter are arabic.

- [ ] **Step 5: Final no-warning commit gate (no file change expected)**

If Steps 1–4 all passed and the working tree is clean (Tasks 1–4 already committed `lib/pagination.typ` and `tests/pagination.typ`), there is nothing to commit. If a fix was needed in Steps 1–4, commit it:

```bash
git add lib/pagination.typ tests/pagination.typ
git commit -m "fix: pagination footer geometry / sequence verification"
```

---

## Self-Review

**Spec coverage:**
- Inline marker functions `front-matter()` / `main-matter()` / `back-matter()` in `lib/pagination.typ` (Decision 1) → Tasks 1, 3, 4. ✓
- `front-matter()` owns the footer via `set page(footer:…, footer-descent: 0.5in)`; `dissertation()` / `lib/template.typ` untouched (Decision 2) → Task 1. ✓
- Counted-but-unnumbered i/ii via `set page(numbering: none)`; counter still advances so approval lands iii (Decision 3, open risk) → Task 2 (with the explicit `counter(page).step()` fallback documented). ✓
- Hardcoded patterns `"i"` (prelims) and `"1"` (body/back) (Decision 4) → Tasks 1, 3. ✓
- `back-matter()` does not change numbering; continuous Arabic, no reset (Decision 5) → Task 4 (asserts page 3). ✓
- `_footer = context align(center, counter(page).display())`, pattern-free display serving both phases (Architecture) → Task 1. ✓
- Footer centered, 0.5″ from the bottom **paper** edge; body within 1″ margin (rule + open risk) → Task 5 Step 3. ✓
- Golden sequence i, ii (hidden) → iii → iv, v → 1, 2 → 3 (Architecture / `tests/pagination.typ`) → built across Tasks 1–4, swept in Task 5 Step 2. ✓
- Verification items: zero warnings (Task 5 Step 1), exact sequence & restart (Tasks 2–4 asserts + Task 5 Step 2), centered + 0.5″ measured (Task 5 Step 3), roman→arabic rendering (Task 5 Step 4). ✓
- Non-goals correctly absent: no real front-matter content (P2), no headings/floats (P3), no TOC/lists (P4), no bibliography (P5).

**Parallel-safety scan:** Only `lib/pagination.typ` and `tests/pagination.typ` are created/modified. No edits to `lib/template.typ`, `lib/blocks.typ`, `pixi.toml`, `tests/smoke.typ`, or `docs/compliance-checklist.md`. All test commands invoke `pixi run typst compile|query …` directly — no new pixi task. `build/` is the only output dir (gitignored), created with `mkdir -p build` before each compile (Typst 0.15 will not auto-create it). Commits add only the two new files.

**Placeholder scan:** No TODOs or unresolved placeholders. The only conditional value is the Task 2 Step 2 fallback (`counter(page).step()`), which is a documented contingency tied to an explicit empirical check (approval assert == 3), not an open blank. The bbox target ~756pt in Task 5 Step 3 is a derived geometric value (792pt − 0.5″·72), not a guess.

**Type / name consistency:** `_footer`, `front-matter`, `main-matter`, `back-matter` are defined in `lib/pagination.typ` and match every import/call site in `tests/pagination.typ`; `dissertation` is imported from `lib/template.typ` and applied via `#show: dissertation`. `counter(page).get().first()` returns the integer page value inside `context` (the page counter is single-level); metadata labels `<p-title> <p-copyright> <p-approval> <p-iv> <p-v> <p-body-1> <p-body-2> <p-back-1>` are unique and reused consistently between the asserts and the query sweep.

---

**Compliance-checklist note (OUT OF SCOPE here — for P6 to tick):** completing this plan satisfies these `[P1]` rows — title/copyright counted-but-unnumbered; approval page = iii; lowercase roman preliminary pages; Arabic numbering restarts at 1; all page numbers centered at the bottom; page numbers 0.5″ from the bottom edge; nothing else intrudes into the margin. P6 checks these off in `docs/compliance-checklist.md`; this phase does not edit that file.
