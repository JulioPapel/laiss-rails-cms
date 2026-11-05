---
prev:
  text: Rendering Images
  link: render_images
next:
  text: Deployment
  link: deployment
---

# Configuration

LaissCms is configured through a Ruby initializer at `config/initializers/laiss_cms.rb`. The install generator creates this file for you. All settings have sensible defaults — you only need to configure what you want to change.

### The Initializer

~~~ ruby
# config/initializers/laiss_cms.rb
LaissCms.configure do |config|
  config.output_image_quality = 85
  config.storage_adapter = "active_storage"
end
~~~

::: info NOTE
`LaissCms.configure` is available since 8.1. In 8.0, use `LaissCms.config.tap` instead.
:::

### Environment-Specific Configuration

Use Rails' standard environment files to override settings per environment.

~~~ ruby
# config/environments/production.rb
Rails.application.configure do
  LaissCms.config.cache_pages = true
end
~~~

## Default Site and Language

Used by the built-in onboarding to create the initial site, language, and frontpage.

~~~ ruby
config.default_site.tap do |default_site|
  default_site.name = "Default Site"
  default_site.host = "*"
end

config.default_language.tap do |default_language|
  default_language.name = "English"
  default_language.code = "en"
  default_language.page_layout = "index"
  default_language.frontpage_name = "Index"
end
~~~

## Images

See the [Rendering Images guide](render_images) for details on these settings.

### output_image_quality
`Integer` (Default: `85`)

Quality for rendered JPEG and WebP images.

### preprocess_image_resize
`String` (Default: `nil`)

Downsize images on upload. Example: `"1000x1000"`.

### image_output_format
`String` (Default: `"original"`)

Global output format. `"original"`, `"jpg"`, `"png"`, or `"webp"`.

### sharpen_images
`Boolean` (Default: `false`)

Enable image sharpening on rendered variants.

### storage_adapter
`String`

The storage backend for pictures and attachments. Either `"active_storage"` or `"dragonfly"` (the default). Can also be set via the `LAISS_CMS_STORAGE_ADAPTER` environment variable.

## Caching

### cache_pages
`Boolean` (Default: `true`)

