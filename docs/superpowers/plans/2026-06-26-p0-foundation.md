# Phase 0 — Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking. When authoring Typst code, also use the `typst-author` skill.

**Goal:** Stand up the Typst project skeleton and base layout layer so a minimal document compiles to a PDF satisfying every global page-/text-level rule in the UCSD manual.

**Architecture:** A `pixi`-pinned `typst` toolchain compiles documents against an in-repo vendored font. A single `#show` function (`lib/template.typ`) applies page geometry, fonts, and text rules; spacing primitives live in `lib/blocks.typ`. Double-spacing is calibrated empirically by measuring line advance in `tests/calibration.typ` and reading it back with `typst query`.

**Tech Stack:** Typst (≥0.13), pixi, TeX Gyre Heros (Helvetica/Arial metric clone, vendored OTFs).

## Global Constraints

- Page: US Letter (8.5″×11″), 1″ margins on all four sides — copied from the template's `pgSz 12240×15840` / `pgMar 1440`.
- Body font: TeX Gyre Heros, 12pt, `fill: black`, one consistent font throughout.
- Footnotes and captions: ≥10pt.
- Body double-spaced = **clean typographic 2.0×** the font's native single line advance (calibrated, not assumed). Single-spacing carve-outs reuse Typst's native single leading (0.65em).
- First-line indent 0.5″ on **every** paragraph (including the first after a heading); no block style; ragged-right (no justification).
- Long quotations: single-spaced, indented 0.5″ on **both** left and right (manual §II, symmetric — overriding the template's asymmetric 0.5″/0.7″), no inserted quotation marks.
- Compile command is canonical: `pixi run build`. Fonts come only from `fonts/` via `--font-path fonts`; no system fonts.
- Repo root is the package root (`typst.toml`, `lib/`, `tests/` at root alongside `docs/`).

---

### Task 1: Project scaffold & font vendoring

**Files:**
- Create: `pixi.toml`
- Create: `typst.toml`
- Create: `.gitignore`
- Create: `fonts/texgyreheros-regular.otf`, `fonts/texgyreheros-bold.otf`, `fonts/texgyreheros-italic.otf`, `fonts/texgyreheros-bolditalic.otf` (downloaded)

**Interfaces:**
- Consumes: nothing.
- Produces: a working `pixi run typst …` toolchain; a `fonts/` directory discoverable via `--font-path fonts`; the `pixi run build` and `pixi run calibrate` tasks used by later tasks.

- [ ] **Step 1: Write `pixi.toml`**

```toml
[workspace]
name = "ucsd-dissertation"
channels = ["conda-forge"]
platforms = ["linux-64"]

[dependencies]
typst = ">=0.13"

[tasks]
build = "typst compile --font-path fonts tests/smoke.typ build/smoke.pdf"
calibrate = "typst query --font-path fonts tests/calibration.typ '<calib>' --field value --one --pretty"
fonts = "typst fonts --font-path fonts"
```

- [ ] **Step 2: Install the toolchain and verify typst runs**

Run: `pixi run typst --version`
Expected: prints `typst 0.13.x` (or newer). If this fails, pixi could not resolve `typst` from conda-forge — stop and report.

- [ ] **Step 3: Write the font-presence check and run it (expect FAIL)**

Run: `pixi run fonts | grep -i "TeX Gyre Heros"`
Expected: FAIL (no output, exit 1) — fonts not vendored yet.

- [ ] **Step 4: Download the TeX Gyre Heros OTFs into `fonts/`**

```bash
mkdir -p fonts
base="https://mirrors.ctan.org/fonts/tex-gyre/opentype"
for f in regular bold italic bolditalic; do
  curl -fsSL "$base/texgyreheros-$f.otf" -o "fonts/texgyreheros-$f.otf"
done
ls -1 fonts
```
Expected: four `.otf` files listed. ⚠️ Requires network. If CTAN is unreachable, fall back to Liberation Sans (`liberation-sans` / `fonts-liberation`) — it shares Helvetica/Arial metrics — and record the substitution in the README (Task 5).

- [ ] **Step 5: Re-run the font-presence check (expect PASS)**

Run: `pixi run fonts | grep -i "TeX Gyre Heros"`
Expected: PASS — prints a line containing `TeX Gyre Heros`.

- [ ] **Step 6: Write `typst.toml`**

```toml
[package]
name = "ucsd-dissertation"
version = "0.0.1"
entrypoint = "lib/template.typ"
authors = ["David Laub"]
license = "MIT"
description = "Typst template for UC San Diego doctoral dissertations (non-joint PhD)."
```

- [ ] **Step 7: Write `.gitignore`**

```gitignore
build/
*.pdf
.pixi/
```

- [ ] **Step 8: Commit**

```bash
git add pixi.toml pixi.lock typst.toml .gitignore fonts/
git commit -m "build: scaffold typst project, pin toolchain, vendor TeX Gyre Heros"
```

---

### Task 2: Base layout in `lib/template.typ`

**Files:**
- Create: `lib/template.typ`
- Create: `tests/smoke.typ`

**Interfaces:**
- Consumes: the `pixi run build` task and `fonts/` from Task 1.
- Produces:
  - `#let body-leading = 0.65em` — the body line leading constant (set to native single here; recalibrated to double in Task 3). Imported by `tests/calibration.typ`.
  - `#let dissertation(title: none, author: none, degree: none, year: none, body) = …` — the master show function. `title`/`author`/`degree`/`year` are accepted but unused in P0 (forward-compat for P2); applied via `#show: dissertation`.

- [ ] **Step 1: Write `tests/smoke.typ` (the compile target)**

```typ
#import "../lib/template.typ": dissertation

#show: dissertation

This is the first paragraph of the smoke test. Its first line must be indented
half an inch, like every other paragraph, and the body must be set in TeX Gyre
Heros at twelve points in solid black.

This is a second paragraph. It exists so we can see paragraph-to-paragraph
rhythm and confirm there is no extra blank line between paragraphs beyond the
line spacing itself.
```

- [ ] **Step 2: Run the build (expect FAIL)**

Run: `pixi run build`
Expected: FAIL — `lib/template.typ` does not exist / `dissertation` unknown.

- [ ] **Step 3: Write `lib/template.typ`**

```typ
// Body line leading. Native single here; recalibrated to 2.0x in Task 3.
#let body-leading = 0.65em

#let dissertation(
  title: none,
  author: none,
  degree: none,
  year: none,
  body,
) = {
  set page(paper: "us-letter", margin: 1in)
  set text(font: "TeX Gyre Heros", size: 12pt, fill: black, lang: "en")
  set par(
    leading: body-leading,
    spacing: body-leading,
    first-line-indent: (amount: 0.5in, all: true),
    justify: false,
  )
  // Footnotes: >=10pt, single-spaced (overrides body spacing).
  show footnote.entry: it => {
    set text(size: 10pt)
    set par(leading: 0.65em, spacing: 0.65em)
    it
  }
  body
}
```

- [ ] **Step 4: Run the build (expect PASS)**

Run: `pixi run build`
Expected: PASS — exits 0 with **no warnings**, creates `build/smoke.pdf`.

- [ ] **Step 5: Confirm page geometry**

Run: `pixi run build && pdfinfo build/smoke.pdf | grep -i "page size" || echo "pdfinfo unavailable"`
Expected: `Page size: 612 x 792 pts (letter)` (US Letter). If `pdfinfo` is unavailable, this is satisfied by the `paper: "us-letter"` set rule — note it and move on.

- [ ] **Step 6: Commit**

```bash
git add lib/template.typ tests/smoke.typ
git commit -m "feat: base layout template (us-letter, 1in margins, heros 12pt, indent)"
```

---

### Task 3: Calibrate double spacing to 2.0×

**Files:**
- Create: `tests/calibration.typ`
- Modify: `lib/template.typ` (the `body-leading` constant)

**Interfaces:**
- Consumes: `body-leading` from `lib/template.typ`.
- Produces: a calibrated `body-leading` expressed in `em` (size-independent), and a `tests/calibration.typ` that emits a `<calib>` metadata dict `{ native-single-pt, recommended-double-em, current-ratio }` queryable via `pixi run calibrate`.

**Why em:** line advance is linear in leading — `advance(L) = box + L`. The native single advance is `advance(0.65em)`; double is `2 × advance(0.65em)`, which requires `leading = advance(0.65em) + 0.65em`. Expressed in `em` this ratio is constant for the font at any point size, so the calibrated value is size-independent.

- [ ] **Step 1: Write `tests/calibration.typ`**

```typ
#import "../lib/template.typ": body-leading

// Baseline-to-baseline advance for a given leading: height of two lines
// minus height of one line. measure() resolves em to pt at the active size.
#let advance(lead) = (
  measure({ set par(leading: lead); [a\ a] }).height
    - measure({ set par(leading: lead); [a] }).height
)

#set text(font: "TeX Gyre Heros", size: 12pt)

#context {
  let single = advance(0.65em)
  let double = single + 0.65em            // target: advance == 2 x single
  let current = advance(body-leading)
  [
    #metadata((
      native-single-pt: repr(single),
      recommended-double-em: double / 12pt, // unitless em count at 12pt
      current-ratio: current / single,
    )) <calib>
  ]
  // Human-readable echo on the page:
  [native single advance: #single \
   recommended double leading: #double (#(double / 12pt)em) \
   current ratio (body-leading / single): #(current / single)]
}
```

- [ ] **Step 2: Run the calibration query and record the numbers (expect ratio ≈ 1.0)**

Run: `pixi run calibrate`
Expected: prints a dict; `current-ratio` ≈ `1.0` (template still uses native single), and `recommended-double-em` ≈ `2.x` (the value to install). **Record `recommended-double-em`.**

- [ ] **Step 3: Install the calibrated leading in `lib/template.typ`**

Replace the `body-leading` line with the measured em value from Step 2 (substitute the exact number printed; for TeX Gyre Heros at 12pt it is ≈ `2.4em`):

```typ
// Body line leading, calibrated to 2.0x the native single advance (Task 3).
// = native-single-advance + 0.65em, expressed in em (size-independent).
#let body-leading = 2.4em  // <-- replace with measured recommended-double-em
```

- [ ] **Step 4: Re-run calibration to verify 2.0× (expect ratio == 2.0)**

Run: `pixi run calibrate`
Expected: `current-ratio` is `2.0` (within ±0.001). If it is off, the installed em value does not match Step 2's measurement — fix it.

- [ ] **Step 5: Rebuild the smoke test to confirm it still compiles**

Run: `pixi run build`
Expected: PASS, no warnings; `build/smoke.pdf` now visibly double-spaced.

- [ ] **Step 6: Commit**

```bash
git add lib/template.typ tests/calibration.typ
git commit -m "feat: calibrate body line spacing to clean 2.0x double"
```

---

### Task 4: Spacing primitives & long-quote block

**Files:**
- Create: `lib/blocks.typ`
- Modify: `tests/smoke.typ` (exercise the primitives + a footnote)

**Interfaces:**
- Consumes: nothing from blocks; `dissertation` from Task 2.
- Produces:
  - `#let single-spaced(body) = …` — wraps content at native single leading (0.65em); reused by captions, bibliography, vita, appendices in later phases.
  - `#let long-quote(body) = …` — single-spaced block, padded 0.5″ left and right, no inserted quotation marks.

- [ ] **Step 1: Add a long quote and a footnote to `tests/smoke.typ`**

Append to `tests/smoke.typ`:

```typ
#import "../lib/blocks.typ": long-quote

Here is a sentence that introduces a long quotation and also carries a
footnote.#footnote[This footnote must render at ten points and be single-spaced,
regardless of the double-spaced body around it.]

#long-quote[
  This is a long quotation of more than six lines. It must be single-spaced and
  indented an additional half inch on both the left and the right margins, with
  no quotation marks added by the template. It runs long enough to wrap across
  several lines so the single spacing inside the block is visually distinct from
  the double-spaced body text that surrounds it on the page here.
]

A trailing paragraph after the quotation, double-spaced and indented like the
rest of the body.
```

- [ ] **Step 2: Run the build (expect FAIL)**

Run: `pixi run build`
Expected: FAIL — `lib/blocks.typ` does not exist / `long-quote` unknown.

- [ ] **Step 3: Write `lib/blocks.typ`**

```typ
// Single line spacing (Typst native single). The reusable carve-out for
// captions, bibliography, vita, and appendices.
#let single-spaced(body) = {
  set par(leading: 0.65em, spacing: 0.65em)
  body
}

// Long quotation (manual §II): single-spaced, indented 0.5in on BOTH sides,
// no inserted quotation marks.
#let long-quote(body) = {
  pad(left: 0.5in, right: 0.5in, single-spaced(body))
}
```

- [ ] **Step 4: Run the build (expect PASS)**

Run: `pixi run build`
Expected: PASS, no warnings; `build/smoke.pdf` created.

- [ ] **Step 5: Confirm the quote and footnote rendered**

Run: `pdftotext build/smoke.pdf - 2>/dev/null | grep -c "single-spaced" || echo "pdftotext unavailable"`
Expected: a count ≥ 2 (the quote text and the footnote text both contain "single-spaced"). If `pdftotext` is unavailable, open `build/smoke.pdf` and visually confirm: the long quote is indented both sides and single-spaced; the footnote is smaller (10pt) and single-spaced.

- [ ] **Step 6: Commit**

```bash
git add lib/blocks.typ tests/smoke.typ
git commit -m "feat: single-spaced primitive and long-quote block"
```

---

### Task 5: README & compliance check-off

**Files:**
- Create: `README.md`
- Modify: `docs/compliance-checklist.md` (tick the `[P0]` rows)

**Interfaces:**
- Consumes: the calibrated `recommended-double-em` value from Task 3, Step 2.
- Produces: build documentation and the recorded calibration value; nothing imported by code.

- [ ] **Step 1: Write `README.md`**

```markdown
# UCSD Doctoral Dissertation — Typst Template

Typst template for a UC San Diego doctoral dissertation (non-joint PhD),
adapted from the 2025–2026 Preparation and Submission Manual.

## Build

    pixi run build        # compiles tests/smoke.typ -> build/smoke.pdf
    pixi run calibrate    # prints the line-spacing calibration metadata
    pixi run fonts        # lists fonts discoverable under fonts/

Requires only `pixi`; it pins Typst and the vendored TeX Gyre Heros font, so
output is identical on any machine.

## Fonts

TeX Gyre Heros (a free Helvetica/Arial metric clone) is vendored under `fonts/`
and used via `--font-path fonts`. [If Liberation Sans was substituted, say so here.]

## Line spacing

Body text is double-spaced as clean typographic 2.0×: the line leading is the
native single advance plus one native leading, calibrated via `pixi run calibrate`.
Recorded value: `body-leading = <RECORDED>em` (≈ 2.4em for TeX Gyre Heros 12pt).
Single-spacing carve-outs (footnotes, long quotes, and later captions/bibliography)
use Typst's native single leading (0.65em).
```

Substitute `<RECORDED>` with the value installed in Task 3.

- [ ] **Step 2: Tick the `[P0]` rows in `docs/compliance-checklist.md`**

Change each `[P0]`-tagged checkbox that Phase 0 satisfies from `- [ ]` to `- [x]`:
legible typeface; 1″ margins; body font ≥10pt (12pt via TeX Gyre Heros); footnotes/captions ≥10pt; one consistent font; all text black; italics-for-emphasis allowed; body double-spaced; 0.5″ first-line indent / no block style; long quotations single-spaced + 0.5″ both sides; captions may be single-spaced (primitive exists). Leave rows tagged for later phases unchanged.

- [ ] **Step 3: Commit**

```bash
git add README.md docs/compliance-checklist.md
git commit -m "docs: README build/spacing notes; check off Phase 0 compliance rows"
```

---

## Self-Review

**Spec coverage:**
- Scaffold/toolchain (pixi, typst.toml, .gitignore) → Task 1. ✓
- Font vendoring (TeX Gyre Heros, `--font-path`) → Task 1. ✓
- Page US Letter + 1″ margins → Task 2 (verified Step 5). ✓
- Fonts/size/black/consistent → Task 2. ✓
- First-line indent 0.5″ all paragraphs, no block, ragged-right → Task 2. ✓
- Footnotes ≥10pt single-spaced → Task 2 (footnote rule) + Task 4 (exercised). ✓
- Double spacing 2.0× (clean typographic, calibrated) → Task 3. ✓
- Single-spaced primitive + long-quote 0.5″ both sides → Task 4. ✓
- Verification (clean compile, 2.0× ratio, page size, README record, checklist) → Tasks 2–5. ✓
- Non-goals (pagination, front matter, floats, lists, back matter) → correctly absent.

**Placeholder scan:** The one substituted value (`body-leading` em) is a genuine measured output of Task 3 Step 2, with the procedure and an approximate value given — not a TODO. No other placeholders.

**Type consistency:** `body-leading` is defined in `lib/template.typ` (Task 2) and imported by `tests/calibration.typ` (Task 3); `dissertation`, `single-spaced`, `long-quote` names match across their definitions and call sites in `tests/smoke.typ`.
