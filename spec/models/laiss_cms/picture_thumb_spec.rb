# frozen_string_literal: true

require "rails_helper"

RSpec.describe LaissCms::PictureThumb, if: LaissCms.storage_adapter.dragonfly? do
  it { should belong_to(:picture).class_name("LaissCms::Picture") }
  it { should validate_presence_of(:signature) }
  it { should validate_presence_of(:uid) }
end
