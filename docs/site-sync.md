# Keeping the documentation site in sync

The documentation site at **railscms.laiss.pt** renders from this repository, but
it lives in its own repo. Nothing about pushing here rebuilds it, so a workflow
tells it to.

## The contract

| | |
| --- | --- |
| Workflow in this repo | `.github/workflows/notify-site.yml` |
| Target repo | `JulioPapel/site-laiss-rails-cms` |
| GitHub event | `repository_dispatch` |
| Event type | `cms-docs-updated` |

The payload names the ref to build against. **The keys are `cms_ref` and
`cms_repo`** — the site repo reads `client_payload.cms_ref`, so a payload using a
different key is accepted by the API and then silently ignored:

```json
{
  "event_type": "cms-docs-updated",
  "client_payload": {
    "cms_ref": "v0.1.0.beta6",
    "cms_repo": "JulioPapel/laiss-rails-cms"
  }
}
```

`cms_ref` is the tag on a tag push, or the commit SHA otherwise, so a release
builds against that exact tag rather than whatever `main` happens to be by the
time the site builds.

The site repo must check out `cms_ref`. Payloads are untrusted input: validate
that it matches `^[0-9a-f]{40}$` or `^v[0-9A-Za-z.\-]+$` before passing it to
`git checkout`.

## When it fires

The workflow is the one in **`JulioPapel/site-laiss-rails-cms` →
`.github/cms-repo-notify-site.yml`**, copied here unchanged. It fires on:

- **A finished `CI` run on `main`** (`workflow_run`), and only when that run
  concluded `success`. A red `main` never republishes the docs. This is why there
  is no `paths` filter: a green main already implies a push, and filtering on
  paths would send the notification twice.
- **A `v*` tag push**, which publishes that tag whether or not CI has caught up.
- **Manual dispatch**, with an optional `cms_ref` to force a specific ref.

**This depends on the `CI` workflow existing and succeeding.** While GitHub
Actions cannot run on this repository (see the CI-blocked diagnosis in the project
store), `CI` never concludes successfully, so the `workflow_run` trigger never
fires. Tag pushes still dispatch, because they do not depend on CI.

## The secret

| | |
| --- | --- |
| Name | `SITE_DISPATCH_TOKEN` |
| Where it must be created | **`JulioPapel/laiss-rails-cms`** — *this* repository, under **Settings → Secrets and variables → Actions** |
| Why here | Secrets are scoped to the repo whose workflow reads them. The workflow runs here, so the secret lives here. Putting it in the site repo would do nothing. |
| What it must be able to do | `contents: write` on `JulioPapel/site-laiss-rails-cms` — enough to send a `repository_dispatch` |

### Creating it

Either of these works; a fine-grained PAT is simpler.

**Fine-grained personal access token**

1. GitHub → Settings → Developer settings → Personal access tokens →
   Fine-grained tokens → **Generate new token**.
2. **Repository access:** only `JulioPapel/site-laiss-rails-cms`.
3. **Permissions:** Repository permissions → **Contents: Read and write**.
4. Generate, copy the token.
5. In `JulioPapel/laiss-rails-cms` → Settings → Secrets and variables → Actions →
   **New repository secret**: name `SITE_DISPATCH_TOKEN`, value the token.

**GitHub App (better for an organisation)**

Install an app with `contents: write` on the site repo, then store its
installation token as `SITE_DISPATCH_TOKEN`. App tokens expire, so a PAT with an
expiry may need rotating; a note in the team calendar is cheaper than a silently
broken sync.

## If the secret is missing

The workflow **skips with a notice** rather than failing:

```
SITE_DISPATCH_TOKEN is not set; skipping the site rebuild.
```

This is deliberate. A contributor's fork has no access to the secret, and a docs
contribution must not fail CI because a deployment credential is absent. The
consequence is that the site will not update until the secret exists — so if
railscms.laiss.pt looks stale after a docs change, check this first.

## Why not use `GITHUB_TOKEN`

The built-in `GITHUB_TOKEN` is scoped to the repository running the workflow. It
cannot dispatch to a *different* repository. A PAT or App token is required
precisely because the target is another repo.
