# frozen_string_literal: true

require "rails_helper"
require "laiss_cms/test_support/shared_publishable_examples"

describe LaissCms::PageVersion do
  it { is_expected.to belong_to(:page) }
  it { is_expected.to have_many(:elements) }

  it { is_expected.to have_db_column(:title).of_type(:string) }
  it { is_expected.to have_db_column(:meta_description).of_type(:text) }
  it { is_expected.to have_db_column(:meta_keywords).of_type(:text) }

  let(:page) { create(:laiss_cms_page) }

  it_behaves_like("being publishable", :laiss_cms_page_version)

  describe "when saved" do
    let(:page_version) { build(:laiss_cms_page_version) }
    let(:page) { page_version.page }

    it "touches the page" do
      expect { page_version.save }.to change(page, :updated_at)
    end
  end

  describe "#set_title_from_page" do
    let(:page) { create(:laiss_cms_page, name: "My Page Name") }

    context "when title is blank" do
      it "sets title from page name" do
        page_version = page.versions.create!(title: nil)
        expect(page_version.title).to eq("My Page Name")
      end

      it "sets title from page name when title is empty string" do
        page_version = page.versions.create!(title: "")
        expect(page_version.title).to eq("My Page Name")
      end
    end

    context "when title is already set" do
      it "does not override the title" do
        page_version = page.versions.create!(title: "Custom Title")
        expect(page_version.title).to eq("Custom Title")
      end
    end
  end

  describe "dependent element destruction" do
    let!(:parent_element) { create(:laiss_cms_element, :with_nestable_elements, :with_ingredients) }
    let!(:nested_element) { parent_element.nested_elements.first }
    let!(:normal_element) { create(:laiss_cms_element, :with_ingredients) }

    let(:page_version) { create(:laiss_cms_page_version) }

    before do
      LaissCms::Element.update_all(page_version_id: page_version.id)
    end

    it "deletes all elements along with the page version" do
      page_version.destroy!
      expect(LaissCms::Element.count).to be_zero
      expect(LaissCms::Ingredient.count).to be_zero
    end
  end

  describe "#element_repository" do
    let(:page_version) { create(:laiss_cms_page_version, :with_elements) }
    subject { page_version.element_repository }

    it "is an element repository containing the pages elements" do
      expect(LaissCms::ElementsRepository).to receive(:new).with(page_version.elements).and_call_original
      expect(subject).to be_a(LaissCms::ElementsRepository)
    end

    it "memoizes the repository so nested rendering reuses one in-memory load" do
      expect(page_version.element_repository).to be(page_version.element_repository)
    end
  end
end
