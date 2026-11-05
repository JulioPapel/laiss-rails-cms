# Populates the dummy app's test database with realistic content.
#
# WHY THIS EXISTS
#
# Every admin screenshot taken against an empty database shows "You do not have any
# websites yet" or "no pages" — useless for judging whether a screen conversion looks
# right. Reviewing a migration against empty states is how a visually broken screen
# survives until the end.
#
# Run it from the repository root, with the root bundle (spec/dummy has no propshaft):
#
#   RAILS_ENV=test bundle exec ruby -e \
#     'require "./spec/dummy/config/environment"; load "./script/seed_demo.rb"'
#
# It is idempotent: content tables are cleared first, so a re-run gives the same state
# rather than accumulating.
#
# IMPORTANT — it pollutes the test database. The specs use transactional fixtures,
# which roll back their own writes but still SEE rows that were already committed. A
# seeded database therefore breaks specs that assume an empty starting state. Run this
# only when taking screenshots, then reset:
#
#   RAILS_ENV=test bundle exec rake laiss_cms:test:prepare
#
# (or simply `rm spec/dummy/storage/test.sqlite3` and re-run the gate, which recreates
# it). The seed prints this warning when it finishes.
#
# It uses FactoryBot rather than hand-built models on purpose: the factories encode
# the current valid attribute set (publication lives on the version, not the page),
# and duplicating that here would drift.

require "factory_bot_rails"
require "laiss_cms/test_support"

FactoryBot.definition_file_paths = [LaissCms::TestSupport.factories_path]
FactoryBot.find_definitions
FactoryBot.reload

[LaissCms::PageVersion, LaissCms::Ingredient, LaissCms::Element,
  LaissCms::Page, LaissCms::Picture, LaissCms::Attachment,
  LaissCms::Language, LaissCms::Site].each(&:delete_all)

site = FactoryBot.create(:laiss_cms_site, name: "Laiss Labs", host: "localhost")
language = FactoryBot.create(:laiss_cms_language, name: "English", language_code: "en", site: site)

root = FactoryBot.create(:laiss_cms_page, :language_root, :public, name: "Index",
  language: language, title: "Welcome to Laiss")

FactoryBot.create(:laiss_cms_page, :public, name: "About", urlname: "about",
  parent: root, language: language, title: "About the studio")
create(:laiss_cms_page, :public, name: "Journal", urlname: "journal",
  parent: root, language: language, title: "Field notes")
FactoryBot.create(:laiss_cms_page, name: "Contact", urlname: "contact",
  page_layout: "contact", parent: root, language: language, title: "Get in touch")

journal = LaissCms::Page.find_by(urlname: "journal")
FactoryBot.create(:laiss_cms_page, :public, name: "Autumn collection", urlname: "autumn",
  parent: journal, language: language, title: "The autumn collection")
FactoryBot.create(:laiss_cms_page, name: "Spring notes", urlname: "spring",
  parent: journal, language: language, title: "Spring notes")
FactoryBot.create(:laiss_cms_page, name: "Imprint", urlname: "imprint",
  parent: root, language: language, title: "Imprint")

# Elements, so the element editor and the element window have something to show.
%w[article teaser].each_with_index do |element_name, i|
  next if LaissCms::ElementDefinition.get(element_name).blank?

  FactoryBot.create(:laiss_cms_element,
    name: element_name,
    page_version: root.draft_version,
    position: i + 1,
    autogenerate_ingredients: true)
end

puts
puts "Seeded (screenshots only)."
puts "NOTE: this database is now unsuitable for specs. Reset it before running them:"
puts "  RAILS_ENV=test bundle exec rake laiss_cms:test:prepare"
puts
puts "  site:     #{site.name}"
puts "  pages:    #{LaissCms::Page.count} (#{LaissCms::Page.published.count} public)"
puts "  elements: #{LaissCms::Element.count}"
