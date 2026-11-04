# frozen_string_literal: true

# Dragonfly is only needed for the legacy dragonfly storage adapter
# and needs to be added to the app's Gemfile.
if defined?(::Dragonfly)
  require "laiss_cms/dragonfly/processors/crop_resize"
  require "laiss_cms/dragonfly/processors/auto_orient"
  require "laiss_cms/dragonfly/processors/thumbnail"

  # Logger
  Dragonfly.logger = Rails.logger

  # Add model functionality
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.extend Dragonfly::Model
    ActiveRecord::Base.extend Dragonfly::Model::Validations
  end

  # Dragonfly 1.4.0 only allows `quality` as argument to `encode`
  Dragonfly::ImageMagick::Processors::Encode::WHITELISTED_ARGS << "flatten"
  Dragonfly::ImageMagick::Processors::Encode::WHITELISTED_ARGS << "background"

  Rails.application.config.after_initialize do
    Dragonfly.app(:laiss_cms_pictures).add_processor(:crop_resize, LaissCms::Dragonfly::Processors::CropResize.new)
    Dragonfly.app(:laiss_cms_pictures).add_processor(:auto_orient, LaissCms::Dragonfly::Processors::AutoOrient.new)
    Dragonfly.app(:laiss_cms_pictures).add_processor(:thumbnail, LaissCms::Dragonfly::Processors::Thumbnail.new)
  end
end
