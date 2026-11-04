# frozen_string_literal: true

FactoryBot.define do
  factory :laiss_cms_dummy_user, class: "DummyUser" do
    sequence(:email) { |n| "john.#{n}@doe.com" }
    password { "s3cr3t" }

    trait :as_member do
      laiss_cms_roles { ["member"] }
    end

    trait :as_admin do
      laiss_cms_roles { ["admin"] }
    end

    trait :as_author do
      laiss_cms_roles { ["author"] }
    end

    trait :as_editor do
      laiss_cms_roles { ["editor"] }
    end
  end
end
