require "rails_helper"

RSpec.describe LaissCms::Admin::FormHelper do
  describe "#laiss_cms_form_for" do
    subject { helper.laiss_cms_form_for(resource) {} }

    let(:resource) do
      [laiss_cms, :admin, LaissCms::Element.new(name: "article")]
    end

    it "returns a form with laiss_cms class" do
      expect(subject).to have_css(".laiss_cms")
    end

    it "enables browser validations" do
      expect(subject).not_to have_css("form[novalidate]")
    end
  end
end
