# Spec: Phase 5 — Back Matter

**Date:** 2026-06-26
**Roadmap:** `docs/roadmaps/2026-06-26-ucsd-thesis-typst-roadmap.md` (Phase 5)
**Status:** Approved design; ready for `writing-plans`.
**Depends on:** P0.

## Goal

Implement the back matter: a numeric-style bibliography that is single-spaced within
entries with a double space between entries and lists **every** author in full (no
"et al."), single-spaced appendices with letter numbering, and the reference-matter
ordering the manual mandates. After this phase the document's tail is compliant.

Output: `lib/backmatter.typ`, a custom CSL under `styles/`, a sample `references.bib`,
and `tests/backmatter.typ` — compiling with zero warnings and showing a multi-author
entry spelled out in full.

## Authoritative rules (from `formattingmanual.pdf`, §III p.43)

| Rule | Manual ref |
|---|---|
| Reference-matter order: Appendices → Addenda → Chronology → Endnotes → Glossary → Bibliography/References/Works Cited | p.43 |
| Appendices **may** be single-spaced | p.43 |
| Bibliography **single-spaced within entries**, **double space between entries** | p.43 |
| Bibliography is the **last** entry in each chapter or in the manuscript | p.43 |
| Non-primary authors **not** depersonalized as "et al." in the bibliography | p.43 |
| Consistent citation/reference style throughout | p.43 |

The manual prescribes **consistency**, not a specific style — the author chooses.

## Decisions (locked)

1. **Numeric in-text citations** (`[1]`, `[2]`), references listed in order. Chosen for
   a computational-biology dissertation; keeps body text uncluttered.
2. **"No et al." → ship a custom CSL.** No stock CSL/Typst style spells out every
   author; a numeric base CSL is committed under `styles/` with the et-al threshold
   lifted (`et-al-min` set above any realistic author count, e.g. 99) so full author
   lists always render in the bibliography. The in-text numeric form is unaffected.
   The manual's "no et al." rule applies to the **bibliography**, so this fully
   satisfies it.
3. **Bibliography spacing via show rules**, not body spacing: `show bibliography: set
   par(leading: 0.65em, spacing: 0.65em)` for single-spaced entries, plus a rule that
   inserts a full blank line (`v`) between entries. Verified empirically because the
   exact selector for "between entries" depends on the Typst version.
4. **`#appendix(title, body)` — auto-lettered, single-spaced.** A counter yields
   Appendix A, B, C…; the body is wrapped in P0's `single-spaced` (permitted by the
   manual). Heading style is consistent with the chapter heading family.
5. **Reference-matter ordering is the author's responsibility, documented.** The
   `#back-matter()` marker (P1) precedes this section; source-file order determines the
   sequence. A header comment in `lib/backmatter.typ` records the mandated order. No
   programmatic reordering (deferred to P6 assembly if needed).
6. **New files only.** Bibliography/appendix helpers are exposed as functions + an
   applicable `#show: backmatter-rules` bundle; `lib/template.typ` is untouched, so
   P1/P3/P5 stay parallelizable.

## Architecture

```
lib/
  backmatter.typ      # backmatter-rules bundle; bib spacing; #appendix(); order doc
styles/
  <numeric>-full-authors.csl   # numeric CSL, et-al-min lifted to force full lists
references.bib          # sample entries incl. one >6-author work for verification
tests/
  backmatter.typ        # an appendix + a bibliography with a multi-author entry
```

### `lib/backmatter.typ`

Exposes:

- **`backmatter-rules(body)`** — `#show: backmatter-rules` installing:
  - `show bibliography: set par(leading: 0.65em, spacing: 0.65em)` — single-spaced.
  - a between-entries blank line (selector verified against the Typst version).
- **`#appendix(title, body)`** — increments an appendix-letter counter, renders an
  `APPENDIX A` heading (consistent with the chapter heading family), wraps `body` in
  `single-spaced`.
- A header comment recording the reference-matter order.
- The bibliography itself is called by the author:
  `#bibliography("references.bib", style: "styles/<numeric>-full-authors.csl")`.

### `styles/<numeric>-full-authors.csl`

A numeric CSL (e.g. an IEEE/Vancouver/Nature numeric base) modified so that
`et-al-min` / `et-al-use-first` never trigger abbreviation — every author is printed.
Committed in-repo so output is reproducible and offline. The README documents the one
edit made relative to the base style.

## Non-goals (deferred)

- Addenda / chronology / endnotes / glossary *content* helpers — only the bibliography
  and appendices are built; the ordering for the rest is documented, not coded.
- Per-chapter bibliographies → noted as possible; manuscript-level bibliography is the
  P5 default. Refine in P6 if the real content uses end-of-chapter references.
- Final assembly/ordering enforcement → **P6**.

## Verification

P5 is complete when:

1. `tests/backmatter.typ` compiles with **zero warnings**.
2. The bibliography renders **single-spaced within entries** with a **full blank line
   between entries** (measured).
3. A reference with **more than six authors** lists **all** of them — no "et al."
   anywhere in the bibliography.
4. In-text citations render as numeric `[n]`.
5. `#appendix(...)` renders `APPENDIX A`, `APPENDIX B`, … and its body is single-spaced.
6. These `compliance-checklist.md` **[P5]** rows are satisfied (checked off in P6):
   reference-matter order; appendices may be single-spaced; bibliography single-spaced
   with double space between entries; bibliography last; no "et al."; consistent style;
   survey/appendix single-spacing.

## Open risks

- **Between-entries selector:** the exact Typst mechanism for spacing *between*
  bibliography entries (vs. within) varies by version; verify the chosen rule produces
  one blank line, not doubled leading inside entries.
- **CSL "et al." suppression:** confirm the edited CSL actually prints all authors for a
  >6-author entry in this Typst version — Typst's CSL engine must honor the lifted
  `et-al-min`. The sample `.bib` entry is the test vector. If the engine still
  abbreviates, escalate (alternative base style or a documented exception) before P6.
- **Numbering-prefix collision:** ensure the appendix-letter counter does not interfere
  with P3's chapter counter or P1's page counter.
