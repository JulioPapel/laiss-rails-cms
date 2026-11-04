# Toolchain pinning

This repository is pinned to exact tool versions so a fresh clone is reproducible
and nobody loses an afternoon to a version mismatch. If a command below fails with
a version error, the pin is the first place to look.

## Pinned versions

| Tool | Version | File | Why this version |
|---|---|---|---|
| Ruby | **4.0.6** | `.tool-versions`, `.ruby-version` | The Ruby that ships Bundler **4.0.16** as its default gem |
| Bundler | **4.0.16** | implied by Ruby; recorded in `Gemfile.lock` | The `BUNDLED WITH` the lockfile was generated with |
| Node | 24.x | `.tool-versions`, `package.json` (`engines`) | Matches the upstream CI matrix |
| pnpm | **11.14.0** | `.tool-versions`, `package.json` (`packageManager`) | Exact version pinned by `packageManager`; installed via `corepack` |

## The 4.0.7 trap

`.ruby-version` used to say `ruby-4.0`, which is a **partial** version. mise
resolves a partial version to the newest installed patch, which on this machine is
**4.0.7**. That Ruby ships Bundler **4.0.20**, not the 4.0.16 recorded in
`Gemfile.lock`, so any `bundle` command fails with:

```
can't find gem bundler (= 4.0.16) with executable bundle (Gem::GemNotFoundException)
```

Two ways out, and this repo takes the first:

1. **Pin Ruby exactly** (what we do). `.tool-versions` and `.ruby-version` both name
   `4.0.6`, so mise selects the Ruby whose default Bundler matches the lockfile.
2. Install Bundler 4.0.16 into 4.0.7 (`gem install bundler -v 4.0.16`). Works, but it
   is a per-machine manual step that a fresh clone does not inherit.

**`.tool-versions` wins over `.ruby-version` in mise**, so both files must agree. If
you edit one, edit the other — a stale `.tool-versions` silently overrides the pin.

## Verifying the pin

```bash
cd ~/Projects/laiss-rails-cms
ruby -v                       # must print 4.0.6
bundle -v                     # must print 4.0.16
tail -2 Gemfile.lock          # must show "BUNDLED WITH / 4.0.16"
bundle check                  # must say dependencies are satisfied
pnpm --version                # must print 11.14.0
```

If `bundle check` reports missing gems, run `bundle install`. Do **not** delete
`Gemfile.lock` to "fix" a version error: it is gitignored here, so it is only ever a
local artefact, but regenerating it under the wrong Ruby re-creates the mismatch.

## JavaScript toolchain

`pnpm` is not installed globally on this machine. It comes from `corepack`, which
ships with Node:

```bash
corepack enable pnpm
corepack prepare pnpm@11.14.0 --activate
pnpm install --frozen-lockfile
```

`--frozen-lockfile` is mandatory: it fails instead of silently resolving different
versions than `pnpm-lock.yaml` records.

## Gates and their expected results

Run these before calling any change done. Numbers are the upstream baseline and a
**drop in example/test counts is a failure even when the exit code is 0** — it means
files stopped being loaded.

```bash
bin/rspec spec --format progress          # 4347 examples, 0 failures
bin/rspec devise/spec --format progress   #  167 examples, 0 failures
bundle exec standardrb                    # clean

pnpm run eslint                           # clean
pnpm run lint                             # prettier --check, clean
pnpm exec herb-lint                       # clean (see caveat below)
pnpm run build                            # exit 0, no tracked files change
pnpm run test                             # 830 tests pass; see caveat below
```

### Caveat: herb-lint scans generated HTML

Herb lints every file it can find, including **gitignored build and test output**.
A coverage report or a Capybara failure screenshot left on disk will produce
hundreds of offences in files nobody wrote. If herb-lint fails, check the paths in
its output first: if they are under `coverage/`, `devise/coverage/` or
`spec/dummy/tmp/`, clear them and re-run.

```bash
rm -rf coverage devise/coverage spec/dummy/tmp/capybara
```

### Caveat: `pnpm run test` is genuinely flaky upstream

Vitest reports **all 830 tests passing** but the process frequently exits 1 with:

```
Unhandled Errors
Vitest caught 1 unhandled error during the test run.
TypeError: routes.url_admin_picture_path is not a function
```

originating from `spec/javascript/alchemy_admin/components/picture_editor.spec.js`.

**How often:** measured over 6 consecutive full runs on the untouched tree — 1 green,
5 red, every one with 830/830 tests passing. This is not a rare flake; it is the
normal outcome on this machine.

**Why:** `picture_editor.js:60` calls `routes.url_admin_picture_path(...)` inside
`updateImage()`, which runs from a `debounce(..., 125)` timer. The spec never
provides an `alchemy_routes` JSON script, so the imported `routes` object is `{}` and
the call is undefined. Whether the 125 ms timer fires while the spec is still on the
stack or after teardown completes is a race — which is why the run sometimes passes
and why the file always passes when run alone.

**Not fixed here.** This is upstream code and upstream test wiring; Phase 0 does not
edit source to make a gate green. Phase 1 (which rewrites `alchemy-*` custom element
tags and touches this component anyway) should fix it properly by mocking
`alchemy_admin/routes` in the spec the way `link_dialog.spec.js:6` already does.

**Until then:** `script/rebrand/gates` retries vitest once and only fails if tests
actually fail or the count is wrong, but you should expect a red exit and verify the
count is 830 before treating it as real.
