# frozen_string_literal: true

module LaissCms
  def self.table_name_prefix
    "laiss_cms_"
  end

  class BaseRecord < ActiveRecord::Base
    include ConfigMissing
    extend ConfigMissing
    extend LaissCms::SearchableResource

    self.abstract_class = true
  end
end
