# frozen_string_literal: true

require "rails_helper"
require "sprockets"

RSpec.describe LaissCms::Engine do
  describe "laiss_cms.admin_stylesheets" do
    let(:initializer) do
      LaissCms::Engine.initializers.detect do
        _1.name == "laiss_cms.admin_stylesheets"
      end
    end

    context "when sprockets is not defined" do
      before do
        hide_const("Sprockets")
      end

      it "does not add laiss_cms/admin/custom.css" do
        initializer.run(Rails.application)
        expect(Rails.application.config.assets.precompile).not_to include("laiss_cms/admin/custom.css")
      end
    end

    context "when sprockets is defined" do
      before do
        stub_const("Sprockets", Class.new)
      end

      it "includes laiss_cms/admin/custom.css" do
        initializer.run(Rails.application)
        expect(Rails.application.config.assets.precompile).to include("laiss_cms/admin/custom.css")
      end
    end
  end

  describe "laiss_cms.importmap" do
    let(:additional_importmap) do
      LaissCms::Configurations::Importmap.new(
        importmap_path: Rails.root.join("config/importmap.rb"),
        name: "additional_importmap",
        source_paths: [Rails.root.join("app/javascript")]
      )
    end

    before do
      stub_laiss_cms_config(admin_importmaps: [additional_importmap])
    end

    it "adds additional importmap to admin imports" do
      initializer = LaissCms::Engine.initializers.find { _1.name == "laiss_cms.importmap" }
      expect(LaissCms.config.admin_js_imports).to receive(:add).with("additional_importmap")
      prepare_blocks = initializer.run(Rails.application)
      prepare_blocks.last.call
    end
  end
end
