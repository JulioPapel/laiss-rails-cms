# Dependabot is intentionally disabled

There is no `.github/dependabot.yml` in this repository, and that is deliberate.
**Re-add it once CI can run.**

## Why

Dependabot opened seven pull requests (npm, bundler and GitHub Actions updates).
Every one of them is red, because GitHub Actions cannot run on this repository:
the account is locked for billing, so jobs are created and then fail before a
runner is ever assigned. The check-run annotation GitHub itself attaches says:

> The job was not started because your account is locked due to a billing issue.

A dependency bump cannot be evaluated without a test run. Merging one on trust is
exactly the situation the gate script exists to prevent, and leaving seven
unverifiable proposals open trains everyone to ignore a red pull request list,
which is worse than having no proposals at all.

So the config was removed rather than left running. An absent config is
unambiguously inactive; an emptied one depends on how the service treats an empty
`updates` list, which is not worth relying on.

## What was removed

`.github/dependabot.yml`, which configured four ecosystems:

| Ecosystem | Directory | Schedule | Notes |
| --- | --- | --- | --- |
| npm | `/` | daily, 7-day cooldown, 30-day for majors | ignored `cropperjs` majors (2.x dropped the stylesheet `admin.scss` imports); grouped `rollup` minor/patch |
| npm | `/guides` | weekly | |
| bundler | `/` | daily | grouped dev-dependencies; grouped `rails` patch updates |
| github-actions | `/` | weekly | grouped all actions |

The `cropperjs` major-version ignore is worth preserving when the file comes back:
2.x removed the bundled stylesheet, and the upgrade needs a manual migration.

## Re-enabling

Restore the file, then let CI pass on `main` before trusting any of it. The seven
pull requests it already opened are still open; close them when the config
returns, so a fresh batch is raised against the current tree.

## The seven existing pull requests

They remain open and red. They were not closed, because closing them is a visible
change to the project's history that nobody asked for. If the owner wants the
list clear in the meantime, they can be closed with a note pointing here.
