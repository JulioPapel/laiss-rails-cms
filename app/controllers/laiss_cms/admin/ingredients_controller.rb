# frozen_string_literal: true

module LaissCms
  module Admin
    class IngredientsController < LaissCms::Admin::BaseController
      load_and_authorize_resource class: LaissCms::Ingredient

      include CropAction

      helper "LaissCms::Admin::Ingredients"

      def edit
        @language = LaissCms::Language.find_by(id: params[:language_id]) ||
          LaissCms::Current.language
      end

      def update
        @page = @ingredient.page # necessary to a render picture ingredient component
        @ingredient.update(ingredient_params)
      end

      private

      def ingredient_params
        params[:ingredient]&.permit(@ingredient.class.stored_attributes[:data]) ||
          ActionController::Parameters.new
      end

      def load_croppable_resource
        @croppable_resource = @ingredient
      end
    end
  end
end
