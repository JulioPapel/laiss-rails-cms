# CI is disabled — parked workflow files

**This project does not use GitHub Actions.** These files are kept here, outside
`.github/`, so they are preserved as a record without ever running.

They were moved out because a GitHub account was billed for Actions minutes on a
private repository and became locked over the charge. Nothing in this repository
causes that bill — this repository is public and its Actions usage was free — but
the decision is to have zero Actions anywhere until the owner decides otherwise.

## What is here

| File | What it did |
| --- | --- |
| `ci.yml` | Ran `script/gates` in three jobs: Ruby specs, JavaScript, and a scratch-app check |
| `release.yml` | Created a GitHub Release from `docs/releases/<tag>.md` when a `v*` tag was pushed |
| `notify-site.yml` | Told the documentation site to rebuild after a green main or a tag |

None of them is required to ship a release. See "How verification works now".

## Do not move these back without a decision

Re-enabling any of them starts spending Actions minutes again. That is an owner
decision, not a maintenance task, and it should be made with the cost understood.
If they come back:

- `ci.yml` calls `script/gates`, which is the same command contributors run. It was
  verified by executing each job's steps locally before being parked.
- `release.yml` and `notify-site.yml` have **never run successfully** — they were
  blocked by the account lock from the day they were written. Their logic is
  simulated and reviewed but not proven. Do not assume they work.

## How verification works now

Everything runs locally, and it is the same set of checks:

```bash
script/gates        # specs, linters, build, JavaScript suite, doc links, scratch app
script/audit        # the release-readiness table with live evidence
```

Run `script/gates` before tagging. That is the whole verification story: there is no
server-side check, so the local result is the only result.

Deployment is unaffected. The documentation site is deployed by **Coolify**, which
pulls the repository itself; it never depended on these workflows.

## Releasing without Actions

There is no release automation, so a release is a manual sequence:

```bash
script/gates                                   # must pass
git tag -a v0.1.0.betaN -m "…"                 # annotated tag at the verified commit
git push origin v0.1.0.betaN                   # the tag itself is the distribution
```

The Release note is `docs/releases/<tag>.md`; if a GitHub Release object is wanted,
it is created by hand. Consumers install from git at the tag, so the tag is what
matters.
