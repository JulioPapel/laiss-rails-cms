# Extending LaissCms

LaissCms has extensive [configuration](configuration) options and class-level extension points, but sometimes you need to go further. This guide is about using LaissCms's helpers in your own controllers, and adding behavior to LaissCms's built-in controllers and models.

::: tip
Looking for ready-made add-ons? See the [Extensions](extensions) page.
:::

## Using LaissCms in Your Controllers

If your app has controllers that render LaissCms content or use LaissCms view helpers like `render_elements` or `render_menu`, include `LaissCms::ControllerActions`:

~~~ ruby
# app/controllers/blog_controller.rb
class BlogController < ApplicationController
  include LaissCms::ControllerActions
end
~~~

This gives your controller access to:

- `current_laiss_cms_site` and `set_laiss_cms_language`
- LaissCms's page and element view helpers
- `current_laiss_cms_user` and `laiss_cms_user_signed_in?`

## Extending LaissCms Controllers

To add behavior to an LaissCms controller, use Ruby's `prepend` inside a `config.to_prepare` block. This ensures the extension is reloaded in development.

~~~ ruby
# config/initializers/laiss_cms_extensions.rb
Rails.application.config.to_prepare do
  LaissCms::PagesController.prepend(PagesControllerExtension)
end
~~~

~~~ ruby
# app/models/pages_controller_extension.rb
module PagesControllerExtension
  def self.prepended(base)
    base.before_action :track_visit, only: :show
  end

  private

  def track_visit
    # your custom logic
  end
end
~~~

## Extending LaissCms Models

The same pattern works for models:

~~~ ruby
# config/initializers/laiss_cms_extensions.rb
Rails.application.config.to_prepare do
  LaissCms::Page.prepend(PageExtension)
end
~~~

~~~ ruby
# app/models/page_extension.rb
module PageExtension
  def self.prepended(base)
    base.scope :featured, -> { where(page_layout: "featured") }
    base.after_publish :notify_subscribers
  end

  private

  def notify_subscribers
    # your custom logic
  end
end
~~~

::: tip
`config.to_prepare` runs on every request in development and once in production, so your extensions are always in sync with code reloads.
:::
