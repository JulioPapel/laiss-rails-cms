# Context for coding agents

This file provides guidance to coding agents when working with code in this repository.

## About LaissCMS

LaissCMS is an open source Rails CMS engine with a flexible, YAML-driven content architecture. It uses a three-tier content model: Pages → Elements → Ingredients, with multi-language support, versioning, and a modern admin interface built with Rails + Web Components.

## Development Commands

### Initial Setup

```bash
bin/setup
```

This installs dependencies (Ruby gems + pnpm packages) and sets up the dummy app in `spec/dummy/`.

### Running Tests

```bash
# Run all tests (prepares database + runs the core and devise specs)
bundle exec rake

# Prepare the database and run a single suite
bundle exec rake laiss_cms:test:core
bundle exec rake laiss_cms:test:devise

# Run RSpec only (core and devise specs, each in its own RSpec process)
bin/rspec

# Run specific test file
bin/rspec spec/models/laiss_cms/page_spec.rb
bin/rspec devise/spec/models/user_spec.rb

# Prepare test database (required before first test run)
bundle exec rake laiss_cms:test:prepare

# Run JavaScript tests
pnpm run test
```

### Building Frontend Assets

```bash
# Build all assets (JavaScript, CSS, Handlebars templates, icons)
pnpm run build

# Build individual components
pnpm run build:admin      # Bundle admin JavaScript (app/javascript/laiss_cms_admin/**)
pnpm run build:js         # Bundle vendored dependencies (sortablejs, shoelace, tinymce, etc.)
pnpm run build:css        # Sass compilation
pnpm run handlebars:compile  # Compile Handlebars templates
pnpm run build:icons      # Generate icon sprite
```

### Running the Dummy App

```bash
# Start the full stack in Docker: builds images and runs the Rails server,
# Sass watcher, and JS bundle watcher (docker compose up --build)
bin/start
```

This starts a Rails server and pnpm watch task in the dummy application for running a full dev environment.

After changing dependencies (`Gemfile` or `package.json`), rebuild the image and
refresh the baked `node_modules` in one step:

```bash
bin/start --refresh
```

### Starting the Rails console

```bash
cd spec/dummy; bin/rails console; cd -
```

This starts the Rails console for running code in the context of the dummy application.

### Running a one off script

```bash
cd spec/dummy; bin/rails runner 'puts Some.ruby.code'; cd -
```

This starts the Rails console for running code in the context of the dummy application.

### Linting

```bash
# Ruby linting (uses Standard/RuboCop)
bundle exec standardrb

# JavaScript linting
pnpm run eslint

# Prettier linting
pnpm run lint
```

### Code Formatting

```bash
# Ruby linting (uses Standard/RuboCop)
bundle exec standardrb --fix

# Prettier formatting
pnpm exec prettier --write app/javascript/**/*.js
```

## Architecture Overview

### Content Model: Three-Tier Hierarchy

LaissCms organizes content in a three-tier hierarchy:

**Pages** (`LaissCms::Page`)
- Top-level content containers organized in a tree structure (using `awesome_nested_set`)
- Each page has a `page_layout` (defined in `config/laiss_cms/page_layouts.yml`)
- Multi-language support: each page belongs to one `LaissCms::Language`
- **Dual-version system**:
  - `draft_version` - Working copy (no `public_on` date)
  - `public_version` - Published content (has `public_on` date)
- Page locking prevents concurrent editing (`locked_by`, `locked_at`)

**Elements** (`LaissCms::Element`)
- Content blocks that live on specific `PageVersion` records
- Defined in `config/laiss_cms/elements.yml`
- Can be **fixed** (permanent) or **mutable** (user-removable)
- Support nesting via `parent_element_id`
- Positioned using `acts_as_list` within scope

**Ingredients** (`LaissCms::Ingredient`)
- The actual content values (text, images, links, etc.)
- Uses **Single Table Inheritance (STI)** with 15+ types:
  - Value types: `Text`, `Headline`, `Html`, `Richtext`, `Number`, `Boolean`
  - Media types: `Picture`, `File`, `Audio`, `Video`
  - Reference types: `Page`, `Node`, `Link`
  - Special types: `Select`, `Datetime`
- Each has a `role` (semantic identifier within element) and optional `related_object` (polymorphic)
- Flexible metadata stored in JSON `data` column

### YAML-Driven Configuration

LaissCms uses declarative YAML definitions that are **separate from database records**:

