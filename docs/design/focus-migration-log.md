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
| 3 | Settings screen | pending |
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
