# Documentation

Which documents are authoritative, and when each was last checked against the
code. The point of this file is that documentation drifts less when someone has to
date it.

## Authoritative

These describe the current code. If one contradicts the code, the document is
wrong — fix it or open an issue.

| Document | Covers | Verified |
| --- | --- | --- |
| [`README.md`](../README.md) | What the project is, install from git, requirements, concepts | 2026-11-05 |
| [`CONTRIBUTING.md`](../CONTRIBUTING.md) | Setup, suites, gates, naming contract, editor policy, commits | 2026-11-05 |
| [`SECURITY.md`](../SECURITY.md) | Reporting a vulnerability, scope | 2026-11-05 |
| [`CODE_OF_CONDUCT.md`](../CODE_OF_CONDUCT.md) | Contributor Covenant 2.1 | 2026-11-05 |
| [`docs/versioning.md`](versioning.md) | Version sequence, release process, no RubyGems | 2026-11-05 |
| [`docs/site-sync.md`](site-sync.md) | The docs-site dispatch, its secret and scope | 2026-11-05 |
| [`docs/design/reference-spec.md`](design/reference-spec.md) | The measured design system | 2026-11-05 |
| [`docs/development/toolchain-pinning.md`](development/toolchain-pinning.md) | Pinned Ruby/Node/pnpm and why | 2026-11-05 |
| `guides/` | Reference documentation, below | 2026-11-05 |

## Guides, by reliability

**Verified end-to-end.** These were executed or read against the code.

| Guide | Note |
| --- | --- |
| [`guides/getting_started.md`](../guides/getting_started.md) | Walkthrough matches the current admin |
| [`guides/elements.md`](../guides/elements.md) | Elements and page layouts |
| [`guides/ingredients.md`](../guides/ingredients.md) | Ingredient types |
| [`guides/pages.md`](../guides/pages.md) | Page tree, versioning, publishing |
| [`guides/configuration.md`](../guides/configuration.md) | Configuration options |
| [`guides/how_to_customize_tinymce.md`](../guides/how_to_customize_tinymce.md) | Rewritten for the reduced editor |

**Reference, mechanically renamed and not yet re-read line by line.** They
describe concepts that still exist, but a specific option name or example may be
stale. Treat them as a starting point and check the code.

`guides/menus.md`, `guides/languages.md`, `guides/sites.md`, `guides/tags.md`,
`guides/library.md`, `guides/i18n.md`, `guides/render_images.md`,
`guides/seeder.md`, `guides/extensions.md`, `guides/how_to_create_a_blog.md`,
`guides/how_to_create_a_contact_form.md`, `guides/how_to_create_custom_ingredients.md`,
`guides/how_to_create_modules.md`, `guides/how_to_extend_laiss_cms.md`,
`guides/how_to_add_custom_authentication.md`,
`guides/how_to_integrate_into_existing_rails_app.md`

**Deployment and upgrade.** Operationally useful, but not verified against a live
deployment in this repository.

`guides/deployment.md`, `guides/how_to_deploy_with_kamal.md`, `guides/upgrading.md`

**Deleted.** Guides for functionality this fork removed. A guide for a feature that
is deliberately gone is a lie rather than a gap, so these were removed:

- dark-mode material — the admin has one light theme
- the old full-featured editor toolbar — reduced to body copy by policy

## Verifying a command

Every command in the documentation is meant to be executable. Two are easy to get
wrong and both fail quietly, so they are called out here as well as in the README:

1. **`bin/rails active_storage:install`** must run before `db:migrate`. Without the
   ActiveStorage tables the engine boots and every image upload fails.
2. **`bin/rails db:seed`** must run after `laiss_cms:install`. The installer
   appends `LaissCms::Seeder.seed!` to `db/seeds.rb` but does not execute it, so
   without this there is no site, no language and no root page — and a page needs a
   parent, so pages cannot be created either.

## How this stays current

- When you change behaviour, update the document in the same commit. A separate
  "docs pass" is how the drift happened the first time.
- Update the **Verified** date above when you actually read a document against the
  code. Do not bump it because you edited the file.
- `script/rebrand/verify` and `script/rebrand/leak_scan` run in CI and cover names,
  not accuracy. Accuracy is on the reviewer.
- Internal links are checked in CI; a broken link fails the build. An image that
  404s in a README is worse than no image.
