# frozen_string_literal: true

module LaissCms
  module Ingredients
    class NodeEditor < BaseEditor
      delegate :node, :page, to: :ingredient

      def input_field
        render LaissCms::Admin::NodeSelect.new(
          node,
          url: laiss_cms.api_nodes_path(language_id: page&.language_id, include: :ancestors),
          query_params: settings.fetch(:query_params, {})
        ) do
          text_field_tag form_field_name(:node_id),
            node&.id,
            id: form_field_id(:node_id),
            class: "laiss_cms_selectbox full_width",
            disabled: !editable?
        end
      end
    end
  end
end
