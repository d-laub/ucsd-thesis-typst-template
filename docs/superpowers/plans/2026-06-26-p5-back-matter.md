# Phase 5 — Back Matter Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking. When authoring Typst code, also use the `typst-author` skill.

**Goal:** Build the dissertation's back matter: a numeric-style bibliography that is single-spaced within entries with a full blank line between entries and lists **every** author in full (no "et al."), single-spaced auto-lettered appendices (Appendix A, B, C…), and the reference-matter ordering the manual mandates (documented, not enforced). After this phase the document's tail is compliant.

**Architecture:** All new files; `lib/template.typ` is untouched so P1/P3/P5 remain parallel. `lib/backmatter.typ` exposes a `#show: backmatter-rules` bundle (bibliography spacing) plus an `#appendix(title, body)` helper that reuses P0's `single-spaced` from `lib/blocks.typ`. A custom numeric CSL committed under `styles/` lifts the "et al." threshold so full author lists always render. A sample `references.bib` carries an >6-author entry as the test vector. `tests/backmatter.typ` is the compile target; "tests" are clean compiles plus `#assert`s and `pdftotext … | grep` checks on the rendered PDF.

**Tech Stack:** Typst (≥0.15,<0.16, per `pixi.toml`), pixi, BibLaTeX `.bib`, CSL 1.0, `pdftotext`/`pdfinfo` (poppler) for PDF assertions. The vendored TeX Gyre Heros font is used via `--font-path fonts`.

## Global Constraints

