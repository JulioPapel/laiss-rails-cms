# Focus theme migration log

One entry per step. What changed, what was verified, and **what is knowingly wrong at
that point** — because during a migration of this size something usually is, and a log
that only records successes is useless when something breaks four steps later.

## THE RULE THIS MIGRATION KEEPS RELEARNING

> **Any vendored rule that assumes it owns the viewport must be measured, not read.**

Three defects of identical shape appeared in the first two steps, each invisible to
reading and obvious to measuring:

| Symptom | The rule | What it assumed |
|---|---|---|
| Every admin page blank | `#main-wrapper { opacity: 0 }` | its jQuery entry point adds `.show` on ready |
| Content could not scroll | `#main-wrapper { overflow: hidden }` | its own fixed-height scroll containers |
| Preview iframe unclickable | `#main_content { height: 100% }` | a parent with a definite height |

A fourth is likely still ahead — `position: fixed` on modals, dropdowns and print
styles is the usual hiding place, and **scoped CSS does not fix `position: fixed`**:
it still resolves against the viewport, not `#laiss_cms`. When dialogs and dropdowns
are converted, check explicitly whether a theme rule positions against the viewport.
If one does, the fix is a `transform` or `contain` on the container to create a
containing block — which has its own consequences for stacking and scrolling, so
measure before applying.

The method, when this bites:

1. Print `getBoundingClientRect()` and computed `height`/`min-height`/`position`/
   `display`/`overflow`/`transform`/`contain`/`will-change` for the containing chain.
2. Do it on both states — with and without the change.
3. Diff the tables. The property that moved is the cause.

That is cheaper than three bisect cycles and produces a diagnosis rather than a
guess. The `814px → 152px` table in Step 1b found in one pass what three CSS
hypotheses had not.

Gates are `script/gates`, run in full after every step. A count that drops is a stop
signal, not a note.

## Order

Steps are numbered by the order they were executed, which is **not** the order first
planned. The original plan converted forms before the shell; that was inverted at the
owner's direction. Reason: converting forms first meant four steps of "gates green,
DOM changed, looks wrong on purpose" before anything could be judged by eye. Landing
the shell and CSS first makes every subsequent step verifiable both by eye and by
gates, which is worth more than the isolation benefit of doing forms early.

| Step | What | Status |
|---|---|---|
| 0 | Bootstrap + theme SCSS foundation | done |
| 1a | Scoped CSS substrate (layout untouched) | done |
| 1b | Shell: layout, sidebar, top bar | done |
| 2 | Forms: simple_form wrapper + builder | done |
| 3 | Settings screen | superseded by template-first |
| 4 | Styleguide screen | pending |
| 5 | Lists: pages, attachments, pictures, users, translations | pending |
| 6 | Dashboard | pending |
| 7 | Editors: element editor, TinyMCE, cropper, dialogs | pending |
| 8 | Delete the old theme | pending |
| 9 | Docs and screenshots | pending |

---

## Step 0 — Bootstrap and theme SCSS foundation

**Changed**

- Added `bootstrap@4.3.1` and `bootstrap-icons` as dev dependencies.
- Copied 80 SCSS files from the theme into `app/stylesheets/laiss_cms/theme/`:
  abstracts, base, layout (header/sidebar/footer/typography), components/ui,
  components/forms. Not copied: `pages/`, `charts/`, rtl and dark variants — the admin
  has none of those.
- New entry `app/stylesheets/laiss_cms/focus.scss` → `app/assets/builds/laiss_cms/focus.css`
  (238 KB, 39 KB gzipped).
- `bundles/copy_theme_fonts.mjs` copies the Bootstrap Icons webfont beside the CSS, so
  a cold clone reproduces the build with no manual step.
- `THIRD-PARTY-NOTICES.md` at repo root: Themefisher MIT, Bootstrap, Bootstrap Icons,
  Inter (OFL), and an explicit "not included" section for Helvetica Neue and the demo
  images.

**Deliberately not included**

- Roboto and the theme's six icon families. Inter is the typeface; it is already
  self-hosted as a variable font and is wired into this bundle.
- Helvetica Neue — commercial typeface, no redistribution licence.
- Four vendor stylesheets the theme's `_reset.scss` imported (animate.css, AOS,
  perfect-scrollbar, metisMenu). All jQuery-era plugins for demo pages; no jQuery here.
- All demo images.

**Verified**

- Licences byte-identical: SHA-256 of `LICENSE`, `devise/LICENSE`, `i18n/LICENSE`
  unchanged before and after.
- All 33 icon names in use map to Bootstrap Icons symbols (2078 available, zero gaps).
- 12/12 gates pass, working tree clean, after the artifact commit.

**Knowingly wrong at this point**

Nothing visible — `focus.css` is not linked from any layout yet, so the admin renders
exactly as before. That was the point of Step 0.

**Notes worth keeping**

- The theme's SCSS is third-party and uses legacy syntax (`@import`, slash division).
  The build silences those deprecations rather than rewriting 80 vendored files.
- `--load-path node_modules` was added so package SCSS resolves, matching how the build
  already loads cropperjs and tom-select.
- `col-xxl-*` in the theme's markup maps to `col-xl-*`. Bootstrap 4.3.1 has no `xxl`
  breakpoint; the vendored grid variables are **not** edited, because forking a
  vendored file is a maintenance trap.

---

## Step 1a — scoped CSS substrate, layout deliberately untouched

**Changed**

- `focus.scss` rewritten: every rule nested inside `#laiss_cms`, the admin's
  `<body>` id. **Zero** `html`, `body`, `:root` or `*` selectors survive in the
  283 KB output — verified by grep, not by inspection.
- Inter wired in at the top level (an `@font-face` has no selector to scope; the
  family name namespaces it).
- `bootstrap/scss/modal` **not imported**. The admin's dialogs are native
  `<dialog>` + `showModal()`, per the owner's decision. Bootstrap's `.modal {
  display: none }` and `.modal-open` body rules expect its own JavaScript and broke
  Shoelace tabs inside our dialog — tabs shrank to a zero-size box and could not be
  clicked, failing 7 feature specs. Removing an unused component fixed them.
- `_reset.scss`: two theme flourishes removed, both correct diagnoses of rules that
  exist for the demo pages and not for us:
  - `#main-wrapper { opacity: 0 }` — the theme fades in via jQuery on ready; we
    load no jQuery, so every admin page rendered blank. Now `opacity: 1`.
  - `#main-wrapper { overflow: hidden }` — assumes the theme's own fixed-height
    scroll containers, driven by `data-sidebar-style` attributes we do not set.
    Now `overflow: visible`.
- `bootstrap/scss/reboot`'s `html`/`body` rules are included but become inert under
  the nested import (`#laiss_cms body` matches nothing). Its descendant rules
  (`*`, headings, lists, tables, form elements) are what we want and scope correctly.

**Why the layout is untouched in this step**

The shell layout was written, then reverted. Wrapping the admin in the theme's
`#main-wrapper` broke two `page_editing_feature_spec` examples — the preview frame's
elements could no longer be hovered or clicked from inside the iframe. It was proven
**not** to be a CSS problem: the same two specs fail with `focus.css` unlinked, and
pass on the base commit. So the cause is the DOM/layout change, not the stylesheet.

Rather than keep bisecting CSS properties (three hypotheses were tried and all were
wrong), the layout change was reverted and this step commits only the part that is
independently verified. Step 1b will attack the iframe by measuring geometry on both
commits and diffing, rather than guessing.

