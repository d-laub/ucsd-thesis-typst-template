# Phase 3 — Body Floats & Headings Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking. When authoring Typst code, also use the `typst-author` skill.

**Goal:** Implement chapter/section heading styles and the four float kinds (figure, table, scheme, graph) with per-kind caption placement, per-chapter numbering, single-spaced captions, facing-caption pages, and 90° landscape rotation — so the body of the dissertation renders correctly and P4 can consume these float definitions for its List-of pages.

**Architecture:** All new behavior lives in a single new module `lib/floats.typ`, exposed as an *applicable show-rule bundle* `floats-rules(body)` plus four thin float constructors (`fig`/`tbl`/`scheme`/`graph`). The bundle installs the heading show rules (two-line `CHAPTER N`, unnumbered sections) and the `figure.caption` placement/spacing rules; the constructors wrap `figure(...)` with the correct `kind`, literal `supplement`, and per-chapter `numbering`. The chapter number drives float numbers by reading `counter(heading)` at the float's location. P3 does **not** edit `lib/template.typ`; the test file applies `#show: floats-rules` itself, keeping P1/P3/P5 parallelizable.

**Tech Stack:** Typst (≥0.15,<0.16 via `pixi`), the vendored TeX Gyre Heros font, P0's `single-spaced` primitive from `lib/blocks.typ`. No pytest — the "test" is `tests/floats.typ` compiled with `pixi run typst compile --font-path fonts --root . tests/floats.typ build/floats.pdf`; a failing test is a compile error or a failing `#assert`, a passing test is a clean compile with zero warnings.

## Global Constraints

- Chapter heading = two-line **centered** display: `CHAPTER N` on its own line, the chapter title on the line below (`show heading.where(level: 1)`).
- Sections / subsections (heading levels ≥ 2) are **unnumbered** display headings — no `1.1` / `1.1.1` section numbers.
- **Figure** & **scheme** captions render **below** the float; **table** & **graph** captions render **above** the float — set via show-set on `figure.caption.position`, not hand-assembled.
- Captions are **single-spaced** via P0's `single-spaced` primitive from `lib/blocks.typ` (one source of truth for single spacing).
- Each caption carries the **literal prefix** "Figure" / "Table" / "Scheme" / "Graph" (the figure `supplement`).
- **Per-chapter numbering** `chapter.n` (e.g. `1.1`, `1.2`), with every float counter **reset at each chapter** (level-1 heading show rule).
- **`facing: true`** flag emits a caption-only page immediately **preceding** the float page (opt-in, not auto-detected).
- **`landscape: true`** flag rotates the float 90° so its **top edge runs along the left margin** (verified empirically: `rotate(-90deg, reflow: true)`).
- **No italics** in headings.
- Chapters *are* numbered (the `CHAPTER N` label); that chapter counter still drives float numbering even though sections are unnumbered.

---

### Task 1: Heading show rules, chapter counter & the `floats-rules` bundle skeleton

**Files:**
- Create: `lib/floats.typ`
- Create: `tests/floats.typ`

**Interfaces:**
- Consumes: `single-spaced` from `lib/blocks.typ` (P0); the built-in `counter(heading)`.
- Produces:
  - `#let chapter-counter = counter(heading)` — **the chapter counter key**; float numbering reads its first level (`chapter-counter.get().first()`).
  - `#let floats-rules(body) = …` — an applicable show bundle (`#show: floats-rules`). In this task it installs the heading show rule only: level-1 headings become a two-line centered `CHAPTER N` / title block (no italics) and **reset all four float counters**; levels ≥ 2 are passed through as unnumbered display headings with italics suppressed. Caption rules and constructors are folded in by Tasks 2–3.

- [ ] **Step 1: Write the heading section of `tests/floats.typ` (the compile target)**

Create `tests/floats.typ` exercising heading levels 1–3 across two chapters. Apply the bundle in the test file (NOT in `dissertation`):

