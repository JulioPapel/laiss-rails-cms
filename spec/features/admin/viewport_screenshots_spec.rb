# frozen_string_literal: true

require "rails_helper"

# The guard that would have caught the 500px screenshots.
#
# Every mobile screenshot in this project was 500x726 while named 375. Nothing failed,
# because nothing was checking. This spec proves the check now fires.
RSpec.describe "ViewportScreenshots.capture", type: :system, js: true do
  include LaissCms::TestSupport::ViewportScreenshots

  before { authorize_user(:as_admin) }

  context "when the browser cannot honour the requested width" do
    before { driven_with_viewport(1440, 900) }

    it "refuses to write a file that would lie about its size" do
      visit "/admin/dashboard"

      expect {
        capture("/tmp/should-not-exist-375.png", width: 375)
      }.to raise_error(/asked for a 375px viewport, the browser reports 1440px/)

      expect(File.exist?("/tmp/should-not-exist-375.png")).to be(false)
    end
  end

  context "with an emulated 375px viewport" do
    before { driven_with_viewport(375, 812) }

    it "writes a file that is genuinely 375px wide" do
      visit "/admin/dashboard"
      expect(page).to have_css("#dashboard .stat-widget-two", count: 4)

      width, height = capture("/tmp/verified-375.png", width: 375, height: 812)

      expect(width).to eq(375)
      expect(height).to eq(812)
      expect(File.exist?("/tmp/verified-375.png")).to be(true)
    end

    it "lays out without horizontal overflow at 375" do
      visit "/admin/dashboard"
      expect(page).to have_css("#dashboard .stat-widget-two", count: 4)

      scroll_width = page.evaluate_script("document.documentElement.scrollWidth")
      expect(scroll_width).to be <= 375
    end
  end

  context "with a normal desktop viewport" do
    before { driven_with_viewport(1440, 900) }

    it "writes a file that is genuinely 1440px wide" do
      visit "/admin/dashboard"

      width, _height = capture("/tmp/verified-1440.png", width: 1440)
      expect(width).to eq(1440)
    end
  end
end
