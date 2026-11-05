$:.push File.expand_path("lib", __dir__)
$:.unshift File.expand_path("../lib", __dir__)

# Maintain your gem's version:
require "laiss_cms_i18n/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name = "laiss_cms_i18n"
  s.version = LaissCmsI18n::VERSION
  # Upstream author retained: the MIT licence in i18n/LICENSE requires the
  # copyright notice and author attribution to be preserved.
  s.authors = ["Thomas von Deyen", "Júlio Papel"]
  s.email = ["julio@laisslabs.com"]
  s.summary = "laiss-rails-cms translation files"
  s.description = "Translation files for laiss-rails-cms, a private in-house fork maintained by Laiss Labs."
  s.license = "MIT"

  s.files = Dir[
    "{app,lib,locales}/**/*",
    "vendor/{assets,locales}/**/*",
    "CHANGELOG.md",
    "LICENSE",
    "README.md"
  ]

  # No public metadata: this gem is never published.

  s.add_dependency "laiss_cms", LaissCmsI18n::VERSION
  s.add_dependency "rails-i18n"
end
