# frozen_string_literal: true

class DummyUser < ActiveRecord::Base
  include LaissCms::UserMethods

  has_many :folded_pages, class_name: "LaissCms::FoldedPage"
  attr_writer :name

  def self.logged_in
    []
  end

  def name
    @name || email
  end

  def laiss_cms_display_name
    name
  end

  def sign_in_count = 0
  def last_sign_in_at = Date.yesterday
end
