# frozen_string_literal: true

FactoryBot.define do
  factory :laiss_cms_picture_thumb, class: "LaissCms::PictureThumb" do
    picture { create(:laiss_cms_picture) }
    signature { SecureRandom.hex(16) }
    sequence(:uid) { |n| "#{Time.now.strftime("%Y/%m/%d")}/#{n}.jpg" }
  end
end