```typ
#import "../lib/floats.typ": floats-rules, chapter-counter

#show: floats-rules

= Introduction
== A section
=== A subsection
Body text under chapter one.

= Methods
Body text under chapter two.

// Programmatic check: after two level-1 headings the chapter counter is 2.
#context assert.eq(
  chapter-counter.get().first(), 2,
  message: "chapter counter should be 2 after two chapters",
)
```

- [ ] **Step 2: Run the build (expect FAIL)**

Run: `pixi run typst compile --font-path fonts --root . tests/floats.typ build/floats.pdf`
Expected: FAIL — `lib/floats.typ` does not exist / `floats-rules` and `chapter-counter` are unknown.

- [ ] **Step 3: Write `lib/floats.typ` (heading rules + chapter counter)**

```typ
#import "blocks.typ": single-spaced

// The chapter counter key. Chapters are the level-1 heading counter; float
// numbering reads its first level via chapter-counter.get().first().
#let chapter-counter = counter(heading)

// Applicable show bundle: #show: floats-rules
#let floats-rules(body) = {
  // Headings. where(level: >= 2) is not expressible, so branch in one rule.
  show heading: it => {
    if it.level == 1 {
      // Reset every float counter at the start of each chapter (decision 4).
      counter(figure.where(kind: image)).update(0)
      counter(figure.where(kind: table)).update(0)
      counter(figure.where(kind: "scheme")).update(0)
      counter(figure.where(kind: "graph")).update(0)
      // Two-line centered CHAPTER N / title, no italics, single-spaced pair.
      set align(center)
      set text(style: "normal", weight: "bold")
      single-spaced(block(width: 100%, breakable: false)[
        CHAPTER #context counter(heading).display("1") \
        #it.body
      ])
    } else {
      // Sections/subsections: unnumbered display heading, no italics.
      set text(style: "normal")
      it
    }
  }
  body
}
```

- [ ] **Step 4: Run the build (expect PASS)**

Run: `pixi run typst compile --font-path fonts --root . tests/floats.typ build/floats.pdf`
Expected: PASS — exits 0 with **no warnings**; `build/floats.pdf` created; the `#context assert.eq` did not trip.

- [ ] **Step 5: Confirm the two-line chapter label and unnumbered sections**

Run: `pdftotext build/floats.pdf - 2>/dev/null | grep -E "CHAPTER (1|2)" || echo "pdftotext unavailable"`
Expected: lines `CHAPTER 1` and `CHAPTER 2` present. Also confirm (visually if `pdftotext` is absent) that the chapter *title* sits on the line below the label, both centered, and that "A section" / "A subsection" carry **no** `1.1` / `1.1.1` numbers and are not italic.

- [ ] **Step 6: Commit**

```bash
git add lib/floats.typ tests/floats.typ
git commit -m "feat(p3): heading show rules (two-line CHAPTER N, unnumbered sections) + chapter counter"
```

---

### Task 2: Four float constructors & per-kind caption placement + single-spaced captions

**Files:**
- Modify: `lib/floats.typ` (add caption show rules to `floats-rules`; add the four constructors)
- Modify: `tests/floats.typ` (add one of each float kind)

**Interfaces:**
- Consumes: `single-spaced` (caption spacing); the bundle from Task 1.
- Produces:
  - Inside `floats-rules`: `show figure.where(kind: image): set figure.caption(position: bottom)`, `… kind: table → top`, `… kind: "scheme" → bottom`, `… kind: "graph" → top`, and `show figure.caption: single-spaced`.
  - `#let fig(body, caption: none, facing: false, landscape: false) = …` — `kind: image`, `supplement: [Figure]`.
  - `#let tbl(body, caption: none, facing: false, landscape: false) = …` — `kind: table`, `supplement: [Table]`.
  - `#let scheme(body, caption: none, facing: false, landscape: false) = …` — `kind: "scheme"`, `supplement: [Scheme]`.
  - `#let graph(body, caption: none, facing: false, landscape: false) = …` — `kind: "graph"`, `supplement: [Graph]`.
  - (`facing` / `landscape` parameters are accepted now but wired up in Tasks 4–5; default `false` = plain in-flow float.)

