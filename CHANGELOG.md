# Changelog

All notable changes to **laiss-rails-cms** are recorded here.

This is a private, in-house fork maintained by Laiss Labs and developed by
Júlio Papel. It is not published to RubyGems. It is derived from an upstream
CMS engine; that derivation is recorded in `LICENSE` and nowhere else.

## Unreleased

### Initial fork

- Forked from the upstream engine at commit
  `08836849179a5d40c5ebdf158d6904bf8152e563` (`main`, 2026-10-30, upstream
  version 9.0.0.dev).
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
