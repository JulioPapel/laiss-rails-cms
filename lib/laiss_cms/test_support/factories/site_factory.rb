# frozen_string_literal: true

FactoryBot.define do
  factory :laiss_cms_site, class: "LaissCms::Site" do
    name { "A Site" }
    host { "domain.com" }

    trait :default do
      public { true }

      name { LaissCms.config.default_site.name }
      host { LaissCms.config.default_site.host }
    end

    trait :public do
      public { true }
    end
  end
end
