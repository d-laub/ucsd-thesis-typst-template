# UCSD Doctoral Dissertation — Typst Template

Typst template for a UC San Diego doctoral dissertation (non-joint PhD),
adapted from the 2025–2026 Preparation and Submission Manual.

## Build

    pixi run build        # compiles tests/smoke.typ -> build/smoke.pdf
    pixi run example      # compiles the generic feature-demo -> build/example.pdf
    pixi run thesis       # compiles your thesis.typ -> build/thesis.pdf
    pixi run calibrate    # prints the line-spacing calibration metadata
    pixi run fonts        # lists fonts discoverable under fonts/

Requires only `pixi`; it pins Typst and the vendored TeX Gyre Heros font, so
output is identical on any machine.

## Fonts

TeX Gyre Heros (a free Helvetica/Arial metric clone) is vendored under `fonts/`
and used via `--font-path fonts`. No font substitution was needed.

## Citation style

Two styles ship under `styles/`. Pick one in the `#bibliography` call at the end
of your `thesis.typ`:

    #bibliography("references.bib", style: "styles/nature-full-authors.csl")

**`ieee-full-authors.csl`** (default) — bracketed numbers.

> The result replicates.\[1] … `[1] J. Watson and F. Crick, "Molecular Structure of Nucleic Acids," Nature, 1953.`

**`nature-full-authors.csl`** — Nature journal style: superscript numbers in
text, and Nature's reference format (surname + initials, `&` before the last
author, sentence-case title, italic abbreviated journal, **bold** volume, page
range, year in parentheses).

> The result replicates.¹ … `1. Watson, J. & Crick, F. Molecular Structure of Nucleic Acids. Nature 171, 737–738 (1953).`

Adjacent citations comma-join (`²,³`) and runs collapse to a range (`¹⁻³`). With
the superscript style the marker goes **after** terminal punctuation, so write it
with no space:

    The result replicates.@wc1953        // renders: The result replicates.¹

Use exactly one style throughout — the manual requires a consistent citation and
reference style.

Both styles print **every** author. The manual forbids depersonalizing
non-primary authors as "et al.", so author-list truncation is removed outright
rather than capped at a high number: a numeric cap still silently drops authors
on a large-consortium paper. `nature-full-authors.csl` therefore differs from
stock Nature, which truncates from six authors on.

## Line spacing

Body text is double-spaced as clean typographic 2.0×: the line leading is the
native single advance plus one native leading, calibrated via `pixi run calibrate`.
Recorded value: `body-leading = 2.029em` (TeX Gyre Heros, 12pt; native single advance 16.55pt, ratio 2.0×).
Single-spacing carve-outs (footnotes, long quotes, and later captions/bibliography)
use Typst's native single leading (0.65em).