- [ ] **Step 1: Add one of each float kind to `tests/floats.typ`**

Append under chapter one (before the `= Methods` chapter) — use trivial bodies so no external assets are needed:

```typ
#import "../lib/floats.typ": fig, tbl, scheme, graph

#fig(rect(width: 3cm, height: 2cm), caption: [A figure; caption below.])
#tbl(table(columns: 2, [a], [b], [c], [d]), caption: [A table; caption above.])
#scheme(rect(width: 3cm, height: 2cm), caption: [A scheme; caption below.])
#graph(rect(width: 3cm, height: 2cm), caption: [A graph; caption above.])
```

- [ ] **Step 2: Run the build (expect FAIL)**

Run: `pixi run typst compile --font-path fonts --root . tests/floats.typ build/floats.pdf`
Expected: FAIL — `fig` / `tbl` / `scheme` / `graph` are unknown.

- [ ] **Step 3: Add the caption rules and constructors to `lib/floats.typ`**

Inside `floats-rules`, before `body`, add the placement and spacing rules:

```typ
  // Caption placement per kind (decision 3): figure & scheme below; table & graph above.
  show figure.where(kind: image): set figure.caption(position: bottom)
  show figure.where(kind: table): set figure.caption(position: top)
  show figure.where(kind: "scheme"): set figure.caption(position: bottom)
  show figure.where(kind: "graph"): set figure.caption(position: top)
  // Captions single-spaced via the P0 primitive (decision 7).
  show figure.caption: single-spaced
```

Then add the constructors (numbering is added in Task 3 — for now figures use the default `"1"` counter):

```typ
#let _float(body, caption: none, kind: none, supplement: none, facing: false, landscape: false) = {
  // facing/landscape wired up in Tasks 4-5; plain float for now.
  figure(body, caption: caption, kind: kind, supplement: supplement)
}

#let fig(body, caption: none, facing: false, landscape: false) = _float(
  body, caption: caption, kind: image, supplement: [Figure],
  facing: facing, landscape: landscape,
)
#let tbl(body, caption: none, facing: false, landscape: false) = _float(
  body, caption: caption, kind: table, supplement: [Table],
  facing: facing, landscape: landscape,
)
#let scheme(body, caption: none, facing: false, landscape: false) = _float(
  body, caption: caption, kind: "scheme", supplement: [Scheme],
  facing: facing, landscape: landscape,
)
#let graph(body, caption: none, facing: false, landscape: false) = _float(
  body, caption: caption, kind: "graph", supplement: [Graph],
  facing: facing, landscape: landscape,
)
```

Note: custom kinds `"scheme"` / `"graph"` *require* an explicit `supplement` (Typst warns / errors otherwise) — that is exactly why each constructor sets it.

- [ ] **Step 4: Run the build (expect PASS)**

Run: `pixi run typst compile --font-path fonts --root . tests/floats.typ build/floats.pdf`
Expected: PASS, **zero warnings** (the explicit supplements silence the custom-kind warning).

- [ ] **Step 5: Verify caption positions programmatically**

Run: `pixi run typst query --font-path fonts --root . tests/floats.typ "figure.caption" --field position`
Expected: in document order `[bottom, top, bottom, top]` (figure→bottom, table→top, scheme→bottom, graph→top). If the queried `position` field does not reflect the show-set rule in this Typst build, fall back to a visual check: open `build/floats.pdf` and confirm the Figure and Scheme captions sit **below** their boxes and the Table and Graph captions sit **above**.

- [ ] **Step 6: Verify literal prefixes and single-spaced captions**

Run: `pdftotext build/floats.pdf - 2>/dev/null | grep -E "^(Figure|Table|Scheme|Graph) " || echo "pdftotext unavailable"`
Expected: four lines beginning `Figure`, `Table`, `Scheme`, `Graph`. To confirm single spacing, make one caption wrap to ≥2 lines (temporarily lengthen its text) and confirm visually it is single-spaced relative to the double-spaced body — then revert the lengthening.

