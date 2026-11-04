# frozen_string_literal: true

module LaissCms
  class ElementToPage
    def self.table_name
      [LaissCms::Element.table_name, LaissCms::Page.table_name].join("_")
    end
  end
end
