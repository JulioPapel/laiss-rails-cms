# frozen_string_literal: true

require "rails_helper"

RSpec.describe LaissCms::Ingredients::SelectEditor, type: :component do
  let(:element) { build_stubbed(:laiss_cms_element, name: "all_you_can_eat") }
  let(:ingredient) { LaissCms::Ingredients::Select.new(id: 1, role: "select", value: "blue", element: element) }

  before do
    vc_test_view_context.class.include LaissCms::Admin::BaseHelper
    allow(ingredient).to receive(:definition) do
      LaissCms::IngredientDefinition.new(role: "select", type: "Select", settings: {select_values: %w[red green blue]})
    end
  end

  it_behaves_like "an laiss_cms ingredient editor"
end