Enable or disable page caching globally. You can also [control caching per page layout](pages#caching).

### page_cache

Controls the `Cache-Control` headers for cached pages.

~~~ ruby
config.page_cache.tap do |page_cache|
  page_cache.max_age = 600                  # max-age in seconds (default: 600)
  page_cache.stale_while_revalidate = 3600  # stale-while-revalidate in seconds (default: nil)
end
~~~

:::tip NOTE
When `stale_while_revalidate` is not set, LaissCms sends `must-revalidate` in the `Cache-Control` header instead.
:::

## Uploads

Configure upload limits and allowed file types.

~~~ ruby
config.uploader.tap do |uploader|
  uploader.upload_limit = 50
  uploader.file_size_limit = 100
  uploader.allowed_filetypes.tap do |file_types|
    file_types.laiss_cms_attachments = ["pdf", "zip"]  # default: ["*"] (all types)
    file_types.laiss_cms_pictures = ["jpg", "jpeg", "gif", "png", "svg", "webp"]  # default
  end
end
~~~

## Links

### link_target_options
`Array<String>` (Default: `["blank"]`)

Values for the link target select in the link dialog. Each value is stored with a leading underscore and rendered as the link's `target` attribute, so `blank` becomes `target="_blank"`.

If you render a link ingredient in your own view, pass the stored value through `LaissCms::Ingredients::LinkTarget#link_target_value` instead of comparing it yourself. It also maps the legacy `blank` value, stored before the underscore was added.

### link_dialog_tabs

Extend the link dialog with custom tabs. The default tabs are: Internal, Anchor, External, and File.

~~~ ruby
config.link_dialog_tabs << "Acme::LinkTab"
~~~

::: tip
laiss-cms-solidus provides a tab for linking to Solidus products.
:::

## Mailer

Configure LaissCms's built-in contact form mailer. See the [contact form guide](how_to_create_a_contact_form) for a full walkthrough.

~~~ ruby
config.mailer.tap do |mailer|
  mailer.page_layout_name = "contact"
  mailer.forward_to_page = false
  mailer.mail_success_page = "thanks"
  mailer.mail_from = "contact@example.com"
  mailer.mail_to = "admin@example.com"
  mailer.subject = "New contact form message"
  mailer.fields = ["name", "email", "message"]
  mailer.validate_fields = ["name", "email"]
end
~~~

## Sitemap

LaissCms generates a Google-compatible XML sitemap at `/sitemap.xml`.

~~~ ruby
config.sitemap.tap do |sitemap|
  sitemap.show_root = true
  sitemap.show_flag = false
end
~~~

Set `show_flag` to `true` to add a "Show in sitemap" checkbox to the page settings, allowing editors to control sitemap visibility per page.

## Publishing

### publish_targets

Trigger jobs when pages are published. For example, to notify a CDN or rebuild a static cache. Each target must be an `ActiveJob` class that accepts a page as argument.

~~~ ruby
config.publish_targets << PublishToCdnJob
~~~

## Admin UI

### admin_page_preview_layout
`String` (Default: `"application"`)

The layout used for rendering the page preview in the admin.

### page_preview_sizes
`Array<Integer>` (Default: `[360, 640, 768, 1024, 1280, 1440]`)

The viewport sizes available in the preview size selector.

### show_page_searchable_checkbox
`Boolean` (Default: `false`)

Show a searchable checkbox in the page form. Useful with search plugins like laiss-cms-pg_search.

### auto_logout_time
`Integer` (Default: `30`)

Minutes of inactivity before the admin session expires. Used by the bundled devise integration to configure Devise's `:timeoutable` module. Disabled in development.

### items_per_page
`Integer` (Default: `15`)

Number of items per page in admin list views (uses Kaminari).

### menu
`Array<LaissCms::Configurations::MenuItem>` <Badge type="tip" text="8.4+" />

The entries of the admin main navigation. LaissCms's own entries (Dashboard, Pages, Menus, Languages, Sites, Tags and Library) are the default. Add entries for your own modules with `config.menu.add`:

~~~ ruby
config.menu.add(
  name: "events",
  title: "Events",
  icon: "calendar",
  url: -> { main_app.admin_events_path },
  condition: -> { can?(:index, :admin_events) }
)
~~~

See [Creating Modules](how_to_create_modules#menu-entry) for all options.

## Admin JavaScript and CSS

LaissCms uses [importmap-rails](https://github.com/rails/importmap-rails) for JavaScript modules in the admin. You can extend the admin interface with custom modules and stylesheets.

~~~ ruby
# Pin a JS module and import it in the admin
LaissCms.importmap.pin "flatpickr/de",
  to: "https://ga.jspm.io/npm:flatpickr@4.6.13/dist/l10n/de.js"
config.admin_js_imports << "flatpickr/de"

# Add a custom stylesheet
config.admin_stylesheets.add("my_app/admin_extension")
~~~

## Admin Path

Change the admin URL path or restrict access:

~~~ ruby
# config/initializers/laiss_cms.rb
LaissCms.admin_path = "backend"
LaissCms.admin_constraints = { subdomain: "admin" }
~~~

The default admin path is `/admin`.

## User Roles

### user_roles
`Array<String>` (Default: `["member", "author", "editor", "admin"]`)

Available user roles. Each role inherits the permissions of the previous one. See the [custom authentication guide](how_to_add_custom_authentication) for setting up your user model.

- **member** - Can view published pages and attachments, including restricted ones
- **author** - Can edit page content, manage elements and ingredients, browse the library
- **editor** - Can create, delete, publish and reorder pages, manage pictures, attachments and tags
- **admin** - Can manage languages, sites and system settings

You can also restrict which roles can edit specific page layouts with [`editable_by`](pages#editable_by). LaissCms uses [CanCanCan](https://github.com/CanCanCommunity/cancancan) for authorization. You can register custom abilities.

~~~ ruby
config.abilities << "MyCustom::Ability"
~~~

Roles can be translated in your locale files. See the [I18n guide](i18n) for details.

~~~ yaml
# config/locales/en.yml
en:
  laiss_cms:
    user_roles:
      member: Member
      author: Author
~~~

## Preview

LaissCms offers two ways to customize the admin's page preview.

### Preview Sources

When multiple preview sources are configured, a select menu appears in the admin preview frame. This is useful when you want to preview content across different frontends, for example if you use LaissCms as a headless CMS via laiss-cms-json_api:

~~~ ruby
config.preview_sources << "MyCustom::PreviewSource"
~~~

### Preview Host

To replace LaissCms's built-in server-side rendered preview entirely, configure a static preview host. This points the preview frame to an external URL, optionally with Basic Auth:

~~~ ruby
config.preview.tap do |preview|
  preview.host = "https://www.my-static-site.com"
  preview.auth.tap do |auth|
    auth.username = ENV["BASIC_AUTH_USERNAME"]
    auth.password = ENV["BASIC_AUTH_PASSWORD"]
  end
end
~~~

## Page URL Paths

Customize how page URLs are generated:

~~~ ruby
# config/initializers/laiss_cms.rb
LaissCms::Page.url_path_class = MyCustomUrlPath
~~~

The default `LaissCms::Page::UrlPath` builds URLs from the page's `urlname` and its ancestors. Your class must respond to `call` and return a path string.

## Format Matchers

Named aliases for regular expressions, commonly used for [ingredient validations](elements#validations).

~~~ ruby
# Use in your models
validates_format_of :url, with: LaissCms.config.format_matchers.url
~~~

## Error Tracking

Replace LaissCms's default error logger with your own handler:

~~~ ruby
# config/initializers/laiss_cms.rb
LaissCms::ErrorTracking.notification_handler = MyErrorHandler
~~~

Your class must respond to `call` with an exception argument.

::: tip
Ready-made integrations exist for the most common services: Sentry, Bugsnag, AppSignal, and [Airbrake](https://github.com/LaissCMS/laiss-cms-airbrake). See [Extensions](extensions) for more.
:::

## Update Check


