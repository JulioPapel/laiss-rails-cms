# frozen_string_literal: true

module LaissCms
  module Admin
    module FormHelper
      # Use this form helper to render any form in LaissCms admin interface.
      #
      # This is simply a wrapper for `simple_form_for`
      #
      # == Defaults
      #
      # * It uses LaissCms::Forms::Builder as builder
      # * It adds the laiss_cms class to form
      #
      def laiss_cms_form_for(object, *args, &block)
        options = args.extract_options!
        options[:builder] = LaissCms::Forms::Builder
        options[:html] = {
          id: options.delete(:id),
          class: ["laiss_cms", options.delete(:class)].compact.join(" "),
          novalidate: false
        }
        simple_form_for(object, *(args << options), &block)
      end
    end
  end
end