- In-text citations are **numeric** (`[1]`, `[2]`), references listed in citation order.
- The bibliography uses a **custom CSL with `et-al-min` lifted** (set to 99) so **all** authors print — no "et al." anywhere in the bibliography, even for >6-author works.
- The bibliography is **single-spaced within entries** with a **full blank line between entries** (set via `show bibliography: set par(...)`, calibrated empirically because the between-entry selector is version-dependent).
- The bibliography is the **last** element of the manuscript.
- Reference-matter order is **Appendices → Addenda → Chronology → Endnotes → Glossary → Bibliography**; recorded as a header comment in `lib/backmatter.typ` and enforced by source-file order (no programmatic reordering — deferred to P6).
- Appendices **may be single-spaced** (manual permits); `#appendix` wraps its body in P0's `single-spaced`.
- `#appendix(title, body)` is **auto-lettered A/B/C…** via a dedicated counter that does not collide with P1's page counter or P3's chapter counter.
- **New files only.** Do **not** modify `lib/template.typ`, `lib/blocks.typ`, `pixi.toml`, `tests/smoke.typ`, or `docs/compliance-checklist.md`. Helpers are applied in the **test file** via `#show: backmatter-rules`, not inside `dissertation()`.
- Test steps invoke `pixi run typst compile …` **directly**; do **not** add a pixi task (shared file). Always `mkdir -p build` first (P0's tasks auto-create it, but direct invocations must too).

---

### Task 1: Sample `references.bib` + custom numeric CSL with full authors

**Files:**
- Create: `references.bib`
- Create: `styles/ieee-full-authors.csl`
- Create: `tests/backmatter.typ`

**Interfaces:**
- Consumes: nothing.
- Produces:
  - `references.bib` — three BibLaTeX entries, one of which (`@octuple2023`) has **eight** authors (the test vector for "no et al.").
  - `styles/ieee-full-authors.csl` — a minimal numeric (IEEE-style `[n]`) CSL whose name elements set `et-al-min="99" et-al-use-first="99"` so every author always prints. Referenced from a `#bibliography(..., style: "styles/ieee-full-authors.csl")` call (a path string relative to the document, resolved under `--root .`).
  - `tests/backmatter.typ` — the compile target; in this task it cites the multi-author entry and renders the bibliography with the custom CSL.

> **CSL approach (read before implementing).** The reproducible, offline path is to **hand-write the minimal numeric CSL committed in-repo** (given in full in Step 2 below) — it needs no network. It is functionally an IEEE-style numeric style (`[n]` in text, numbered list in the bibliography) with the et-al threshold removed; hence the name `ieee-full-authors.csl`. The single behavioural edit relative to a stock IEEE CSL is: stock IEEE sets `et-al-min="7" et-al-use-first="1"` on its name elements (so 7+ authors collapse to "first author *et al.*"); here those are set to `99`/`99`, which never triggers for any realistic author count. (Optional, network-dependent alternative — **not required**: fetch upstream IEEE from `https://raw.githubusercontent.com/citation-style-language/styles/master/ieee.csl` and apply exactly that one edit to every `<name … et-al-min/et-al-use-first …>` it contains. If the network is unavailable, use the hand-written CSL below — it is the primary deliverable.)

- [ ] **Step 1: Write `references.bib`**

```bibtex
@article{octuple2023,
  author  = {Smith, Alice and Johnson, Bob and Williams, Carol and Brown, David
             and Jones, Eve and Garcia, Frank and Miller, Grace and Davis, Henry},
  title   = {A Genome-Wide Survey of Octuple Authorship},
  journal = {Journal of Computational Biology},
  year    = {2023},
}

@book{taocp2020,
  author    = {Knuth, Donald E.},
  title     = {The Art of Computer Programming},
  publisher = {Addison-Wesley},
  year      = {2020},
}

@article{wc1953,
  author  = {Watson, James and Crick, Francis},
  title   = {Molecular Structure of Nucleic Acids},
  journal = {Nature},
  year    = {1953},
}
```

The eight surnames in `octuple2023` are distinct words; **"Davis"** (the 8th author) appears in the PDF only if every author is printed — it is the grep witness in later steps.

- [ ] **Step 2: Write `styles/ieee-full-authors.csl`**

A self-contained CSL 1.0 numeric style; `et-al-min="99" et-al-use-first="99"` on both the citation and bibliography name elements forces full author lists.

```xml
<?xml version="1.0" encoding="utf-8"?>
<style xmlns="http://purl.org/net/xbiblio/csl" class="in-text" version="1.0" default-locale="en-US">
  <info>
    <title>IEEE (Full Authors — UCSD Dissertation)</title>
    <id>https://standardmodel.bio/csl/ieee-full-authors</id>
    <updated>2026-06-26T00:00:00+00:00</updated>
    <summary>Numeric [n] style; et-al threshold lifted so all authors always print.</summary>
  </info>
  <macro name="author">
    <names variable="author">
      <name and="text" delimiter=", " initialize-with=". "
            et-al-min="99" et-al-use-first="99"/>
    </names>
  </macro>
  <macro name="issued-year">
    <date variable="issued">
      <date-part name="year"/>
    </date>
  </macro>
  <citation collapse="citation-number">
    <layout prefix="[" suffix="]" delimiter="], [">
      <text variable="citation-number"/>
    </layout>
  </citation>
  <bibliography et-al-min="99" et-al-use-first="99" second-field-align="flush">
    <layout>
      <text variable="citation-number" prefix="[" suffix="] "/>
      <text macro="author" suffix=", "/>
      <text variable="title" quotes="true" suffix=", "/>
      <text variable="container-title" font-style="italic" suffix=", "/>
      <text macro="issued-year" suffix="."/>
    </layout>
  </bibliography>
</style>
```

- [ ] **Step 3: Write the initial `tests/backmatter.typ` (the compile target)**

```typ
#import "../lib/template.typ": dissertation

#show: dissertation

The first claim is well established. @octuple2023 The second draws on classic
work. @taocp2020 @wc1953

#bibliography("references.bib", style: "styles/ieee-full-authors.csl")
```

- [ ] **Step 4: Run the compile (expect FAIL only if CSL/bib is malformed; otherwise PASS-with-content-check)**

Run:
```bash
mkdir -p build && pixi run typst compile --font-path fonts --root . tests/backmatter.typ build/backmatter.pdf
```
Expected: clean compile, **zero warnings**, `build/backmatter.pdf` created. If Typst reports "failed to parse CSL" or "invalid style", the CSL in Step 2 is malformed — fix it before proceeding. (This is the first place the chosen CSL is exercised end-to-end.)

- [ ] **Step 5: KEYSTONE — assert all eight authors print and no "et al." appears**

Run:
```bash
pdftotext build/backmatter.pdf - 2>/dev/null > build/backmatter.txt || echo "pdftotext unavailable"
echo "et-al count:"; grep -c -i "et al" build/backmatter.txt
echo "Davis (8th author) present:"; grep -c "Davis" build/backmatter.txt
echo "First author present:"; grep -c "Smith" build/backmatter.txt
```
Expected:
- `et-al count:` → **0** (no abbreviation anywhere).
- `Davis (8th author) present:` → **≥ 1** (the last author of the 8-author work printed in full).
- `First author present:` → **≥ 1**.

If `et al` count is **non-zero**, Typst's CSL engine did **not** honour the lifted `et-al-min` — this is the spec's flagged risk. STOP and escalate per "Open risks" in the spec (try the upstream-IEEE-plus-edit alternative, or document an exception) before continuing. If `pdftotext` is unavailable, open `build/backmatter.pdf` and visually confirm the `octuple2023` entry lists all eight surnames (Smith … Davis) with no "et al.".

- [ ] **Step 6: Confirm numeric in-text citations**

Run:
```bash
grep -c -E "\[1\]|\[2\]|\[3\]" build/backmatter.txt
```
Expected: ≥ 1 — citations render as bracketed numbers `[n]`, not author-year. (Visual fallback: confirm `[1]`, `[2]`, `[3]` appear in the body text.)

- [ ] **Step 7: Commit**

```bash
git add references.bib styles/ieee-full-authors.csl tests/backmatter.typ
git commit -m "feat(p5): sample bib + custom numeric CSL forcing full author lists"
```

---

### Task 2: `backmatter-rules` — single-spaced bibliography with blank line between entries

**Files:**
- Create: `lib/backmatter.typ`
- Modify: `tests/backmatter.typ` (apply `#show: backmatter-rules`)

**Interfaces:**
- Consumes: P0's `single-spaced` from `lib/blocks.typ` (for Task 3; imported here so the module is whole). The bibliography rendered in Task 1.
- Produces: `backmatter-rules(body)` — a `#show: backmatter-rules` bundle installing `show bibliography: set par(leading: <single>, spacing: <blank-line>)` so entries are single-spaced internally with one blank line between them. Also a header comment recording the mandated reference-matter order.

> **Spacing mechanism (read before implementing).** In Typst a bibliography's entries are separate paragraphs, so `par(leading: …)` controls spacing **within** an entry (the wrapped lines) and `par(spacing: …)` controls the gap **between** entries. Single-spaced within = `leading: 0.65em` (Typst native single, matching P0's `single-spaced`). "Double space / full blank line between entries" = a larger `spacing`; start at `1.3em` (≈ 2× the single leading) and confirm empirically in Step 5 that it reads as exactly one blank line, not doubled internal leading. If a future entry contains an internal paragraph break (rare for `.bib` output), the documented fallback is a `show bibliography.entry: it => block(below: <blank-line>, it)` wrapper — note it in a comment but do not implement unless Step 5 shows the `par(spacing)` approach failing.

