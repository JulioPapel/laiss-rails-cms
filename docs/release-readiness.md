# Release readiness

What this project claims about itself, and how each claim was established. Written
for a reader deciding whether a beta is safe to publish.

Regenerate the mechanical rows with `script/audit`; run the suites with
`script/gates`. This document is a reading of the repository on 2026-11-05 at
`5b2223d3e`, and the two scripts are how to check whether it is still true.

> ## Superseded by 0.1.0.beta7 (2026-11-05)
>
> The rows below were established at `5b2223d3e` for **beta6** and are kept as that
> record. They are correct as a statement about that commit; several are no longer
> correct about the current release. **Verified against HEAD at `852664b85`:**
>
> | Row | Says | Actually, at beta7 | Why it moved |
> |---|---|---|---|
> | 1 | Version is `0.1.0.beta6` | **`0.1.0.beta7`** | release bump |
> | 2 | Tag `v0.1.0.beta6` | **`v0.1.0.beta7`** | release bump |
> | 3 | 427 tag names on origin | **425** | beta1–beta5 tags were removed after that reading |
> | 4 | Core suite — 4410 examples | **4399** | the restored original suite's own count |
> | 7 | JavaScript suite — 846 tests | **823** | theme-toggle tests removed with the toggle |
> | 9 | All 15 gates pass | **12 gates** | the per-screen migration-log gate was retired |
> | 13–15 | install checks against the beta6 tag | **re-verified against beta7** | see below |
>
> **Rows 13–15 were re-run against `v0.1.0.beta7` on 2026-11-06.** Both proofs were
> performed from scratch with `stdin` closed, installing from the remote tag exactly as
> the release notes instruct:
>
> **No-auth app** — `gem "laiss_cms"` + `propshaft` only.
> `bundle install` resolved `laiss_cms (0.1.0.beta7 b7d33c9)`. `active_storage:install`,
> `laiss_cms:install`, `db:migrate`, `db:seed` all exit 0; the seed created 2 pages
> (Index + About). `GET /` → **200**. `GET /admin` → 301 → `/admin/dashboard` → **500
> `LaissCms::NoCurrentUserFoundError`**, which is the documented behaviour for an app
> with no `current_user`: it fails closed, with no admin markup in the response body
> (`id="laiss_cms"` appears zero times). No `::Devise`, no `LaissCms::User`.
>
> **Devise app** — the same plus `gem "devise"`.
> `bundle install` resolved `laiss_cms (0.1.0.beta7 b7d33c9)` and `devise (4.9.4)`.
> `active_storage:install`, `laiss_cms:install`, `g laiss_cms:devise:install`,
> `db:migrate`, `db:seed` all exit 0; 2 pages seeded. `::Devise` and `LaissCms::User`
> defined, 39 routes. `GET /` → 200; `/admin/login` → 302 → `/admin/signup`, which
> renders **200** with a password field (the first-user flow).
>
> **One defect found by these proofs, now documented in the release notes and README:**
> the release notes listed no `require "laiss_cms/devise"` step. An app with `devise` in
> its Gemfile and no such require **does not boot at all** —
> `uninitialized constant LaissCms::Devise`, from `lib/laiss_cms/engine.rb:41`.
> Reproduced from a clean app, and fixed by adding the require after `Bundler.require`.
> An app without the `devise` gem boots fine either way. The docs are corrected; **the
> artefact is unchanged**, so this is a documentation defect, not a code regression
> introduced by beta7 — the initializer predates the restore point (`d612ce798`).
>
> Row 22 (173 refs, 42 documents) was re-checked and **is still accurate**.
>
> The "four CI jobs" phrasing is also stale: the workflows are parked in `ci-disabled/`
> and none has run (rows 23, 24, 30). Verification is local, via `script/gates`.

**In one line:** the software is well tested locally and the delivery machinery has
never executed once. Publication readiness depends on clearing a billing lock and
watching four CI jobs run for the first time.

---

## Claims and their evidence

