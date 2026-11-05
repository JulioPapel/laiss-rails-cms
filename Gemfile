# frozen_string_literal: true

source "https://rubygems.org"

gemspec

rails_version = ENV.fetch("RAILS_VERSION", "8.1")
gem "rails", "~> #{rails_version}.0"

if ENV["DB"].nil? || ENV["DB"] == "sqlite"
  gem "sqlite3", "~> 2.0"
end
if ENV["DB"] == "mysql" || ENV["DB"] == "mariadb"
  gem "mysql2", "~> 0.5.1"
end
gem "pg", "~> 1.0" if ENV["DB"] == "postgresql"

# Translations for every locale except English now ship inside laiss_cms itself
# (config/locales/extra), so there is no separate gem to require.

# Devise based authentication. The integration code ships inside laiss_cms
# itself; only the `devise` gem is separate, and it stays optional so the core
# specs (which use the DummyUser stub) and any host app with its own sign-in run
# without it. The dummy app requires the integration in development and for the
# devise specs, never for the core specs.
gem "devise", ">= 4.9", "< 6.0", require: false

if ENV.fetch("LAISS_CMS_STORAGE_ADAPTER", "active_storage") == "active_storage"
  gem "ruby-vips"
else
  gem "dragonfly", "~> 1.4"
end

group :development, :test do
  gem "execjs", "~> 2.10.0"
  gem "rubocop", require: false
  gem "standard", "~> 1.25", require: false

  # Still need Sprockets for tests
  gem "sprockets", "~> 4.2", ">= 4.2.1", require: false

  if ENV["GITHUB_ACTIONS"]
    gem "simplecov-cobertura", "~> 3.0"
  else
    gem "launchy"
    gem "annotaterb"
    gem "yard"
    gem "redcarpet"
    gem "debug"
    gem "listen"
    gem "active_record_query_trace", require: false
    gem "rack-mini-profiler", require: false
    gem "ruby-lsp-rspec", require: false
  end
end

# Ruby 3.1 split out the net-smtp gem
# Necessary until https://github.com/mikel/mail/pull/1439
# got merged and released.
if Gem.ruby_version >= Gem::Version.new("3.1.0")
  gem "net-smtp", "~> 0.5.1", require: false
end

gem "web-console", "~> 4.2", group: :development

gem "rails_live_reload", "~> 0.5.0"

gem "dartsass-rails", "~> 0.5.0"

gem "propshaft", "~> 1.0"

gem "i18n-debug", "~> 1.2", require: false # Set to `"i18n/debug"` if you want to debug missing translations

gem "brakeman", "~> 8.0", require: false

# Rails is not ready yet
gem "json", "< 3", require: false