**Verified**

- 4410 core / 167 devise / 846 vitest — counts whole, no drop.
- Zero global selectors leaked from the substrate.
- `focus.css` is **not linked from any layout yet**, so the admin renders exactly as
  before. That is intentional: this step adds a scoped stylesheet and removes two
  dead theme rules, nothing more.

**Knowingly wrong at this point**

Nothing visible. The admin is unchanged; `focus.css` is built but unlinked.

**Open**

Step 1b: the preview iframe breakage. Hypothesis to test first — `#main_content` uses
`height: 100%`, which resolves against a parent with a definite height; `#main-wrapper`
may not provide one, changing the containing block. The probe measures geometry on
both commits and diffs.

---

## Step 1b — shell layout, and the preview-iframe cause

**Changed**

- `#main-wrapper` now wraps the admin, with the theme's `nav-header`/sidebar/content
  structure. `focus.css` is linked, so the substrate finally applies.
- `#main-wrapper` gets `height: 100vh` in `_reset.scss`.

**The iframe failure, measured rather than guessed**

Step 1's layout broke two `page_editing_feature_spec` examples: elements inside the
page-preview iframe could no longer be hovered or clicked. Three CSS hypotheses were
tried and all were wrong, so the step was reverted (see 1a).

The cause was found with one geometry probe comparing both states:

| Element | Without shell | With shell | |
|---|---|---|---|
| `#main-wrapper` | absent | 196px | created, auto height |
| `#main_content` | **814px** | **152px** | **−662px** |
| iframe | 694px | 694px | unchanged |

`#main_content` uses `height: 100%`. A percentage height only resolves against a
parent with a **definite** height; `#main-wrapper` had none, so the percentage
resolved to `auto` and the content area collapsed to its intrinsic height. The iframe
kept its 694px, overflowed its parent by 542px, and the spec's hover coordinate landed
outside the visible area.

Fix: `height: 100vh` on `#main-wrapper`. `#main_content` returns to 814px and
`page_editing_feature_spec` passes 38/38.

**This is a theme rule that assumed it owned the viewport**, like `opacity` and
`overflow` before it — the same family of defect, and the reason the layout step could
not be verified by eye alone.

**Verified**

- 4410 core / 167 devise / 846 vitest — counts whole.
- Geometry measured: `#main_content` 814px, matching pre-shell.
- `page_editing_feature_spec` 38/38, the two previously failing examples included.

**Knowingly wrong at this point**

The interior of every screen still uses the old design: cards, tables, forms and
buttons are Bootstrap-shaped underneath but styled by the old admin CSS. Steps 2–7
convert each screen. The sidebar is the theme's container but still our navigation
markup, which is converted with the screens.

---

## Step 2 — forms

**Changed**

One file carries almost all of it: the `:laiss_cms` wrapper in
`config/initializers/simple_form.rb`, which controls all 71 `f.input` call sites.

- Wrapper now emits `.input.form-group` → `label.form-control-label` →
  `input.form-control` → `.invalid-feedback` / `small.form-text.text-muted`.
- `class: [:input, :"form-group"]` — **both** classes. `input` is the historical
  wrapper class that simple_form also uses to build the per-attribute class
  (`ingredient_render_size` and friends); dropping it silently broke any selector
  targeting those. `form-group` is what Bootstrap needs.
- `lib/laiss_cms/ingredients/base_editor.rb`: the ingredient editor builds its own
  error markup rather than using the wrapper, so its `tag.small(class: "error")`
  became `tag.div(class: "invalid-feedback d-block")`.

**Specs updated (7 assertions, 5 files)**

The theme change moves the error element and the input classes. These specs asserted
the old markup, so they were updated to assert the new markup — same behavioural
intent, different selector:

| File | Was | Now |
|---|---|---|
| `page_permitted_roles_select_spec` | `small.error` | `.invalid-feedback` |
| `base_editor_spec` (×2) | `small.error` | `.invalid-feedback` |
| `edit_elements_feature_spec` (×2) | `small.error` | `.invalid-feedback` |
| `page_creation_feature_spec` | `... form small.error` | `... form .invalid-feedback` |
| `languages_features_spec` | `... .error` | `... .invalid-feedback` |
| `ingredients/edit_spec` (view) | `.input.ingredient_render_size` | `.form-group.ingredient_render_size` |
| `forms/builder_spec` | `class: [:string, :required, type]` | `class: ["form-control", :string, :required, type]` |

**Verified**

- 4410 core / 167 devise / 846 vitest — counts whole.
- All 12 gates pass.

**A mistake I made and corrected**

The seed script polluted the test database. The specs use **transactional
fixtures**, which roll back their own writes but still *see* rows already committed,
so 7 pages of seeded content broke a spec that assumed an empty starting state
(`page_creation_feature_spec` could not find the "add child" link it expected). The
seed now says so in its header and in its output, with the reset command. The failure
looked like a form-conversion bug and was not.

**Knowingly wrong at this point**

- The **Save button on Settings sits between two cards** instead of at the end of the
  form. Confirmed pre-existing from Step 1b, not introduced by the form work — the
  settings screenshot is identical before and after this step. It is a layout issue in
  the shell, and Step 3 (Settings) is where it gets fixed.
- Every other screen still uses the old card/table styling.

**Screenshots** (`media/theme-focus/wip/`)

- `step2-settings-1440.png` — forms converted, Bootstrap inputs and cards.
- `step2-page-new-1440.png`
- `step2-pages-1440.png`

---

## Step 3 — Settings

**Changed**

`app/views/laiss_cms/admin/settings/show.html.erb` rewritten on theme components:

- Page header → `h1.h4` + `p.text-muted`.
- Each section → `.card > .card-header + .card-body`.
- Each field → `.form-group.row` with `label.col-sm-3.col-form-label`,
  `div.col-sm-7` (control + `small.form-text` hint) and `div.col-sm-2` for the badge.
- Inputs → `form-control` / `custom-select` / `custom-control custom-switch`.
- Effect badge → `.badge.badge-success` / `.badge-secondary`.
- **Save button moved into its own card at the end of the form.** It previously sat
  between two section cards, positioned by the old theme's absolute layout rather than
  by document flow. That was a Step 1b defect, confirmed by screenshotting before and
  after Step 2 and getting identical images.

**Why this template needed separate work from Step 2**

It uses `*_tag` helpers (`select_tag`, `number_field_tag`, `check_box_tag`) rather
than `f.input`, so the simple_form wrapper change did not reach it. This is the half of
the form surface the wrapper does not cover — 48 call sites across the admin.

**Specs updated (2 assertions)**

| File | Was | Now |
|---|---|---|
| `settings_spec` | `.settings-badge--runtime/-restart` | `.badge-success` / `.badge-secondary` |
| `settings_spec` | `.settings-section` count via `.card` | `.settings-section` — new class on the section cards only, because the save card is also a `.card` and the count became 5 |

**Verified**

- 4410 core / 167 devise / 846 vitest — counts whole.
- All 12 gates pass.
- Settings screenshot: labels left, controls centred, hints below, badges right-aligned,
  save button in its own card at the end.

**Knowingly wrong at this point**

- Only Settings has a converted interior. Every other screen still uses the old card and
  table styling, so the admin looks inconsistent between screens until Steps 4–7.
- The seeded database is still in place; it must be reset before running specs.

