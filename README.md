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

## Line spacing

Body text is double-spaced as clean typographic 2.0×: the line leading is the
native single advance plus one native leading, calibrated via `pixi run calibrate`.
Recorded value: `body-leading = 2.029em` (TeX Gyre Heros, 12pt; native single advance 16.55pt, ratio 2.0×).
Single-spacing carve-outs (footnotes, long quotes, and later captions/bibliography)
use Typst's native single leading (0.65em).
