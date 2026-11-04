# frozen_string_literal: true

require "rails_helper"

RSpec.describe LaissCms::Page::Definitions do
  describe ".selectable_layouts" do
    let(:site) { create(:laiss_cms_site) }
    let!(:language) { create(:laiss_cms_language, code: :de) }
    subject { LaissCms::Page.selectable_layouts(language.id) }

    it "should not display hidden page layouts" do
      subject.each { |l| expect(l["hide"]).not_to eq(true) }
    end

    it "should not display layoutpages" do
      subject.each { |l| expect(l["layoutpage"]).not_to eq(true) }
    end

    context "with already taken layouts" do
      before do
        allow(LaissCms::PageDefinition).to receive(:all).and_return([LaissCms::PageDefinition.new(unique: true)])
        allow(LaissCms::Page).to receive(:where).and_return double(pluck: [1])
      end

      it "should not include unique layouts" do
        subject.each { expect(_1.unique).not_to eq(true) }
      end
    end

    context "with sites layouts present" do
      let(:definition) do
        {"name" => "default_site", "page_layouts" => %w[index]}
      end

      before do
        allow_any_instance_of(LaissCms::Site).to receive(:definition).and_return(definition)
      end

      it "should only return layouts for site" do
        expect(subject.length).to eq(1)
        expect(subject.first["name"]).to eq("index")
      end
    end

    context "with layoutpages set to true" do
      subject { LaissCms::Page.selectable_layouts(language.id, layoutpages: true) }

      it "should only return layoutpages" do
        subject.each { expect(_1.layoutpage).to eq(true) }
      end
    end
  end

  describe ".human_layout_name" do
    subject { LaissCms::Page.human_layout_name("contact") }

    context "with no translation present" do
      it "returns the name capitalized" do
        is_expected.to eq("Contact")
      end
    end

    context "with translation present" do
      before { expect(LaissCms).to receive(:t).and_return("Kontakt") }

      it "returns the translated name" do
        is_expected.to eq("Kontakt")
      end
    end
  end
end