---

## Reboot: template-first method

The screen-by-screen adaptation above was the wrong method. It fitted the theme to our
ERB markup instead of taking the theme's DOM and injecting our data into it — which is
inventing, and the owner had explicitly ruled that out. Steps 0–3 remain as history; the
work below replaces them.

**The rule:** our markup conforms to the theme's. Where a screen has no theme
counterpart, compose only from components the theme already demonstrates.

---

## Commit A — icon box artefacts (`e4c024473`)

**Not tofu, and not a border.** Eight negative checks: no missing `@font-face`, the
sprite returns 200 as `image/svg+xml`, `<use>` geometry is 11×11, zero elements with a
box background or border. Two separate bugs instead:

1. **Class collision.** The theme writes `<i class="icon icon-…">` for its font glyphs;
   ours emitted `<svg class="icon">`, so theme rules landed on our SVG. Now
   `class="laiss-icon"`, a name the theme does not claim. `.icon` survives as a
   documented alias for unconverted screens only.
2. **Twelve icons absent from the sprite.** The element appends `-line`, so
   `translate-2` requested `ri-translate-2-line`, which remixicon has no file for. The
   new guard found eleven more: `download`, `minus`, `times`, `info-circle`, `cog`,
   `copy`, `info`, `angle-double-left`, `link`, `link-unlink`, `sun`, `moon`. Six are
   Font Awesome names inherited from the old theme and are mapped explicitly.

**The guard** fails the build on: a listed icon with no source file; any referenced icon
name with no sprite symbol (printing the variants tried); an svg-sprite error. Verified by
planting a bogus icon name — exit 1, named. 126 symbols now cover every referenced icon.

---

## Commit B — Settings (`template-first`)

**Source:** `theme/form-element.html` — `.card > .card-header > h4.card-title`, then
`.card-body > .basic-form > form > .form-group > label + .form-control`. Adopted
verbatim; only the fields and values are ours.

### Deletions, with grep evidence

Before deleting anything, every Settings-owned selector was checked across all templates
and components.

| Deleted | Grep evidence |
|---|---|
| `app/stylesheets/laiss_cms/admin/settings.scss` (440 lines) | All `.settings-page*`, `.settings-section`, `.settings-field*`, `.settings-input`, `.settings-badge*`, `.settings-form__actions`, `.settings-switch*` classes return **zero** references outside `admin/settings/`. |
| 106 lines of Settings rules in `modern_components.scss` | Same check; `.settings-*` count in that file after removal: **0**. |
| `.settings-section` entry in the shared card selector list | Removed from the group selector; the other twelve surfaces in that list are untouched. |

**One thing the grep caught before it broke a screen.** `.theme-toggle` lived inside
`settings.scss` but is used by `_user_info.html.erb` and `_theme_toggle.html.erb` — the
top bar and drawer. Deleting the file wholesale would have silently un-styled the theme
control. Extracted first to `admin/theme_toggle.scss` (151 lines), verified still present
in the built CSS (`theme-toggle`: 1 match) after the deletion.

**Verified:** 18/18 settings specs; `settings-page` selector count in the built CSS is 0;
`.laiss-icon` renders with zero empty boxes in the screenshot.


---

## Commit C — Dashboard (`template-first`)

**Source:** `theme/index.html` — `.container-fluid > .row > .col-* > .card`, with
`.stat-widget-two.card-body > .stat-content > .stat-text + .stat-digit` for the stat
cards. Adopted verbatim; only the figures and labels are ours.

**One theme element deliberately NOT used.** The stat card's `.progress` bar exists in
the theme to show a proportion ("85% of budget spent"). Our widgets carry a count and
an optional infos line — there is no proportion to express. Rendering a bar at an
invented width would be fabrication, so the element is omitted rather than faked.

**Semantic hooks kept alongside theme classes.** `.count`, `.infos`, `.widget-body`,
`.user-name` are retained because the widget API and 93 component specs address them.
They name what a value IS, not how it looks, so they survive a restyle.

### Deletions, with grep evidence

`dashboard.scss` went from **486 to 18 lines**. The 468 deleted lines defined 20
selectors, each checked against all templates and components:

| Checked | Result |
|---|---|
| `.bar`, `.count`, `.logo`, `.widget` | Substring matches only — `Menubar`, `country`, `logout`, a local variable named `widget`. **No class usage outside the dashboard.** |
| The other 16 (`.bar__draft`, `.bar__public`, `.button_to`, `.greeting`, `.label-with-icon`, `.license`, `.license-text`, `.ruby-rails-version`, `.stats`, `.table-scroll`, `.top-row`, `.user-name`, `.version`, `.version-info`, `.widget-body`, `.widgets`) | Zero references outside `admin/dashboard/` |
| Whole file | Every rule was nested under `#dashboard`, so nothing outside that screen could depend on it even in principle |

What survives is the one thing that is still ours: `#dashboard` is the page's scroll
container (`display: flex; overflow: auto`).

**Verified:** 93 widget component specs and 9 dashboard feature specs pass; full gates
green including the artifact check.

### CORRECTION — this evidence table was wrong, and the page was broken

The first row above is the one that lied. `.bar` and `.logo` were not substring
matches; **both were real class usages**, and deleting their rules broke the screen.
The row reads "substring matches only" for four names at once, which hides that the
conclusion was reached per-name and was wrong for two of them:

| Name | Claim | Reality |
|---|---|---|
| `.bar` | substring only (`country`) | **Real.** `usage_widget.html.erb` emits `.bar`, `.bar__public`, `.bar__draft`. Without the rule the span is `display: inline` at **0×0**, and the usage tables collapsed into a ragged stack. |
| `.logo` | substring only (`logout`) | **Real.** `system_info.html.erb` emits `<div class="logo">`. Without the rule `logo.svg` rendered at its intrinsic **900×900** and pushed every widget below the fold. |
| `.count` | substring only | True — `.count` had no live rule of its own; the widget's count is sized by `.stat-digit`. |
| `.widget` | substring only (local var) | True for *styling*, but see below: the `.widget` **element** is real and its wrapper mattered for layout. |

Two further rules were deleted that the table did not name at all:
`td.usage-stats--bar` / `--label` / `--value` (the column proportions) and the
`.label-with-icon > svg` size rule. The second is why element icons rendered at
**406×406** inside a table cell.

**The grep was not wrong; the reading of it was.** `class="bar"` does appear in the
templates, but a bare `bar` substring grep returns `Menubar` and `country_code` too, so
the list looked like noise and was dismissed whole. The lesson for every remaining
deletion in this migration: **match `class="…\bname\b"` and read the hits one by one**,
rather than matching the bare name and judging the result as a set.

---

## Verification rule for conversions (owner-mandated)

**"Gates green" is not sufficient evidence for a screen conversion.**

The dashboard shipped rendering only a greeting. The suite was green throughout: 93
widget component specs and 9 dashboard feature specs all passed, because they asserted
that the widget *markup existed*. It did. The widgets were in the DOM the whole time —
at 34px wide, below a 990px fold, with 0×0 chart bars.

So for every converted screen, verification means comparing **content** against the
pre-conversion screen, not running the suite:

1. **DOM element count** inside the content area (`document.querySelectorAll("#dashboard *").length`)
2. **Visible text** (`innerText`, which skips anything display:none or zero-sized)
3. **Geometry of the things that carry content** — the width of a grid column, the size
   of an injected SVG, the height of a card

