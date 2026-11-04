$:.push File.expand_path("lib", __dir__)
$:.unshift File.expand_path("../lib", __dir__)

# Maintain your gem's version:
require "laiss_cms_i18n/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name = "laiss_cms_i18n"
  s.version = LaissCmsI18n::VERSION
  s.authors = ["Thomas von Deyen"]
  s.email = ["thomas@vondeyen.com"]
  s.homepage = "https://alchemy-cms.com"
  s.summary = "LaissCMS translation files"
  s.description = "Translation files for LaissCMS"
  s.license = "MIT"

  s.files = Dir[
    "{app,lib,locales}/**/*",
    "vendor/{assets,locales}/**/*",
    "CHANGELOG.md",
    "LICENSE",
    "README.md"
  ]

  s.metadata["homepage_uri"] = s.homepage
  s.metadata["source_code_uri"] = "https://github.com/LaissCMS/laiss_cms/tree/main/i18n"
  s.metadata["changelog_uri"] = "https://github.com/LaissCMS/laiss_cms/blob/main/CHANGELOG.md"

  s.add_dependency "laiss_cms", LaissCmsI18n::VERSION
  s.add_dependency "rails-i18n"
end
