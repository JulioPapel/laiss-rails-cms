---
prev: false
next:
  text: Elements
  link: elements
---

# Getting started

A walkthrough that matches the current admin: create a page, add an element, edit
an ingredient, publish.

Every command below has been run against this repository at tag
`v0.1.0.beta2`.

## Prerequisites

- **Ruby** `>= 3.1` (development pins `4.0.6`)
- **Rails** `>= 7.2, < 8.2`
- **A database** — SQLite, PostgreSQL or MariaDB
- **ImageMagick or libvips** for image processing, via `image_processing`
- **Node 24 + pnpm 11** only if you build the assets yourself

## 1. Create the application

```bash
gem install rails
rails new my-site --database=sqlite3
cd my-site
```

## 2. Add the engine

`laiss_cms` is **not on RubyGems**. Install it from git at a tag:

```ruby
# Gemfile
gem "laiss_cms",
  git: "git@github.com:JulioPapel/laiss-rails-cms.git",
  tag: "v0.1.0.beta2"

# optional: authentication. The integration ships inside laiss_cms; only the
# devise gem is separate, and leaving it out is a supported setup.
gem "devise", "~> 4.9"
```

```bash
bundle install
```

Your app needs an asset pipeline — `propshaft` (Rails' default) or `sprockets`.
The admin's JavaScript is rendered through `importmap-rails`, which reads
`config.assets`; without a pipeline every admin page raises `NoMethodError`.

## 3. Install, in this order

```bash
bin/rails active_storage:install        # 1
bin/rails laiss_cms:install             # 2
bin/rails g laiss_cms:devise:install    # 3, only if using the bundled sign-in
bin/rails db:migrate                    # 4
bin/rails db:seed                       # 5
```

Steps **1** and **5** are easy to miss and both fail quietly:

| Step | What breaks without it |
| --- | --- |
| `active_storage:install` | The engine boots, but every image upload fails: there are no ActiveStorage tables. |
| `db:seed` | The installer appends `LaissCms::Seeder.seed!` to `db/seeds.rb` but does **not** run it. Without it there is no site, no language and no root page — and because a page needs a parent, the **New page** button produces nothing. |

## 4. Opt in to authentication

The authentication code ships inside `laiss_cms` but does nothing until you ask
for it, so that an app with its own sign-in is unaffected. Add this to
`config/application.rb`, after `require "laiss_cms"`:

```ruby
require "laiss_cms/devise"
```

Without it there is no `LaissCms::User`, no `/admin/login` route and no admin user
screen. The rest of the CMS works normally.

If the admin raises `NoCurrentUserFoundError`, that line is what is missing.

## 5. Create the content tree

`db:seed` creates the site, the default language and the pages declared in
`db/seeds/laiss_cms/pages.yml`. The installer writes a starter file with one root
page and one child, so a fresh install has something to look at immediately. Edit
it to describe your own structure — the indentation under `children:` is what
builds the tree:

```yaml
- name: Index
  urlname: index
  page_layout: index
  title: Welcome
  children:
    - name: About
      urlname: about
      page_layout: index
      title: About
```

If you installed with `--skip-demo-files`, that file is empty on purpose and
`db:seed` says so.

Then re-run:

```bash
bin/rails db:seed
```

The first entry becomes the **language root**.

Re-running `db:seed` is safe but **inert**: if any page already exists the seeder
logs "There are already pages present" and skips the whole page step. So adding
entries to `pages.yml` later does nothing — that file seeds an empty database
only. Use `db:reset` to rebuild from scratch, or create further pages in the
admin.

Note there is no `public` attribute on a page. Visibility is set by publishing it
(a `public_on` timestamp) from the admin, not in the YAML.

## 6. Sign in

```bash
bin/rails server
```

Visit <http://localhost:3000/admin>. On a fresh database the admin redirects to
**sign up**, and the account you create is given the `admin` role — verified: the
first user is created with `laiss_cms_roles = "admin"`.

The sign-up route stays reachable afterwards rather than returning 404, so treat
it as a development convenience and restrict it in production at your web server
or with your own route constraint.

## 7. Create a page in the admin

1. **Pages** in the sidebar.
2. **Add a page** in the toolbar. Give it a name and pick a page layout.
3. It appears in the sitemap tree. Click it to open the editor.

The editor has three parts: the page tree / element list on the left, a **live
preview** in the centre, and the **element editor** on the right.

The sidebar collapses automatically on this screen so the canvas gets the width.
The small chevron at the top of the rail brings it back, and the choice is
remembered while you keep working.

## 8. Add an element

1. In the element panel, use **New element** (or press `alt+n`).
2. Pick a type from your `elements.yml`.
3. The element appears as a card and its fields open.

Each card has a header with a drag handle and a toolbar: duplicate, cut, delete,
visibility, and publication schedule.

## 9. Edit an ingredient

An **ingredient** is one field on an element. Types are declared in the element
definition, so the editor shows the right control:

- **Text** — a single-line input
- **Richtext** — the reduced editor described below
- **Picture** — a picker into the image library, with cropping
- **Link**, **Select**, **Boolean**, **Datetime** — the obvious controls

The rich-text field is deliberately limited to **inline formatting and lists**:
bold, italic, link, bulleted and numbered lists, blockquote, inline code, undo,
redo, clear formatting. Headings, sizes, alignment, colours and tables are not
available, because layout and hierarchy come from the element definition. That is
why an author cannot break the page's structure.

See [Customizing the editor](how_to_customize_tinymce) if you need to change it,
and read the policy there first.

## 10. Publish

Changes are saved on the element (the **Save** button on the element's footer) and
the page is published with **Publish changes** in the top bar.

An unpublished page is only visible in the preview. Publication can also be
scheduled — the calendar control in the toolbar sets a `public_on` time.

## Where to go next

- [Elements](elements) — the content model, and how page layouts fit in
- [Ingredients](ingredients) — every field type
- [Pages](pages) — versioning, scheduling, locking
- [Menus](menus) — navigation separate from the page tree
- [Configuration](configuration) — every engine option
- [Deployment](deployment) — taking it to production
