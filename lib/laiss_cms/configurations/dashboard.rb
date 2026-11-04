# frozen_string_literal: true

module LaissCms
  module Configurations
    class Dashboard < LaissCms::Configuration
      option :stats, :collection, item_type: :class, default: [
        [
          "LaissCms::Admin::Dashboard::Widget", {
            id: "PageCounts",
            style: "stat"
          }
        ],
        [
          "LaissCms::Admin::Dashboard::Widget", {
            id: "UserCounts",
            style: "stat"
          }
        ],
        [
          "LaissCms::Admin::Dashboard::Widget", {
            id: "PictureCounts",
            style: "stat"
          }
        ],
        [
          "LaissCms::Admin::Dashboard::Widget", {
            id: "AttachmentCounts",
            style: "stat"
          }
        ]
      ]

      option :widgets, :collection, item_type: :class, default: [
        [
          "LaissCms::Admin::Dashboard::Widget", {
            id: "LockedPages",
            style: "wide"
          }
        ],
        [
          "LaissCms::Admin::Dashboard::Widget", {
            id: "RecentPages",
            style: "wide"
          }
        ],
        [
          "LaissCms::Admin::Dashboard::Widget", {
            id: "ElementUsage",
            style: "usage",
            loading: "lazy"
          }
        ],
        [
          "LaissCms::Admin::Dashboard::Widget", {
            id: "PageUsage",
            style: "usage",
            loading: "lazy"
          }
        ],
        [
          "LaissCms::Admin::Dashboard::Widget", {
            id: "Sites",
            loading: "lazy",
            condition: -> { helpers.multi_site? }
          }
        ],
        [
          "LaissCms::Admin::Dashboard::Widget", {
            id: "OnlineUsers",
            loading: "lazy",
            condition: -> {
              LaissCms.config.user_class.respond_to?(:logged_in)
            }
          }
        ]
      ]
    end
  end
end
