# frozen_string_literal: true

module LaissCms
  module Configurations
    class Importmap < LaissCms::Configuration
      option :importmap_path, :pathname
      option :source_paths, :collection, item_type: :pathname
      option :name, :string
    end
  end
end
