# Documentation

Which documents are authoritative, which are verified, and which are not. The
point of this file is that a reader never has to guess how much to trust a page.

Verified means: **I read the document against the code, or executed its commands.**
Not "it looks right."

## Verified against the code

| Document | What was checked | Date |
| --- | --- | --- |
| [`README.md`](../README.md) | Every command executed in a scratch Rails app installed from the git tag. Every internal link and image reference resolved programmatically. | 2026-11-05 |
| [`CONTRIBUTING.md`](../CONTRIBUTING.md) | Commands run; gate names read from `script/gates`. | 2026-11-05 |
| [`SECURITY.md`](../SECURITY.md) | Checked that the core raises `NoCurrentUserFoundError` rather than falling open, and that authorisation is CanCan-based (`app/models/laiss_cms/permissions.rb`). | 2026-11-05 |
| [`CODE_OF_CONDUCT.md`](../CODE_OF_CONDUCT.md) | Contributor Covenant 2.1 text, standard. | 2026-11-05 |
| [`docs/versioning.md`](versioning.md) | `LaissCms::VERSION` is the only source; gemspec and dashboard read from it; `gem build` succeeded and reported version `0.1.0.beta7`. | 2026-11-05 |
| [`docs/release-readiness.md`](release-readiness.md) | Every claim this project makes, marked VERIFIED with how, or UNVERIFIED with what would prove it. Regenerate the mechanical rows with `script/audit`. | 2026-11-05 |
| [`docs/site-sync.md`](site-sync.md) | Rewritten: it documented a GitHub Actions dispatch that has been withdrawn. Now describes the Coolify deploy path and states plainly that a docs change is published by redeploying the site. | 2026-11-05 |
| [`docs/design/reference-spec.md`](design/reference-spec.md) | Measurements taken with PIL from the supplied reference set; the method is stated in the file. Describes the owner's **target** design, not current behaviour. | 2026-11-05 |
| [`docs/design/focus-migration-log.md`](design/focus-migration-log.md) | **Reverted, not guidance.** The record of an abandoned Focus-theme migration, kept as evidence and warning. Nothing in it describes the software at HEAD. | 2026-11-05 |
| [`guides/getting_started.md`](../guides/getting_started.md) | Every command executed end to end. Claims about the seeder and the first-user role checked against behaviour. The sidebar-collapse claim was corrected: there is no expand toggle, the rail simply collapses on the editor and restores on leaving it. | 2026-11-05 |
| [`guides/extensions.md`](../guides/extensions.md) | What ships is verified against the gemspecs. | 2026-11-05 |
| [`guides/how_to_customize_tinymce.md`](../guides/how_to_customize_tinymce.md) | Rewritten from `lib/laiss_cms/tinymce.rb` and `bundles/tinymce.js` — the toolbar string, plugin list, `valid_elements` and formats were copied from the code, not retyped. | 2026-11-05 |

## Spot-checked, not read line by line

Each of these had **specific factual claims verified against the code**, but the
document as a whole was not read end to end. A specific example or option name
elsewhere in the page may still be wrong.

| Document | Claims verified |
| --- | --- |
| [`guides/tags.md`](../guides/tags.md) | Gutentag is the tagging engine (gemspec dependency). |
| [`guides/languages.md`](../guides/languages.md) | `language_code`, `country_code` and a per-site `default` flag exist on `LaissCms::Language`. |
| [`guides/sites.md`](../guides/sites.md) | `host` is present and unique case-insensitively (`LaissCms::Site` validations). |
| [`guides/library.md`](../guides/library.md) | Pictures and attachments are separate models; variants are generated (`PictureVariant`). |
| [`guides/elements.md`](../guides/elements.md) | Elements and page layouts are covered here (8 references); page layouts are defined in `page_layouts.yml`. |
| [`guides/ingredients.md`](../guides/ingredients.md) | Ingredient types match `app/models/laiss_cms/ingredients/`. |
| [`guides/pages.md`](../guides/pages.md) | Pages hold no content directly; tree behaviour comes from `awesome_nested_set` per the gemspec. |
| [`guides/menus.md`](../guides/menus.md) | Menus are modelled as nodes (`LaissCms::Node`), separate from the page tree. |
| [`guides/i18n.md`](../guides/i18n.md) | Said to install a separate `laiss_cms_i18n` gem. All locales now ship inside `laiss_cms`, so the install snippet was replaced with a note that there is nothing to install. |
| [`guides/seeder.md`](../guides/seeder.md) | The seeder skips page seeding when `LaissCms::Page.exists?` — proven by running it twice. |

## NOT verified

These have **not** been read against the code. Read them with suspicion; they were
carried over and may describe behaviour that has since changed.

`guides/render_images.md`, `guides/configuration.md`,
`guides/how_to_create_a_blog.md`, `guides/how_to_create_a_contact_form.md`,
`guides/how_to_create_custom_ingredients.md`, `guides/how_to_create_modules.md`,
`guides/how_to_extend_laiss_cms.md`, `guides/how_to_add_custom_authentication.md`,
`guides/how_to_integrate_into_existing_rails_app.md`, `guides/deployment.md`,
`guides/how_to_deploy_with_kamal.md`, `guides/upgrading.md`, `guides/about.md`,
`guides/README.md`, `guides/index.md`

`configuration.md` is the most consequential of these — it claims to document every
option. The authoritative source for options is
`lib/laiss_cms/configurations/main.rb`, which is generated from the options
themselves.

## Deleted

Nothing was deleted in the audit: the only guide describing removed functionality
(`how_to_customize_tinymce.md`) was rewritten instead, because the extension point
still exists and only its contents were wrong. If a guide for a genuinely removed
feature turns up, delete it — a guide for something deliberately gone is a lie
rather than a gap.

## Two steps that fail silently

Called out here because losing them wastes an afternoon:

1. **`bin/rails active_storage:install`** must run before `db:migrate`. Without the
   ActiveStorage tables the engine boots and every image upload fails.
2. **`bin/rails db:seed`** must run after `laiss_cms:install`. The installer appends
   `LaissCms::Seeder.seed!` to `db/seeds.rb` but never executes it, so there is no
   site, no language and no root page — and because a page needs a parent, pages
   cannot be created at all.

## How this stays honest

- Change behaviour and the document in the same commit. A separate "docs pass" is
  how the drift happened here the first time.
- Update a row only when you actually read that document against the code.
- The suite checks behaviour, not prose accuracy. A guide can be wrong while its examples pass.
  CI checks that internal links resolve. Accuracy is on the reviewer.
- Every command block in the documentation is meant to be executable. If you paste
  one and it fails, that is a documentation bug, not a user error.
