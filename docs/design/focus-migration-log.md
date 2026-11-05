# Focus theme migration log

One entry per step. What changed, what was verified, and **what is knowingly wrong at
that point** — because during a migration of this size something usually is, and a log
that only records successes is useless when something breaks four steps later.

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
| 1b | Shell: layout, sidebar, top bar | blocked on preview iframe |
| 2 | Forms: simple_form wrapper + builder | pending |
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
