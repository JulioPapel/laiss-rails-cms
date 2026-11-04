# frozen_string_literal: true

module LaissCms
  module Admin
    module PreviewTime
      extend ActiveSupport::Concern

      included do
        before_action :set_preview_time, if: :should_set_preview_time?
      end

      private

      def set_preview_time
        Current.preview_time = Time.zone.parse(params[:laiss_cms_preview_time])
      end

      def should_set_preview_time?
        params[:laiss_cms_preview_time].present? && can?(:edit_content, LaissCms::Page)
      end
    end
  end
end