- [ ] **Step 7: Commit**

```bash
git add lib/floats.typ tests/floats.typ
git commit -m "feat(p3): fig/tbl/scheme/graph constructors with per-kind caption placement + single-spaced captions"
```

---

### Task 3: Per-chapter numbering with literal prefix & reset at each chapter

**Files:**
- Modify: `lib/floats.typ` (add the chapter-aware numbering function; wire it into `_float`)
- Modify: `tests/floats.typ` (assert `1.1`, `1.2`, and reset to `2.1` in chapter 2)

**Interfaces:**
- Consumes: `chapter-counter` (Task 1); the per-kind float counters reset by the level-1 heading rule (Task 1).
- Produces: `#let chapter-float-numbering = n => numbering("1.1", chapter-counter.get().first(), n)` — a numbering **function** (evaluated contextually during caption display) that prefixes each float's own count `n` with the chapter number. Wired into every `figure(...)` via `numbering: chapter-float-numbering`.

- [ ] **Step 1: Add numbering assertions to `tests/floats.typ`**

Add a second figure in chapter one and a figure in chapter two, with in-document `#context assert.eq` checks that compose `chapter.n` from the counters at each float's location. (`assert.eq` failing = failing test.)

```typ
// --- chapter one: expect 1.1 then 1.2 ---
#fig(rect(width: 2cm, height: 1cm), caption: [First figure of chapter one.])
#context assert.eq(
  str(chapter-counter.get().first()) + "."
    + str(counter(figure.where(kind: image)).get().first()),
  "1.1", message: "first figure should be 1.1",
)
#fig(rect(width: 2cm, height: 1cm), caption: [Second figure of chapter one.])
#context assert.eq(
  str(chapter-counter.get().first()) + "."
    + str(counter(figure.where(kind: image)).get().first()),
  "1.2", message: "second figure should be 1.2",
)

= Methods
// --- chapter two: counter must RESET; first figure is 2.1, not 1.3 ---
#fig(rect(width: 2cm, height: 1cm), caption: [First figure of chapter two.])
#context assert.eq(
  str(chapter-counter.get().first()) + "."
    + str(counter(figure.where(kind: image)).get().first()),
  "2.1", message: "chapter two's first figure should reset to 2.1",
)
```

(Place the chapter-one figures before the existing `= Methods` heading; merge the existing `= Methods` chapter block with the chapter-two figure so there is a single second chapter.)

- [ ] **Step 2: Run the build (expect FAIL)**

Run: `pixi run typst compile --font-path fonts --root . tests/floats.typ build/floats.pdf`
Expected: FAIL — figures still use the default `"1"` numbering, so the composed strings are `1.1`/`1.2`/`1.3`; the `2.1` assertion (and the reset) fails.

- [ ] **Step 3: Add the numbering function and wire it into `_float`**

In `lib/floats.typ`, after `chapter-counter`:

```typ
// Per-chapter float numbering: chapter.n with the chapter read at the float's
// location. Evaluated in context when the caption displays, so .get() is valid.
#let chapter-float-numbering = n => numbering(
  "1.1", chapter-counter.get().first(), n,
)
```

And add `numbering: chapter-float-numbering` to the `figure(...)` call in `_float`:

```typ
#let _float(body, caption: none, kind: none, supplement: none, facing: false, landscape: false) = {
  figure(
    body, caption: caption, kind: kind, supplement: supplement,
    numbering: chapter-float-numbering,
  )
}
```

- [ ] **Step 4: Run the build (expect PASS)**

Run: `pixi run typst compile --font-path fonts --root . tests/floats.typ build/floats.pdf`
Expected: PASS, zero warnings; all three `assert.eq` numbering checks hold (`1.1`, `1.2`, `2.1`).

- [ ] **Step 5: Confirm prefixed numbers render and reset (cross-kind)**

