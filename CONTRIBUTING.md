# Contributing

laiss-rails-cms is a **private, in-house project**. It has no public issue
tracker and no open contribution process: raise changes with the Laiss Labs team
directly.

## Working on the engine

```bash
bundle install
pnpm install --frozen-lockfile
pnpm run build

RAILS_ENV=test bundle exec rake laiss_cms:test:prepare
bin/rspec spec          # core
bin/rspec devise/spec   # devise engine
```

Gates that must be green before a change lands:

```bash
bundle exec standardrb
pnpm run eslint && pnpm run lint && pnpm exec herb-lint
pnpm run test
script/rebrand/verify
```

Expected counts are documented in
[docs/development/toolchain-pinning.md](docs/development/toolchain-pinning.md).
A **drop** in example count is a failure even at "0 failures" — it means files
stopped loading. The only legitimate drops are recorded in `CHANGELOG.md`.

After editing anything in `app/javascript` or `app/stylesheets`, run
`pnpm run build` and commit the artefacts under `app/assets/builds/`: consumers
load them without a Node toolchain.

## Keeping up with upstream security fixes

This repository carries the upstream project's full history and has an
`upstream` remote for exactly this purpose. **Both `origin` and `upstream` have
their push URLs disabled** so nothing can be pushed to upstream by accident.

```bash
# Fetch upstream changes (read-only)
git fetch upstream

# Find a security fix by its CVE or subject
git log upstream/main --oneline --grep='CVE'
git log upstream/main --oneline --since='3 months ago' -- '*security*'

# Cherry-pick it onto our branch
git cherry-pick <sha>
```

Cherry-picking will usually conflict, because every identifier in this
codebase was renamed during the fork (namespace, engine name and database table
prefix all differ from upstream). Resolve conflicts **towards our naming** — the
canonical mapping lives in `script/rebrand/mapping.yml` — and then
then confirm the mapping table still describes reality:

```bash
script/rebrand/verify     # fails if any upstream token leaked back in
bin/rspec spec && bin/rspec devise/spec
```

Add a `CHANGELOG.md` entry under `Unreleased` describing the fix and naming the
upstream commit, so the provenance of a security patch is auditable without
repeating the upstream product name in code.

Do **not** merge `upstream/main` wholesale: that would reintroduce upstream
branding, publishing automation and documentation for a different product.

## Licence

BSD-3-Clause. See [LICENSE](LICENSE). The upstream copyright notices are
retained there as the licence requires; do not remove them.