- [ ] **Step 1: Write `lib/backmatter.typ`**

```typ
// ============================================================================
// Back matter (UCSD formatting manual §III p.43).
//
// REFERENCE-MATTER ORDER (author's responsibility — enforced by source order):
//   Appendices -> Addenda -> Chronology -> Endnotes -> Glossary -> Bibliography
// The bibliography is the LAST element of the manuscript.
//
// This module is applied in the document via `#show: backmatter-rules` and the
// `#appendix(title, body)` helper; it does NOT modify `dissertation()`.
// ============================================================================

#import "../lib/blocks.typ": single-spaced

// Single line leading within a bibliography entry (Typst native single).
#let bib-leading = 0.65em
// Gap between bibliography entries: one blank single-spaced line.
// Calibrated empirically (Task 2, Step 5); ~2x the single leading.
#let bib-entry-gap = 1.3em

#let backmatter-rules(body) = {
  // Bibliography: single-spaced within entries, blank line between entries.
  show bibliography: set par(leading: bib-leading, spacing: bib-entry-gap)
  body
}
```

- [ ] **Step 2: Apply the bundle in `tests/backmatter.typ`**

Insert the import and `#show` immediately after the existing `dissertation` show line:

```typ
#import "../lib/template.typ": dissertation
#import "../lib/backmatter.typ": backmatter-rules

#show: dissertation
#show: backmatter-rules
```

(Leave the body and `#bibliography(...)` line from Task 1 unchanged.)

- [ ] **Step 3: Run the compile (expect PASS)**

Run:
```bash
mkdir -p build && pixi run typst compile --font-path fonts --root . tests/backmatter.typ build/backmatter.pdf
```
Expected: clean compile, **zero warnings**. If `backmatter-rules` is undefined the import line fails — that is the intended pre-implementation failure had the module not existed; here it should pass.