Run: `pdftotext build/floats.pdf - 2>/dev/null | grep -E "Figure (1\.1|1\.2|2\.1)" || echo "pdftotext unavailable"`
Expected: `Figure 1.1`, `Figure 1.2`, `Figure 2.1` all present — confirming the literal prefix + chapter numbering + per-chapter reset. Also confirm the `Table`/`Scheme`/`Graph` captions now read `Table 1.1` / `Scheme 1.1` / `Graph 1.1` (each kind has its own counter, all reset per chapter — verifies the custom-kind risk).

- [ ] **Step 6: Commit**

```bash
git add lib/floats.typ tests/floats.typ
git commit -m "feat(p3): per-chapter float numbering (chapter.n) with literal prefix and per-chapter reset"
```

---

### Task 4: `facing: true` caption-on-preceding-page

**Files:**
- Modify: `lib/floats.typ` (the `facing` branch of `_float`)
- Modify: `tests/floats.typ` (a `facing: true` float in a fresh chapter)

**Interfaces:**
- Consumes: `single-spaced`, `chapter-counter`, the kind counter.
- Produces: in `_float`, when `facing: true`: a vertically-centered caption-only page, a `pagebreak()`, then the float rendered with **no** caption (so the caption appears once, on the facing page). The float stays a real `figure` element (queryable by P4) and still steps its kind counter; the facing page predicts the float's number as `counter(figure.where(kind: kind)).get().first() + 1` (the figure steps the counter when it renders on the next page).

- [ ] **Step 1: Add a facing float to `tests/floats.typ`**

Add a third chapter whose single figure uses `facing: true`, so its number is deterministically `3.1`:

```typ
= Results
#fig(
  rect(width: 4cm, height: 3cm),
  caption: [A facing-caption figure; its caption is on the preceding page.],
  facing: true,
)
```

- [ ] **Step 2: Run the build (expect FAIL)**

Run: `pixi run typst compile --font-path fonts --root . tests/floats.typ build/floats.pdf`
Expected: FAIL — `_float` ignores `facing`, so the caption renders with the float (not on a preceding page); the verification in Step 5 will not hold. (If you prefer a hard failure first, temporarily add `#assert(false)` inside the not-yet-written facing branch; otherwise this task is verified structurally in Step 5.)

- [ ] **Step 3: Implement the `facing` branch in `_float`**

```typ
#let _float(body, caption: none, kind: none, supplement: none, facing: false, landscape: false) = {
  if facing {
    // Caption-only page, vertically & horizontally centered, single-spaced.
    {
      set align(center + horizon)
      single-spaced[
        #context [
          #supplement~#numbering(
            "1.1",
            chapter-counter.get().first(),
            counter(figure.where(kind: kind)).get().first() + 1,
          ): #caption
        ]
      ]
    }
    pagebreak()
    // The float itself on the next page, no caption (shown on facing page),
    // still a real numbered figure for P4's List-of queries.
    figure(
      body, caption: none, kind: kind, supplement: supplement,
      numbering: chapter-float-numbering,
    )
  } else {
    figure(
      body, caption: caption, kind: kind, supplement: supplement,
      numbering: chapter-float-numbering,
    )
  }
}
```

