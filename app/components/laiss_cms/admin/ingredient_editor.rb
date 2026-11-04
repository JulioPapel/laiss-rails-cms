# frozen_string_literal: true

module LaissCms
  module Admin
    # Adapter component for rendering ingredient editors.
    #
    # Handles both deprecated partial-based editors and component based editors.
    # Use with_collection for efficient batch rendering of ingredients.
    #
    # @example Component based editors (no element_form needed)
    #   <%= render LaissCms::Admin::IngredientEditor.with_collection(
    #     element.ungrouped_ingredients
    #   ) %>
    #
    # @example With element_form for deprecated partials
    #   <%= render LaissCms::Admin::IngredientEditor.with_collection(
    #     element.ungrouped_ingredients,
    #     element_form: f
    #   ) %>
    #
    class IngredientEditor < ViewComponent::Base
      with_collection_parameter :ingredient

      # @param ingredient [LaissCms::Ingredient] The ingredient to render an editor for
      # @param element_form [ActionView::Helpers::FormBuilder, nil] Optional form builder for deprecated partials
      def initialize(ingredient:, element_form: nil)
        @ingredient = ingredient
        @element_form = element_form
      end

      def call
        if has_editor_partial?
          LaissCms::Deprecation.warn <<~WARN
            Ingredient editor partials are deprecated!
            Please create a `#{@ingredient.class.name}Editor` class inheriting from `LaissCms::Ingredients::BaseEditor`.
          WARN
          LaissCms::Deprecation.silence do
            render partial: "laiss_cms/ingredients/#{@ingredient.partial_name}_editor",
              locals: {element_form: @element_form},
              object: LaissCms::IngredientEditor.new(@ingredient)
          end
        else
          render @ingredient.as_editor_component
        end
      end

      private

      def has_editor_partial?
        helpers.lookup_context.template_exists?("laiss_cms/ingredients/_#{@ingredient.partial_name}_editor")
      end
    end
  end
end
