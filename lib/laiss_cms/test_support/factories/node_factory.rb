# frozen_string_literal: true

FactoryBot.define do
  factory :laiss_cms_node, class: "LaissCms::Node" do
    language { LaissCms::Language.default || create(:laiss_cms_language) }
    name { "A Node" }
    menu_type { LaissCms::Node.available_menu_names.first }

    trait :with_page do
      association :page, factory: :laiss_cms_page
      name { nil }
    end

    trait :with_url do
      url { "https://example.com" }
    end
  end
end
