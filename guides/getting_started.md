---
prev: false
next:
  text: Elements
  link: elements
---

# Getting Started

This guide walks you through installing LaissCMS into a Rails application. By the end you will have a running LaissCms instance with an admin user.

## Prerequisites

You need a working Ruby on Rails development environment. If you are new to Rails, follow the [Install Ruby on Rails](https://guides.rubyonrails.org/install_ruby_on_rails.html) guide first.

- [Ruby](https://www.ruby-lang.org/en/documentation/installation/) >= 3.1
- [Ruby on Rails](https://rubyonrails.org) >= 7.2
- [ImageMagick](https://imagemagick.org) or [libvips](https://www.libvips.org) for image processing
- A database: [PostgreSQL](https://www.postgresql.org), [MariaDB](https://www.mariadb.org), or [SQLite](https://sqlite.org)

::: tip
Use a package manager to install system dependencies. [Homebrew](https://brew.sh) on macOS, or your Linux distribution's package manager.
:::

## Create a Rails Application

If you don't have an existing Rails app, create one.

~~~ bash
gem install rails
rails new myapp
cd myapp
~~~

::: tip
See the [Rails Getting Started guide](https://guides.rubyonrails.org/getting_started.html) for more options.
:::

## Install LaissCms

Add the gem and run the installer. It will mount LaissCms in your routes, create configuration files, set up the database, and generate demo content.

~~~ bash
bundle add laiss_cms
bin/rails laiss_cms:install
~~~

The installer asks for your site's primary language. Accept the defaults or enter your own.

## Authentication

LaissCms lets you choose your own authentication strategy.

**Option A: Use laiss-cms-devise** (recommended for new projects)

Add the gem and run its installer.

::: tip
See [Extensions](extensions) for all available add-ons.
:::

~~~ bash
bundle add laiss-cms-devise
bin/rails g laiss_cms:devise:install
~~~

**Option B: Use your existing authentication**

If your app already has a user model, configure LaissCms to use it. See the [custom authentication guide](how_to_add_custom_authentication) for details.

## Start the Server

~~~ bash
bin/rails server
~~~

Open [http://localhost:3000/admin](http://localhost:3000/admin) in your browser. You will be prompted to create the first admin user.

After signing in you can start building pages. Continue with the [Elements](elements) guide to learn how to define your content structure.

## Changing the Mount Point

The installer automatically mounts LaissCms at the root of your application. If your app has its own routes and you want LaissCms to handle only a subpath, change the mount point in `config/routes.rb`.

~~~ ruby
# config/routes.rb
Rails.application.routes.draw do
  # your app's routes
  resources :products

  # mount LaissCms under /cms instead of /
  mount LaissCms::Engine => "/cms"
end
~~~

::: warning
LaissCms has a catch-all route for page URLs. Mount it after your own routes so they take priority.
:::

## What the Installer Creates

The installer generates these files in your app.

| File | Purpose |
|------|---------|
| `config/laiss_cms/elements.yml` | [Element](elements) definitions |
| `config/laiss_cms/page_layouts.yml` | [Page layout](pages) definitions |
| `config/laiss_cms/menus.yml` | Menu definitions |
| `config/initializers/laiss_cms.rb` | LaissCms [configuration](configuration) |
| `app/views/layouts/application.html.erb` | Application layout with LaissCms helpers |
| `app/views/laiss_cms/page_layouts/_standard.html.erb` | Demo [page layout](pages#page-layouts) partial |
| `app/views/laiss_cms/elements/_article.html.erb` | Demo [element](elements#rendering) partial |
| `app/assets/stylesheets/laiss_cms/admin/custom.css` | Custom [admin styles](configuration#admin-javascript-and-css) |
