# Versioning

laiss-rails-cms has its **own version sequence**, starting at `0.1.0`.

The upstream project it was forked from was at 9.x. Our numbering deliberately
does **not** continue that sequence, so the two cannot be confused: a `0.x` from
this repository is not an early upstream release, and a `9.x` is not ours.

## The rule

- We follow [Semantic Versioning](https://semver.org/) from `0.1.0` onward.
- Pre-releases are `0.x.y.betaN`, e.g. `0.1.0.beta1`, `0.1.0.beta2`.
- While the major number is `0`, a breaking change may land in a minor bump
  (`0.1.0` → `0.2.0`). This is normal semver behaviour for pre-1.0 and is why we
  are explicit about it here.
- Once we reach `1.0.0`, breaking changes require a major bump.

## Where the version lives

**One constant:** `lib/laiss_cms/version.rb` → `LaissCms::VERSION`.

Everything else reads from it:

| Consumer | How it gets the version |
| --- | --- |
| `laiss_cms.gemspec` | `gem.version = LaissCms::VERSION` |
| Admin dashboard "system info" card | `LaissCms.version` (server-rendered) |
| `gem build` | from the gemspec, so from the constant |
| Git tag | `v` + the constant, e.g. `v0.1.0.beta1` |

A bump is therefore a single edit to `version.rb`, plus the tag and the release
notes file. `package.json` is intentionally **not** versioned: it describes the
asset build, is never published, and a second version number would only drift.

## Releasing

1. Edit `LaissCms::VERSION`.
2. Add the entry to `CHANGELOG.md` under a heading matching the new version.
3. Write `docs/releases/v<version>.md`.
4. Commit.
5. Tag: `git tag -a v<version> -m "laiss-rails-cms <version>"`.
6. Push the tag. The `release` workflow turns it into a GitHub Release using
   `GITHUB_TOKEN` only.

**There is no RubyGems publishing, and there never will be.** This gem is
consumed as a path or git dependency. No workflow in this repository runs
`gem push`, and none should be added.

## Why not continue upstream's numbering

Continuing at 9.x would imply this fork tracks upstream's release train. It does
not: upstream fixes are cherry-picked when they matter, not merged wholesale, and
the feature set has diverged. An independent sequence is the honest signal —
`0.x` means "young fork, expect movement", which is exactly the current state.

The derivation from upstream is recorded in `LICENSE`, as the BSD-3-Clause
licence requires, and nowhere else in the tree. The version number is not a place
to disclose it.
