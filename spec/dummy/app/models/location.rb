# frozen_string_literal: true

class Location < ActiveRecord::Base
  extend LaissCms::SearchableResource
  include LaissCms::Taggable

  has_many :events

  def self.ransackable_associations(_auth_object = nil)
    [
      :events
    ]
  end
end
