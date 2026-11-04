module LaissCms
  module Admin
    class AttachmentSelect < ViewComponent::Base
      delegate :laiss_cms, to: :helpers

      def initialize(attachment = nil, url: nil, placeholder: LaissCms.t("Please choose"), query_params: nil)
        @attachment = attachment
        @url = url
        @placeholder = placeholder
        @query_params = query_params
      end

      def call
        content_tag("laiss-cms-attachment-select", content, attributes)
      end

      private

      def attributes
        options = {
          "allow-clear": true,
          placeholder: @placeholder,
          url: @url || laiss_cms.api_attachments_path
        }

        if @query_params
          options[:"query-params"] = @query_params.to_json
        end

        if @attachment
          selection = ActiveModelSerializers::SerializableResource.new(@attachment)
          options[:selection] = selection.to_json
        end

        options
      end
    end
  end
end
