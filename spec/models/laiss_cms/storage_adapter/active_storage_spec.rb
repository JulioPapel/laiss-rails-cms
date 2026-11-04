require "rails_helper"

RSpec.describe LaissCms::StorageAdapter::ActiveStorage, if: LaissCms.storage_adapter.active_storage? do
  describe ".file_formats" do
    subject(:file_formats) do
      described_class.file_formats(class_name, scope: scope)
    end

    context "for a LaissCms::Picture" do
      let(:class_name) { "LaissCms::Picture" }
      let(:scope) { LaissCms::Picture.all }

      let!(:picture1) { create(:laiss_cms_picture, name: "Ping", image_file: fixture_file_upload("image.png")) }
      let!(:picture2) { create(:laiss_cms_picture, name: "Jay Peg", image_file: fixture_file_upload("image3.jpeg")) }

      it "should return all picture file formats" do
        is_expected.to match_array(["image/jpeg", "image/png"])
      end

      context "with a scope" do
        let(:scope) { LaissCms::Picture.where(name: "Jay Peg") }

        it "should only return scoped picture file formats" do
          is_expected.to eq(["image/jpeg"])
        end
      end
    end

    context "for a LaissCms::Attachment" do
      let(:class_name) { "LaissCms::Attachment" }
      let(:scope) { LaissCms::Attachment.all }

      let!(:attachment1) do
        create(:laiss_cms_attachment, name: "Pee Dee Eff", file: fixture_file_upload("file.pdf"))
      end

      let!(:attachment2) do
        create(:laiss_cms_attachment, name: "Zip File", file: fixture_file_upload("archive.zip"))
      end

      it "should return all attachment file formats" do
        is_expected.to match_array [
          "application/pdf",
          "application/zip"
        ]
      end

      context "with a scope" do
        let(:scope) { LaissCms::Attachment.where(name: "Pee Dee Eff") }

        it "should only return scoped attachment file formats" do
          is_expected.to eq ["application/pdf"]
        end
      end
    end
  end

  describe ".searchable_laiss_cms_resource_attributes" do
    subject { described_class.searchable_laiss_cms_resource_attributes(class_name) }

    context "for LaissCms::Picture" do
      let(:class_name) { "LaissCms::Picture" }

      it "returns an array of attributes for the search field query" do
        is_expected.to eq(%w[name image_file_blob_filename])
      end
    end

    context "for LaissCms::Attachment" do
      let(:class_name) { "LaissCms::Attachment" }

      it "returns an array of attributes for the search field query" do
        is_expected.to eq(%w[name file_blob_filename])
      end
    end
  end

  describe ".ransackable_associations" do
    subject { described_class.ransackable_associations(class_name) }

    context "for LaissCms::Picture" do
      let(:class_name) { "LaissCms::Picture" }

      it "returns an array of ransackable associations" do
        is_expected.to eq(%w[image_file_blob])
      end
    end

    context "for LaissCms::Attachment" do
      let(:class_name) { "LaissCms::Attachment" }

      it "returns an array of ransackable associations" do
        is_expected.to eq(%w[file_blob])
      end
    end
  end

  describe ".image_file_present?" do
    subject { described_class.image_file_present?(picture) }

    let(:picture) { LaissCms::Picture.new }

    context "when image_file is present" do
      before do
        expect(picture.image_file).to receive(:attached?) { true }
      end

      it { is_expected.to be(true) }
    end

    context "when image_file is not present" do
      before do
        expect(picture.image_file).to receive(:attached?) { false }
      end

      it { is_expected.to be(false) }
    end
  end

  describe ".set_attachment_name?" do
    subject { described_class.set_attachment_name?(attachment) }

    let(:attachment) { LaissCms::Attachment.new }

    context "when file_name has changed" do
      before do
        expect(attachment.file).to receive(:changed?) { true }
      end

      it { is_expected.to be(true) }
    end

    context "when file_name has not changed" do
      before do
        expect(attachment.file).to receive(:changed?) { false }
      end

      it { is_expected.to be(false) }
    end
  end

  describe ".has_convertible_format?" do
    subject { LaissCms.storage_adapter.has_convertible_format?(picture) }

    context "for an convertible image" do
      let(:picture) { build(:laiss_cms_picture) }

      it { is_expected.to eq(true) }
    end

    context "for an non-convertible image" do
      let(:picture) { build(:laiss_cms_picture, image_file: fixture_file_upload("icon.svg")) }

      it { is_expected.to eq(false) }
    end
  end
end
