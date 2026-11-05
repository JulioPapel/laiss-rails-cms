# Translations

Every supported locale ships inside `laiss_cms` itself. There is no separate
translation gem to install and no install generator to run.

## Using them

Nothing to add to the `Gemfile`. The locale files are on `I18n.load_path` as soon
as `laiss_cms` is required, so the only decision is which locale the admin uses:

```ruby
# config/application.rb
config.i18n.available_locales = [:en, :de, :fr]
config.i18n.default_locale = :en
```

Available: `en` `de` `es` `fr` `it` `nb-NO` `nl` `pl` `ru` `zh-CN`

## Where the files live

| Path | Contents |
| --- | --- |
| `config/locales/laiss_cms.en.yml` | English, the reference locale |
| `config/locales/extra/laiss_cms.<locale>.yml` | Every other locale |
| `config/locales/extra/laiss_cms_users.<locale>.yml` | Admin user screens |
| `config/locales/extra/laiss_cms_devise.<locale>.yml` | Devise's own messages |

Rails globs `config/locales/**/*.yml` from every engine root, so no initializer
is involved. An earlier attempt to add one registered `de` twice.

## Overriding a translation

Put your own file in the host app's `config/locales/` using the same tree. A host
app's load path comes after the engine's, so the later entry wins.

## Licence

The translation files are MIT licensed, as they were in the upstream
`laiss_cms_i18n` gem. `LICENSE` in this directory records that, and it is retained
verbatim.

## History

`CHANGELOG.md` is the upstream changelog from before these files were folded into
the engine. It is kept for attribution, not as a description of this repository's
releases.
