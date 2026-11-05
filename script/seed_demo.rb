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
# It uses FactoryBot rather than hand-built models on purpose: the factories encode
# the current valid attribute set (publication lives on the version, not the page),
# and duplicating that here would drift.

require "factory_bot_rails"
require "laiss_cms/test_support"

FactoryBot.definition_file_paths = [LaissCms::TestSupport.factories_path]
FactoryBot.find_definitions
FactoryBot.reload

include FactoryBot::Syntax::Methods

[LaissCms::PageVersion, LaissCms::Ingredient, LaissCms::Element,
  LaissCms::Page, LaissCms::Picture, LaissCms::Attachment,
  LaissCms::Language, LaissCms::Site].each(&:delete_all)

site = create(:laiss_cms_site, name: "Laiss Labs", host: "localhost")
language = create(:laiss_cms_language, name: "English", language_code: "en", site: site)

root = create(:laiss_cms_page, :language_root, :public, name: "Index",
  language: language, title: "Welcome to Laiss")

about = create(:laiss_cms_page, :public, name: "About", urlname: "about",
  parent: root, language: language, title: "About the studio")
create(:laiss_cms_page, :public, name: "Journal", urlname: "journal",
  parent: root, language: language, title: "Field notes")
contact = create(:laiss_cms_page, name: "Contact", urlname: "contact",
  page_layout: "contact", parent: root, language: language, title: "Get in touch")

journal = LaissCms::Page.find_by(urlname: "journal")
create(:laiss_cms_page, :public, name: "Autumn collection", urlname: "autumn",
  parent: journal, language: language, title: "The autumn collection")
create(:laiss_cms_page, name: "Spring notes", urlname: "spring",
  parent: journal, language: language, title: "Spring notes")
create(:laiss_cms_page, name: "Imprint", urlname: "imprint",
  parent: root, language: language, title: "Imprint")

# Elements, so the element editor and the element window have something to show.
%w[article teaser].each_with_index do |element_name, i|
  next if LaissCms::ElementDefinition.get(element_name).blank?

  create(:laiss_cms_element,
    name: element_name,
    page_version: root.draft_version,
    position: i + 1,
    autogenerate_ingredients: true)
end

puts "Seeded:"
puts "  site:     #{site.name}"
puts "  pages:    #{LaissCms::Page.count} (#{LaissCms::Page.published.count} public)"
puts "  elements: #{LaissCms::Element.count}"
