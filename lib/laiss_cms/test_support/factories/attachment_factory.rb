# frozen_string_literal: true

FactoryBot.define do
  factory :laiss_cms_attachment, class: "LaissCms::Attachment" do
    transient do
      file do
        Rack::Test::UploadedFile.new(
          LaissCms::Engine.root.join("lib", "laiss_cms", "test_support", "fixtures", "image.png")
        )
      end
    end

    after(:build) do |attachment, acc|
      if acc.file
        attachment.file = acc.file
      end
    end

    name { "image" }
    file_name { "image.png" }
  end
end
