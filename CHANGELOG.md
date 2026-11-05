# Changelog

All notable changes to **laiss-rails-cms** are recorded here.

This is a private, in-house fork maintained by Laiss Labs and developed by
Júlio Papel. It is not published to RubyGems. It is derived from an upstream
CMS engine; that derivation is recorded in `LICENSE` and nowhere else.

## Unreleased

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
  feed, so it showed upstream content inside the rebranded admin.

The upstream project's own changelog is not carried forward here: it describes
a different product's releases, not this fork's history. For a security fix that
lands upstream, cherry-pick it and add an entry under Unreleased describing the
fix.
