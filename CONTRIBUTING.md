# Contributing to laiss-rails-cms

Thanks for taking the time. This file is the whole workflow: how to get it
running, what the rules are, and what a pull request has to pass.

## What this project is

A CMS engine for Rails, maintained by Laiss Labs. Content is modelled as **pages**
made of **elements**, and each element has typed **ingredient** fields.

It is **not** published to RubyGems. You consume it as a git or path dependency.
See [`docs/versioning.md`](docs/versioning.md).

## Getting it running

### Requirements

- Ruby (see `.ruby-version`; the gemspec requires `>= 3.4`)
- Rails `>= 7.2, < 8.2`
- Node 24 and pnpm 11 for the asset build

### Setup

```bash
git clone git@github.com:JulioPapel/laiss-rails-cms.git
cd laiss-rails-cms
bundle install
pnpm install
pnpm run build          # generates app/assets/builds, which are committed
```

### Remote access: SSH or a credential helper

**Push over HTTPS will fail on a machine with no credential helper**, with:

```
fatal: could not read Username for 'https://github.com'
```

That is not a permissions problem; git simply has nowhere to read a password
from. Pick one:

**SSH (recommended).** GitHub authenticates by key, and `git push` needs no
further setup:

```bash
# one key, one identity
ssh-keygen -t ed25519 -C "you@example.com"
# add the .pub to GitHub: Settings -> SSH and GPG keys -> New SSH key
ssh -T git@github.com            # expect: Hi <you>! You've successfully authenticated
git remote set-url origin git@github.com:JulioPapel/laiss-rails-cms.git
```

**HTTPS + a credential helper.** Required if you must use `https://` URLs:

```bash
# store a token (a Personal Access Token with `repo` scope, not your password)
git config --global credential.helper store      # writes ~/.git-credentials
# or, on macOS / Windows, the OS keychain:
git config --global credential.helper osxkeychain
git config --global credential.helper manager
```

The `gh` CLI being logged out does **not** mean git cannot push. They use
different credential stores. Check what actually matters with:

```bash
git push --dry-run origin HEAD
```

## Running the suites

```bash
bundle exec rspec spec            # core, ~4419 examples
bin/rspec devise/spec             # devise, ~167 examples, must run from its own bundle
pnpm exec vitest --run            # components, ~851 tests
```

`bin/rspec` runs each library from its own directory with its own bundle. Use it
when you want both suites together.

### Verify a checkout with one command

```bash
script/gates
```

That runs all twelve gates in order and prints a pass/fail table with the counts.
It is the same logic CI runs, so a green run here means the code is sound even if
GitHub Actions is unavailable. Use it before opening a pull request and before
trusting a tag.

It also takes a subset: `script/gates ruby`, `script/gates js`,
`script/gates rebrand`.

### The counts matter

CI asserts the example counts **do not drop**. A broken `require` makes RSpec load
fewer files, still exit 0, and still print "0 failures" — so without a floor the
suite can rot while CI stays green.

If you add specs, raise the floor in `.github/workflows/ci.yml` (`MIN_CORE`,
`MIN_DEVISE`, `MIN_VITEST`). Never lower it.

## Linting

```bash
bundle exec standardrb
pnpm run eslint
pnpm run lint          # prettier --check
pnpm exec herb-lint    # ERB
```

If `lint` or `herb-lint` lints the `coverage/` HTML and fails, clear it first:

```bash
rm -rf coverage devise/coverage spec/dummy/tmp/capybara
```

## The naming contract

The rebrand is **mechanical**, from one mapping:
[`script/rebrand/mapping.yml`](script/rebrand/mapping.yml). Do not hand-rename
things.

| Script | What it does |
| --- | --- |
| `script/rebrand/verify` | fails if a name appears in a forbidden casing or separator form |
| `script/rebrand/leak_scan` | fails if the upstream name appears anywhere outside the three `LICENSE` files |
| `script/rebrand/self_test` | tests the rebrand tooling itself |
| `script/rebrand/leak_scan_test` | tests the leak scanner |
| `script/rebrand/gates` | runs every gate with the baseline counts baked in |

### The rule this project makes publicly

The derivation from the upstream project is disclosed in `LICENSE`, because
BSD-3-Clause requires the copyright notice to be retained. It is disclosed
**nowhere else**: not in source, not in docs, not in comments, not in commit
messages. `script/rebrand/leak_scan` enforces that, and CI runs it, so a leak
fails the build.

### Tokens

Every existing configuration token name must keep resolving. Tokens are **added,
never renamed**, so host apps' overrides keep working.

## Design rules

See [`docs/design/reference-spec.md`](docs/design/reference-spec.md) for the
measured design system, and `docs/versioning.md` for release numbering.

- One light theme. The admin does not follow the OS appearance.
- Blue for the primary action and the current state; the brand accent only for
  the current state, and never as the sole signal.
- Borders are tiered: meaning-carrying boundaries (form controls, focus) clear
  3:1, decorative edges stay light. Measured, not eyeballed.
- Radius, spacing, control heights and type are `rem`, on one scale.
- Every interactive element has rest / hover / focus / active, and focus is never
  removed without a replacement.

## The rich-text editor policy

Body fields are **intentionally limited to inline formatting and lists**: bold,
italic, link, bulleted and numbered lists, blockquote, inline code, undo/redo,
clear formatting.

This is a design decision. Layout, headings and hierarchy come from element
definitions, so a body field must not be able to set type size or alignment —
that would let a writer break the page's structure.

Consequences, all deliberate:

- Tables, text colour, background colour, font family and size, alignment, the
  paragraph-format select, media insertion, source/HTML view and emoji are **not
  available**, and their plugins are **not loaded**.
- `valid_elements` is the backstop: anything outside the allowed set is stripped
  even on paste or programmatic insert.
- Paste is forced to plain text, so external styling cannot leak in.
- `app/stylesheets/laiss_cms/body-copy.scss` styles exactly the elements the
  editor can emit. **If you add a tag to `valid_elements`, add a rule there in the
  same commit** — otherwise that markup publishes unstyled.

Adding a button means adding its plugin to `DEFAULT_PLUGINS` in
`lib/laiss_cms/tinymce.rb` **and** to the imports in `bundles/tinymce.js`.

## Commits and pull requests

- One logical change per commit. Small and reviewable beats large and complete.
- Write the **why** in the message, not the what. "Fix the button" is useless;
  "the toolbar covered the Save button because the band height was assumed"
  explains the change and prevents the regression.
- Reference the issue if there is one.
- Do not rewrite published history on `main`. No force-push.

A pull request must satisfy the checklist in the template: gates run, leak scan
clean, counts not lowered, artifacts rebuilt.

## Upstream security fixes

This is a maintained fork, not a mirror. Upstream fixes are **cherry-picked when
they matter**, never merged wholesale, because the feature sets have diverged.

```bash
git fetch upstream
git log --oneline upstream/main ^main          # what we do not have
git show <sha>                                 # read before taking it
git cherry-pick <sha>                          # then fix up names if needed
```

After any cherry-pick:

1. Run `script/rebrand/verify` and `script/rebrand/leak_scan`. A cherry-picked
   commit can reintroduce the upstream name.
2. Run the full gate suite.
3. Mention the source commit in the message so the provenance is traceable
   without naming the project in the tree.

## Releases

See [`docs/versioning.md`](docs/versioning.md). In short: one constant, an
annotated tag, and a workflow that creates a GitHub Release from it.
**There is no RubyGems publishing, and adding it is not a welcome change.**

## Getting help

Open an issue. For security problems, do **not** open a public issue — see
[`SECURITY.md`](SECURITY.md).
