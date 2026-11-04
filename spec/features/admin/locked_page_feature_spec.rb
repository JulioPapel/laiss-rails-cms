# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Locked pages feature", type: :system do
  let(:a_page) { create(:laiss_cms_page) }

  let(:user) do
    create(:laiss_cms_dummy_user, :as_author)
  end

  before do
    a_page.lock_to!(user)
    authorize_user(user)
  end

  it "displays tab for each locked page" do
    visit laiss_cms.admin_pages_path

    within "#locked_pages" do
      expect(page).to have_link a_page.name, href: laiss_cms.edit_admin_page_path(a_page)
    end
  end

  it "unlocks the page and removes its tab when clicking unlock", :js do
    visit laiss_cms.admin_pages_path

    within "#locked_page_#{a_page.id}" do
      find("button[title='#{LaissCms.t(:explain_unlocking)}']").click
    end

    expect(page).to have_no_selector("#locked_page_#{a_page.id}")
    expect(a_page.reload).not_to be_locked
  end

  it "unlocks the page from the dashboard widget and removes its tab", :js do
    visit laiss_cms.admin_dashboard_path

    within "#LockedPages" do
      find("button[title='#{LaissCms.t(:explain_unlocking)}']").click
    end

    expect(page).to have_no_selector("#locked_page_#{a_page.id}")
    expect(page).to have_no_selector("#LockedPages a", text: a_page.name)
    expect(a_page.reload).not_to be_locked
  end

  context "with multiple languages" do
    let!(:language) do
      create(:laiss_cms_language, :klingon)
    end

    it "displays information for language" do
      visit laiss_cms.admin_pages_path

      within "#locked_page_#{a_page.id}" do
        expect(page).to have_content a_page.language.code
      end
    end
  end

  context "with multiple sites" do
    let!(:site) do
      create(:laiss_cms_site, host: "another-site.com")
    end

    it "displays information for site" do
      visit laiss_cms.admin_pages_path

      within "#locked_page_#{a_page.id}" do
        expect(page).to have_content a_page.site.name
      end
    end
  end
end
