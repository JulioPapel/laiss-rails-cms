# frozen_string_literal: true

require "thor"

module LaissCms
  module Install
    class Tasks < Thor
      SENTINEL = /\.routes\.draw do(?:\s*\|map\|)?\s*$/

      include Thor::Actions

      no_tasks do
        def inject_routes(auto_accept = false)
          return if File.read("./config/routes.rb").match?("mount LaissCms::Engine")

          mountpoint = "/"
          unless auto_accept
            mountpoint = ask("- At which path do you want to mount LaissCms CMS at?", default: mountpoint)
          end

          inject_into_file "./config/routes.rb", "\n  mount LaissCms::Engine, at: '#{mountpoint}'\n",
            {after: SENTINEL, verbose: true}
        end

        def inject_seeder
          seed_file = Rails.root.join("db", "seeds.rb")
          args = [seed_file, "LaissCms::Seeder.seed!\n"]
          if File.exist?(seed_file)
            append_file(*args)
          else
            add_file(*args)
          end
        end
      end
    end
  end
end
