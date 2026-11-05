# Changelog

All notable changes to **laiss-rails-cms** are recorded here.

This is a private, in-house fork maintained by Laiss Labs and developed by
Júlio Papel. It is not published to RubyGems. It is derived from an upstream
CMS engine; that derivation is recorded in `LICENSE` and nowhere else.

## Unreleased

## 0.1.0.beta7 — admin UI reverted to the original, near-black sidebar

**Releases beta1–beta5 no longer exist**; `v0.1.0.beta6` remains available.

- **The theme migration was reverted.** The admin was being restyled by adopting an
  external Bootstrap theme ("Focus"), which rewrote the admin's markup page by page —
  views, components, partials, the icon class and the simple_form wrapper. That was the
  wrong method: a UI lift changes how an interface looks, not the interface. It is undone
  in full, not finished.

  Restored to their pre-theme state: all 68 admin stylesheets (byte-identical), the build
  artifacts (the compiled `admin.css` is byte-identical), every view, partial and component
  that had been rewritten, `icon.js` emitting `class="icon"` again, and the simple_form
  error wrapper (`small.error`) that the theme had changed to Bootstrap's
  `.invalid-feedback` across 71 `f.input` call sites. Bootstrap 4.3.1 and Bootstrap Icons
  are removed entirely, with their licensing notices.

  Two dashboard widgets are deliberately not restored because they made outbound requests
  on every page load: a news reader (`alchemy-cms.com`) and an update checker
  (`rubygems.org`).

  Features added during that period are kept rather than deleted: Settings, Events, the
  bundled sign-in screens, user management and the notification mailers.

- **Sidebar background is now near-black (`#0f1218`).** The brand's own hue (220°, from
  `#00349c`) at 7.5% lightness and 20% saturation — deliberate rather than flat black, and
  still in the brand's family rather than a neutral grey. CSS only: no ERB, no class names,
  no custom elements, verified by diffing the compiled CSS.

  Measured contrast: nav labels 21.00:1, icons 18.75:1, Help/Leave 21.00:1, active label on
  the orange fill 7.69:1, orange fill against the sidebar 7.69:1, muted text 10.05:1.

  Two failures that predate this release are fixed as a consequence: the active label was
  4.37:1 on orange (below AA), and sub-navigation hover was white on a pale orange at
  2.24:1. Hover and active are now distinct states — they previously shared one rule, so a
  hovered entry looked selected.

- Retired the per-screen migration-log gate: it enforced a rule for a process that no longer
  runs. The script and the log are kept, with instructions to re-enable.
- Test baselines return to the original suite's own counts: 4,399 specs, 823 JS tests.

## 0.1.0.beta6 — migration tooling removed; earlier betas withdrawn

**This is the only installable version.** The tags for beta1–beta5 have been removed
from the repository, and their per-release notes with them.

- **Removed the scripts used to derive this fork from upstream.** They should never
  have shipped publicly. The decisive problem was `mapping.yml`: a complete
  old-name-to-new-name table covering every identifier, prefix and path that changed,
  which contradicts the policy enforced everywhere else — that the derivation is
  disclosed in `LICENSE` and nowhere else. Removed: `mapping.yml`, `lib.rb`, `apply`,
  `verify`, `leak_scan`, `leak_scan_test`, `self_test`, `rename_paths.rb`, `README.md`.

- **`script/gates` remains and absorbs the gate implementation**, which used to live
  under `script/rebrand/`. Specs, linters, build, vitest, doc links and the
  scratch-app check are unchanged, as are the count floors.

- **CI is three jobs** — `ruby`, `javascript`, `scratch` — and no longer has a
  rebrand-guard job.

- **The upstream-name policy is no longer automated.** The scan that enforced it was
  part of the removed tooling. It is now a review obligation documented in
  `CONTRIBUTING.md`, with the search to run. Stated here rather than dropped quietly.

