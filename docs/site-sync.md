# Keeping the documentation site in sync

The documentation site at **railscms.laiss.pt** renders from this repository, but it
lives in its own repo: `JulioPapel/site-laiss-rails-cms`.

## How it works

**Coolify pulls the site repository and builds it there.** This project does not use
GitHub Actions, and nothing in this repository triggers a rebuild — there is no
workflow, no dispatch, and no secret to configure here.

The site's build fetches this repository's markdown at a pinned ref and produces the
documentation from it. That means the published docs reflect whichever ref the site
is configured to build against, not whatever is on `main` at that moment.

## Publishing a documentation change

1. Merge the change here.
2. Tag it if it is a release (`v0.1.0.betaN`) — see `docs/releases/`.
3. In Coolify, redeploy the site against the new ref, or wait for the next scheduled
   build if one is configured.

Which ref the site uses is set in the site repository, not here. Look for `CMS_REF`
in `JulioPapel/site-laiss-rails-cms` (`README.md` and `coolify.md`) — it accepts a
tag, a branch, or a full commit SHA.

## Why there is no automatic trigger any more

There used to be a workflow here that sent a `repository_dispatch` event to the site
repository on a green `main` or a tag push. It is parked in `ci-disabled/` with the
rest of the Actions files and it **never ran successfully** — it was blocked by an
account-level billing lock from the day it was written.

It is not coming back without an explicit decision to re-enable GitHub Actions, which
this project does not currently use. If that ever changes, `ci-disabled/README.md`
records what each parked file did and what was and was not proven about it.

The important consequence: **a docs change is not published by pushing it.** It is
published when the site is rebuilt.
