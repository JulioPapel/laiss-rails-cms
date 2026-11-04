# frozen_string_literal: true

FactoryBot.define do
  factory :laiss_cms_element, class: "LaissCms::Element" do
    name { "article" }
    autogenerate_ingredients { false }
    page_version { parent_element&.page_version || association(:laiss_cms_page_version) }

    trait :fixed do
      fixed { true }
      name { "right_column" }
    end

    trait :unique do
      unique { true }
      name { "header" }
    end

    trait :with_nestable_elements do
      name { "slider" }
    end

    trait :nested do
      parent_element { association(:laiss_cms_element, name: "slider") }
      name { "slide" }
    end

    trait :compact do
      name { "slide" }
    end

    trait :with_ingredients do
      autogenerate_ingredients { true }
    end
  end
end