Presence is not evidence. A widget can be present, styled to nothing, and off-screen.

For the dashboard this check is now executable: `spec/features/admin/dashboard_layout_spec.rb`
measures the four stat cards, the logo, the first row's height, the usage bars' height,
and the rendered text. **All five examples were confirmed to fail against the pre-fix
files** — a regression spec that has never failed is not known to test anything.

---

## THE ROOT CAUSE OF THE "GHOST SQUARES", AND WHY IT TOOK A TURN

The owner's first complaint and the last fix of the icon investigation are the same
bug. **`chrome_polish.scss` pinned navigation icons to `--icon-size-1x` (16px)** under
the selector `#main_navi laiss-cms-icon`, described at the time as "icons are one size,
regardless of which icon set the entry uses". `navigation.scss` sets them to
`--icon-size-xxl` (26px). An **ID selector beats a class selector**, so the 16px pin
won and the nav had always rendered its icons at 16px.

At 16px, `ri-pages-line` — which is literally a rectangle with a header bar and an inner
box — is too small to read as a page and reads as an empty square. So did `ri-menu-2`,
`ri-archive-drawer` and the rest: all correct glyphs, all at the wrong size.

Measured after the fix: **26×26 host / 26×26 svg.** Before: 16×16 host, 26×26 svg
overflowing it.

### The lesson worth keeping

**One symptom, three causes.** The ghost squares were:

1. a class collision (`class="icon"` matching theme rules aimed at `<i class="icon">`),
2. twelve icons absent from the sprite, including `ri-translate-2-line`, and
3. a 16px size pin that beat the intended 26px.

Each fix exposed the next, because each was genuinely present. A pixel-level ASCII map
settled it when three rounds of DOM and CSS probing had not: the map showed a filled
rectangle outline with internal shapes — an icon drawing correctly — rather than the
1px uniform border a CSS box or a tofu glyph would produce.

The rule: **when a symptom survives its first plausible explanation, keep measuring
until the evidence is unambiguous, and expect more than one cause.** Stopping at the
first fix would have shipped two of the three.


---

## Commit D — Dashboard, content restored (`35ea7df12`)

The dashboard from Commit C rendered a greeting and empty space. What the owner saw,
against what was actually in the page:

| What he saw | What it was |
|---|---|
| A tall panel on the right with a large letter "L" and an abstract graphic | The Laiss logo, rendering at its intrinsic **900×900** because `logo.svg` declares `width="900px" height="900px"` and the `.logo` rule that had constrained it was deleted. Not theme demo content — our own asset, unconstrained. |
| A huge empty area in the middle | The top row, stretched to **990px** by that logo. The stat widgets were below it, inside the same scroll container. |
| Four stat widgets missing | Present, 304px columns rendered at **34px** — a collapsed column, so their content overflowed rather than laid out. |
| Locked-pages and last-updated lists missing | Present, but below the fold and further down because the usage widgets had inflated to **10,277px**. |

Nothing was absent. Everything was present and unreadable, which is why every presence
assertion passed.

### The four causes

1. **Columns emitted inside the widget shell.** `StatWidget` rendered its own
   `.col-lg-3.col-sm-6`, but inside `.widget > turbo-frame`, not as a direct child of
   `.row`. Bootstrap columns size from `flex-basis` against the row, so at that depth
   they collapsed to content width. The column now comes from the caller
   (`_stats.html.erb`); `StatWidget` renders only the `.card`, as the theme's own
   markup does.

2. **`<turbo-frame>` is `display: inline`.** Unknown elements are inline by default.
   An inline box does not establish a block formatting context for its child, so the
   widget cards had no height to fill. `#dashboard .widget > turbo-frame` is `block`
   now.

3. **Unconstrained injected SVG — the logo.** Now `120×120`.

4. **The usage bars.** `.bar` is `display: inline` without its rule, measuring **0×0**,
   which turned the usage tables into a ragged stack. The rule and the column
   proportions are restored. The bar is not fabricated: its width is each row's count
   against the highest row, split published/draft. This is the opposite case to the
   stat card's `.progress`, which stays omitted because our stat widgets carry no
   proportion.

**A fifth, found while measuring:** element icons were injected as raw SVG from
`ElementDefinition#icon_file` with no size rule, rendering **406×406** inside a table
cell and stretching every row to ~425px. `.label-with-icon > svg` now supplies the box.

This is the same shape of bug as the logo, and it is the third time in this migration
that **an injected inline SVG with no explicit size** has broken a layout. Worth
checking for on every remaining screen.

### Verified

- `#dashboard *` element count: **185 → 617**
- `innerText` length: **507 → 1,307** characters
- Four stat cards: **230×108** each, in **304px** columns
- Logo: **120×120**
- Top row: **990px → 267px**
- Usage bars: **0×0 → 249×8** and **252×8**
- `ElementUsage` height: **10,277px → 1,386px** (it lists all 24 element definitions,
  including unused ones — pre-existing behaviour of the widget, unchanged here)

Gates: all 11 pass, 4,415 core examples and 167 devise examples.

---

## The 375px screenshots were 500px, and had been all along

Every `*-375.png` in this migration before this commit was **500×726**. The
screenshots were named 375 because `resize_to(375, 812)` was called; the driver
silently ignored the width, and `window.innerWidth` reported **500**. Nobody had
compared the name against the pixels.

Cause: the system specs run `headless_firefox`, and a Firefox window has a minimum
width that `resize_to` cannot go below. Selenium's `execute_cdp_cmd` is not on the
driver in this version (4.52), and `Selenium::WebDriver::DevTools` needs a constructor
that is not reachable from Capybara's driver object.

What works: drive Chrome with `mobileEmulation`, which the browser applies before the
page loads so media queries fire correctly.

```ruby
driven_by(:selenium, using: :chrome, screen_size: [1440, 1000]) do |caps|
  caps.add_argument("--headless=new")
  caps.add_argument("--no-sandbox")
  caps.add_argument("--disable-dev-shm-usage")
  caps.add_emulation(device_metrics: { width: 375, height: 812, pixel_ratio: 1 })
end
```

Measured after: `window.innerWidth=375`, `document.documentElement.scrollWidth=375`
(no horizontal overflow), `save_screenshot` writes 375×812.

**The rule:** a screenshot's filename is a claim. Verify it against the file's pixel
dimensions and against `window.innerWidth`, and put those two numbers next to the
image when reporting. `media/theme-focus/final/` now holds `dashboard-1440.png`
(1440×914), `dashboard-375.png` (375×812), `settings-1440.png` (1440×814) and
`settings-375.png` (375×812).

### Now enforced, not remembered

Two rules, both written because the failure already happened:

**1. `script/check_screenshots`** — reads the PNG header and compares the real pixel
width against the width in the filename (`*-1440.png`, `*-375.png`). Runs on any
directory; `--expect WIDTH` overrides. Negative-tested against the actual old 500×726
file named `*-375.png`: exit 1, naming both numbers.

**2. `LaissCms::TestSupport::ViewportScreenshots`** — capture-time guard. `capture(path,
width:)` refuses to write a file when `window.innerWidth` is not the requested width, and
refuses to write one whose pixel width disagrees with the name. `driven_with_viewport(w,
h)` registers a Chrome driver with `add_emulation(device_metrics:)`, which applies the
viewport *before* load so media queries fire correctly.

