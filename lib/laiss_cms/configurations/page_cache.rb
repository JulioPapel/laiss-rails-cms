# frozen_string_literal: true

module LaissCms
  module Configurations
    class PageCache < LaissCms::Configuration
      # === Page caching max age
      #
      # Control the max-age duration in seconds in the cache-control header.
      #
      option :max_age, :integer, default: 600

      # === Page caching stale-while-revalidate
      #
      # Set stale-while-revalidate cache-control header.
      #
      option :stale_while_revalidate, :integer
    end
  end
end
