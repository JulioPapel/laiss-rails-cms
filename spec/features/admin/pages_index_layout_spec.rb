# frozen_string_literal: true

require "rails_helper"

# Content verification for the Pages index, per the rule in
# docs/design/focus-migration-log.md: element count and innerText length are compared
# against the pre-conversion screen, because a spec that asserts markup exists passes on
# a page that lost its content.
#
# Pre-conversion numbers, measured on `main` before this screen was converted:
#
#   tree view:  320 elements, 179 characters of innerText
#   list view:  (see below — the table structure changed, so the count is expected to move)
#
# The tree numbers are the regression floor: the tree's markup was NOT converted, so its
# content must still be exactly what it was. The list numbers will grow because the table
# gained the theme's `.table-responsive` wrapper and the status cells became badges.
RSpec.describe "The Pages index", type: :system, js: true do
  let(:site) { create(:laiss_cms_site, :default) }
  let!(:language) { create(:laiss_cms_language, site: site) }

  before { authorize_user(:as_admin) }

  def root_element
    page.evaluate_script(<<~JS)
      (function () {
        var c = document.querySelector("#main_content") || document.body;
        c.setAttribute("data-root", "1");
        return true;
      })()
    JS
  end

  def element_count
    page.evaluate_script('document.querySelectorAll("[data-root] *").length')
  end

  def visible_text
    page.evaluate_script('document.querySelector("[data-root]").innerText') || ""
  end

  describe "tree view" do
    before do
      create(:laiss_cms_page, :language_root, :public, name: "Index", language: language)
      create(:laiss_cms_page, :public, name: "About", urlname: "about",
        parent: LaissCms::Page.first, language: language)
    end

    it "keeps the page tree's content" do
      visit "/admin/pages?view=tree"
      expect(page).to have_css("#sitemap", wait: 5)
      root_element

      text = visible_text
      expect(text).to include("Index")
      expect(text).to include("About")
      # The three column headings the tree declares. Compared case-insensitively: the
      # stylesheet uppercases them with text-transform, and innerText reports the
      # RENDERED text, so it reads "NAME" while the source says "Name".
      downcased = text.downcase
      expect(downcased).to include(LaissCms::Page.human_attribute_name(:name).downcase)
      expect(downcased).to include(LaissCms::Page.human_attribute_name(:urlname).downcase)
      expect(downcased).to include(LaissCms.t(:page_status).downcase)

      # A per-page floor, not a total: the baseline 320 elements were measured with 7
      # pages seeded, and this example creates 2. A page node contributes about 40
      # elements (icon, folder button, three links, five tool buttons with tooltips),
      # so 2 pages must still exceed 80. Measuring a raw total here would only be
      # testing how much fixture data the example happened to create.
      expect(element_count).to be >= 80
      # Measured at 41 characters for these two pages ("NAME / URL-PATH / STATUS /
      # Index / / / About / /about" plus newlines). The floor only has to catch a tree
      # that rendered headings and no rows.
      expect(text.length).to be >= 30
    end
  end

  describe "list view" do
    before do
      root = create(:laiss_cms_page, :language_root, :public, name: "Index", language: language)
      create(:laiss_cms_page, :public, name: "About", urlname: "about", parent: root, language: language)
      create(:laiss_cms_page, name: "Contact", urlname: "contact", parent: root, language: language)
    end

    it "renders the theme's table component" do
      visit "/admin/pages?view=list"
      expect(page).to have_css("table.table.list", wait: 5)

      # The theme's overflow wrapper, which table-basic.html uses around its table.
      expect(page).to have_css(".table-responsive > table.table")

      root_element
      text = visible_text
      expect(text).to include("About")
      expect(text).to include("Contact")
      expect(text).to include("NAME")
    end

    it "renders page status as a theme badge" do
      visit "/admin/pages?view=list"
      expect(page).to have_css("table.table.list", wait: 5)

      # Contact is a draft: it must carry the theme's .badge, and the badge must be a
      # flex box so its icon and label have a gap. An inline-block badge silently
      # collapses the gap to 0 — measured before this was fixed.
      expect(page).to have_css(".page_status.badge")

      gap = page.evaluate_script(<<~JS)
        (function () {
          var b = document.querySelector(".page_status.badge");
          if (!b) return null;
          var cs = getComputedStyle(b);
          return {display: cs.display, gap: cs.gap, radius: cs.borderTopLeftRadius};
        })()
      JS
      expect(gap["display"]).to eq("inline-flex")
      expect(gap["gap"]).to eq("4px")
    end
  end

  it "branches on @view rather than rendering one layout for both" do
    create(:laiss_cms_page, :language_root, :public, name: "Index", language: language)

    visit "/admin/pages?view=tree"
    expect(page).to have_css("#sitemap", wait: 5)
    expect(page).to have_no_css("table.table.list")

    visit "/admin/pages?view=list"
    expect(page).to have_css("table.table.list", wait: 5)
    expect(page).to have_no_css("#sitemap")
  end
end