- [ ] **Step 4: Re-run the keystone (regression — still no "et al.")**

Run:
```bash
pdftotext build/backmatter.pdf - 2>/dev/null > build/backmatter.txt
grep -c -i "et al" build/backmatter.txt
```
Expected: **0**. The spacing change must not have altered author rendering.

- [ ] **Step 5: Verify single-spacing within + blank line between (measured / visual)**

Run:
```bash
pdftotext -layout build/backmatter.pdf - 2>/dev/null | sed -n '/References/,$p'
```
Expected (visual confirm): each entry's wrapped lines sit on consecutive single-spaced lines; between two entries there is exactly **one** blank line. If the gap looks doubled or the internal lines look loose, adjust `bib-entry-gap` (between) or confirm `bib-leading` is `0.65em` (within) in `lib/backmatter.typ` and re-run. Record the final `bib-entry-gap` value in the module comment. (Optional finer check: `pdftotext` does not expose leading directly; for a numeric confirmation, query line baselines — but the layout dump above is the accepted check, mirroring P0's visual-confirm steps.)

- [ ] **Step 6: Commit**

```bash
git add lib/backmatter.typ tests/backmatter.typ
git commit -m "feat(p5): backmatter-rules — single-spaced bib entries, blank line between"
```

---

### Task 3: `#appendix(title, body)` — auto-lettered, single-spaced

**Files:**
- Modify: `lib/backmatter.typ` (add the counter + `appendix` function)
- Modify: `tests/backmatter.typ` (add two appendices before the bibliography)

**Interfaces:**
- Consumes: `single-spaced` (already imported in Task 2).
- Produces: `#appendix(title, body)` — steps a dedicated `counter("p5-appendix")`, renders an `APPENDIX A` / `APPENDIX B` … heading (level-1, consistent with the chapter heading family), then the `body` wrapped in `single-spaced`. The counter name `p5-appendix` is distinct from any page or chapter counter, avoiding collision (spec risk: "numbering-prefix collision").

- [ ] **Step 1: Add the appendix helper to `lib/backmatter.typ`**

Append below `backmatter-rules`:

```typ
// Auto-lettered appendices (A, B, C, ...). Dedicated counter — does not collide
// with the page counter (P1) or chapter counter (P3).
#let appendix-counter = counter("p5-appendix")

#let appendix(title, body) = {
  appendix-counter.step()
  context {
    let letter = numbering("A", appendix-counter.get().first())
    heading(level: 1)[APPENDIX #letter: #title]
  }
  single-spaced(body)
}
```

`numbering("A", 1)` → `"A"`, `numbering("A", 2)` → `"B"`, etc. The heading text is literally `APPENDIX A: …` so it greps case-insensitively in Step 5.

- [ ] **Step 2: Add the import + two appendices to `tests/backmatter.typ`**

Add `appendix` to the backmatter import and place two appendices **before** the bibliography (source order = reference-matter order: appendices precede the bibliography):

```typ
#import "../lib/backmatter.typ": backmatter-rules, appendix
```

Before the `#bibliography(...)` line, insert:

```typ
#appendix("Supplementary Methods")[
  This appendix is single-spaced, as the manual permits for reproduced research
  materials and survey instruments. It runs long enough to wrap across several
  lines so the single spacing inside the appendix body is visually distinct from
  the double-spaced body of the dissertation.
]

#appendix("Supplementary Tables")[
  A second appendix, lettered B automatically by the appendix counter.
]
```

- [ ] **Step 3: Run the compile (expect PASS)**

Run:
```bash
mkdir -p build && pixi run typst compile --font-path fonts --root . tests/backmatter.typ build/backmatter.pdf
```
Expected: clean compile, **zero warnings**. (Had `appendix` not been defined in Step 1, the import would fail — the intended TDD failure.)

- [ ] **Step 4: Assert the appendix lettering rendered**

Run:
```bash
pdftotext build/backmatter.pdf - 2>/dev/null > build/backmatter.txt
echo "APPENDIX A:"; grep -c -i "APPENDIX A" build/backmatter.txt
echo "APPENDIX B:"; grep -c -i "APPENDIX B" build/backmatter.txt
```
Expected: each ≥ 1 — auto-lettering produced both `APPENDIX A` and `APPENDIX B`. (Visual fallback: open the PDF; the first appendix heading reads "APPENDIX A: Supplementary Methods", the second "APPENDIX B: Supplementary Tables".)