- **GitHub Actions is disabled.** Every workflow moved to `ci-disabled/` at the
  repository root, where GitHub does not read them, after the account was billed for
  Actions minutes on a different repository and became locked. Verification is
  `script/gates` run locally; deployment is Coolify pulling the repository. A release
  is a tag at a commit where the gates passed. `ci-disabled/README.md` explains what
  each parked file did and that none of them ever ran successfully.

## 0.1.0.beta5 — corrective

- **Minimum Ruby raised to 3.4** (was a claimed 3.1). 3.1 was never run, and ransack
  6.x / view_component 4.x both require 3.2+, so the old claim only held by silently
  downgrading them. Ruby 3.4.12 and 4.0.6 are now the tested versions; the 3.4/7.2
  matrix leg was run before being added.
- **The guides could not be built.** The VitePress theme still imported three
  advertising components that no longer existed, so `guides:build` failed with
  "Could not resolve ./SideBarAd.vue". Three cross-tree links also failed the
  dead-link check. Both fixed; the build produces 29 pages.
- **`script/gates` diagnoses a missing tool.** Without pnpm it printed five bare FAILs
  and no cause. It now checks prerequisites first and says what to install.
- **`script/gates` warns on a Ruby/.ruby-version mismatch**, which makes Selenium fail
  with "unable to find browser binary" and reads as a broken suite.
- **`notify-site` runs outside a runner.** Its steps aborted on an unset
  `$GITHUB_OUTPUT`, so the workflow could not be exercised locally.
- **Action refs pinned to released tags.** `ruby/setup-ruby@v1` was a branch, not a
  tag. The SHA-pinning trade-off is documented in `ci.yml` for the owner.

## 0.1.0.beta4 — corrective

Both defects found by executing `ci.yml`'s steps rather than reading them. Neither
affects an installed app.

- **The devise spec job could not have passed.** `ci.yml` ran
  `bundle exec rspec devise/spec` from the root, which loaded the core spec helper
  (a load-path lookup hits `./spec` first), leaving the integration inactive and
  failing five files with `uninitialized constant LaissCms::Devise`. `script/gates`
  passed because it goes through `bin/rspec`, which cd's into each lib.

  Every CI job now runs a `script/gates` subset, so there is one implementation of
  the checks. The `counts` job is gone: it duplicated the example floors with stale
  hardcoded numbers and would have failed on every run. Two things the refactor
  nearly lost were caught and preserved — the committed-build-artifacts check, now
  in `run_js` and negative-tested, and the plain-`rails` requirement of the scratch
  gate.

- **33 committed coverage artifacts** under `devise/coverage`, including a lock file
  and generated HTML. Untracked and now ignored.

## 0.1.0.beta3 — corrective

Two defects in 0.1.0.beta2, both found by installing that release into a fresh app.
No migrations, no config renames, no data changes.

- **The admin was broken in an app without an asset pipeline.** Every admin page
  returned 500 with `NoMethodError: undefined method 'assets'`, raised from inside
  a template because `importmap-rails` reads `config.assets` and Rails'
  `--minimal` template ships neither propshaft nor sprockets. The engine now
  checks at boot and raises `LaissCms::AssetPipelineMissing`, whose message names
  the gem to add. A pipeline stays a requirement: the admin is the engine's whole
  surface and its routes cannot be switched off, so failing at boot beats a 500 on
  the first request.

- **`script/gates` did not prepare the test database.** A fresh clone failed both
  Ruby gates with `no such table: laiss_cms_attachments`; it passed only where the
  database already existed. The gate now runs `laiss_cms:test:prepare` when the
  tables are absent. CI was already doing this in a separate step — the gap was in
  the script the release notes point readers at.

- Added a `scratch` gate that builds a throwaway Rails app with no asset pipeline
  and asserts the boot error appears. Confirmed to fail when the guard is removed.

## 0.1.0.beta2 — one gem, and a test suite that does not depend on file order