- `config/laiss_cms/page_layouts.yml` - Page layout definitions
- `config/laiss_cms/elements.yml` - Element definitions with ingredient specs
- Definition classes (`PageDefinition`, `ElementDefinition`, `IngredientDefinition`) are read-only configuration objects

This separation allows runtime configuration changes without database migrations.

### Key Model Relationships

```
Site
└── languages (LaissCms::Language)
    └── pages (LaissCms::Page - nested set tree)
        └── versions (LaissCms::PageVersion)
            └── elements (LaissCms::Element - can be nested)
                └── ingredients (LaissCms::Ingredient - STI)
                    └── related_object (polymorphic: Picture, Page, etc.)
```

### Navigation System

**Nodes** (`LaissCms::Node`) represent menu/navigation structure separate from page hierarchy:
- Also uses nested set pattern per language
- Can attach to pages or link to external URLs
- Referenced by elements via `Ingredients::Node`

### Service Objects

Complex business logic is extracted into service classes in `app/services/laiss_cms/`:

- `CopyPage` - Deep copies pages with all elements and ingredients
- `DuplicateElement` - Element copying with ingredient awareness
- `PageTreePreloader` - Optimizes page tree loading to prevent N+1 queries
- `DeleteElements` - Batch deletion with recursive nested element handling

Use service objects for complex operations rather than bloating models.

## Frontend Architecture

### Build System

- **JavaScript**: Rollup for bundling (see `rollup.config.mjs`)
- **CSS**: Sass with compression
- **Package Manager**: pnpm
- **Templates**: Handlebars for client-side rendering

### JavaScript Patterns

The admin interface uses a **hybrid architecture**:

**Modern Web Components** (preferred for new features):
- Custom elements in `app/javascript/laiss_cms_admin/components/`
- Extend `HTMLElement` directly; do all DOM work in `connectedCallback`
- Examples: `laiss-cms-sitemap`, `laiss-cms-element-editor`, `laiss-cms-datepicker`
- Vanilla JavaScript (no framework dependency)

**Rails Integration**:
- Turbo for navigation (replacing Turbolinks)
- Turbo Frames and Streams for forms
- Custom events: `LaissCms.${name}` namespace
- View Component: Used to populate Ruby values into custom JS elements.

**Global Object**: `window.LaissCms` provides legacy utilities:
```javascript
LaissCms.t()          // i18n translation
LaissCms.growl()      // Notifications
LaissCms.LinkDialog   // Link picker
LaissCms.closeCurrentDialog()
```

Always prefer local imports for global usage where possible.

### ViewComponents

Admin UI uses Rails ViewComponents for rendering:
- Each ingredient type has two components:
  - `*_editor.rb` - Form in admin UI
  - `*_view.rb` - Frontend rendering
- Located in `app/components/laiss_cms/ingredients/`

## Testing Patterns

### Test Structure

```
spec/
├── models/        # Model unit tests
├── features/      # System tests (Capybara with JavaScript)
├── controllers/   # Controller specs
├── requests/      # API/routing specs
├── components/    # ViewComponent specs
├── javascript/    # Frontend tests (Vitest)
└── support/       # Shared helpers and matchers
```

### Tools

- **RSpec** with Rails integration
- **FactoryBot** for test data (`create(:laiss_cms_page)`)
- **Capybara** for browser automation (with Selenium for JS tests)
- **Shoulda Matchers** for ActiveRecord assertions
- **WebMock** for HTTP stubbing
- **SimpleCov** for coverage
- **Vitest** for JavaScript unit tests

### Shared Examples

Use shared examples for consistent testing across similar classes:
- `shared_ingredient_examples` - Common ingredient behavior
- `shared_ingredient_editor_examples` - Admin form tests
- `having_picture_thumbnails_examples` - Picture variant tests

### Thread-Local State

Use `LaissCms::Current` for thread-safe context:
```ruby
LaissCms::Current.language = language
LaissCms::Current.site = site
LaissCms::Current.preview_page = page
```

## Code Style & Conventions

Follow Ruby and JavaScript conventions from `CONTRIBUTING.md`:

**Ruby**:
- Two spaces, no tabs
- Prefer `&&`/`||` over `and`/`or`
- Use `->` over `lambda`
- Ruby 1.9+ hash syntax: `{a: 'b'}`
- Run `bundle exec standardrb --fix` before committing

**JavaScript**:
- Use Prettier for formatting
- Custom elements should extend `HTMLElement`
- Event-driven communication between components
- Prefer modern ES6+ syntax

