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

The payload names the ref to build against:

```json
{
  "event_type": "cms-docs-updated",
  "client_payload": {
    "ref": "v0.1.0.beta1",
    "ref_type": "tag",
    "sha": "<full commit sha>",
    "tag": "v0.1.0.beta1"
  }
}
```

On a **tag** push, `ref` is the tag name and `tag` is set, so a release builds
against that exact tag rather than against whatever `main` happens to be. On a
**branch** push, `ref` is the commit sha and `tag` is empty.

The site repo must check out `client_payload.ref`. Payloads are untrusted input:
validate that `ref` matches `^[0-9a-f]{40}$` or `^v[0-9A-Za-z.\-]+$` before
passing it to `git checkout`.

## When it fires

- **Push to `main`** where a documentation path changed (`docs/**`, `guides/**`,
  `README.md`, `CHANGELOG.md`). The path test runs inside the job rather than as a
  workflow filter: GitHub ANDs every filter under a single `push` key, so
  `branches` + `paths` + `tags` would require a *tag* push that also changed a
  docs file — every release would be skipped.
- **Push of any `v*` tag.** A release always rebuilds.
- **Manual dispatch**, for a forced rebuild.

A push that touches no documentation logs `No documentation changed` and stops.

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
