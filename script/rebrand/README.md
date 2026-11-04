# Rebrand tooling

Scripts that turn the AlchemyCMS fork into laiss-rails-cms. Everything here is
driven by one data file, so a token is renamed in exactly one place.

**Nothing in here has been run with `--write` against the repository.** Phase 0
built and proved the tooling; the rename itself is Phase 1 onward.

## Files

| File | Purpose |
|---|---|
| `mapping.yml` | The canonical naming table. One row per upstream token. Read by every other script. |
| `lib.rb` | Shared core: mapping loading, file discovery, matching, transform. |
| `apply` | Rewrites file contents. **Dry-run by default**; `--write` to apply. |
| `verify` | Guard. Fails if upstream tokens remain outside the licence allowlist, or if replacement tokens drifted in casing. |
| `self_test` | In-memory proof that the mapping round-trips and that corruption is caught. Never touches the tree. |
| `gates` | Runs every gate with the baseline numbers baked in. |

## Usage

```bash
ruby script/rebrand/self_test        # assert the tooling works
ruby script/rebrand/apply            # dry run: what would change
ruby script/rebrand/apply --write    # apply
ruby script/rebrand/verify           # is the tree fully rebranded?
script/rebrand/gates                 # all gates, or: gates ruby|js|rebrand
```

## How a token is matched

Each row in `mapping.yml` declares a `mode`:

- **`word`** — must not be flanked by `[A-Za-z0-9_]`. Used for constants and
  identifiers, so `Alchemy` never matches inside `AlchemyCMS`, and `myalchemy` is
  left alone.
- **`prefix`** — only the left side is anchored, so a following identifier character
  is part of the match. Used for `alchemy_` and `alchemy-`, where the whole point is
  to rewrite `alchemy_page` and `alchemy-icon`.
- **`literal`** — plain substring, no boundaries. Used for `Alchemy::`, which is
  always followed by an identifier character.

Rows are applied **longest pattern first**, so the most specific token always wins.
That is what stops `AlchemyCMS` becoming `LaissCmsCMS`. Ordering is deterministic:
equal-length rows keep their `mapping.yml` order.

## Idempotence

`apply` is safe to run twice. A second pass over an already-rebranded tree reports
zero changes, which `self_test` asserts and which `lib.rb` enforces structurally: it
refuses to load a mapping whose replacement value contains another row's upstream
token, because that combination could never be stable.

## Two bugs this tooling already caught

Both were found by building it, and both are recorded because they are the failure
modes a naive `sed` would ship:

1. **The tool rewrote its own mapping table.** With `script/rebrand` in scope, the
   first pass rewrote `mapping.yml`, replacing every `from` value with its `to`
   value. The second run then failed with "duplicate from tokens". `script/rebrand`
   is now excluded — it is the one place upstream tokens legitimately live, as data.
2. **Route helpers were flagged as drift.** A first drift rule treated
   `laiss_cms.new_admin_page_path` as "snake_case used as a constant". It is not:
   Rails prefixes route helpers with the engine's snake_case name (upstream:
   `alchemy.admin_element_path`). The rule now fires only on `laiss_cms::`, and
   `self_test` asserts the route-helper form is *not* flagged.

## Allowlisted files

`LICENSE`, `i18n/LICENSE`, `devise/LICENSE` are the only files permitted to contain
the upstream name. BSD-3-Clause requires the copyright notice, conditions and
disclaimer to be retained, and requires the upstream holder's name not be used to
endorse the derived product — which is exactly why everything else must be renamed.

`verify` fails if any of those three files goes missing, so the notices cannot be
deleted by accident.
