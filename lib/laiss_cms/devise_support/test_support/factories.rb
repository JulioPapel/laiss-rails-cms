# frozen_string_literal: true

FactoryBot.define do
  factory :laiss_cms_user, class: LaissCms::User do
    sequence(:login) { |n| "john_#{n}.doe" }
    sequence(:email) { |n| "john_#{n}@doe.com" }
    firstname { "John" }
    lastname { "Doe" }
    password { "s3cr3t" }
    password_confirmation { "s3cr3t" }

    factory :laiss_cms_admin_user do
      laiss_cms_roles { "admin" }
    end

    factory :laiss_cms_member_user do
      laiss_cms_roles { "member" }
    end

    factory :laiss_cms_author_user do
      laiss_cms_roles { "author" }
    end

    factory :laiss_cms_editor_user do
      laiss_cms_roles { "editor" }
    end
  end
end
