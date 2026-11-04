# frozen_string_literal: true

require "rails_helper"

RSpec.describe LaissCms::Admin::ResourceName, type: :model do
  let(:klass) do
    Class.new do
      include LaissCms::Admin::ResourceName

      attr_reader :controller_path

      def initialize(controller_path)
        @controller_path = controller_path
      end
    end
  end

  let(:controller_path) { "laiss_cms/admin/pages" }

  let(:instance) { klass.new(controller_path) }

  describe "#resource_model_name" do
    it "returns the correct resource model name" do
      expect(instance.send(:resource_model_name)).to eq("LaissCms::Page")
    end
  end

  describe "#resource_name" do
    it "returns the correct resource name" do
      expect(instance.send(:resource_name)).to eq("page")
    end
  end

  describe "#resource_array" do
    it "returns the correct resource array" do
      expect(instance.send(:resource_array)).to eq(["laiss_cms", "pages"])
    end
  end

  describe "#resources_name" do
    it "returns the correct resources name" do
      expect(instance.send(:resources_name)).to eq("pages")
    end
  end

  describe "#controller_path_array" do
    it "returns the correct controller path array" do
      expect(instance.send(:controller_path_array)).to eq(["laiss_cms", "admin", "pages"])
    end
  end
end
