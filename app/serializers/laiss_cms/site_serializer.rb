# frozen_string_literal: true

module LaissCms
  class SiteSerializer < ActiveModel::Serializer
    attributes :id,
      :name
  end
end
