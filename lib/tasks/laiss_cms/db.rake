# frozen_string_literal: true

require "laiss_cms/seeder"

namespace :laiss_cms do
  namespace :db do
    desc "Seeds the database with LaissCms defaults"
    task seed: [:environment] do
      LaissCms::Seeder.seed!
    end
  end
end
