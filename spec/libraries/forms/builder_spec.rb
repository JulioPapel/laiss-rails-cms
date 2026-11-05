# frozen_string_literal: true

require "rails_helper"

RSpec.describe LaissCms::Forms::Builder, type: :controller do
  let(:object_name) { "Ding" }
  let(:form_object) { double("FormObject", foo: "Baz") }

  shared_examples_for "datepicker expect" do
    it "has the laiss-cms-datepicker" do
      expect(template).to receive(:content_tag).with("laiss-cms-datepicker", "<laiss-cms-datepicker>", {"input-type" => type})
      subject
    end

    it "returns input field" do
      expect(template).to receive(:text_field).with(
        "Ding",
        :foo,
        hash_including(
          type: :text,
          value: value,
          class: ["form-control", :string, :required, type]
        )
      )
      subject
    end
  end

  let(:builder) { described_class.new(object_name, form_object, template, {}) }

  describe "#datepicker" do
    let(:attribute) { :foo }

    let(:template) do
      double(
        "Template",
        controller: controller,
        label: "<label>",
        text_field: "<input>",
        content_tag: "<laiss-cms-datepicker>"
      )
    end

    subject { builder.datepicker(attribute, options) }

    context "with date value" do
      context "on the object" do
        let(:options) { {as: :date} }
        let(:form_object) { double("FormObject", foo: "2021-07-14") }

        it_behaves_like "datepicker expect" do
          let(:type) { :date }
          let(:value) { "2021-07-14T00:00:00+02:00" }
        end
      end

      context "in the html options" do
        let(:options) { {as: :date, input_html: {value: "2021-08-01"}} }

        it_behaves_like "datepicker expect" do
          let(:type) { :date }
          let(:value) { "2021-08-01T00:00:00+02:00" }
        end
      end
    end

    context "as date" do
      let(:options) { {as: :date} }

      it_behaves_like "datepicker expect" do
        let(:type) { :date }
        let(:value) { nil }
      end
    end

    context "as time" do
      let(:options) { {as: :time} }

      it_behaves_like "datepicker expect" do
        let(:type) { :time }
        let(:value) { nil }
      end
    end

    context "as datetime" do
      let(:options) { {as: :datetime} }

      it_behaves_like "datepicker expect" do
        let(:type) { :datetime }
        let(:value) { nil }
      end
    end
  end

  describe "#richtext" do
    let(:attribute) { :foo }

    let(:template) do
      double(
        "Template",
        controller: controller,
        label: "<label>",
        textarea: "<textarea>",
        text_area: "<textarea>", # need to support Rails 7
        content_tag: "<laiss-cms-tinymce>"
      )
    end

    subject { builder.richtext(attribute) }

    it "uses a laiss-cms-tinymce" do
      receiving_method = (Rails::VERSION::MAJOR >= 8) ? :textarea : :text_area
      expect(template).to receive(receiving_method).with(
        "Ding",
        :foo,
        hash_including(
          class: ["form-control", :text, :required]
        )
      )
      expect(template).to receive(:content_tag).with("laiss-cms-tinymce", "<laiss-cms-tinymce>")
      subject
    end
  end
end