| # | Claim | Status | How established, or what would prove it |
|---|---|---|---|
| 1 | Version is `0.1.0.beta6` and is the single source | **VERIFIED** | `script/audit`: constant and gemspec agree; `gem build` succeeds |
| 2 | Tag `v0.1.0.beta6` exists, annotated, on the released commit | **VERIFIED** | `git cat-file -t` → tag; present on origin |
| 3 | 427 tag names on origin, none moved or deleted | **VERIFIED** | `git ls-remote --tags` distinct count; earlier tags' shas unchanged |
| 4 | Core suite passes — 4410 examples | **VERIFIED** | `script/gates ruby` from a cold clone at the tag |
| 5 | Devise suite passes — 167 examples | **VERIFIED** | Same run, **and** independently from the repo root and from `devise/` |
| 6 | Suite is order-independent | **VERIFIED** | Four full runs at seeds 1234, 98765, 4242, 31337 — all clean |
| 7 | JavaScript suite passes — 846 tests | **VERIFIED** | `script/gates js` in a cold clone |
| 8 | Lint clean (eslint, prettier, herb-lint, standardrb) | **VERIFIED** | `script/gates` |
| 9 | All 15 gates pass from a cold clone | **VERIFIED** | Fresh clone, no lockfile, no node_modules, no test DB |
| 10 | The gate prepares its own test database | **VERIFIED** | Deleted the DB, re-ran, 471 KB file recreated with an in-run mtime |
| 11 | Example counts cannot silently rot | **VERIFIED** | Gate fails on a count differing from `BASELINE_*`; CI reads the same constants |
| 12 | Ruby requirement matches tested versions | **VERIFIED** | `>= 3.4.0`; 3.4.12 and 4.0.6 both exercised. Narrowed from 3.1, which was never run |
| 13 | Install works from the published tag, no auth | **VERIFIED** | Fresh `rails new`; resolved `0.1.0.beta6`; install + seed → 2 pages; `GET /` 200 |
| 14 | Install works from the published tag, with auth | **VERIFIED** | Same app + devise → `::Devise`, `LaissCms::User`, 167 routes |
| 15 | Engine boots with no `devise` in the bundle | **VERIFIED** | No `::Devise`, no `LaissCms::User`, no auth routes; rest of CMS works |
| 16 | App without an asset pipeline gets a named boot error | **VERIFIED** | `LaissCms::AssetPipelineMissing` naming `gem "propshaft"`; gate negative-tested |
| 17 | No upstream name outside the licence files | **NOT AUTOMATED** | The leak-scan gate was removed with the migration tooling. Now a review obligation; `CONTRIBUTING.md` gives the search to run |
| 18 | Licence obligations met | **VERIFIED** | Upstream body byte-identical in `LICENSE` and `devise/LICENSE` (BSD-3), `i18n/LICENSE` (MIT), vs upstream `0883684917` |
| 19 | No personal PII shipped | **VERIFIED** | `script/audit`: zero matches; `gem.email` removed and the built `.gem` inspected |
| 20 | No absolute local paths shipped | **VERIFIED** | `script/audit`: zero matches |
| 21 | No coverage artifacts committed | **VERIFIED** | 33 removed; `script/audit` confirms zero tracked |
| 22 | Docs links, images and anchors resolve | **VERIFIED** | `script/check_doc_links`: 173 refs across 42 documents |
| 23 | No GitHub Actions workflows | **VERIFIED** | `.github/workflows/` is empty; `script/audit` confirms |
| 24 | Parked workflows are documented and inert | **VERIFIED** | Three files in `ci-disabled/` with a README; GitHub does not read that path |
| 25 | Gate script is portable to a GNU runner | **VERIFIED** (statically) | No `realpath`/`stat`/`xargs`/GNU-only flags; `sed -i.bak` is the portable form; `mktemp -d` POSIX |
| 26 | Site builds from the CMS repo | **VERIFIED** | Built locally against the tag: 36 pages, 0 link errors |
| 27 | Site install instructions match the packaging | **VERIFIED** | Built `_site/index.html`: one Gemfile line plus optional devise |
| 28 | Deployment path is Coolify pulling the repo | **VERIFIED** | No dispatch exists; recorded in `ci-disabled/README.md` and `docs/site-sync.md` |
| 29 | A release is a tag plus a local gate run | **VERIFIED** | `script/gates` green at the tagged commit; the tag is the distribution |
| 30 | CI has ever run a job | **NOT APPLICABLE** | The project does not use GitHub Actions. Not a gap; a decision |
| 31 | A GitHub Release exists | **NOT APPLICABLE** | No release automation. Consumers install from git at the tag |
| 32 | The site rebuilds without a dispatch | **NOT APPLICABLE** | No dispatch; Coolify pulls the site repo and builds it there |
| 33 | **Ruby 3.4 / Rails 7.2 passes** | **PARTIAL** | 4298 non-JS examples, 0 failures. The 112 JS failures were a missing browser, not Rails 7.2 — the same specs failed identically in the main checkout with the same broken PATH |
| 34 | **Ruby 3.1 / Rails 7.2 passes** | **WITHDRAWN** | 3.1 is not installable here. The requirement was narrowed to `>= 3.4` rather than leave an untestable promise |
| 35 | Dependabot does not open new PRs | **NOT APPLICABLE** | Config removed from the repository |
| 36 | Seven open Dependabot PRs remain | **OPEN ITEM** | Cannot be evaluated without Actions. Owner decision to close or leave |
| 37 | The 424 inherited upstream tags are harmless | **JUDGEMENT** | They exist publicly. Nothing depends on them. Owner decision |

---

## What is load-bearing and what is not

**Trustworthy:** rows 1–29. These were established by running something, usually from
a cold clone at a published tag, not by reading code.

**Not applicable, by decision:** rows 30–32, 35–36. The project does not use GitHub
Actions. These are not gaps waiting to close; they describe infrastructure that was
deliberately switched off after an account was billed for Actions minutes elsewhere.

**Deliberately withdrawn:** row 34. The gemspec no longer claims 3.1.

**Not mine to decide:** row 37, and whether a project whose verification is entirely
local should be published at all.

## Verification is local, and that is the design

**This project does not use GitHub Actions.** `script/gates` run locally is the
verification, not a rehearsal for a server-side check. There is no build on the other
end to catch what a local run misses.

That has a cost worth naming: **a contributor who does not run `script/gates` gets no
warning from anywhere.** There is no status check, no badge, no red mark on a pull
request. The gate is the whole enforcement.

It is also why two real defects were found by *executing* the old workflow steps
locally rather than reading them — an authentication-spec job that could not pass from
the repository root, and a count floor that had gone stale. Both would have failed on
the first server-side run. There is no such run any more, so the local gate has to be
run honestly and its failures taken seriously.

## To publish

1. `script/gates` green at the commit you intend to tag.
2. `script/audit` for the mechanical facts.
3. Tag it, push the tag. The tag is the distribution.
4. Redeploy the documentation site in Coolify if the docs changed — nothing here
   triggers that.
