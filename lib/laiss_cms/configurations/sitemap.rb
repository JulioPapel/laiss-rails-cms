# frozen_string_literal: true

module LaissCms
  module Configurations
    class Sitemap < LaissCms::Configuration
      option :show_root, :boolean, default: true
      option :show_flag, :boolean, default: false
      option :max_age, :integer, default: 3600
    end
  end
end
