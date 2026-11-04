# frozen_string_literal: true

module LaissCms
  class LanguageSerializer < ActiveModel::Serializer
    attributes :id,
      :name
  end
end