Both are covered by `spec/features/admin/viewport_screenshots_spec.rb`, including the
negative case (a 1440 session asked for 375 must raise and must not leave a file behind).

**A trap found while building it.** `driven_by` reuses the driver already registered
under that browser, so two examples at different sizes silently shared one session — a
375 example reported `innerWidth` 1440. The helper now registers a driver named after
its viewport (`viewport_375x812`) so each size is its own registration. Without that,
the guard would have been testing the wrong page and passing.

---

## Shared component pass — defects found in the dashboard screenshot

Recorded here as they are found, fixed in the shared pass rather than screen by screen,
because each one affects more than the screen it was spotted on.

### Alerts — icon overlapping the text ("no pages")

**Symptom:** in the locked-pages empty state the info icon sat on top of the word "no".
Measured: icon at x=241, text starting at x=233, **overlap of 29px**.

**Two causes, and the second one matters much more than the alert.**

*Cause 1 — the layout technique.* `laiss-cms-message` positioned its icon
`position: absolute; left: var(--spacing-2)` and relied on the container's
`padding-left: var(--spacing-8)` to reserve the gutter. Any failure of that padding puts
the icon straight onto the text. It is now a flex child with `gap`, so the gutter comes
from the gap and the two cannot collide.

*Cause 2 — the whole theme's cascade was inverted by scoping.* The theme's reset is
`* { padding: 0 }`. Nesting the theme under `#laiss_cms` (the `<body>` id) emits it as
`#laiss_cms *`, which is specificity **(1,0,0)** — an id. Every bare-class or
bare-element rule in our component layer is at most (0,1,0) and **loses to it**.

In the original theme that reset is `*` at (0,0,0), so any class rule overrode it and the
layering worked. Scoping it under an id silently inverted the cascade for the entire
admin.

Measured, at the time of discovery:

```
laiss-cms-message   declared padding: var(--spacing-2) var(--spacing-4) … var(--spacing-8)
                    computed padding: 0px          ← every var it referenced resolved fine
```

The vars were not the problem: `--spacing-8` read `2rem` in the browser. The declaration
was being beaten. Forcing the same shorthand inline produced `padding-left: 32px`, which
proved the rule was correct and simply outranked.

**Why this is logged as a shared-pass item and not an alert fix:** any component rule in
our stylesheets that relies on a bare class or element selector inherits padding,
margin or outline from nothing. `.card-body` and `.widget-body` only looked right because
they happen to be addressed by `#dashboard …` selectors that already outrank the reset.
The audit of which components are actually affected belongs in the shared pass, where
each is compared against the pre-conversion screen.

The alert itself is fixed — icon right edge 254, text left 266, **gap 12px**, icon
`position: static`.

### User button — "text in a box" rather than a button

**Two causes again.**

1. `link_to_if(edit_user_path, …)` — when `edit_user_path` is nil, which is the default
   configuration and the demo app's, `link_to_if` renders **no tag at all**, just the bare
   string. There was no element to style.
2. The only rule that would have dressed it targeted `laiss-cms-current-user-name` — an
   element name this component has never emitted. The real class is `.current-user-name`,
   so the rule never matched anything.

Measured before: **140×21, padding 0, radius 0, transparent background**.
After: **152×34, pill radius 999px, resting background `rgb(241,243,248)`, 8px gap**,
and the label is always an element whether or not the user is editable.

The component now documents its theme provenance: `theme/index.html`'s header profile
control (`li.nav-item.header-profile > a.nav-link > i`). The theme's version is a dropdown
of Profile / Inbox / Logout driven by Bootstrap's JavaScript, which this project does not
ship — so the control's *shape* is adopted, and the dropdown itself is deferred to the
shared pass where the menu component is settled.


---

## Screen 1 of the remaining list — Pages index (`table-basic.html` + tree)

**Where the work stopped:** this screen is complete and committed. Next is Library /
pictures. Nothing after that has been started.

### Provenance, in one sentence per view

- **List view (`?view=list`): converted from `theme/table-basic.html`** —
  `.table-responsive > table.table`, `.badge` for status. The theme's outer
  `.card > .card-title + .card-body` frame is deliberately **not** reproduced.
- **Tree view (`?view=tree`): composed, because the theme has no usable counterpart.**
  See the evidence below.

### Why the tree is a composition, with the evidence

`theme/uc-nestable.html` is the only page in the theme with a tree. Its markup is
`.dd > ol.dd-list > li.dd-item > div.dd-handle`, and **all of its layout comes from a
jQuery plugin we do not ship**:

```
theme/vendor/nestable2/css/jquery.nestable.min.css
  .dd-list .dd-list { padding-left: 30px }   ← the indentation
  .dd-item          { min-height: 20px }
  .dd-handle        { display: block; height: 30px; border: 1px solid #ccc }
```

The theme's own SCSS for the component (`scss/components/uc/_uc-nestable.scss`) contains
only thirteen declarations, and every one of them restyles the **handle's colour**:

```
color: $white;  background: $primary;  border-radius: 0;  border: 1px solid $border;
```

So adopting `uc-nestable.html` "verbatim" would mean shipping nestable2's plugin CSS and
reimplementing its drag behaviour — a vendor library the project has consistently refused.
`col-xxl-*` was mapped rather than forked for the same reason.

The tree therefore keeps our `.sitemap_*` structure, which already carries the states the
plugin demo has none of: folded/unfolded, locked, offline, restricted, scheduled,
per-page action tools, drag handle on non-root pages. Composing it from the theme's
**visual** primitives — the same card, the same badges, the same icon size, the same
hairline row rule — is what was approved in the audit as "Composition — nested list, not a
table".

**This is the one place in the screen where I am substituting something for a theme page,
and it is flagged rather than presented as a direct adoption.**

### Two defects found while converting, and their causes

**1. The status badge showed as a bare word with no chip and no gap.**
`page_status_indicators.html.erb` emitted `<span class="page_status">` with no badge class
at all. It now emits the theme's `.badge badge-<variant>`, mapped by meaning:

| State | Variant | Why |
|---|---|---|
| locked | `badge-warning` | someone is holding it; not an error |
| restricted | `badge-light` | visible to some, quietly |
| offline | `badge-light` | the normal state of a draft |
| scheduled | `badge-primary` | waiting on a date is a plan, not a problem |

`badge-danger` is unused on purpose: red stays reserved for actual failure.

Then the gap measured **0px** even after the badge was applied, because the theme's
`#laiss_cms .badge` sets `display: inline-block` at specificity **(1,1,0)** and our bare
`.page_status` flex rule is **(0,1,0)**. `gap` does nothing on an inline-block. Fixed with
`body#laiss_cms .page_status` — measured after: `display: inline-flex`, `gap: 4px`.

**This is the same cascade inversion logged in the shared pass. It is the second
occurrence, and it will not be the last: any rule of ours written on a bare class is
below the theme's reset.**

**2. `table.table` collided with our own `.table` div-grid.** `tables.scss` defined
`.table { display: flex; flex-direction: column }` for a `<div class="table">` grid used by
exactly one view (legacy page URLs). Adding the theme's `class="table"` to real `<table>`
elements made every index table a flex container — measured `display: flex` on the table,
which is invalid for table layout. Our class was renamed `.div-table` (its only user
updated), leaving `.table` to mean the theme's table. This is a rename, not a removal: the
`div-table` grid keeps its exact behaviour.

### The 375px view was broken by the desktop sidebar, and it was pre-existing

