# Release readiness

What this project claims about itself, and how each claim was established. Written
for a reader deciding whether a beta is safe to publish.

Regenerate the mechanical rows with `script/audit`; run the suites with
`script/gates`. This document is a reading of the repository on 2026-11-05 at
`5b2223d3e`, and the two scripts are how to check whether it is still true.

**In one line:** the software is well tested locally and the delivery machinery has
never executed once. Publication readiness depends on clearing a billing lock and
watching four CI jobs run for the first time.

---

## Claims and their evidence

| # | Claim | Status | How established, or what would prove it |
|---|---|---|---|
| 1 | Version is `0.1.0.beta4` and is the single source | **VERIFIED** | `script/audit`: constant and gemspec agree; `gem build` succeeds |
| 2 | Tag `v0.1.0.beta4` exists, annotated, on the released commit | **VERIFIED** | `git cat-file -t` → tag; peeled to `d0f244e18`; present on origin |
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
| 13 | Install works from the published tag, no auth | **VERIFIED** | Fresh `rails new`; resolved `0.1.0.beta4`; install + seed → 2 pages; `GET /` 200 |
| 14 | Install works from the published tag, with auth | **VERIFIED** | Same app + devise → `::Devise`, `LaissCms::User`, 167 routes |
| 15 | Engine boots with no `devise` in the bundle | **VERIFIED** | No `::Devise`, no `LaissCms::User`, no auth routes; rest of CMS works |
| 16 | App without an asset pipeline gets a named boot error | **VERIFIED** | `LaissCms::AssetPipelineMissing` naming `gem "propshaft"`; gate negative-tested |
| 17 | No upstream name outside the licence files | **VERIFIED** | `leak_scan` over 1752 tracked files; tooling negative-tested with 3 probes |
| 18 | Licence obligations met | **VERIFIED** | Upstream body byte-identical in `LICENSE` and `devise/LICENSE` (BSD-3), `i18n/LICENSE` (MIT), vs upstream `0883684917` |
| 19 | No personal PII shipped | **VERIFIED** | `script/audit`: zero matches; `gem.email` removed and the built `.gem` inspected |
| 20 | No absolute local paths shipped | **VERIFIED** | `script/audit`: zero matches |
| 21 | No coverage artifacts committed | **VERIFIED** | 33 removed; `script/audit` confirms zero tracked |
| 22 | Docs links, images and anchors resolve | **VERIFIED** | `script/check_doc_links`: 173 refs across 42 documents |
| 23 | CI calls `script/gates` — one implementation | **VERIFIED** | `script/audit`; jobs: javascript, leak-scan, ruby, scratch |
| 24 | Every action ref in the workflows resolves | **VERIFIED** | Queried GitHub for each: three `@v4` tags, and `ruby/setup-ruby@v1` is a branch (valid, mutable) |
| 25 | Gate script is portable to a GNU runner | **VERIFIED** (statically) | No `realpath`/`stat`/`xargs`/GNU-only flags; `sed -i.bak` is the portable form; `mktemp -d` POSIX |
| 26 | Site builds from the CMS repo | **VERIFIED** | Built locally against the tag: 36 pages, 0 link errors |
| 27 | Site install instructions match the packaging | **VERIFIED** | Built `_site/index.html`: one Gemfile line plus optional devise |
| 28 | Dispatch payload matches the site's handler | **VERIFIED** (simulated POST) | `event_type` matches both site workflows; `cms_ref` is what both read; JSON parsed for all four triggers |
| 29 | Release workflow would create the Release | **SIMULATED** | `gh` argv checked with a stub; idempotent branch and `--generate-notes` fallback both verified. Never executed |
| 30 | **CI has ever run a job** | **UNVERIFIED** | Every job fails before a runner is assigned. Proved by: billing cleared and one green run |
| 31 | **A GitHub Release exists** | **UNVERIFIED — does not exist** | 0 releases; API create returns 401. Proved by: re-running the failed release workflow |
| 32 | **The site auto-rebuilds on dispatch** | **UNVERIFIED** | Never fired. Proved by: `SITE_DISPATCH_TOKEN` set, a runner, and one dispatch |
| 33 | **Ruby 3.4 / Rails 7.2 passes** | **PARTIAL** | 4298 non-JS examples, 0 failures. The 112 JS failures were a missing browser, not Rails 7.2 — the same specs failed identically in the main checkout with the same broken PATH |
| 34 | **Ruby 3.1 / Rails 7.2 passes** | **WITHDRAWN** | 3.1 is not installable here. The requirement was narrowed to `>= 3.4` rather than leave an untestable promise |
| 35 | **Dependabot will not open new PRs** | **UNVERIFIED** | Config deleted; only GitHub can confirm. Proved by: watching the PR list |
| 36 | **The 7 open Dependabot PRs are red only from the lock** | **UNVERIFIED** | Their jobs never started; the annotation says billing, which is all the evidence there is |
| 37 | The 424 inherited upstream tags are harmless | **JUDGEMENT** | They exist publicly. Nothing depends on them. Owner decision |

---

## What is load-bearing and what is not

**Trustworthy:** rows 1–27. These were established by running something, mostly from
a cold clone at a published tag, not by reading code.

**Depends entirely on GitHub:** rows 30–32, 35–36. One dependency, not many. Clearing
the billing lock and watching one green run converts most of them to verified or to a
concrete bug.

**Deliberately withdrawn:** row 34. The gemspec no longer claims 3.1.

**Not mine to decide:** row 37, and whether a project whose CI has never run should
be published at all.

## Why the CI gap matters more than it looks

Two defects were found by executing `ci.yml`'s steps rather than reading them, both of
which would have failed on the very first run:

- The devise spec job could not pass. It ran rspec from the repository root, which
  loaded the core spec helper and left the integration inactive. `script/gates` passed
  because it goes through `bin/rspec`, which changes directory.
- The `counts` job hardcoded floors of 4419/851 against real counts of 4410/846.

Had billing not been locked, **beta2 and beta3 would have shipped with red CI.** The
lock did not cause the broken workflow; it hid it. That is the argument for not
publishing on local evidence alone, however thorough the local evidence is.

## To publish

1. Clear the billing lock.
2. Let CI run to completion on `main`. It will be the first run ever; expect it to
   find something.
3. Re-run the failed "Release" workflow — it creates the Release from
   `docs/releases/v0.1.0.beta4.md` with no new tag needed.
4. Confirm the site rebuild fires from the dispatch.