**Commit Messages**:
- Do not use bullet points in commit message bodies
- Write short explanatory sentences that explain why the change is useful or necessary
- Focus on the reasoning and context, not just listing what changed
- Keep commits focused on a single topic. Unrelated changes must go in separate commits

## Important Patterns

### Definition Repositories

Layouts and elements can use custom definition repositories:
```ruby
LaissCms::Page.layouts_repository = CustomClass
LaissCms::Element.definitions_repository = CustomClass
```

### Nested Set Operations

Pages and nodes use `awesome_nested_set` for tree hierarchies:
- Efficient querying: `page.ancestors`, `page.descendants`, `page.subtree`
- Avoid manual parent_id manipulation
- Use scoped queries: `LaissCms::Page.where(language: lang)`

### Writing Migrations (data loss hazard)

**SQLite silently destroys data when a migration rebuilds a table.** It has no
real `ALTER TABLE`, so Rails implements these operations by copying the rows
aside, running `DROP TABLE`, and copying them back:

`change_column` · `change_column_null` · `change_column_default` ·
`rename_column` · `remove_column` · `remove_columns` · `add_timestamps` ·
`add_column` with `null: false` and **no** `default:`

With foreign keys enforced, SQLite's `DROP TABLE` performs an implicit
`DELETE`, which fires `ON DELETE CASCADE`. The rebuilt table keeps its rows,
but **every cascading descendant is deleted permanently**. Rebuilding
`laiss_cms_pages` empties `laiss_cms_page_versions`, `laiss_cms_elements` and
`laiss_cms_ingredients`. Rails guards the rebuild with `PRAGMA foreign_keys =
OFF`, but that pragma is a **silent no-op inside a transaction**, and
migrations run in a transaction by default — so the guard never applies.

Rules for any migration touching a table with cascading children:
- Prefer avoiding the rebuild: `add_column` with both `null: false` and a
  `default:` is a plain `ALTER TABLE ADD COLUMN`. A nullable column plus a
  model-level `attribute :foo, default: -> { ... }` behaves identically on every
  adapter, and is the only option for MySQL `text` columns, which cannot carry a
  literal default.
- If a rebuild is unavoidable (including `remove_column` in `down`), declare
  `disable_ddl_transaction!` so the pragma takes effect — then make the
  migration safe to re-run, since it no longer rolls back as a unit.
- Verify with `ruby bin/check-destructive-migrations` (also enforced in CI).
- Always test a migration against a **populated** database and assert child row
  counts survive. An empty dummy database hides this entirely.

### Versioning Workflow

When working with page content:
- Authors edit `page.draft_version`
- Publishing sets `public_on` datetime on version
- Readers always see `page.public_version`
- Never modify published versions directly

### Custom Ingredient Types

Create new ingredient types by:
1. Subclass `LaissCms::Ingredient` in `app/models/laiss_cms/ingredients/`
2. Add view component in `app/components/laiss_cms/ingredients/`
3. Add editor component for admin UI
4. Register in element YAML definitions

## Upgrading LaissCms

After updating the gem:
```bash
bundle update laiss_cms
bin/rake laiss_cms:upgrade
```

This runs automated upgrade tasks. Read the output carefully for manual steps.

## File Locations

- **Models**: `app/models/laiss_cms/`
- **Controllers**: `app/controllers/laiss_cms/admin/` (admin), `app/controllers/laiss_cms/` (frontend)
- **Views**: `app/views/laiss_cms/admin/`, `app/views/laiss_cms/`
- **Components**: `app/components/laiss_cms/` (ViewComponents)
- **JavaScript**: `app/javascript/laiss_cms_admin/`
- **Stylesheets**: `app/stylesheets/laiss_cms/`
- **Services**: `app/services/laiss_cms/`
- **Serializers**: `app/serializers/laiss_cms/` (API responses)
- **Jobs**: `app/jobs/laiss_cms/`
- **Lib**: `lib/laiss_cms/` (core engine code)
- **Config**: `config/laiss_cms/` (YAML definitions)
- **Generators**: `lib/generators/laiss_cms/`
- **Translations**: `i18n/` (the `laiss_cms_i18n` gem, versioned together with `laiss_cms`; see `i18n/CLAUDE.md`)
- **Authentication**: `devise/` (the `laiss-cms-devise` gem, versioned together with `laiss_cms`; it shares the root bundle and `spec/dummy`, which only loads it for the devise specs, so `bin/rspec` runs them separately from inside `devise/`)

## Resources

- Documentation: the `guides/` directory in this repository
- API Docs: generate locally with `bundle exec rake rdoc`
