# frozen_string_literal: true

require "rails_helper"

module LaissCms
  describe ElementToPage do
    # ClassMethods

    describe ".table_name" do
      it "should return table name" do
        expect(ElementToPage.table_name).to eq("laiss_cms_elements_laiss_cms_pages")
      end
    end
  end
end
