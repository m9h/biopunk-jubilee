# Closing the Verification Gap

A concrete proposal to integrate **Tandem**'s physical–digital assertion model into
**science-jubilee**, so that Jubilee-derived laboratory machines (DuckBot, FungiBot, the
Sonication Station) can detect their own failures instead of silently propagating them into
data.

Built with [`research-infra`](https://github.com/) — content lives in frontmatter-tagged
Markdown under `content/`, and is assembled into both a LaTeX article and a Beamer deck.

## The argument in one paragraph

Jubilee's machines are not meaningfully limited by their *motion*. They are limited by their
inability to *observe their own state*: there is no motion-completion handshake, no tool-seating
verification, no liquid-level detection, and no way to assert that the physical world matches
the program's model of it. Every resulting failure is therefore silent — and a silent failure in
a ten-day assay does not halt the experiment, it contaminates it. The Machine Agency already
published the fix (Tandem, CHI 2024) and pointed it at a milling machine instead of at its own
laboratory robots.

## Build

Requires `pandoc`, `xelatex`, and the `metropolis` Beamer theme.

```bash
make            # both PDFs
make manuscript # manuscript/output/jubilee-tandem.pdf         (25 pp)
make slides     # manuscript/output/jubilee-tandem_slides.pdf  (20 frames)
make check      # verify: no unresolved citations, no missing glyphs, no frame overflow
```

## Layout

```
content/            # the source of truth — frontmatter-tagged Markdown
  00-abstract.md
  10-introduction.md          The silent failure
  20-background-3dp-lineage.md        History of 3D printing → Jubilee
  21-background-liquid-handling.md    Hamilton, Opentrons, PyLabRobot, the physics
  22-background-science-jubilee.md    The platform and its machines
  23-background-tandem.md             The answer already written
  30-method-architecture.md           Three layers + the Sensor Rule
  31-method-sensors.md                The three sensors that make assertions bite
  32-method-workpackages.md           WP0–WP5
  40-results-measurement.md           The measurements the field is missing
  50-discussion.md                    Roads not taken, and why
  60-conclusion.md
  90-appendix-evidence.md             Evidence grade for every load-bearing number
  91-appendix-bom.md                  BOM + firmware checklist
manuscript/
  config.yaml       # research-infra ProjectConfig
  references.bib
  output/           # generated
```

Each file's YAML frontmatter carries `section` and `weight` (which set assembly order) and a
`slide_summary` (which becomes the Beamer frame). The appendices deliberately carry no
`slide_summary`, so they appear in the article but not the deck.

## Conventions

- **Every quantitative claim is graded** in `content/90-appendix-evidence.md`: measured `[M]`,
  claimed `[C]`, no-data `[N]`, or derived `[D]`. Where a number does not exist in the
  literature, the absence *is* the finding.
- Claims we could not substantiate are listed explicitly and **not made**.
- Two pandoc gotchas this document has already hit, recorded so you don't rediscover them:
  an inline `$math$` whose closing `$` is immediately followed by a digit is **not** parsed as
  math (write `$\approx$ 390`, not `$\approx$390`); and Unicode `≈ ≥ ≤ ₂` have no glyph in the
  default XeLaTeX text font — use LaTeX math instead.
