# Note Canvas Test

This note exercises everything the theme currently styles. Read it in both
Live Preview and Reading view (`Ctrl+E` toggles), and in both light and dark
(`Ctrl+P` → "Toggle light/dark mode").

The paragraph you are reading is body copy at line-height 1.75. It should sit
on near-white paper that is a touch lighter than the sidebars around it, in a
column that stops well short of the window edge.

## What to look for

This is an h2. Two things mark it: the hairline rule underneath, and the fact
that it **hangs one rem to the left** of this paragraph. That outdent is the
canvas's signature move — check that the "W" above is left of the "T" here.

### This is an h3

It also hangs into the gutter, but has no rule. The h2 rule alone marks the
major section break.

#### This is an h4

An h4 sits flush in the text column and is *slightly smaller* than body text —
that is deliberate. It leans on weight (550) rather than size, and the outdent
of h3 above is what separates them.

##### This is an h5

Smallest step in a deliberately flat ramp.

## Inline type

Body text with **bold at weight 600**, *italic*, ~~strikethrough in muted
grey~~, `inline code on a tinted ground`, ==a yellow highlight==, an
[internal link](#), and an [external link](https://obsidian.md).

In dark mode the highlight stays a light paper-yellow with dark ink, the way
it would print — check that the highlighted text above is still readable.

## Lists

- First item at 1.5rem indent
- Second item, with 0.5em between siblings
    - Nested item
    - Another nested item
- Third item

1. Ordered lists use the same rhythm
2. Second
3. Third

- [ ] An unchecked task
- [x] A completed task

## Blockquote

> A blockquote carries a three-pixel rule in the accent colour — lime in
> light mode, a softer Gruvbox yellow-green in dark — with muted italic text.
>
> A second paragraph inside the same quote.

## Code

Inline `const x = 1` against a paragraph, then a fenced block:

```python
def canvas(width: int = 50) -> str:
    """Code should be monospace on a tinted ground."""
    return "paper" * width
```

## Table

| Token | Light | Dark |
| --- | --- | --- |
| background-primary | stone-50 | gb-dark-soft |
| text-normal | stone-600 | gb-light4 |
| accent | lime-750 | gb-bright-aqua |

## Rule

Above the rule.

---

Below the rule.

## Heading adjacency

Spacing above a heading should not double up when headings follow each other
directly:

## Two h2s in a row
### An h3 directly under an h2
#### And an h4 directly under that

Back to body text, which should clear the h4 above by 1.25rem.
