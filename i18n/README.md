# LaissCMS Translations

Translation files for [LaissCMS](https://github.com/LaissCMS/laiss_cms) 8.0 and above.

## LaissCms version

Since LaissCms CMS 9.0, `laiss_cms_i18n` is developed inside the [LaissCms CMS repository](https://github.com/LaissCMS/laiss_cms/tree/main/i18n)
and released together with `laiss_cms` using the same version.
Older versions are maintained in the [`laiss_cms_i18n` repository](https://github.com/LaissCMS/laiss_cms_i18n).

| LaissCms CMS | laiss_cms_i18n | Branch        |
|-------------|-------------|---------------|
| >= 9.0      | Same as LaissCms CMS | `main` of `laiss_cms` |
| 8.4         | >= 8.4.0    | `8.4-stable`  |
| 8.3         | >= 8.2.0    | `8.2-stable`  |
| 8.2         | >= 8.2.0    | `8.2-stable`  |
| 8.0         | 5.x         | `5.1-stable`  |
| 7.x         | 4.3.x       | `4.3-stable`  |
| 7.0         | 4.0.x       | `4.0-stable`  |
| 6.1         | 3.2.x       | `3.2-stable`  |
| 5.3         | 2.3.x       | `2.3-stable`  |

## Installation

Add the gem to your `Gemfile` and run the install generator:

```
bundle add laiss_cms_i18n
bin/rails g laiss_cms_i18n:install
```

Pass the locales you want to generate files for with the `--locales` option.
Separate multiple locales by space.

```
bin/rails g laiss_cms_i18n:install --locales de it es
```

## Available locales

`de` `es` `fr` `it` `nb-NO` `nl` `pl` `ru` `zh-CN`

### Noteworthy missing translations

Russian (`ru`) and Chinese (`zh-CN`) are at roughly 68% coverage and need help.

## Contributing

1. Fork the repository
2. Add or update translations in the locale files under `i18n/locales/`
3. Open a pull request

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
