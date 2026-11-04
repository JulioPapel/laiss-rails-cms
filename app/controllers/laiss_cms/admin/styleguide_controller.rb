# frozen_string_literal: true

module LaissCms
  module Admin
    class StyleguideController < BaseController
      authorize_resource class: :laiss_cms_admin_styleguide
    end
  end
end
