# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Show page feature:", type: :system do
  context "When no page is present" do
    before do
      LaissCms::Page.delete_all
    end

    context "and no admin user is present yet" do
      before do
        LaissCms.config.user_class.delete_all
      end

      it "shows a welcome page" do
        visit "/"
        expect(page).to have_content("Welcome to LaissCms")
      end
    end

    context "and admin user is present" do
      let!(:admin) { create(:laiss_cms_dummy_user, :as_admin) }

      it "shows a create page button" do
        visit "/"
        expect(page).to have_link("Create your first page")
      end
    end
  end

  context "when pages are present" do
    let(:default_language) { create(:laiss_cms_language) }

    let(:public_page) do
      create(:laiss_cms_page, :public, name: "Page 1")
    end

    let(:public_child) do
      create(:laiss_cms_page, :public, name: "Public Child", parent_id: public_page.id)
    end

    context "When no page is published" do
      let!(:default_language_root) do
        create(:laiss_cms_page, :language_root, language: default_language, name: "Home")
      end

      context "but admin user is present" do
        let!(:admin) { create(:laiss_cms_dummy_user, :as_admin) }

        it "shows a publish page button" do
          visit "/"
          expect(page).to have_link("Publish your homepage")
        end
      end
    end

    context "that are published" do
      let!(:default_language_root) do
        create(:laiss_cms_page, :public, :language_root, language: default_language, name: "Home")
      end

      let(:public_page) { create(:laiss_cms_page, :public, autogenerate_elements: true) }
      let(:article) { public_page.elements.find_by_name("article") }
      let(:ingredient) { article.ingredient_by_role("intro") }

      before do
        ingredient.update_columns(value: "Welcome to Peters Petshop")
      end

      it "should include all its elements and ingredients" do
        visit "/#{public_page.urlname}"
        within("div#content") do
          expect(page).to have_content("Welcome to Peters Petshop")
        end
      end

      describe "menubar" do
        context "rendering for guest users" do
          it "is prohibited" do
            visit "/#{public_page.urlname}"
            within("body") { expect(page).not_to have_selector("laiss-cms-menubar") }
          end
        end

        context "rendering for members" do
          it "is prohibited" do
            authorize_user(build(:laiss_cms_dummy_user))
            visit "/#{public_page.urlname}"
            within("body") { expect(page).not_to have_selector("laiss-cms-menubar") }
          end
        end

        context "rendering for authors" do
          it "is allowed" do
            authorize_user(:as_author)
            visit "/#{public_page.urlname}"
            within("body") { expect(page).to have_selector("laiss-cms-menubar") }
          end
        end

        context "rendering for editors" do
          it "is allowed" do
            authorize_user(:as_editor)
            visit "/#{public_page.urlname}"
            within("body") { expect(page).to have_selector("laiss-cms-menubar") }
          end
        end

        context "rendering for admins" do
          it "is allowed" do
            authorize_user(:as_admin)
            visit "/#{public_page.urlname}"
            within("body") { expect(page).to have_selector("laiss-cms-menubar") }
          end
        end

        context "contains", js: true do
          let(:host) { "#{page.server.host}:#{page.server.port}" }

          before do
            authorize_user(:as_admin)
            visit "/#{public_page.urlname}"
          end

          it "a link to the admin area" do
            within find("laiss-cms-menubar").shadow_root do
              expect(page).to have_selector("a[href='#{laiss_cms.admin_dashboard_url(host: host)}']")
            end
          end

          it "a link to edit the current page" do
            within find("laiss-cms-menubar").shadow_root do
              expect(page).to \
                have_selector("a[href='#{laiss_cms.edit_admin_page_url(public_page, host: host)}']")
            end
          end

          it "a form and button to logout of laiss_cms" do
            within find("laiss-cms-menubar").shadow_root do
              expect(page).to \
                have_selector("form[action='#{LaissCms.config.logout_path}'][method='post']")
              expect(page).to \
                have_selector("form[action='#{LaissCms.config.logout_path}'] > button[type='submit']")
              expect(page).to \
                have_selector("form[action='#{LaissCms.config.logout_path}'] > input[type='hidden'][name='_method'][value='#{LaissCms.config.logout_method}']")
            end
          end
        end
      end
    end
  end

  describe "Handling of non-existing pages" do
    before do
      # We need a admin user or the signup page will show up
      allow(LaissCms.config.user_class).to receive(:laiss_cms_admins).and_return([1, 2])
    end

    it "should render public/404.html" do
      expect {
        visit "/non-existing-page"
      }.to raise_error(ActionController::RoutingError)
    end
  end

  describe "navigation rendering" do
    context "with menu available" do
      let(:menu) { create(:laiss_cms_node, menu_type: "main_menu") }
      let(:page1) { create(:laiss_cms_page, :public, name: "Page 1") }
      let(:page2) { create(:laiss_cms_page, :public, name: "Page 2") }
      let!(:node1) { create(:laiss_cms_node, page: page1, parent: menu) }
      let!(:node2) { create(:laiss_cms_node, page: page2, parent: menu) }

      it "should show the navigation with all pages" do
        visit "/"
        within("nav ul") do
          expect(page).to have_selector('li a[href="/page-1"], li a[href="/page-2"]')
        end
      end

      it "shows the navigation in a custom controller" do
        visit "/ns/locations"
        within("nav ul") do
          expect(page).to have_selector('li a[href="/page-1"], li a[href="/page-2"]')
        end
      end
    end
  end

  describe "accessing restricted pages" do
    let!(:restricted_page) { create(:laiss_cms_page, :restricted, public_on: Time.current) }

    context "as a guest user" do
      it "I am not able to visit the page" do
        visit restricted_page.urlname
        expect(current_path).to eq(LaissCms.config.login_path)
      end
    end

    context "as a member user" do
      before do
        authorize_user(create(:laiss_cms_dummy_user, :as_member))
      end

      it "I am able to visit the page" do
        visit restricted_page.urlname
        expect(current_path).to eq("/#{restricted_page.urlname}")
      end

      context "and the page is restricted to another role" do
        before do
          restricted_page.update!(permitted_roles: %w[restricted_test])
        end

        it "I am not able to visit the page" do
          visit restricted_page.urlname
          expect(current_path).to_not eq("/#{restricted_page.urlname}")
        end
      end
    end

    context "as a member user having the pages role" do
      before do
        authorize_user(create(:laiss_cms_dummy_user, laiss_cms_roles: %w[member restricted_test]))
        restricted_page.update!(permitted_roles: %w[restricted_test])
      end

      it "I am able to visit the page" do
        visit restricted_page.urlname
        expect(current_path).to eq("/#{restricted_page.urlname}")
      end
    end
  end
end