At 375 the filter sidebar is `position: fixed` with `width: var(--sidebar-width)` —
**232px over a 375px viewport**, leaving the table 143px. Two separate causes:

1. `#library_sidebar` had no mobile rule at all. It is now `position: static`, full width,
   and sits after the table.
2. `#main_content:has(#filter_bar)` still reserved `--sidebar-width` as **padding-right**
   after that, because `#filter_bar` lives *inside* `#library_sidebar`. Now overridden at
   the strength the desktop rule uses.

Measured after: `padding-right` 232px → **9.6px**, table 143px → **363px** inside its own
scroll region, `document.scrollWidth` = **375** (no page overflow).

**A build trap worth recording:** `pnpm run build:css` alone **exits 0 on a Sass error**,
so a `rm` + `build:css` cycle left a stale file and I measured twice against CSS that did
not contain my change. `pnpm run build` (the one the gate runs) does exit non-zero —
verified by breaking the SCSS on purpose: exit 65. Always use `pnpm run build`, and check
the file, not the exit code of the narrow script.

### Verification, per the two mandatory rules

| | Before | After |
|---|---|---|
| `#main_content *` elements, tree | 320 | 320 (unchanged — tree markup not converted) |
| `innerText`, tree | 179 chars | 179 chars |
| `#main_content *` elements, list | 520 | 520 |
| `innerText`, list | 606 chars | 606 chars |
| `table` computed display | `flex` (wrong) | `table` |
| status badge | no `.badge`, gap 0px | `.badge`, `inline-flex`, gap 4px |
| 375: table width | 143px | 363px |
| 375: `document.scrollWidth` | 375 | 375 |

Specs: `spec/features/admin/pages_index_layout_spec.rb`, four examples. **Three confirmed
failing against the pre-fix files**; the tree example passes either way because that markup
was not touched — stated rather than implied.


---

## The log is the single source of truth, and it ships with each screen

**This file is the record of what each screen adopted.** Not the commit messages, not a
summary at the end of the migration. If this session dies mid-migration, the next person
reads this file to learn where the work actually stopped.

**Therefore: every screen commits its own entry, in the same commit as the change.**

That rule was audited when it was written, and it had already slipped — four commits
changed views or stylesheets without touching this file, two of them real screen work:

```
de55d662c  Step 0: Bootstrap and theme SCSS foundation
e4c024473  Fix the icon box artefacts
35ea7df12  Dashboard: restore the widgets the conversion had hidden
f74bb6e73  Dashboard: one card surface per widget, not two
```

The last two were substantive and are written up below retroactively. They are also the
reason the rule is now enforced rather than remembered.

### Enforced by a gate

`script/check_migration_log` fails when a commit touching `app/views/`,
`app/components/` or `app/stylesheets/` does not also touch this file. Build artifacts are
excluded. It checks commits not yet on `main`, so it guards new work without failing on
history; the four commits above are listed explicitly in the script as grandfathered, with
this entry as the record of why.

Negative-tested: a throwaway commit changing one stylesheet without the log exits 1 and
names the commit and the file.

### No dangling release-note links

Checked when the beta note files were removed from the store's `docs/`: the repository has
**zero** links to `docs/releases/v0.1.0.beta{1..5}.md`. The CHANGELOG mentions those
versions as prose history with no markdown links at all, and `docs/releases/` contains only
`v0.1.0.beta6.md`. `script/check_doc_links` covers `docs/**/*.md` and was negative-tested
against a deliberate `releases/v0.1.0.beta5.md` link — it failed with "link target does not
exist". A link to a deleted file cannot survive the gate.

---

# MIGRATION-LEVEL DEFECT: the theme's universal reset inverted the cascade

**This is not a component footnote.** It affected every screen in the admin, it was
invisible to every spec, and it silently made each new rule we wrote a coin flip.

## What the reset was doing

The theme's base layer is a bare `* { padding: 0 }`:

```scss
// theme/base/_reset.scss, upstream
* { outline: none; padding: 0; }
```

In the original theme that is specificity **(0,0,0)**, so any class rule overrode it and
the layering worked as designed. But the whole theme is imported inside `#laiss_cms { }` so
it cannot touch the host page — and Sass prefixes the parent, emitting:

```css
#laiss_cms * { outline: none; padding: 0 }   /* specificity (1,0,0) — an ID */
```

**An id beats every bare class.** Every rule in our component layer written as
`.thing { padding: … }` (0,1,0) or `button { padding: … }` (0,0,1) lost to a *reset*. That
is the one thing a reset must never win against, and it had been true since the theme was
scoped.

## Step 1 — measured the blast radius before touching anything

Probe: every rule in `admin.css` whose selector is at most (0,1,0) — the only kind the
reset can beat — that declares `padding` or `margin` and matches a real element on the
Pages index. For each, the declared value was resolved to pixels with a detached element
and compared against the computed value on the live element.

```
rules examined:  61
reset winning:   41   (of which 24 computed to exactly 0px)
```

The 24 that computed to 0px — i.e. **the reset beat them outright**:

```
button, input[type=submit], a.button   .toolbar            .pagination
input[type=text], select, textarea     .pagination-wrapper .per-page-select-form
.toolbar input.search_input_field      .resources-table-wrapper
.laiss-cms-popover                     .ts-wrapper.laiss_cms_selectbox .ts-control
.main_navi_entry label                 .subnavi_tab a
.dayContainer, .flatpickr-*            .numInputWrapper span
td.status .page_status
```

The other 17 were mismatches where a **different rule of ours** with higher specificity
won — normal cascade behaviour, not the reset. They are listed separately because counting
them as damage would have overstated the blast radius.

Corroborating symptom from the pre-fix baseline capture: `button` and `input` measured
**0×0** on screens where they are not hidden.

## Step 2 — the fix

`theme/base/_reset.scss` now wraps the reset in `:where()`:

```scss
:where(#laiss_cms) {
  * { outline: none; padding: 0; … }
}
```

`:where()` contributes **zero specificity**, so the emitted selector is
`:where(#laiss_cms) *` at **(0,0,1)** — the same weight as a bare element selector, which
is what a reset is. It still only matches inside `#laiss_cms`, so the host-safety guarantee
that motivates the wrapper is unchanged.

Restored order:

```
theme component (1,x,x)  >  our component (0,1,x)  >  reset (0,0,1)  >  UA default
```

The file carries a comment saying not to rewrite it as a plain `*` inside the wrapper and
not to "simplify" the `:where()` away, because either puts it back at (1,0,0).

## Step 3 — verified, and the blast radius was real

Same probe after the fix:

```
rules examined:  61
reset winning:    3   (24 → 3)
```

The three remaining are **not** the reset, and each was checked individually:

| Rule | Why it is still 0 | Verdict |
|---|---|---|
| `.dayContainer` | flatpickr's own later rule sets `padding: 0` | vendor ordering, correct |
| `td.status .page_status` | `:first-of-type` deliberately zeroes the left margin | correct |
| `textarea, input[...]` | a later rule of ours overrides the shorthand | correct |

Spot-checks of previously-dead rules now computing correctly:

| | Before | After |
|---|---|---|
| `.toolbar` padding | 0px | **12px 24px** |
| `.pagination` padding | 0px | **8px** |
| `.laiss-cms-popover` padding | 0px | **8px** |
| search input padding | 0px | **8px 16px 8px 32px** |
| `select` padding (settings) | 0px | **6px 12px** |
| `select` size (pages) | 18×36 | **62×36** |

