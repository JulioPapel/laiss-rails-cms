require_relative "../rails_helper"

RSpec.describe LaissCms do
  describe ".devise_modules" do
    it "delegates to LaissCms::Devise.config.devise_modules" do
      LaissCms::Devise.deprecator.silenced do
        expect(LaissCms.devise_modules).to eq(LaissCms::Devise.config.devise_modules)
      end
    end

    it "is deprecated" do
      expect_any_instance_of(ActiveSupport::Deprecation).to receive(:warn).with(
        a_string_including("devise_modules is deprecated"),
        an_instance_of(Array)
      )
      LaissCms.devise_modules
    end
  end
end
