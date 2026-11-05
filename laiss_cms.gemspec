# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "laiss_cms/version"

Gem::Specification.new do |gem|
  gem.name = "laiss_cms"
  gem.version = LaissCms::VERSION
  gem.platform = Gem::Platform::RUBY
  # The authors are the upstream contributors, retained because BSD-3-Clause
  # requires the copyright notice and contributor attribution to be preserved.
  # Laiss Labs / Júlio Papel are the maintainers of this fork; see LICENSE.
  gem.authors = ["Thomas von Deyen", "Robin Boening", "Marc Schettke", "Hendrik Mans", "Carsten Fregin", "Martin Meyerhoff", "Júlio Papel"]
  # No `gem.email`. This gem is never published to RubyGems, so the field has no
  # consumer — it would only copy a personal address into the metadata of every
  # built .gem file. `gem build` does not require it.
  gem.summary = "A semantically structured and full-featured CMS Engine for Rails"
  gem.description = "laiss-rails-cms is a private, in-house CMS engine for Rails, " \
    "maintained by Laiss Labs. It is consumed as a path or git dependency and is " \
    "not published to RubyGems."
  # Narrowed from ">= 3.1.0": 3.1 was never tested. A gem requirement is a promise
  # to consumers, and 3.4 and 4.0.6 are the versions with evidence behind them (see
  # the CI matrix). Two dependencies also exclude 3.1 at their newest versions
  # (ransack 6.x and view_component 4.x both need >= 3.2), so the 3.1 claim only
  # resolved by silently downgrading them.
  gem.required_ruby_version = ">= 3.4.0"
  gem.license = "BSD-3-Clause"
  gem.files = Dir[
    "{app,config,db,lib}/**/*",
    "vendor/{assets,javascript}/**/*",
    "LICENSE",
    "README.md"
  ]
  gem.require_paths = ["lib"]

  # Deliberately no homepage_uri / source_code_uri / changelog_uri: this gem is
  # never published, so public metadata would only be misleading. There is no
  # public repository URL to point at.

  %w[
    actionmailer
    actionpack
    actionview
    activejob
    activemodel
    activerecord
    activestorage
    activesupport
    railties
  ].each do |rails_gem|
    gem.add_runtime_dependency rails_gem, [">= 7.2", "< 8.2"]
  end

  gem.add_runtime_dependency "active_model_serializers", ["~> 0.10.14"]
  gem.add_runtime_dependency "acts_as_list", [">= 0.3", "< 2"]
  gem.add_runtime_dependency "awesome_nested_set", [">= 3.9.0", "< 4.0"]
  gem.add_runtime_dependency "cancancan", [">= 2.1", "< 4.0"]
  gem.add_runtime_dependency "csv", ["~> 3.3"]
  gem.add_runtime_dependency "gutentag", ">= 2.2.1", "< 4.0"
  gem.add_runtime_dependency "image_processing", ">= 1.14", "< 3.0"
  gem.add_runtime_dependency "importmap-rails", ["~> 2.0"]
  # Not a gem dependency, because either pipeline satisfies it, but the admin
  # requires one of them: `javascript_importmap_tags` reads `config.assets`, so an
  # app without an asset pipeline raises NoMethodError when rendering any admin
  # page. Rails' `--minimal` template omits both, which is how this was found — by
  # installing the released gem into one. Documented in the README and the release
  # notes; asserted here so the requirement is visible next to the importmap
  # dependency that causes it.
  gem.add_runtime_dependency "kaminari", ["~> 1.1"]
  gem.add_runtime_dependency "originator", ["~> 3.1"]
  gem.add_runtime_dependency "ransack", ">= 4.0", "< 7.0"
  gem.add_runtime_dependency "simple_form", [">= 4.0", "< 6"]
  gem.add_runtime_dependency "turbo-rails", [">= 1.4", "< 2.1"]
  gem.add_runtime_dependency "view_component", ">= 3", "< 5"

  gem.add_development_dependency "capybara", ["~> 3.0"]
  gem.add_development_dependency "capybara-screenshot", ["~> 1.0"]
  gem.add_development_dependency "capybara-shadowdom", ["~> 0.3"]
  gem.add_development_dependency "factory_bot_rails", ["~> 6.0"]
  gem.add_development_dependency "puma", "~> 8.0"
  gem.add_development_dependency "rails-controller-testing", ["~> 1.0"]
  gem.add_development_dependency "rspec-activemodel-mocks", ["~> 1.0"]
  gem.add_development_dependency "rspec-rails", ["~> 8.0"]
  gem.add_development_dependency "simplecov", ["~> 0.20"]
  gem.add_development_dependency "selenium-webdriver", ["~> 4.10"]
  gem.add_development_dependency "webmock", ["~> 3.3"]
  gem.add_development_dependency "shoulda-matchers", "~> 8.0"
  gem.add_development_dependency "db-query-matchers", "~> 0.12"
  gem.add_development_dependency "timecop", ["~> 0.9"]

  gem.post_install_message = <<~MSG
    -------------------------------------------------------------
                Thank you for installing laiss-rails-cms
    -------------------------------------------------------------

    - Complete the installation in an existing Rails application:

      $ bin/rails laiss_cms:install

    - Complete the upgrade of an existing laiss-rails-cms installation:

      $ bin/rails laiss_cms:upgrade

    and follow the onscreen instructions.

    This is a private, in-house fork maintained by Laiss Labs.
    It is not published to RubyGems and has no public support channels.
    -------------------------------------------------------------

  MSG
end
