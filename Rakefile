begin
  require "bundler/setup"
rescue LoadError
  puts "You must `gem install bundler` and `bundle install` to run rake tasks"
end

begin
  require "rdoc/task"
rescue LoadError
  require "rdoc/rdoc"
  require "rake/rdoctask"
  RDoc::Task = Rake::RDocTask
end

desc "Generate documentation for LaissCms CMS."
RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = "rdoc"
  rdoc.title = "LaissCms CMS"
  rdoc.options << "--line-numbers" << "--inline-source"
  rdoc.rdoc_files.include("README.md")
  rdoc.rdoc_files.include("config/laiss_cms/*.yml")
  rdoc.rdoc_files.include("lib/**/*.rb")
  rdoc.rdoc_files.include("app/**/*.rb")
end

APP_RAKEFILE = File.expand_path("spec/dummy/Rakefile", __dir__)
load "rails/tasks/engine.rake"

require "rspec/core"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task default: "laiss_cms:test:all"

# One gem ships everything: the translations are folded into the engine, and the
# devise integration is code inside the engine that only activates when the
# `devise` gem is present. Only the main gemspec is built or released.
Bundler::GemHelper.install_tasks

namespace :laiss_cms do
  namespace :test do
    desc "Prepares database for testing LaissCms"
    task :prepare do
      system(
        <<~BASH
          cd spec/dummy && \
          export RAILS_ENV=test && \
          bin/rake db:create && \
          bin/rake db:environment:set && \
          bin/rake db:migrate:reset && \
          bin/rails g laiss_cms:install --skip --skip-demo-files --auto-accept --skip-db-create && \
          bin/rails dartsass:build && \
          cd -
        BASH
      ) || fail
    end

    desc "Prepares the database and runs the LaissCms core specs"
    task core: :prepare do
      sh "bin/rspec", "spec"
    end

    desc "Prepares the database and runs the authentication (devise) specs"
    task devise: :prepare do
      sh "bin/rspec", "devise/spec"
    end

    desc "Prepares the database and runs all specs"
    task all: [:core, :devise]
  end

  # Release and changelog automation deliberately removed. This gem is a
  # private in-house fork: it is never published to RubyGems, so there is no
  # version bumping, tagging, gem pushing or changelog-from-git tooling.
  # Version lives in lib/laiss_cms/version.rb and is bumped by hand when a
  # consumer needs it.
end
