# LaissCms I18n - Claude Code Guidelines

## Project Overview

This gem provides translations for [LaissCms CMS](https://github.com/LaissCMS/laiss_cms). Translation files live in `locales/laiss_cms.<locale>.yml`.

## Reference Codebase

The LaissCms CMS source is the parent directory of this gem. Always use it to:
- Look up where translation keys are used
- Check the English reference locale at `config/locales/laiss_cms.en.yml`
- Verify keys are actually used before adding translations

## Rake Tasks

Run these from the repository root:

- `bundle exec rake app:translations:status` — Show translation coverage for all locales
- `bundle exec rake "app:translations:missing[de]"` — Show missing keys for a specific locale
- `bundle exec rake app:translations:validate` — Validate YAML syntax for all locale files

## Translation Workflow

1. Run `app:translations:missing[<locale>]` to find missing keys
2. Check the LaissCms CMS codebase to verify keys are actually used before translating
3. Only **add** missing keys — never remove existing keys without explicit permission
4. Keys with `nil` values in the EN locale (like `element_names`, `ingredient_roles`, `page_layout_names`) are user-customizable placeholders — do not add them to other locales
5. Some keys exist only in code (not in the EN locale file) and rely on `LaissCms.t`'s fallback (humanizing the key). These still need translations in other locales.
6. Validate YAML after editing: `bundle exec rake app:translations:validate`
7. Commit one language per commit

## How LaissCms.t Works

`LaissCms.t(key)` automatically scopes all lookups under the `laiss_cms` namespace. So `LaissCms.t(:hello)` looks up `laiss_cms.hello`, and `LaissCms.t(:name, scope: [:filters, :page])` looks up `laiss_cms.filters.page.name`. See `lib/laiss_cms/i18n.rb` for details.

## Translation Style

- Use consistent formatting within each locale file
- Preserve existing YAML anchors (e.g., `&mime_types` and `<<: *mime_types`)
- Keep keys in the same order as they appear in the file — add new keys near related existing keys
- When unsure about a translation, ask — do not guess
