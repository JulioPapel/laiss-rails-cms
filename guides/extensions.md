# Extensions

`laiss-rails-cms` has **no third-party extension ecosystem.** This fork is
maintained by Laiss Labs, and nothing is published to RubyGems.

Earlier versions of this page listed an "official" set of extensions — an
e-commerce integration, JSON:API and GraphQL APIs, PostgreSQL search, and others
— each linking to a GitHub organisation and installing from RubyGems. **None of
that applies to this fork.** Those packages are not maintained here, are not
installable through this project, and the links would not resolve.

What actually ships in this repository:

| Gem | What it is |
| --- | --- |
| `laiss_cms` | The engine, including all translations and the authentication code |
| `devise` | Optional third-party gem the authentication integration activates |

There is one gem to install, consumed from git at a tag. Authentication ships
inside `laiss_cms` but is opt-in: add `require "laiss_cms/devise"` to
`config/application.rb`. Without it the engine has no user model and no sign-in
routes, which is what you want when the host app brings its own.

See the [installation section of the README](../README#installation).

## Extending it yourself

You do not need an extension system for most customisation. In rough order of
how often you will need them:

**Content definitions** — the usual answer. Page layouts, elements and their
ingredients are YAML in `config/laiss_cms/`. Adding a content type is a config
change, not code:

- [Elements](elements)
- [Ingredients](ingredients)
- [Page layouts](elements#page-layouts)

**Custom ingredients** — when a field needs a control that does not exist yet:
[Creating custom ingredients](how_to_create_custom_ingredients).

**Admin extensions** — for a new screen inside the admin, with its own navigation
entry and permissions: [Creating modules](how_to_create_modules) and
[Extending the admin](how_to_extend_laiss_cms).

**CanCan abilities** — to add your own permission rules alongside the engine's
roles. Register your ability class with `LaissCms.config.abilities.add`.
See [Permissions](../CONTRIBUTING.md) for the naming contract.

**Authentication** — bring your own, or use the bundled integration:
[Custom authentication](how_to_add_custom_authentication).

## A note on installable gems

If you find a guide or a blog post referencing `laiss-cms-*` gems on RubyGems, it
predates this fork. Installing one will either fail or pull in a different,
unrelated codebase. The only supported source is this repository, at a tag.
