# frozen_string_literal: true

FactoryBot.define do
  factory :laiss_cms_picture, class: "LaissCms::Picture" do
    transient do
      image_file do
        Rack::Test::UploadedFile.new(
          LaissCms::Engine.root.join("lib", "laiss_cms", "test_support", "fixtures", "image.png")
        )
      end
    end

    after(:build) do |picture, acc|
      if acc.image_file
        case LaissCms.storage_adapter.name
        when :active_storage
          filename = acc.image_file.original_filename
          content_type = Marcel::MimeType.for(extension: File.extname(filename))
          picture.image_file.attach(
            io: acc.image_file.open,
            filename:,
            content_type:,
            identify: false,
            metadata: {
              width: 1,
              height: 1
            }
          )
        when :dragonfly
          picture.image_file = acc.image_file
          picture.image_file_size = acc.image_file.size
          picture.image_file_format = File.extname(acc.image_file_name).delete(".").downcase
        end
      end
    end

    # Unique per picture. The name is what `Picture#url` uses as the filename in
    # the variant URL, so a shared name gave every picture the same URL even when
    # the underlying bytes differed — ActiveStorage's route then served a variant
    # cached for a different blob, and the browser reused it. Examples that ran
    # after another picture spec could get a 1x1 image where a 500x500 was meant.
    sequence(:name) { |n| "image-#{n}" }
    upload_hash { Time.current.hash }
  end
end
