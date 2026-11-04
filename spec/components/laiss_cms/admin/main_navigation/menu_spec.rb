# frozen_string_literal: true

require "rails_helper"

RSpec.describe LaissCms::Admin::MainNavigation::Menu, type: :component do
  let(:first) do
    LaissCms::Configurations::MenuItem.new(name: "first", title: "First", position: 1, url: -> { laiss_cms.admin_pages_path })
  end

  let(:between) do
    LaissCms::Configurations::MenuItem.new(name: "between", title: "Between", position: 4.1, url: -> { laiss_cms.admin_languages_path })
  end

  let(:last) do
    LaissCms::Configurations::MenuItem.new(name: "last", title: "Last", position: 5, url: -> { laiss_cms.admin_sites_path })
  end

  let(:unpositioned) do
    LaissCms::Configurations::MenuItem.new(name: "unpositioned", title: "Unpositioned", url: -> { laiss_cms.admin_tags_path })
  end

  before do
    vc_test_view_context.class.include LaissCms::Admin::BaseHelper
    stub_laiss_cms_config(menu: [unpositioned, last, between, first])
  end

  it "renders the entries sorted by position with unpositioned entries last" do
    render_inline(described_class.new)
    expect(page.all("#main_navi laiss-cms-main-navi-entry label").map(&:text)).to eq(%w[First Between Last Unpositioned])
  end

  describe "#items" do
    it "returns the menu items sorted by position with unpositioned entries last" do
      expect(described_class.new.items).to eq([first, between, last, unpositioned])
    end
  end
end
