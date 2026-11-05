# Authentication

Devise-based authentication for `laiss_cms`. The integration ships inside the
engine; there is no separate authentication gem to install.

`devise` itself is **not** a dependency of `laiss_cms`. A host app that supplies
its own user model and sign-in must be able to boot without it, so the
integration does nothing until asked for.

## Turning it on

```ruby
# Gemfile
gem "laiss_cms", git: "https://github.com/JulioPapel/laiss-rails-cms.git", tag: "<tag>"
gem "devise", "~> 4.9"
```

```ruby
# config/application.rb, after `require "laiss_cms"`
require "laiss_cms/devise"
```

Then:

```bash
bin/rails g laiss_cms:devise:install
bin/rails db:migrate
```

Without the `require`, there is no `LaissCms::User`, no `/admin/login`,
`/admin/signup`, `/admin/logout` or `/admin/passwords` route, and no admin user
screen. The rest of the CMS works normally.

## Where the code lives, and why

| Path | Contents |
| --- | --- |
| `lib/laiss_cms/devise.rb` | The public entry point and `available?` |
| `lib/laiss_cms/devise_app/` | `LaissCms::User` and the admin controllers |
| `lib/laiss_cms/devise_support/` | The Railtie, config, install generator, patch |

None of it is under `app/`, deliberately. Rails eager loads that tree in
production, so an app without the `devise` gem failed at boot with
`uninitialized constant Devise`. `lib/laiss_cms/devise_app` is added as an
autoload root only when the integration loads.

The integration is a Railtie rather than an Engine: as an engine its root became
the `laiss_cms` gem root and Rails loaded `config/routes.rb` a second time.

## Specs

They live in `devise/spec/` and run in their own process, because the core specs
boot the dummy app *without* the integration so the `DummyUser` stub path stays
covered. `bin/rspec` handles the split.

## Licence

BSD-3-Clause, retained from the upstream `laiss-cms-devise` gem. `LICENSE` in this
directory is the authoritative copy and is kept verbatim, including the upstream
copyright and contributor attribution, which the licence requires.

## History

`CHANGELOG.md` is the upstream changelog from before this code was folded into the
engine. It is kept for attribution, not as a description of this repository's
releases.
