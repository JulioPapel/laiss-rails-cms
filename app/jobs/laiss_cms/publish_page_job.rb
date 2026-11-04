# frozen_string_literal: true

module LaissCms
  class PublishPageJob < BaseJob
    queue_as :default

    def perform(page_id, public_on:)
      page = LaissCms::Page.includes(
        LaissCms::EagerLoading.page_includes(version: :draft_version)
      ).find(page_id)
      LaissCms::Page::Publisher.new(page).publish!(public_on: public_on)
    end
  end
end
