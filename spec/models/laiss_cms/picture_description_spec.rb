# frozen_string_literal: true

require "rails_helper"

RSpec.describe LaissCms::PictureDescription do
  it { should belong_to(:picture).class_name("LaissCms::Picture") }
  it { should belong_to(:language).class_name("LaissCms::Language") }

  describe "validations" do
    let(:picture) { create(:laiss_cms_picture) }
    let(:language) { create(:laiss_cms_language) }

    let!(:description) do
      described_class.create!(picture: picture, language: language, text: "Test description")
    end

    it { should validate_uniqueness_of(:picture_id).scoped_to(:language_id) }
  end
end