Packaging and correctness. Nothing here changes what the admin looks like.

### One gem

- **`laiss_cms` is the only gem to install.** The translations and the
  authentication integration were separate gems (`laiss_cms_i18n`,
  `laiss-cms-devise`) consumed from git with a `glob:` pointing at their own
  gemspecs. Both are now part of the engine, so a `Gemfile` has one line.

  ```ruby
  gem "laiss_cms", git: "…", tag: "v0.1.0.beta2"
  ```

  Upgrading: delete the two old lines and their `glob:` options. Leaving them
  behind points Bundler at gemspecs that no longer exist.

- **Translations need no install step.** All ten locales are on
  `I18n.load_path` as soon as the engine is required. The `laiss_cms_i18n:install`
  generator is gone.

- **Authentication is optional and opt-in.** `devise` is not a dependency of
  `laiss_cms`; an app that brings its own user model and sign-in boots without
  it. Add it where you want the bundled screens:

  ```ruby
  # config/application.rb, after `require "laiss_cms"`
  require "laiss_cms/devise"
  ```

  Without that line there is no `LaissCms::User`, no `/admin/login`,
  `/admin/signup`, `/admin/logout` or `/admin/passwords` route, and no admin user
  screen. Before this release the integration announced itself by being installed;
  now it announces itself only when asked, which is what makes bringing your own
  auth viable.

  The user migrations ship with the install generator rather than the engine's
  `db/migrate`, so an app with its own user model does not get a `laiss_cms_users`
  table it never asked for.

- The `flickwerk` dependency is gone. It existed to locate a single patch file,
  which is now required directly.

### Fixed

- **Redirects after an admin action went to the bare admin root.** The safety
  check interpolated the engine's mount path (`/`) into a regular expression,
  producing `^//admin/`, which never matches. Every accepted redirect therefore
  fell through to the fallback: deleting a user from `/admin/users` landed on
  `/admin` instead of the user list. Found by booting a fresh app, not by the
  suite, because the suite's mount path made the same mistake invisible.

- **`BaseMailer` raised in an app without `ApplicationMailer`.** The fallback
  referred to `ActionMailer::Base` unqualified inside `module LaissCms`, so Ruby
  looked for `LaissCms::ActionMailer`. Apps that define `ApplicationMailer` never
  reached the fallback.

- **The engine failed to boot where `config.assets` does not exist.** Every
  asset-path initializer now checks for it, so a minimal Rails app without
  sprockets or propshaft can load the engine.

- **The admin did not render in an app without an asset pipeline.** Every admin
  page raised `NoMethodError: undefined method 'assets'`, because the layout renders
  its JavaScript through `importmap-rails`, which reads `config.assets`. The engine
  already worked in any app with propshaft or sprockets — but Rails' `--minimal`
  template has neither, and nothing said so. The requirement is now stated in the
  README, the getting-started guide and the release note's Requirements list, and
  noted in the gemspec beside the `importmap-rails` dependency that causes it.

- **`db:seed` created nothing, silently.** The installer told you to run it but
  wrote no `db/seeds/laiss_cms/pages.yml`, and the seeder returned early when that
  file was absent without printing anything. The admin then came up with no site,
  no language and no pages, which reads as a broken install rather than an unseeded
  one. The installer now writes a starter file with one root page and one child, so
  a fresh install seeds a working tree. When the file is missing or declares no
  pages, `db:seed` says exactly which file it looked for and that no pages were
  created. A comment-only file — what `--skip-demo-files` produces — also parses to
  nil and used to raise `NoMethodError` from inside the seeder; it now counts as an
  empty list.

- **A non-interactive install produced an app that could not seed.** The installer
  asked for the primary language's code and name with `ask`, which returns `nil`
  when stdin is not a terminal — CI, Docker, or any scripted install. The nil was
  written into the generated initializer as `default_language.code = nil`, and
  `db:seed` then died in `create_default_language!` with
  `Validation failed: Name can't be blank, Language code can't be blank`, naming
  neither the installer nor the language. It now falls back to `en` / `English`.

