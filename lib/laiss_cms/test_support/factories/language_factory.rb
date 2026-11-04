# frozen_string_literal: true

FactoryBot.define do
  factory :laiss_cms_language, class: "LaissCms::Language" do
    name { "Your Language" }
    language_code { "en" }
    locale { ::I18n.default_locale }
    default { true }
    frontpage_name { "Intro" }
    page_layout { LaissCms.config.default_language.page_layout }

    public { true }

    site { LaissCms::Site.first || create(:laiss_cms_site, :default) }

    trait :klingon do
      name { "Klingon" }
      language_code { "kl" }
      locale { :kl }
      frontpage_name { "Tuq" }
      default { false }
    end

    trait :english do
      name { "English" }
      language_code { "en" }
      locale { :en }
      default { false }
    end

    trait :german do
      name { "Deutsch" }
      language_code { "de" }
      locale { :de }
      default { false }
    end
  end
end
