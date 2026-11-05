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

