require "laiss_cms/tasks/usage"

namespace :laiss_cms do
  desc "List LaissCms elements and pages usage"
  task usage: [:page_usage, :element_usage]

  desc "List LaissCms elements usage"
  task page_usage: :environment do
    include ActionView::Helpers::NumberHelper

    puts "\n  LaissCms pages usage"
    results = LaissCms::Tasks::Usage.pages_count_by_type
    if results.any?
      puts "  ----------------------"
      puts "\n"
      results.each do |row|
        puts "  #{number_with_delimiter(row["count"])} 𝗑 #{row["page_layout"]}"
      end
      puts "\n  = #{number_with_delimiter(LaissCms::Page.count)} pages in total."
    else
      puts "  > No pages found!"
    end
  end

  desc "List LaissCms elements usage"
  task element_usage: :environment do
    include ActionView::Helpers::NumberHelper

    puts "\n  LaissCms elements usage"
    results = LaissCms::Tasks::Usage.elements_count_by_name
    if results.any?
      puts "  ----------------------"
      puts "\n"
      results.each do |row|
        puts "  #{number_with_delimiter(row["count"])} 𝗑 #{row["name"]}"
      end
      puts "\n  = #{number_with_delimiter(LaissCms::Element.count)} elements in total."
    else
      puts "  > No elements found!"
    end
  end
end
