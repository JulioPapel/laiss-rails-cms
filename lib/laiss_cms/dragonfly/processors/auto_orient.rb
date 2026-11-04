# frozen_string_literal: true

require "dragonfly/image_magick/commands"

module LaissCms
  module Dragonfly
    module Processors
      class AutoOrient
        def call(content)
          ::Dragonfly::ImageMagick::Commands.convert(
            content,
            "-auto-orient"
          )
        end
      end
    end
  end
end
