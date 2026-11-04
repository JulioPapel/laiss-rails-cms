# frozen_string_literal: true

require "rails_helper"

describe "LaissCms::AuthAccessors" do
  describe ".user_class" do
    it "injects userstamp class methods" do
      expect(LaissCms.config.user_class).to respond_to(:stamper_class_name)
      expect(LaissCms.config.user_class.stamper_class_name).to eq(:"::DummyUser")
    end
  end
end