- [ ] **Step 5: Confirm the appendix body is single-spaced**

Run:
```bash
pdftotext -layout build/backmatter.pdf - 2>/dev/null | sed -n '/APPENDIX A/,/APPENDIX B/p'
```
Expected (visual confirm): the appendix paragraph's wrapped lines are single-spaced (tight), visibly tighter than the double-spaced body above. This is the `single-spaced` wrapper from P0 doing its job.

- [ ] **Step 6: Commit**

```bash
git add lib/backmatter.typ tests/backmatter.typ
git commit -m "feat(p5): #appendix — auto-lettered, single-spaced helper"
```

---

### Task 4: Integration — numeric citations + appendices + bibliography, full assertion sweep

**Files:**
- Modify: `tests/backmatter.typ` (finalize as the integration fixture)

**Interfaces:**
- Consumes: `dissertation`, `backmatter-rules`, `appendix`, `references.bib`, `styles/ieee-full-authors.csl` — all from Tasks 1–3.
- Produces: the final `tests/backmatter.typ` exercising the full back matter in mandated order (appendices → bibliography), plus an in-document `#assert` guarding the appendix counter, and a consolidated PDF-level assertion sweep that is the phase's acceptance gate.

- [ ] **Step 1: Add an in-document counter assertion to `tests/backmatter.typ`**

After the two appendices and **before** the bibliography, add a context assertion that the appendix counter reached 2 (defensive, fails the compile if lettering logic regresses):

```typ
#context assert(
  counter("p5-appendix").get().first() == 2,
  message: "expected exactly two appendices (A, B)",
)
```

Confirm the final file order is: body with `@`-citations → `#appendix` A → `#appendix` B → assertion → `#bibliography(...)`. The bibliography is the **last** element (manual rule).

- [ ] **Step 2: Run the compile (expect PASS)**

Run:
```bash
mkdir -p build && pixi run typst compile --font-path fonts --root . tests/backmatter.typ build/backmatter.pdf
```
Expected: clean compile, **zero warnings**. A failing `#assert` would abort the compile with the message — that is the test firing.

- [ ] **Step 3: Run the full acceptance sweep**

Run:
```bash
pdftotext build/backmatter.pdf - 2>/dev/null > build/backmatter.txt
echo "1) et-al count (want 0):";        grep -c -i "et al" build/backmatter.txt
echo "2) 8th author Davis (want >=1):"; grep -c "Davis" build/backmatter.txt
echo "3) 1st author Smith (want >=1):"; grep -c "Smith" build/backmatter.txt
echo "4) numeric cite [n] (want >=1):"; grep -c -E "\[1\]|\[2\]|\[3\]" build/backmatter.txt
echo "5) APPENDIX A (want >=1):";       grep -c -i "APPENDIX A" build/backmatter.txt
echo "6) APPENDIX B (want >=1):";       grep -c -i "APPENDIX B" build/backmatter.txt
```
Expected: line 1 → `0`; lines 2–6 → each ≥ 1. **Line 1 is the keystone**: zero "et al." in the bibliography. If `pdftotext` is unavailable, open `build/backmatter.pdf` and confirm each item visually (all eight authors of `octuple2023` spelled out; `[1]`/`[2]`/`[3]` in text; APPENDIX A and B headings; bibliography last and single-spaced with blank lines between entries).

- [ ] **Step 4: Confirm reference-matter order (appendices precede bibliography)**

Run:
```bash
grep -n -E -i "APPENDIX A|APPENDIX B|References|Bibliography" build/backmatter.txt
```
Expected: `APPENDIX A` and `APPENDIX B` line numbers precede the bibliography heading's line number — the mandated order holds in the rendered output.

- [ ] **Step 5: Final clean-compile gate (zero warnings)**

Run:
```bash
mkdir -p build && pixi run typst compile --font-path fonts --root . tests/backmatter.typ build/backmatter.pdf 2>&1 | tee build/backmatter.log
test ! -s build/backmatter.log && echo "CLEAN: no warnings"
```
Expected: `CLEAN: no warnings` (empty log). Any warning text is a failure — resolve before committing.

- [ ] **Step 6: Commit**

```bash
git add tests/backmatter.typ
git commit -m "test(p5): integration — numeric cites + appendices + full-author bibliography"
```