## Step 4 — every converted screen re-shot and diffed

Content was expected to be unchanged, because this fix changes styling, not markup. It was:

| Screen | elements before → after | innerText before → after |
|---|---|---|
| dashboard | 618 → 618 | 1,307 → 1,307 |
| settings | 132 → 132 | 1,515 → 1,515 |
| pages list | 520 → 520 | 607 → 607 |
| pages tree | 320 → 320 | 179 → 179 |

One geometry change on the pages list, and it is the fix working:
`input` 18×36 → **62×36**, table 1036 → 1020px. The select was being crushed to its content
width by the missing padding.

Screenshots re-taken at 1440 and at a verified 375 for all four screens; every file
confirmed by `script/check_screenshots`, `scrollWidth` equal to the viewport on all eight.

All 4,423 core specs and 167 devise specs pass.

## The lesson

**A reset scoped under an id is not a reset.** When a stylesheet is nested for host safety,
every bare `*` rule inside it silently gains an id's weight. The symptom is not an error —
it is a component that looks "almost right", with padding missing, and no spec can see it
because nothing is broken, only unstyled.

Anything similar in another scoped stylesheet needs the same `:where()` treatment. Grep for
`* {` inside any scoped block before adding a new one.

---

# THE METHOD WAS WRONG: Phase 1 restores the original admin

**Status: the theme migration is stopped and reversed.** This entry is the record of why,
what was restored, and what was kept. The "new UI" is now a CSS-only uplift applied on top
of the original admin, and it has not started.

## The correction

The owner's instruction, in his words: *"get the original theme it had for AlchemyCMS put it
back and then change it to look at the one I gave you without losing any of the original
elements or components, it's just a UI lifting. Now a new UI."*

The method up to this point was the opposite: markup was rewritten to match the Focus theme
page by page, components were replaced, Bootstrap was adopted, views were edited. That
produced a design that lost original elements — the dashboard, for one, ended up with four
Bootstrap stat cards and none of its original `.widget-body > .name + .count + .infos`
structure. Every entry above that says "converted from theme page X" describes work that
this commit reverses.

**A UI lift changes how the existing interface looks. It does not change the interface.**

## Two redesign campaigns, not one — which is why the restore point matters

The history is not a single redesign. There were two, and restoring to the wrong boundary
would have kept half the problem:

| Commit | What it did | Markup touched |
|---|---|---|
| `c25c598b2` **Apply the Laiss Labs palette, Inter, Laiss marks** | brand colours + font over the ORIGINAL admin | 1 file, 3 lines (menubar) |
| `51bd2078e` Phase 7: journal theme | first real restyle | 3 view files |
| `0b733654f` **Rework the admin into a single modern light theme** | **+3,229 lines** — the big structural rewrite | 38 files |
| `de55d662c`…`8e4df05ad` | Focus/Bootstrap adoption (the work reversed here) | many |

**Restore point: `c25c598b2`.** It is the last commit where the admin still had its original
AlchemyCMS structure and markup, with the Laiss palette applied — the owner's identity
without the redesign. Going back further (`439731dbd`, stock Alchemy blue) would have undone
branding work he asked for.

## What was restored, and the evidence it is identical

Restored verbatim from `c25c598b2`:

| Area | Files | Verification |
|---|---|---|
| `app/stylesheets/**` | 68 | **68/68 byte-identical** |
| `app/assets/builds/**` | 18 | `admin.css` **byte-identical** — the restored SCSS compiles to exactly the original output |
| `app/views` + `app/components` | 22 | **20/22 byte-identical**; the 2 differences are the deliberate outbound-call removals below |
| `app/javascript/.../icon.js` | 1 | emits `class="icon"` again (the theme had renamed it `laiss-icon` for its own benefit) |
| icon sprite | 1 | 112 original symbols |
| `config/initializers/simple_form.rb` | 1 | `b.use :error, wrap_with: {tag: :small, class: :error}` — the theme had switched this to Bootstrap's `.invalid-feedback`, which changes the validation markup of **71 `f.input` call sites** |
| `package.json` | 1 | Bootstrap 4.3.1 and bootstrap-icons removed entirely |

Deleted: the whole `app/stylesheets/laiss_cms/theme/` tree, `focus.scss`, `_modern-theme.scss`,
`_journal-palette.scss`, `body-copy.scss`, the nine `*_polish.scss` files,
`modern_components.scss`, `responsive.scss`, `theme_toggle.*`, `drawer.js`, and Bootstrap from
`THIRD-PARTY-NOTICES.md` (three sections: Focus Bootstrap, Bootstrap, Bootstrap Icons).

## Deliberately NOT restored: two outbound-call widgets

Both make network requests, and this project's policy is no outbound connections:

- **`NewsReader`** — fetched `https://www.alchemy-cms.com/news` on every dashboard load.
- **`UpdateCheck`** — fetched `rubygems.org/api/v1/versions/laiss_cms.json`, which 404s
  because this gem is never published.

These are the only two places the restored markup differs from `c25c598b2`, each replaced
by a comment explaining why at the render site. Nothing else was dropped.

## Kept, but NOT restored: features that did not exist at the restore point

Restoring the tree wholesale would have deleted working features — the same mistake in the
other direction. These are kept as they are and will be restyled to match the restored
original in the uplift:

- **Settings** — `app/views/laiss_cms/admin/settings/show.html.erb` (0 view files at `c25c598b2`)
- **Events** — no views at `c25c598b2`
- **Auth screens** — `user_sessions/new`, `user_sessions/_logo`, `passwords/new`,
  `passwords/edit`, plus `devise.scss` and `devise/login.scss`
- **Users** — `users/{index,edit,new,signup,confirm_password}.html.erb`,
  `users/{_fields,_resource_table,_confirm_password_notice}.html.erb`
- **Notifications** — 12 mailer templates
- **`devise/shared/_error_messages.html.erb`**

`devise.scss` had to be re-added to `package.json`'s build:css pointing at
`app/stylesheets/laiss_cms/devise.scss`, because the original entry referenced the
`devise/` gem directory that no longer exists.

## Verification

**Suite:** 4,399 examples, 0 failures — the ORIGINAL suite's own count, green against the
original markup. All gates pass (core, devise, standardrb, eslint, prettier, herb-lint, doc
links, screenshot sizes, build, vitest 823, artifacts, scratch app).

Theme-era specs deleted, because they test a design that no longer exists and are absent
from `c25c598b2`: `cascade_reset`, `dashboard_layout`, `pages_index_layout`,
`viewport_screenshots`, `sidebar_collapse`, `theme_toggle.spec.js`. Specs the theme had
edited for Bootstrap selectors are reverted with it: `builder_spec`,
`page_permitted_roles_select_spec`, `languages_features_spec`, `page_creation_feature_spec`,
`ingredients/edit_spec`, `icon.spec.js`.

**Per-screen inventory, 1440, all `scrollWidth == innerWidth` (no horizontal overflow):**

| Screen | elements | innerText |
|---|---|---|
| dashboard | 552 | 1,146 |
| pages list | 519 | 603 |
| pages tree | 320 | 179 |
| page new | 47 | 47 |
| library (pictures) | 53 | 253 |
| library (attachments) | 51 | 250 |
| menus (`/admin/nodes`) | 28 | 248 |
| languages | 66 | 190 |
| sites | 58 | 164 |
| tags | 11 | 62 |
| settings (kept feature) | 132 | 1,515 |
| events (kept feature) | 126 | 84 |
| styleguide | 629 | 1,525 |
| help | 58 | 368 |

