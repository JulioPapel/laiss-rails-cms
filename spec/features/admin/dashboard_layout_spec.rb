# frozen_string_literal: true

require "rails_helper"

# The dashboard's widgets are fetched into turbo-frames, so they are in the DOM even
# when nothing about them is visible. Presence assertions passed while the screen
# showed a greeting and empty space: a 900x900 logo pushed every widget below the
# fold, and the stat columns collapsed to 34px because their .col-* had no .row
# parent. Both failures are geometry, so these assertions are geometry.
#
# A screen conversion is not verified until its content is measured on screen. This
# file is that check for the dashboard; `#dashboard *` element count and
# window.innerText are the two numbers to compare against the pre-conversion screen.
RSpec.describe "The Dashboard layout", type: :system, js: true do
  let(:user) { create(:laiss_cms_dummy_user, :as_editor, name: "Joe Editor") }

  before { authorize_user(user) }

  # Width and height of the first match, or [0, 0] when absent.
  def box(selector)
    page.evaluate_script(<<~JS)
      (function () {
        var el = document.querySelector(#{selector.to_json});
        if (!el) return [0, 0];
        var r = el.getBoundingClientRect();
        return [Math.round(r.width), Math.round(r.height)];
      })()
    JS
  end

  # Widgets arrive through turbo-frame requests, so every measurement has to wait for
  # them to resolve first. Waiting on the widgets themselves, not on a sleep.
  def wait_for_widgets
    expect(page).to have_css("#dashboard .stat-widget-two", count: 4)
    expect(page).to have_css("#LockedPages .widget-body")
    expect(page).to have_css("#RecentPages .widget-body")
  end

  it "shows all four stat widgets at a usable width" do
    visit admin_dashboard_path
    wait_for_widgets

    boxes = page.evaluate_script(<<~JS)
      Array.from(document.querySelectorAll("#dashboard .stat-widget-two")).map(function (el) {
        var r = el.getBoundingClientRect();
        return [Math.round(r.width), Math.round(r.height)];
      })
    JS

    expect(boxes.size).to eq(4)
    boxes.each do |width, height|
      # A collapsed column reports the content width of its text — 34px when this
      # last broke. 150px is comfortably below a real quarter-column at any
      # desktop width and comfortably above a collapsed one.
      expect(width).to be > 150, "a stat widget is #{width}px wide, which is a collapsed column"
      expect(height).to be > 60, "a stat widget is #{height}px tall, which is a collapsed card"
    end
  end

  it "constrains the system info logo to a sane size" do
    visit admin_dashboard_path
    wait_for_widgets

    width, height = box("#dashboard .system-info .logo svg")
    # logo.svg declares width="900px" height="900px" and has no CSS of its own, so
    # without a rule it renders 900x900 and pushes the whole page down.
    expect(width).to be_between(1, 200), "the logo is #{width}px wide"
    expect(height).to be_between(1, 200), "the logo is #{height}px tall"
  end

  it "keeps the top row from swallowing the page" do
    visit admin_dashboard_path
    wait_for_widgets

    _width, height = box("#dashboard > .container-fluid > .row")
    # The row holding the greeting and system info. It was 990px tall when the logo
    # was unconstrained; its content is a greeting and a small info card.
    expect(height).to be < 600, "the first row is #{height}px tall"
  end

  it "renders the usage bars with height" do
    visit admin_dashboard_path
    expect(page).to have_css("#PageUsage .usage-stats .bar")

    bars = page.evaluate_script(<<~JS)
      Array.from(document.querySelectorAll("#dashboard .usage-stats .bar")).map(function (el) {
        var r = el.getBoundingClientRect();
        return [Math.round(r.width), Math.round(r.height)];
      })
    JS

    expect(bars.size).to be > 0
    # Without the .bar rules the span is display: inline and measures 0x0, so the
    # table rows turn into a ragged stack of text.
    bars.each do |_width, height|
      expect(height).to be > 2, "a usage bar is #{height}px tall, which is an unstyled inline span"
    end
  end

  it "renders the widgets' visible text, not just their markup" do
    create(:laiss_cms_page, :public)

    visit admin_dashboard_path
    wait_for_widgets

    text = page.evaluate_script('document.querySelector("#dashboard").innerText')

    # innerText is what a person can read: it skips elements hidden with display:none
    # or zero size. The old dashboard passed presence assertions and still read as a
    # greeting, so the assertion is on the text.
    expect(text).to include(LaissCms::Page.model_name.human(count: :many))
    expect(text).to include(LaissCms.t("Currently locked pages"))
    expect(text).to include(LaissCms.t("Your last updated pages"))
    expect(text).to include(LaissCms.t(:page_usage, total: "").split(/[:(]/).first.strip)
  end
end
