# frozen_string_literal: true

require "rails_helper"

RSpec.describe LaissCms::DeleteElements do
  let!(:parent_element) { create(:laiss_cms_element, :with_nestable_elements, :with_ingredients) }
  let!(:nested_element) { parent_element.nested_elements.first }
  let!(:normal_element) { create(:laiss_cms_element, :with_ingredients, tag_names: ["Zero"]) }

  before do
    nested_element.tag_names = ["Cool"]
    nested_element.save!
    expect(LaissCms::Element.count).not_to be_zero
    expect(LaissCms::Ingredient.count).not_to be_zero
    expect(Gutentag::Tagging.count).not_to be_zero
  end

  subject { LaissCms::DeleteElements.new(elements).call }

  context "with all elements" do
    let(:elements) { [parent_element, nested_element, normal_element] }

    it "destroys all elements" do
      subject
      expect(LaissCms::Element.count).to be_zero
      expect(LaissCms::Ingredient.count).to be_zero
      expect(Gutentag::Tagging.count).to be_zero
    end

    context "when calling with an ActiveRecord::Relation" do
      let(:elements) { LaissCms::Element.all }

      it "works" do
        subject
        expect(LaissCms::Element.count).to be_zero
        expect(LaissCms::Ingredient.count).to be_zero
        expect(Gutentag::Tagging.count).to be_zero
      end
    end

    context "when calling it as an association" do
      let(:page_version) { create(:laiss_cms_page_version) }
      let(:elements) { page_version.elements }
      before do
        LaissCms::Element.update_all(page_version_id: page_version.id)
      end

      it "works" do
        subject
        expect(LaissCms::Element.count).to be_zero
        expect(LaissCms::Ingredient.count).to be_zero
        expect(Gutentag::Tagging.count).to be_zero
      end
    end
  end

  context "when calling with an element having nested elements that is not in the collection" do
    let(:elements) { [parent_element, normal_element] }

    it "raises an error and deletes nothing" do
      expect { subject }.to raise_exception(LaissCms::DeleteElements::WouldLeaveOrphansError)
    end
  end
end
