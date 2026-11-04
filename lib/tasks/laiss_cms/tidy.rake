# frozen_string_literal: true

require "laiss_cms/tasks/tidy"

namespace :laiss_cms do
  namespace :tidy do
    desc "Tidy up LaissCms database."
    task :up do
      Rake::Task["laiss_cms:tidy:element_positions"].invoke
      Rake::Task["laiss_cms:tidy:remove_orphaned_records"].invoke
      Rake::Task["laiss_cms:tidy:remove_trashed_elements"].invoke
      Rake::Task["laiss_cms:tidy:remove_duplicate_legacy_urls"].invoke
      Rake::Task["laiss_cms:tidy:remove_legacy_essence_tables"].invoke
    end

    desc "Fixes element positions."
    task element_positions: [:environment] do
      LaissCms::Tidy.update_element_positions
    end

    desc "Remove orphaned records (elements)."
    task remove_orphaned_records: [:environment] do
      Rake::Task["laiss_cms:tidy:remove_orphaned_elements"].invoke
    end

    desc "Remove orphaned elements."
    task remove_orphaned_elements: [:environment] do
      LaissCms::Tidy.remove_orphaned_elements
    end

    desc "Remove trashed elements."
    task remove_trashed_elements: [:environment] do
      LaissCms::Tidy.remove_trashed_elements
    end

    desc "Remove duplicate legacy URLs"
    task remove_duplicate_legacy_urls: [:environment] do
      LaissCms::Tidy.remove_duplicate_legacy_urls
    end

    desc "Remove all legacy essence tables"
    task remove_legacy_essence_tables: [:environment] do
      LaissCms::Tidy.remove_legacy_essence_tables
    end

    desc "List LaissCms elements usage"
    task elements_usage: :environment do
      puts "\n"
      removable_elements = []
      names = LaissCms::Element.definitions.map { |e| e["name"] }
      longest_name = names.max_by { |name| name.to_s.length }.length + 1
      names.sort.each do |name|
        names = LaissCms::Element.where(name: name)
        count = names.count
        page_count = LaissCms::Page.where(id: names.pluck(:page_id)).published.count
        if count.zero?
          removable_elements.push(name)
        else
          spacer = " " * (longest_name - name.length)
          puts "#{name}#{spacer}is used\t#{count}\ttime(s) on\t#{page_count}\tpublic page(s)"
        end
      end
      if removable_elements.many?
        puts "\n"
        puts "These elements can probably be removed. They are not used anywhere:"
        puts "\n"
        removable_elements.each do |name|
          puts name
        end
      end
    end
  end
end
