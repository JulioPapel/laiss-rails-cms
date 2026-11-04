# frozen_string_literal: true

require "laiss_cms/tasks/generate_thumbnails"

namespace :laiss_cms do
  namespace :generate do
    desc "Generates all thumbnails for LaissCms Pictures and Picture Ingredients."
    task thumbnails: [
      "laiss_cms:generate:picture_thumbnails",
      "laiss_cms:generate:ingredient_picture_thumbnails"
    ]

    desc "Generates thumbnails for LaissCms Pictures (set ASYNC=true to enqueue them as background jobs, active_storage only)."
    task picture_thumbnails: :environment do
      async = ActiveModel::Type::Boolean.new.cast(ENV["ASYNC"]) && LaissCms.storage_adapter.active_storage?

      puts "#{async ? "Enqueuing" : "Generating"} thumbnails for #{LaissCms::Picture.count} pictures..."

      LaissCms::GenerateThumbnails.pictures(async: async) { print "." }

      puts "\nDone!"
    end

    desc "Generates thumbnails for LaissCms Picture Ingredients (set ELEMENTS=element1,element2 to only generate thumbnails for a subset of elements, set ASYNC=true to enqueue them as background jobs, active_storage only)."
    task ingredient_picture_thumbnails: :environment do
      element_names = ENV["ELEMENTS"].presence&.split(",")
      async = ActiveModel::Type::Boolean.new.cast(ENV["ASYNC"]) && LaissCms.storage_adapter.active_storage?

      puts "#{async ? "Enqueuing" : "Generating"} thumbnails for picture ingredients..."

      count = 0
      LaissCms::GenerateThumbnails.ingredients(element_names: element_names, async: async) do
        count += 1
        print "."
      end

      puts "\n#{async ? "Enqueued" : "Generated"} thumbnails for #{count} picture ingredients. Done!"
    end
  end
end
