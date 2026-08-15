# Matcha

An Obsidian theme ported from the note canvas in
[Kosmos](https://github.com/Kosmos-Law/kosmos) — a paper-page reading surface
with a deliberately flat heading ramp, where hierarchy is carried by headings
hanging into the gutter rather than by size alone.

Light is a neutral gray and lime palette; dark is Gruvbox, a warm
Hojicha-inspired ramp whose accent shifts from cool lime to a softer
yellow-green.

## Install

**From this repo, into every local vault at once:**

```sh
./publish.sh --activate
```

That symlinks `theme.css` and `manifest.json` into
`<vault>/.obsidian/themes/Matcha/` for each vault under `~/Obsidian`, so
editing this repo updates every vault with no republish step. See
`./publish.sh --help` for `--copy` (for synced vaults), `--dry-run`, and
`--vaults DIR`.

**Manually:** copy `theme.css` and `manifest.json` into
`<vault>/.obsidian/themes/Matcha/`, then Settings → Appearance → Themes.

## Font

Nothing to install, on any device. The theme sets **Inter**, which Obsidian
bundles inside the app as one variable face spanning `font-weight: 100 900`.

That matters because the heading ramp is carried by weight as much as by size:
h2 and h3 sit at 500 and h4 at 550, a half-step that only a variable font can
render. Kosmos gets this by serving Noto Sans from Google Fonts, which returns
the variable build. A *locally installed* Noto Sans generally cannot — Debian's
`fonts-noto-core`, for instance, ships only Regular and Bold, so 500 collapses
to 400 and 550 rounds up to 700, leaving h4 heavier than the h2 above it.

So this is a deliberate substitution: Inter for Noto Sans, to keep Kosmos's
actual weights working everywhere rather than degrade the ramp to 400/700.

Code blocks prefer JetBrains Mono and fall back to Source Code Pro, which
Obsidian also bundles.

Kosmos draws its canvas at `1.1rem`. Heading sizes here are `em`-based so they
track Obsidian's own font-size setting, which means **Settings → Appearance →
Font size: 17 or 18** reproduces the original proportions most closely.

## Requirements

Obsidian 1.5.0 or later. Colours are kept in OKLCH exactly as authored in
Kosmos, so the two codebases stay diffable, and OKLCH needs a recent Chromium.

## Status

Stage 1 covers the palette, semantic tokens, canvas metrics, the heading ramp,
and the note title. Code blocks, tables, lists, and blockquotes currently fall
through to Obsidian's defaults, which derive from the tokens set here. Porting
those explicitly is the next step.

## Provenance

Ported from these files in Kosmos:

| Kosmos | provides |
| --- | --- |
| `static/css/palette.css` | palette tokens |
| `static/css/colors.css` | semantic tokens, light and dark |
| `static/css/apps/notes.css` | the canvas / paper page |
| `static/css/apps/notes-editor.css` | prose inside the canvas |

Kosmos is AGPL-3.0. This theme is MIT — see `LICENSE`. That relicensing is the
author's to make as the copyright holder of the ported CSS; if the Kosmos
styles have other contributors, revisit it before publishing.