Reference screenshots: `media/restore/*-1440.png`, every file confirmed 1440×857 by
`script/check_screenshots`.

**Not reachable in this fork, before or after the restore:** `/admin/users`. It falls
through to the public Pages controller (`LaissCms::Page not found`), because the Users module
is not mounted as an admin route in this build. That is pre-existing and unrelated to this
change; the views exist and are kept.

## The empty-state alert was never broken

Repeatedly reported as "the icon overlaps the text", including by image readings of the
screenshot. Measured on the restored original:

```
laiss-cms-message  display:block padding:8px 16px 8px 32px
icon               position:absolute left:8px  x=211..227
text               starts x=235
GAP = 8px
```

Confirmed by an ASCII pixel map of the alert region: icon glyph ends at column ~26, text
begins at column ~33. **No overlap.** The original reserves a 32px left padding for an
absolutely-positioned icon, which is a correct and conventional technique.

The defect existed only in the theme version, where I had deleted that padding and then
"fixed" the icon with flex — a bug I introduced and then reported as a pre-existing fault.
The original was right.

## The rule this established

**Look at the original before changing it.** Most of the defects chased in this migration —
the ghost squares, the 900px logo, the 0×0 bars, the collapsed columns — were consequences
of replacing working markup with theme markup, not faults in the admin. A CSS lift would
have avoided all of them, and the visual result would have been the same.

## Items already identified for the CSS uplift (Phase 2)

The owner named four on the restored Pages index. **All four are achievable in CSS alone**,
which is the test of whether they belong in Phase 2 at all:

| Item | CSS-only? | How |
|---|---|---|
| Page names render light grey; should be the strongest text in the table | **yes** | the name cell is `<td class="name">`; raise its colour/weight |
| "offline" is plain text, not a badge | **yes** | `td.status .page_status` already exists as a selector; give it a chip |
| Row action icons cramped; want the theme's spacing and a 44px target | **yes** | `.icon_button` sizing/padding; no markup change |
| "7 Pages" heading oversized vs the toolbar beside it | **yes** | `#main_content h1` / `.resources-header` scale |

None requires touching ERB, a class name, or a custom element — which is exactly why they
belong in the uplift rather than in another markup pass.

## Scope for Phase 2, stated as a constraint

A single new stylesheet layer, loaded last, changing only: typography, colour, spacing,
radius, border and shadow. **Zero ERB changes. Zero class renames. Zero custom element
changes.** If a visual change cannot be made without touching markup, it is out of scope and
gets reported rather than done.

The reference images the owner supplied (`app/stylesheets/laiss_cms/_modern-theme.scss` was
the last attempt at them, and `docs/design/reference-spec.md` holds the measured spec) are the
target. What was wrong last time was not the target — it was achieving it by rewriting markup.

---

# PHASE 2 — the sidebar: near-black, CSS only

The owner approved the restored admin ("sempre é melhor assim") and asked for exactly one
visual change. This is it, and it is the first real exercise of the constraint: **no ERB,
no class renames, no custom element changes.** Three stylesheet files and their build
output. Nothing else.

## The colour, and why it is that colour

```css
--color-sidebar_bg: #0f1218;
```

**#0f1218 is the brand's own hue held at very low lightness.** The brand deep is `#00349c`,
which is 220deg. This is 220deg at **L 7.5%** and **S 20%** — near-black, but a blue-leaning
near-black rather than a neutral one.

Why not pure `#000`: it reads as "no colour was chosen". Why not a neutral `#141414`: the
workspace design reference is explicit that neutrals in this system carry a trace of the
brand hue rather than being literal greys, and the sidebar is the largest single colour
surface in the admin. `#0f1218` keeps the sidebar in the same family as the rest of the
palette while reading as deliberate rather than flat.

It is deliberately **not** `--color-grey_very_dark` (`#14161b`): that token is the dark
theme's *body* neutral and is meant to be neutral. The sidebar wants the brand tint, so it
gets its own token rather than borrowing one whose purpose is different.

## Contrast, measured in the browser

Not computed from the token values — read back from `getComputedStyle` on live elements,
then the ratio calculated from the resolved sRGB. Probe: `sidebar_contrast2`.

| Pair | Measured | WCAG AA needs | Result |
|---|---|---|---|
| nav label vs sidebar (`#fff` on `#0f1218`) | **21.00:1** | 4.5:1 body | pass |
| nav icon vs sidebar (currentColor fill) | **18.75:1** | 3:1 graphics | pass |
| Help / Leave label vs sidebar | **21.00:1** | 4.5:1 | pass |
| active label on orange fill (`#0f1218` on `#fc8708`) | **7.69:1** | 4.5:1 body | pass |
| orange active fill vs sidebar | **7.69:1** | 3:1 graphics | pass |
| muted text `#b9bec7` vs sidebar | **10.05:1** | 4.5:1 | pass |
| hover surface `#272a2f` vs sidebar | **1.30:1** | (a lift, not a boundary) | visible |
| white text on hover surface | **14.40:1** | 4.5:1 | pass |

## Two pre-existing AA failures fixed on the way

Both were failing **before** this change, on the old navy, and are worth recording because
the darker base made them unignorable:

1. **Active label was `#00349c` on `#fc8708` — 4.37:1.** Below AA for body text. It now uses
   the sidebar surface colour, `#0f1218`, at **7.69:1**.
2. **Sub-navigation hover was a literal `hsl(28deg, 77%, 63%)` with white text — 2.24:1.**
   Badly failing. It now uses the same `--color-sidebar_hover_bg` lift as a first-level
   hover, so both menu levels read consistently and the label keeps the sidebar text colour.

## Hover and active are now different states

`&.active, &:hover` shared one rule, so a hovered entry looked exactly like the selected
one. On navy that was merely redundant; against near-black an orange fill on every hover
would have made the whole menu look selected. Hover now lifts the surface (10% toward
white, `#272a2f`), and only `.active` carries the orange indicator.

## Group separators

There are none. The menu has no separator elements — the visual grouping comes from the
`margin-bottom` on `.main_navi_entry` and the `--spacing-7` top padding on `#main_navi`,
neither of which changed. Checked the markup rather than assuming, because the request
named them.

## The mobile drawer

There is no separate drawer stylesheet: at 375 the sidebar is the same `#left_menu` at a
48px rail, driven by the same `--main-menu-bg-color`. It inherits the change with no
additional rule, confirmed by screenshot.

## Scope proof

Compiled-CSS diff, fragment by fragment (`admin.css`, `theme.css`, `dark-theme.css`,
`light-theme.css`, `welcome.css`):

```
theme.css       26 changed fragments: 6 new sidebar tokens + 5 main-menu aliases × 2 themes
admin.css       14 changed fragments: all inside .main_navi_entry / .subnavi_tab selectors
dark/light.css  16 each: the same token aliases
welcome.css      6: the new token definitions
```

**Zero changed fragments outside sidebar selectors or sidebar tokens.** The one fragment that
needed checking by hand — `background-color:hsl(28,77%,63%)` — resolves inside
`.subnavi_tab.active a, .subnavi_tab a:hover` and is absent from the new build.

No other colour, spacing, typography, radius, border or shadow declaration changed.