### Test suite

The suite only passed under some random seeds. Six independent leaks of global
state caused it; all six reproduced on the previous release, so none was
introduced by this one. Fixed:

- `i18n_spec` wrote `@@available_locales` and reset it to `nil` rather than
  restoring it, and the setter example had no cleanup at all.
- `engine_spec` ran an initializer that appends to the global
  `config.assets.precompile` and never removed the entry.
- `message_spec` reloaded `Message` under a stubbed mailer configuration; the
  reloaded class outlived the stub, so later examples saw a model that only knew
  one field.
- `settings_spec` "restored" configuration by writing catalogue defaults, but
  `auto_logout_time` defaults to 30 there and is 40 in `config.yml`, so the
  cleanup itself corrupted the value.
- `attachments_controller_spec` spied with `expect_any_instance_of` on
  `ActiveRecord::Relation`, which is process-wide.
- Every picture fixture shared the name `"image"`, and the name becomes the
  filename in the variant URL. Two examples produced the same URL for different
  bytes, so the browser served a cached 1×1 where a 500×500 was meant.

Verified with four full runs at seeds 1234, 98765, 4242 and 31337: 4408 examples,
0 failures each.

### Added

- `script/check_doc_links` verifies links, images and anchors across the guides
  and now runs as one of the gates.
- `script/gates` collects all thirteen checks behind one command, including
  counts that fail on a drop rather than only on an error.

## 0.1.0.beta1 — first public beta

First beta under laiss-rails-cms' own independent version sequence. The
numbering deliberately does not continue upstream's 9.x, so the two cannot be
confused; see `docs/versioning.md`.

- Admin redesign: single light theme, blue primary with the brand accent used
  only for the current state, contrast-audited borders, radius/space/type scales
  in `rem` so the UI scales with the reader's font size.
- Settings screen: reads and writes real engine configuration, persisted across
  restarts, with runtime-writable and restart-required fields labelled honestly.
- Sidebar collapses on the page editor, with a toggle to expand it again that is
  remembered for the session.
- Rich-text editor reduced to body copy only — bold, italic, link, lists,
  blockquote, inline code, undo/redo, clear formatting — with paste forced to
  plain text and `valid_elements` as the backstop. Layout, headings and hierarchy
  come from element definitions, not from what a writer types.
- Public body-copy stylesheet so every element the editor can emit renders on the
  published site.
- Contrast: dark/light hairlines moved onto measured 3:1 boundaries with a
  separate decorative tier, so nothing looks boxed and nothing disappears.
- Fixes: the datepicker calendar no longer opens as a floating body-level popup;
  toasts no longer intercept clicks; the mobile drawer focuses the active row.

### Initial fork

- Forked from the upstream engine at commit
  `08836849179a5d40c5ebdf158d6904bf8152e563` (`main`, 2026-10-30). The upstream
  tree carried its own 9.x version string; laiss-rails-cms versioning is
  independent of it from this point — see `docs/versioning.md`.
- Renamed the Ruby namespace to `LaissCms`, the engine to `laiss_cms`, and the
  database table prefix to `laiss_cms_`.
- Replaced the Laiss Labs brand: palette derived from the Logo 2026 masters,
  Inter as the default typeface, and the Laiss marks throughout the admin.
- Adopted BSD-3-Clause with the upstream notices retained, plus the Laiss Labs
  copyright line.
- Removed publishing, release and changelog automation. The gem builds locally
  and is consumed as a path or git dependency only.
- Removed the dashboard News widget: it fetched the upstream project's news
  feed, so it showed third-party content inside the admin.

The upstream project's own changelog is not carried forward here: it describes
a different product's releases, not this fork's history. For a security fix that
lands upstream, cherry-pick it and add an entry under Unreleased describing the
fix.