(`~` is a non-breaking space between the supplement and number, matching Typst's default caption separator intent.)

- [ ] **Step 4: Run the build (expect PASS)**

Run: `pixi run typst compile --font-path fonts --root . tests/floats.typ build/floats.pdf`
Expected: PASS, zero warnings.

- [ ] **Step 5: Confirm the caption sits on the page *preceding* the float**

Render per-page text and locate the caption vs. the float page:

```bash
# The facing caption "Figure 3.1" must appear on an earlier page than the
# (text-less) float box. Find the page holding the caption:
pdftotext -layout build/floats.pdf - 2>/dev/null | grep -n "Figure 3.1" \
  || echo "pdftotext unavailable — open build/floats.pdf and confirm visually"
```
Expected (programmatic): `Figure 3.1` appears exactly once. Open `build/floats.pdf` and confirm the caption is alone, vertically centered on its page, and the **next** page holds the rectangle with no caption. If `pdftotext` is unavailable, rely on the visual check. Also confirm the predicted number `3.1` matches the float's chapter/position (it is the only float in chapter 3).

- [ ] **Step 6: Commit**

```bash
git add lib/floats.typ tests/floats.typ
git commit -m "feat(p3): facing: true emits a single-spaced caption-only page preceding the float"
```

---

### Task 5: `landscape: true` 90° rotation (top along left margin)

**Files:**
- Modify: `lib/floats.typ` (the `landscape` branch of `_float`)
- Modify: `tests/floats.typ` (a `landscape: true` float)

**Interfaces:**
- Consumes: the `figure` produced in `_float`.
- Produces: when `landscape: true`, the whole float (body + caption) wrapped in `rotate(-90deg, reflow: true, …)` so the float's **top edge runs along the left margin**. `-90deg` was verified empirically against the manual's sample orientation (a probe rendered the content's top edge on the left, reading bottom-to-top); a `+90deg` would mirror it.

- [ ] **Step 1: Add a landscape float to `tests/floats.typ`**

```typ
= Discussion
#graph(
  rect(width: 14cm, height: 7cm),
  caption: [A wide landscape graph rotated 90 degrees.],
  landscape: true,
)
```

- [ ] **Step 2: Run the build (expect FAIL)**

Run: `pixi run typst compile --font-path fonts --root . tests/floats.typ build/floats.pdf`
Expected: FAIL — `_float` ignores `landscape`, so the 14cm-wide box overflows the portrait text block (overflow warning) and is not rotated. (Treat the overflow warning as the failing signal; the zero-warnings goal is restored once rotation is implemented.)

- [ ] **Step 3: Implement the `landscape` branch in `_float`**

Wrap the constructed float in the rotation. Compute the figure first, then rotate (apply to both the plain and the facing-float-page paths; facing+landscape is out of scope and need not compose):

```typ
  let make = caption => figure(
    body, caption: caption, kind: kind, supplement: supplement,
    numbering: chapter-float-numbering,
  )
  if facing {
    // …caption page + pagebreak as in Task 4…
    let f = make(none)
    if landscape { rotate(-90deg, reflow: true, f) } else { f }
  } else {
    let f = make(caption)
    // -90deg => top edge along the LEFT margin (verified empirically).
    if landscape { rotate(-90deg, reflow: true, f) } else { f }
  }
```

(Refactor `_float` so the `figure(...)` call is built once via the `make` closure and reused by both branches — DRY.)

- [ ] **Step 4: Run the build (expect PASS)**

Run: `pixi run typst compile --font-path fonts --root . tests/floats.typ build/floats.pdf`
Expected: PASS, **zero warnings** (the wide box no longer overflows because `reflow: true` lets the rotated box occupy its rotated bounding box).

- [ ] **Step 5: Verify rotation DIRECTION (top along the left margin)**

This is structural/visual — confirm the sign of the rotation:

```bash
# Render the landscape page to an image if poppler is available:
pdftoppm -png -r 100 build/floats.pdf build/floats-pg 2>/dev/null \
  && echo "rendered build/floats-pg-*.png — open the Discussion page" \
  || echo "pdftoppm unavailable — open build/floats.pdf directly"
```
Expected: open the rendered page (or the PDF) and confirm the graph's **top edge runs along the LEFT margin** — i.e. to read it you rotate the page 90° clockwise, and the caption (above a graph) ends up on the **right** side reading bottom-to-top. If instead the top edge is on the *right* margin (mirrored), change `-90deg` to `+90deg` in `_float` and re-verify. ⚠️ A 90° sign error mirrors the float — this check is the gate.

- [ ] **Step 6: Commit**

```bash
git add lib/floats.typ tests/floats.typ
git commit -m "feat(p3): landscape: true rotates float 90deg with top along the left margin"
```

---

## Self-Review

**Spec coverage** (against `2026-06-26-p3-floats-headings-design.md`):
- Decision 1 — two-line centered `CHAPTER N` / title via `show heading.where(level: 1)` → Task 1. ✓
- Decision 2 — sections/subsections unnumbered; chapter counter still drives floats → Task 1 (branch on `it.level`) + Task 3 (numbering reads `chapter-counter`). ✓
- Decision 3 — caption placement via show-set on `figure.caption.position` (figure/scheme bottom, table/graph top) → Task 2 (verified by querying `figure.caption` `position`). ✓
- Decision 4 — per-chapter reset in the level-1 heading rule; numbering reads chapter counter → resets in Task 1, numbering + reset assertions in Task 3. ✓
- Decision 5 — explicit `facing: true` → caption-only page preceding the float → Task 4. ✓
- Decision 6 — explicit `landscape: true` → 90° rotation, top along left margin → Task 5 (`rotate(-90deg, reflow: true)`, empirically verified). ✓
- Decision 7 — captions reuse P0 `single-spaced` → `show figure.caption: single-spaced` (Task 2) and the facing caption page (Task 4). ✓
- Decision 8 — exposed as `#show: floats-rules`, no edit to `lib/template.typ` → bundle applied in the test file only. ✓
- Verification items 1–6 — zero-warning compile (every Task Step 4), two-line/​unnumbered headings (T1), caption above/below + prefix + single-spaced (T2), per-chapter reset to 2.1 (T3), facing caption page (T4), landscape rotation (T5). ✓
- Open risks — custom kinds `"scheme"`/`"graph"` integrate with counter reset & numbering (verified T3 Step 5); rotation direction (gated T5 Step 5); counter-reset timing (asserted `2.1` not `1.3`, T3 Step 1/4). ✓
- Non-goals — TOC / List-of pages (P4), "Continued" multipage handling, pagination/front-matter/bibliography — correctly absent.

**Placeholder scan:** No `TODO`/`<FILL>` placeholders. The only empirically-chosen value, `rotate(-90deg)`, was verified by a probe (top edge rendered on the left margin) and is re-gated in Task 5 Step 5 with the `+90deg` fallback spelled out. The facing-page `+ 1` number prediction is explained (the figure steps its kind counter when it renders on the following page) and checked in Task 4 Step 5.

**Name/type consistency:** `floats-rules(body)`, `fig`/`tbl`/`scheme`/`graph` (each `(body, caption: none, facing: false, landscape: false)`), `chapter-counter` (= `counter(heading)`), and the internal `chapter-float-numbering` / `_float` are defined in `lib/floats.typ` and imported under the same names in `tests/floats.typ`. Kinds are `image` (figure), `table`, `"scheme"`, `"graph"`; supplements are the literal `[Figure]`/`[Table]`/`[Scheme]`/`[Graph]`; these strings are the same ones the per-kind caption show-set rules and counter-reset updates key on.

**Parallel-safety:** Only NEW files are created/modified — `lib/floats.typ` and `tests/floats.typ`. No edits to `lib/template.typ`, `lib/blocks.typ`, `pixi.toml`, `tests/smoke.typ`, or `docs/compliance-checklist.md`. No pixi task is added; all test steps invoke `pixi run typst compile`/`pixi run typst query` directly. Safe to run concurrently with P1/P5.

**Checklist note (for P6 — out of scope here):** When this phase is verified, P6 should tick these `docs/compliance-checklist.md` **[P3]** rows: "Figure captions placed below the figure" (l.124), "Table captions placed above the table" (l.125), "Scheme captions placed below the scheme" (l.126), "Graph captions placed above the graph" (l.127), "Captions single-spaced; consistent format throughout" (l.128), "Facing caption page precedes the figure/table…" (l.129), "Landscape floats rotated 90° with the top along the left margin" (l.130), "…figures/tables/appendices carry chapter identification or consecutive numbering" (l.131), and the prefix portion of the figure/table/graph caption-word row (l.120, jointly with P4). Leave them unticked in P3.
