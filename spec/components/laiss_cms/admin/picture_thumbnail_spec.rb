# frozen_string_literal: true

require "rails_helper"

RSpec.describe LaissCms::Admin::PictureThumbnail, type: :component do
  let(:component) do
    described_class.new(picture)
  end

  # Pinned because the example below asserts the name attribute; the factory
  # otherwise sequences names to keep variant URLs distinct between examples.
  let(:picture) { create(:laiss_cms_picture, name: "image") }

  it "renders medium thumbnail" do
    expect(picture).to receive(:thumbnail_url).with(size: "160x120")
    render_inline component
  end

  it "adds picture name as name attribute" do
    render_inline component
    expect(page).to have_css("laiss-cms-picture-thumbnail[name='image']")
  end

  context "when size is 'small'" do
    let(:component) do
      described_class.new(picture, size: "small")
    end

    it "renders small thumbnail" do
      expect(picture).to receive(:thumbnail_url).with(size: "80x60")
      render_inline component
    end
  end

  context "when size is 'large'" do
    let(:component) do
      described_class.new(picture, size: "large")
    end

    it "renders large thumbnail" do
      expect(picture).to receive(:thumbnail_url).with(size: "240x180")
      render_inline component
    end
  end

  context "when css_class is given" do
    let(:component) do
      described_class.new(picture, css_class: "padding-top")
    end

    it "adds class" do
      render_inline component
      expect(page).to have_css(".padding-top")
    end
  end

  context "when thumbnail_url is is nil" do
    before do
      allow(picture).to receive(:thumbnail_url) { nil }
    end

    it "renders file-damage icon" do
      render_inline component
      expect(page).to have_css("laiss-cms-icon[name=file-damage]")
    end

    context "when placeholder is given" do
      let(:component) do
        described_class.new(picture, placeholder: "<laiss-cms-icon name='image' size='xl'></laiss-cms-icon>".html_safe)
      end

      it "renders file-damage icon" do
        render_inline component

        expect(page).to have_css("laiss-cms-icon[name=image][size=xl]")
      end
    end
  end
end
