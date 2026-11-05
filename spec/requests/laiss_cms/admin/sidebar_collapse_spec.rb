# frozen_string_literal: true

require "rails_helper"

# Upstream already collapses the sidebar on the page editor via
# content_for(:main_menu_style). What was missing is a way to expand it again and
# any memory of the choice. These specs pin both, plus the upstream default so a
# future change cannot quietly remove it.
#
# There is no custom element and no JavaScript: the state is server-rendered and
# flipped by a plain link.
RSpec.describe "Admin sidebar collapse", type: :request do
  let(:page) { create(:laiss_cms_page) }

  before { authorize_user(:as_admin) }

  def collapsed?
    response.body.include?('<body id="laiss_cms" class="') &&
      response.body[/<body[^>]*class="([^"]*)"/, 1].to_s.split.include?("collapsed-menu")
  end

  def toggle_link
    Nokogiri::HTML(response.body).at_css("a.sidebar-collapse-toggle")
  end

  describe "the upstream default is preserved" do
    it "is collapsed on the page editor" do
      get "/admin/pages/#{page.id}/edit"
      expect(collapsed?).to be(true)
    end

    it "is expanded on the dashboard" do
      get "/admin/dashboard"
      expect(collapsed?).to be(false)
    end
  end

  describe "expanding from the editor" do
    it "expands when the toggle is followed" do
      get "/admin/pages/#{page.id}/edit", params: {sidebar: "expanded"}
      expect(collapsed?).to be(false)
    end

    it "remembers the choice on the next editor request" do
      get "/admin/pages/#{page.id}/edit", params: {sidebar: "expanded"}
      get "/admin/pages/#{page.id}/edit"
      expect(collapsed?).to be(false)
    end

    it "can be collapsed again" do
      get "/admin/pages/#{page.id}/edit", params: {sidebar: "expanded"}
      get "/admin/pages/#{page.id}/edit", params: {sidebar: "collapsed"}
      expect(collapsed?).to be(true)
    end
  end

  describe "the toggle link" do
    it "is offered on the editor" do
      get "/admin/pages/#{page.id}/edit"
      expect(toggle_link).to be_present
    end

    it "is not offered where nothing collapses" do
      get "/admin/dashboard"
      expect(toggle_link).to be_nil
    end

    it "carries an accessible name and controls relationship" do
      get "/admin/pages/#{page.id}/edit"
      expect(toggle_link["aria-controls"]).to eq("left_menu")
      expect(toggle_link["aria-label"]).to be_present
    end

    it "reports aria-expanded false while collapsed" do
      get "/admin/pages/#{page.id}/edit"
      expect(toggle_link["aria-expanded"]).to eq("false")
    end

    it "reports aria-expanded true once expanded" do
      get "/admin/pages/#{page.id}/edit", params: {sidebar: "expanded"}
      expect(toggle_link["aria-expanded"]).to eq("true")
    end

    it "points at the opposite state so one click flips it" do
      get "/admin/pages/#{page.id}/edit"
      expect(toggle_link["href"]).to include("sidebar=expanded")

      get "/admin/pages/#{page.id}/edit", params: {sidebar: "expanded"}
      expect(toggle_link["href"]).to include("sidebar=collapsed")
    end
  end
end
