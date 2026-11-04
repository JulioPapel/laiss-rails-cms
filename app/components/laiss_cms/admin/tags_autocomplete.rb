module LaissCms
  module Admin
    class TagsAutocomplete < ViewComponent::Base
      delegate :laiss_cms, to: :helpers

      def initialize(additional_class: nil)
        @additional_class = additional_class
      end

      def call
        content_tag("laiss-cms-tags-autocomplete", content, attributes)
      end

      private

      def attributes
        {
          placeholder: LaissCms.t(:search_tag),
          url: laiss_cms.autocomplete_admin_tags_path,
          class: @additional_class
        }
      end
    end
  end
end
