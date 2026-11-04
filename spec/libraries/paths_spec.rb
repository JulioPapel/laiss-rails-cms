# frozen_string_literal: true

require "rails_helper"

module LaissCms
  describe "Paths" do
    describe "defaults" do
      it "has default value for LaissCms.admin_path" do
        expect(LaissCms.admin_path).to eq("admin")
      end

      it "has default value for LaissCms.admin_constraints" do
        expect(LaissCms.admin_constraints).to eq({})
      end
    end
  end
end
