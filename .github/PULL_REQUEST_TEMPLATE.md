## What this changes

<!-- One or two sentences. The "why" matters more than the "what". -->

## Why

<!-- The situation that made this necessary. Link the issue if there is one. -->

## Checklist

- [ ] **Gates run locally.** `script/rebrand/gates` passes — not just the specs.
- [ ] **Example counts did not drop.** Core ≥ 4419, devise ≥ 167, vitest ≥ 851.
      If I added specs, I raised the floors in `.github/workflows/ci.yml`.
- [ ] **Leak scan clean.** `script/rebrand/leak_scan` passes: no upstream name
      anywhere outside the three `LICENSE` files. The derivation is disclosed in
      `LICENSE` and nowhere else.
- [ ] **No upstream names in the diff** — source, comments, docs, or this
      description.
- [ ] **Build artifacts committed.** `pnpm run build` was run and the result
      committed; CI fails if they are stale.
- [ ] **Configuration tokens added, never renamed.** Every existing name still
      resolves.
- [ ] **Design rules followed** (`docs/design/reference-spec.md`): `rem` for
      radius/spacing/type, the contrast tiering, and focus never removed without a
      replacement.

## If this touches the rich-text editor

- [ ] `valid_elements` in `lib/laiss_cms/tinymce.rb` still describes exactly what
      the toolbar can produce.
- [ ] Any new tag in `valid_elements` has a matching rule in
      `app/stylesheets/laiss_cms/body-copy.scss`.
- [ ] Any new button has its plugin in `DEFAULT_PLUGINS` **and** in the imports in
      `bundles/tinymce.js`.

## Screenshots

<!-- For admin or public-facing changes. Before and after. -->

## Notes for the reviewer

<!-- Anything you are unsure about. Honest uncertainty is more useful than silence. -->
