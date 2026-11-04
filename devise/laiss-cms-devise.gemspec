$:.push File.expand_path("../lib", __FILE__)
$:.unshift File.expand_path("../lib", __dir__)

# Maintain your gem's version:
require "laiss_cms/devise/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name = "laiss-cms-devise"
  s.version = LaissCms::Devise::VERSION
  s.authors = ["Thomas von Deyen"]
  s.email = ["thomas@vondeyen.com"]
  s.homepage = "https://alchemy-cms.com"
  s.summary = "Devise based user authentication for LaissCMS."
  s.description = "Devise based user authentication for LaissCMS."

  s.files = Dir["{app,config,db,lib}/**/*", "LICENSE", "CHANGELOG.md", "README.md"]

  s.add_dependency "laiss_cms", LaissCms::Devise::VERSION
  s.add_dependency "devise", ">= 4.9", "< 6.0"
  s.add_dependency "flickwerk", ["~> 0.3.6"]

  s.post_install_message = <<~MSG
    In order to complete the installation or the upgrade of LaissCms::Devise run:

      $ bin/rails g laiss_cms:devise:install

  MSG
end
