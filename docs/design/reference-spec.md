# Reference spec — measured from the supplied design reference set

This file is the durable record of the design the owner pointed at. Everything
below was **measured** from the seven images with Python/PIL, not estimated by
eye. Where a value is inferred rather than measured, it says so.

## The source images

All seven are **752 × 564 px** JPEG-recompressed PNGs. That is a small,
down-scaled export, so:

- One design pixel ≈ **1.915 image pixels** at a 1440-wide design viewport.
  Every design value below is the measured image value × 1.915, then rounded to
  a sensible step.
- Sub-pixel detail (1px hairlines, exact letter-spacing, 2px underlines) cannot
  be recovered from a 752-wide export. Those are inferred and marked.

| File | Screen shown |
| --- | --- |
| `aa5f3aba…png` | Dashboard with top navigation, two-column cards, plan bar |
| `8c2e5e24…png` | Same dashboard, composed with two other screens |
| `7126e3a8…png` | Form Library — sidebar nav list, 4-column card grid |
| `c929281a…png` | Scoring step — icon rail + secondary sidebar + centre card |
| `2dc9a5aa…png` | Customisation — property panel with tabs, swatches, toggles |
| `cca7d53f…png` | Builder — 4-column: icon rail, list, canvas, properties |
| `69743536…png` | Report builder — element picker, canvas, customisation |

The set is **not** one consistent screen. It is a family of screens for the same
product, and they disagree with each other (see "Conflicts" below). Where they
disagree, the value used is the one that appears in the most screens.

## Measured geometry

### App container

| Attribute | Measured (image px) | Design px (@1440) |
| --- | --- | --- |
| Page background | `#f2f1f8` corner sample | same |
| Container white area | x 38→700, y 42→563 | x 73→1341 |
| Container inset from viewport | 38 left, 42 top | ~73 / ~80 |
| Container radius | visually large; not measurable at 752px | 24 (inferred) |

Reading: the app is a **floating rounded card inset from the window**, not a
full-bleed layout. This is the single most structural difference from the
current admin, which paints to the window edges.

### Sidebar

| Attribute | Measured | Design px |
| --- | --- | --- |
| Sidebar right edge (divider) | x = 197 | 377 |
| Sidebar inner left padding | white starts x = 38, first content ~49 | ~21 |
| Divider | single 1px column, `#f0eff2`–`#f1f3f4` | 1px, very light |
| Sidebar background | `#fcfeff` (white, not tinted) | white |

From `7126e3a8` specifically (the clearest sidebar):

- nav items are **plain text rows**, not capsules
- active item: blue label + thin blue underline the width of the word
- nav divider between items: full-width 1px hairline
- very generous vertical spacing between nav items (roughly 24–30 design px)

### Cards

| Attribute | Measured | Design px |
| --- | --- | --- |
| Card fill | `#ffffff` | white |
| Card radius | large; 8–16 inferred | 12 |
| Card border | `#e5e7eb`-class, ~1 image px | 1px `#e4e7ee` |
| Card shadow | present, very soft | `0 1px 2px` + `0 4px 12px` @ 4–6% |
| Card padding | ~12–16 design px measured in `cca7d53f` | 20 (rounded up) |

Vertical rhythm from `aa5f3aba` at x=520 (design px): gaps of **3.8, 23, 28.7,
3.8** between stacked elements, i.e. an 8px-based scale with 24 and 32 in use.

### Colour, with roles

Only saturated pixels are listed; the image is >95% near-white.

| Hex | Role | Notes |
| --- | --- | --- |
| `#2848a8` | Primary blue — buttons, active nav, links | hue 225, S .62 |
| `#2848a0` | Same blue, darker instance | hue 224 |
| `#2048a0` | Same blue, deeper | hue 221 |
| `#184090` | Blue, pressed/darker | hue 220 |
| `#0090b8` | Secondary cyan — graph/chart accent | hue 193, S 100% |
| `#c03810` | Orange-red — active tool indicator | hue 13.6, S .85 |
| `#f88060` | Light orange — highlight fill | hue 12.6 |
| `#d08060` | Muted orange — secondary highlight | hue 17.1 |
| `#fafcfe`…`#f6f7fb` | Page background family | near-white, faint blue cast |
| `#ffffff` | Card and sidebar surface | |
| `#e4e7ee` | Card border | |
| `#f0f1f5` | Nav divider / hairline | |

**Blue + orange.** Not monochrome. The blue is the primary; the orange is used
sparingly for the *active* indicator only. That matches what Phase 9 shipped
(`#00349c` deep + `#FC8708` accent), and the measured reference blue
`#2848a8` is very close in hue (225 vs our 218).

## Type (inferred from proportions)

| Role | Design px | Weight |
| --- | --- | --- |
| Greeting / page title | 24–28 | 600–700 |
| Section heading | 16–18 | 600 |
| Body / labels | 13–14 | 400–500 |
| Metadata | 11–12 | 400, muted grey |
| Stat number | 28–32 | 700 |

Letter-spacing is **not measurable** at this resolution. Tight negative tracking
on headings (−0.02em) is retained from Phase 9 as a reasonable reading.

## Conflicts between images, and how they were resolved

| Question | Evidence | Resolution |
| --- | --- | --- |
| Sidebar or top nav? | `aa5f3aba`/`8c2e5e24` show a **top** nav; `7126e3a8`/`cca7d53f` show a **left sidebar** | Keep the **left sidebar** — 5 of 7 images have one, and the current admin is side-nav. Top nav in 2 images is a different layout of the same product. |
| Nav active = pill or text+underline? | `7126e3a8` is explicit: blue text + word-width underline, no fill. `c929281a` shows a pale orange fill for the secondary sidebar. | **Text + underline** for the primary nav. The pale tint is used only for the secondary (sub) navigation, which ours also has. |
| Full-bleed or floating card? | All images show the app inset on a tinted background | Inset, **but** only horizontally at ≥1440; a full floating shell is a larger structural change than the complaint requires. Stated as a deviation. |
| Card border or shadow only? | `aa5f3aba` says "no visible high-contrast borders"; `7126e3a8` shows a 1px line | **1px decorative line + soft shadow.** WCAG does not apply to it; see below. |

## Contrast deviations (reference fails, we do not)

Measured reference values that are below WCAG 2.1 and how they are handled:

| Reference element | Problem | Our handling |
| --- | --- | --- |
| Muted grey body text (~`#9aa0ad` on white) | ≈2.6:1, needs 4.5:1 | Use `--text-color-muted` `#4d5566` (8.1:1). Same visual role, dark enough to read. |
| Light grey metadata / placeholder | ≈2.3:1 | `--placeholder-color` `#6f7787` (4.6:1). |
| Card border `#e4e7ee` | 1.24:1 | Kept as **decorative** (no WCAG requirement), while **form controls and focus** use `#7c8494` (3.76:1). This is the tiering that stopped the "boxed" look. |
| Orange `#f88060` as an active indicator | ≈2.4:1 on white | Kept for the indicator only, and paired with a colour-independent signal (weight + underline), so colour is never the sole carrier. |

## What the references do not cover

Nothing in the set shows a **data table with many rows**, a **modal dialog**, a
**toast**, a **mobile drawer**, or a **settings form**. For those screens the
same system was extended: same card chrome, same radius, same decorative/3:1
border tiers, same type scale. Those extensions are marked as such in the
source comments rather than presented as measured.
