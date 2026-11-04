# frozen_string_literal: true

module LaissCms
  module Configurations
    module Menu
      DEFAULT = [
        {
          name: "dashboard",
          title: "Home",
          position: 1,
          icon: "home-2",
          url: -> { laiss_cms.admin_dashboard_path },
          condition: -> { can?(:index, :laiss_cms_admin_dashboard) }
        },
        {
          name: "pages",
          title: "modules.pages",
          position: 2,
          icon: "pages",
          url: -> { laiss_cms.admin_pages_path },
          condition: -> { can?(:index, :laiss_cms_admin_pages) },
          children: [
            {
              title: "modules.pages",
              url: -> { laiss_cms.admin_pages_path },
              condition: -> { can?(:index, :laiss_cms_admin_pages) }
            },
            {
              title: "modules.layoutpages",
              url: -> { laiss_cms.admin_layoutpages_path },
              condition: -> { can?(:index, :laiss_cms_admin_layoutpages) }
            }
          ]
        },
        {
          name: "menus",
          title: "modules.menus",
          position: 3,
          icon: "menu-2",
          url: -> { laiss_cms.admin_nodes_path },
          condition: -> { can?(:index, :laiss_cms_admin_nodes) }
        },
        {
          name: "languages",
          title: "modules.languages",
          position: 4,
          icon: "translate-2",
          icon_style: "none",
          url: -> { laiss_cms.admin_languages_path },
          condition: -> { can?(:index, :laiss_cms_admin_languages) }
        },
        {
          name: "sites",
          title: "modules.sites",
          position: 5,
          icon: "global",
          url: -> { laiss_cms.admin_sites_path },
          condition: -> { can?(:index, :laiss_cms_admin_sites) }
        },
        {
          name: "tags",
          title: "modules.tags",
          position: 6,
          icon: "price-tag-3",
          url: -> { laiss_cms.admin_tags_path },
          condition: -> { can?(:index, :laiss_cms_admin_tags) }
        },
        {
          name: "archive",
          title: "modules.library",
          position: 7,
          icon: "archive-drawer",
          url: -> { laiss_cms.admin_pictures_path },
          condition: -> { can?(:index, :laiss_cms_admin_pictures) },
          children: [
            {
              title: "modules.pictures",
              url: -> { laiss_cms.admin_pictures_path },
              condition: -> { can?(:index, :laiss_cms_admin_pictures) }
            },
            {
              title: "modules.attachments",
              url: -> { laiss_cms.admin_attachments_path },
              condition: -> { can?(:index, :laiss_cms_admin_attachments) }
            }
          ]
        }
      ].freeze
    end
  end
end
