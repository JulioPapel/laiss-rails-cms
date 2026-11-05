---
prev: false
next: false
---

# How To: Integrate Into an Existing Rails App

This guide covers integrating LaissCMS into a Rails application that already has its own routes, controllers, and views. If you are starting a new project, see [Getting Started](getting_started) instead.

## Install LaissCms

Add the gem and run the installer with `--skip-demo-files` to avoid overwriting your existing layout and views.

~~~ bash
bundle add laiss_cms
bin/rails laiss_cms:install --skip-demo-files
~~~

The installer mounts LaissCms in your routes, creates [configuration files](getting_started#3-install-in-this-order), sets up the database, and seeds the default site and language.

## Authentication

LaissCms needs to know which users can access the admin. Point it to your user model and authentication:

~~~ ruby
# config/initializers/laiss_cms.rb
LaissCms.configure do |config|
  config.user_class = "User"
  config.current_user_method = "current_user"
  config.login_path = "/login"
  config.logout_path = "/logout"
end
~~~

Your user model must respond to `laiss_cms_roles` and return an array of role names:

~~~ ruby
class User < ApplicationRecord
  def laiss_cms_roles
    admin? ? %w[admin] : %w[editor]
  end
end
~~~

See the [custom authentication guide](how_to_add_custom_authentication) for the full list of required methods and configuration options.

## Routing

The installer mounts LaissCms at the root path by default. Since LaissCms has a catch-all route for pages, it must be mounted **after** your own routes.

~~~ ruby
# config/routes.rb
Rails.application.routes.draw do
  resources :products
  resources :orders

  mount LaissCms::Engine => "/"
end
~~~

::: warning
If LaissCms is mounted before your routes, its catch-all will intercept requests meant for your controllers.
:::

### Mounting at a Subpath

If you prefer LaissCms to handle only a portion of your site, mount it at a subpath:

~~~ ruby
mount LaissCms::Engine => "/cms"
~~~

The admin interface is then available at `/cms/admin` and LaissCms pages are served under `/cms/...`.

## Layout

LaissCms renders pages through your `application.html.erb` layout. Add the LaissCms meta data partial and the edit mode bar to your existing layout:

~~~ erb
<!DOCTYPE html>
<html>
  <head>
    <!-- your existing head content -->
    <%= render "laiss_cms/pages/meta_data" if @page %>
  </head>
  <body>
    <!-- your existing body content -->
    <%= yield %>
    <%= render "laiss_cms/edit_mode" if @page %>
  </body>
</html>
~~~

The `if @page` guard ensures these partials only render on LaissCms-managed pages and don't interfere with your own controllers.

::: tip
The meta data partial sets `<title>` and `<meta name="description">` from the current LaissCms page.
:::

## Using LaissCms Helpers

If your own controllers need access to LaissCms's view helpers (like `render_menu` for navigation or `current_laiss_cms_site`), include the `ControllerActions` module:

~~~ ruby
class ApplicationController < ActionController::Base
  include LaissCms::ControllerActions
end
~~~

This gives you:

| Helper | Purpose |
|--------|---------|
| `render_menu` | Render an LaissCms navigation menu |
| `render_breadcrumb` | Render a breadcrumb trail |
| `current_laiss_cms_site` | The current site based on the request host |
| `Current.language` | The current language |

::: tip
If you only need LaissCms helpers in specific controllers, include the module there instead of in `ApplicationController`.
:::

### Rendering LaissCms Menus in Your Layout

A common use case is rendering an LaissCms-managed navigation menu in your application layout, shared across both your own pages and LaissCms pages:

~~~ erb
<!-- app/views/layouts/application.html.erb -->
<nav>
  <%= render_menu do |node| %>
    <%= link_to node.name, node.url,
        class: node.active?(request) ? "active" : nil %>
  <% end %>
</nav>
~~~

See the [Menus guide](menus) for more rendering options.

## Administrate App Resources

LaissCms's admin interface is not limited to CMS content. You can add your own models (events, products, orders) as admin modules with full CRUD views, search, pagination, and authorization built in.

~~~ ruby
# app/controllers/admin/events_controller.rb
class Admin::EventsController < LaissCms::Admin::ResourcesController
end
~~~

Register the module and it appears in the admin sidebar alongside pages, images, and other LaissCms modules.

See the [Custom Modules guide](how_to_create_modules) for the full setup including routes, module registration, authorization, and view customization.

## Next Steps

- [Elements](elements) — define your content structure
- [Pages](pages) — configure page layouts
- [Configuration](configuration) — customize LaissCms's behavior
- [Custom Authentication](how_to_add_custom_authentication) — connect your existing user model
- [Custom Modules](how_to_create_modules) — manage your own models in the LaissCms admin
