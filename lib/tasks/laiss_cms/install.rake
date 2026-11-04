# frozen_string_literal: true

namespace :laiss_cms do
  desc "Installs LaissCms CMS into your app."
  task :install do
    require "generators/laiss_cms/install/install_generator"
    LaissCms::Generators::InstallGenerator.start
  end

  desc "Mounts LaissCms into your routes."
  task :mount do
    require "laiss_cms/install/tasks"
    LaissCms::InstallTasks.new.inject_routes
  end
end
