# frozen_string_literal: true

require "rails_helper"

RSpec.describe LaissCms::Ingredients::DatetimeEditor, type: :component do
  let(:element) { build_stubbed(:laiss_cms_element, name: "all_you_can_eat") }
  let(:ingredient_editor) { described_class.new(ingredient) }
  let(:ingredient) { LaissCms::Ingredients::Datetime.new(id: 1234, role: "datetime", element: element) }

  before do
    vc_test_view_context.class.send(:include, LaissCms::Admin::BaseHelper)
  end

  it_behaves_like "an laiss_cms ingredient editor"

  it "renders a datepicker" do
    render_inline ingredient_editor
    expect(page).to have_css('laiss-cms-datepicker[input-type="datetime"] input[type="text"].datetime')
  end

  context "without edit permission" do
    before do
      allow(vc_test_view_context).to receive(:can?).and_return(false)
    end

    it "renders a readonly datepicker input" do
      render_inline ingredient_editor
      expect(page).to have_css('laiss-cms-datepicker input[type="text"][disabled]')
    end
  end
end
