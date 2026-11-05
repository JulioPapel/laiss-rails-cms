# Changelog

All notable changes to **laiss-rails-cms** are recorded here.

This is a private, in-house fork maintained by Laiss Labs and developed by
Júlio Papel. It is not published to RubyGems. It is derived from an upstream
CMS engine; that derivation is recorded in `LICENSE` and nowhere else.

## Unreleased

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
