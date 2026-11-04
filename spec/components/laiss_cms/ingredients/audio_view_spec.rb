# frozen_string_literal: true

require "rails_helper"

RSpec.describe LaissCms::Ingredients::AudioView, type: :component do
  let(:file) do
    fixture_file_upload("image with spaces.png")
  end

  let(:attachment) do
    build_stubbed(:laiss_cms_attachment, file: file, name: "a podcast", file_name: "image with spaces.png")
  end

  let(:ingredient) do
    LaissCms::Ingredients::Audio.new(
      role: "video",
      attachment: attachment,
      autoplay: true,
      controls: true,
      loop: true,
      muted: true
    )
  end

  subject do
    render_inline described_class.new(ingredient)
    page
  end

  context "without attachment" do
    let(:ingredient) { LaissCms::Ingredients::Audio.new(attachment: nil) }

    it "renders nothing" do
      is_expected.to have_content("")
    end
  end

  context "with attachment" do
    it "renders a audio tag with source" do
      is_expected.to have_selector(
        "audio[controls][muted][loop][autoplay] source[src]"
      )
    end
  end
end
