---
prev:
  text: Deployment
  link: deployment
next: false
---

# Updating LaissCms

This guide describes how to update LaissCMS to a new version.

## Update the Gem

Update the version constraint in your `Gemfile` and run bundler.

~~~ diff
-gem 'laiss_cms', '~> 8.0'
+gem 'laiss_cms', '~> 8.1'
~~~

If you use laiss-cms-devise for authentication, update it as well. The major and minor versions of `laiss_cms` and `laiss-cms-devise` match.

~~~ diff
-gem 'laiss_cms', '~> 8.0'
+gem 'laiss_cms', '~> 8.1'
-gem 'laiss-cms-devise', '~> 8.0'
+gem 'laiss-cms-devise', '~> 8.1'
~~~

Then run bundler.

~~~ bash
bundle update laiss_cms laiss-cms-devise
~~~

## Run the Upgrade Task

The upgrade task runs all necessary migrations and adjustments.

~~~ bash
bin/rails laiss_cms:upgrade
~~~

Follow the on-screen instructions. The task will inform you about changes and any manual steps required.

If you have `laiss-cms-devise` installed, re-run its install generator to pick up any changes.

~~~ bash
bin/rails g laiss_cms:devise:install
~~~

### Run Individual Upgrade Tasks

Upgrade tasks can also be run individually. For example, to run only the config upgrade:

~~~ bash
bin/rails laiss_cms:upgrade:config
~~~

List all available upgrade tasks with:

~~~ bash
bin/rails -T laiss_cms:upgrade
~~~

## Follow-ups

Most of the time the upgrader handles everything. But some upgrades require manual steps — these are listed as TODOs at the end of the upgrade output. Follow them carefully.

## Major Version Upgrades

Major versions follow the same upgrade process, but include breaking changes. They remove deprecated features and old upgrade tasks.

::: warning
Before upgrading to the next major version, make sure you have addressed all deprecation warnings and run all upgrade tasks in the current version first.
:::

## Upgrading in Production

After deploying a new version of the `laiss_cms` gem, database migrations run automatically via `db:prepare`.

The `laiss_cms:upgrade` task bundles several individual upgrade tasks. Some of these (like data migrations) need to run in production, while others (like config or file changes) are meant for development only. Check the output of `bin/rails -T laiss_cms:upgrade` and run the relevant tasks individually in production as needed.

## Verify the Upgrade

After upgrading:

1. Review the changes with `git diff`
2. Run your test suite
3. Check the [CHANGELOG](https://github.com/LaissCMS/laiss_cms/blob/main/CHANGELOG.md) for details on what changed
