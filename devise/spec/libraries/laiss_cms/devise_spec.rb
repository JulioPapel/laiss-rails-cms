require "rails_helper"

RSpec.describe LaissCms::Devise do
  describe ".layout" do
    it "delegates to LaissCms::Devise.config.layout" do
      LaissCms::Devise.deprecator.silenced do
        expect(LaissCms::Devise.layout).to eq(LaissCms::Devise.config.layout)
      end
    end

    it "is deprecated" do
      expect_any_instance_of(ActiveSupport::Deprecation).to receive(:warn).with(
        a_string_including("layout is deprecated"),
        an_instance_of(Array)
      )
      LaissCms::Devise.layout
    end
  end
end
