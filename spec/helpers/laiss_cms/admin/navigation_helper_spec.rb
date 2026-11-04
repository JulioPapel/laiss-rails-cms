# frozen_string_literal: true

require "rails_helper"

describe LaissCms::Admin::NavigationHelper do
  let(:laiss_cms_module) do
    {
      "name" => "dashboard",
      "engine_name" => "laiss_cms",
      "navigation" => {
        "name" => "modules.dashboard",
        "controller" => "laiss_cms/admin/dashboard",
        "action" => "index",
        "icon" => "dashboard"
      }
    }
  end

  describe "#laiss_cms_main_navigation_entry" do
    before do
      allow(helper).to receive(:can?).and_return(true)
    end

    it "is deprecated" do
      expect(LaissCms::Deprecation).to receive(:warn)
      helper.laiss_cms_main_navigation_entry(laiss_cms_module)
    end
  end

  describe "#url_for_module" do
    it "is deprecated" do
      expect(LaissCms::Deprecation).to receive(:warn)
      helper.url_for_module(laiss_cms_module)
    end
  end

  describe "#sorted_laiss_cms_modules" do
    it "is deprecated" do
      expect(LaissCms::Deprecation).to receive(:warn)
      helper.sorted_laiss_cms_modules
    end
  end
end