---

## Self-Review

**Spec coverage (every Verification item in the spec):**
- Numeric in-text citations `[n]` → Task 1 CSL `<citation>`; asserted Task 1 Step 6, Task 4 Step 3 line 4. ✓
- Custom CSL with `et-al-min` lifted; >6-author entry prints all authors; **no "et al."** → Task 1 CSL + 8-author `octuple2023`; keystone asserted Task 1 Step 5, regression Task 2 Step 4, final Task 4 Step 3 line 1. ✓
- Bibliography single-spaced within entries + full blank line between → Task 2 `backmatter-rules` (`leading`/`spacing`), confirmed Task 2 Step 5. ✓
- Bibliography is the last element → enforced by source order in `tests/backmatter.typ`; checked Task 4 Step 4. ✓
- Reference-matter order documented (Appendices → Addenda → Chronology → Endnotes → Glossary → Bibliography) → header comment in `lib/backmatter.typ` (Task 2 Step 1); ordering of the two implemented kinds (appendices before bibliography) verified Task 4 Step 4. ✓
- Appendices may be single-spaced → `appendix` wraps body in `single-spaced` (Task 3); confirmed Task 3 Step 5. ✓
- `#appendix(title, body)` auto-lettered A/B/C → `counter("p5-appendix")` + `numbering("A", …)` (Task 3); asserted Task 3 Step 4 and Task 4 Step 1/Step 3 lines 5–6. ✓
- Zero-warning compile → Task 4 Step 5. ✓
- Counter-collision risk → dedicated `counter("p5-appendix")`, distinct from page/chapter counters (Task 3 Step 1 comment). ✓
- Between-entry selector risk → handled via `par(spacing)` with an empirical calibration step and a documented `bibliography.entry` fallback (Task 2). ✓

**Placeholder scan:** No `<numeric>` or TODO placeholders remain. The CSL file is named concretely (`styles/ieee-full-authors.csl`) and given in full. The one empirically-tuned value, `bib-entry-gap = 1.3em`, has a starting value, a calibration step (Task 2 Step 5), and a record-the-final-value instruction — it is a measured output, not a placeholder.

**Name / type consistency:** `backmatter-rules(body)` and `appendix(title, body)` are defined in `lib/backmatter.typ` and imported under those exact names in `tests/backmatter.typ`. `single-spaced` is imported from `lib/blocks.typ` (matches P0's export). `bib-leading`/`bib-entry-gap`/`appendix-counter` are module-local. The CSL path string `"styles/ieee-full-authors.csl"` matches the created file and resolves under `--root .`. Bib keys (`octuple2023`, `taocp2020`, `wc1953`) match between `references.bib` and the `@`-citations in the test.

**Parallel-safety:** Created files only — `lib/backmatter.typ`, `styles/ieee-full-authors.csl`, `references.bib`, `tests/backmatter.typ`. No edits to `lib/template.typ`, `lib/blocks.typ`, `pixi.toml`, `tests/smoke.typ`, or `docs/compliance-checklist.md`. No pixi task added; all compiles call `pixi run typst compile …` directly. Helpers applied via `#show` in the test file, not in `dissertation()`.

---

## Note for P6 — `[P5]` checklist rows this phase satisfies

Checklist check-off is **out of scope** here (P6 owns `docs/compliance-checklist.md`). After P5 merges, P6 may tick these `[P5]` rows in `## Back matter (§III p.43)`:

- Reference-matter order: Appendices → Addenda → Chronology → Endnotes → Glossary → Bibliography — **documented** in `lib/backmatter.typ`; appendices-before-bibliography verified (Task 4 Step 4). (Addenda/chronology/endnotes/glossary content helpers are non-goals — order is documented, not coded.)
- Appendices may be single-spaced — satisfied (`#appendix` → `single-spaced`).
- Bibliography single-spaced with a double space between entries — satisfied (`backmatter-rules`).
- Bibliography is the last entry in the manuscript — satisfied (source order; verified).
- Non-primary authors not depersonalized as "et al." in the bibliography — satisfied (custom CSL; keystone test = 0).
- Consistent citation/reference style throughout — satisfied (single numeric CSL used for both citations and bibliography).
- Also supports `## Margins & spacing` row "Survey instruments / reproduced research materials in appendix may be single-spaced [P5]" — satisfied by `#appendix`'s single-spaced body.
