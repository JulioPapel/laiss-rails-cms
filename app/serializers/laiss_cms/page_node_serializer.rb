# frozen_string_literal: true

module LaissCms
  class PageNodeSerializer < ActiveModel::Serializer
    attributes :id,
      :url_path,
      :parent_id
  end
end
