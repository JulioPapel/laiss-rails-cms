# frozen_string_literal: true

require "rails_helper"
require "cancan/matchers"

describe LaissCms::Permissions do
  subject { ability }

  let(:ability) { LaissCms::Permissions.new(user) }
  let(:attachment) { mock_model(LaissCms::Attachment, restricted?: false) }
  let(:restricted_attachment) { mock_model(LaissCms::Attachment, restricted?: true) }
  let(:picture) { mock_model(LaissCms::Picture, restricted?: false) }
  let(:restricted_picture) { mock_model(LaissCms::Picture, restricted?: true) }
  let(:public_page) { build(:laiss_cms_page, :public, restricted: false) }
  let(:unpublic_page) { build(:laiss_cms_page) }
  let(:restricted_page) { build(:laiss_cms_page, :public, restricted: true) }
  let(:role_restricted_page) do
    build(:laiss_cms_page, :public, restricted: true, permitted_roles: %w[restricted_test])
  end
  let(:roleless_restricted_page) do
    build(:laiss_cms_page, :public, restricted: true, permitted_roles: [])
  end
  let(:published_element) { mock_model(LaissCms::Element, restricted?: false, public?: true) }
  let(:restricted_element) { mock_model(LaissCms::Element, restricted?: true, public?: true) }
  let(:language) { build(:laiss_cms_language) }
  let(:public_node) { build(:laiss_cms_node, name: nil, page: public_page) }
  let(:external_node) { build(:laiss_cms_node, :with_url) }
  let(:restricted_node) { build(:laiss_cms_node, name: nil, page: restricted_page) }
  let(:role_restricted_node) { build(:laiss_cms_node, name: nil, page: role_restricted_page) }
  let(:unpublished_node) { build(:laiss_cms_node, name: nil, page: unpublic_page) }

  context "A guest user" do
    let(:user) { nil }

    it "can only download not restricted attachments" do
      is_expected.to be_able_to(:download, attachment)
      is_expected.not_to be_able_to(:download, restricted_attachment)
    end

    it "can only see not restricted attachments" do
      is_expected.to be_able_to(:show, attachment)
      is_expected.not_to be_able_to(:show, restricted_attachment)
    end

    it "can only visit not restricted pages" do
      is_expected.to be_able_to(:show, public_page)
      is_expected.not_to be_able_to(:show, restricted_page)
      is_expected.to be_able_to(:index, public_page)
      is_expected.not_to be_able_to(:index, restricted_page)
    end

    it "can only see public not restricted elements" do
      is_expected.to be_able_to(:show, published_element)
      is_expected.not_to be_able_to(:show, restricted_element)
      is_expected.to be_able_to(:index, published_element)
      is_expected.not_to be_able_to(:index, restricted_element)
    end

    it "can only see nodes linking to public not restricted pages or external urls" do
      is_expected.to be_able_to(:read, public_node)
      is_expected.to be_able_to(:read, external_node)
      is_expected.not_to be_able_to(:read, restricted_node)
      is_expected.not_to be_able_to(:read, unpublished_node)
    end
  end

  context "A member" do
    let(:user) { build(:laiss_cms_dummy_user, :as_member) }

    it "can download all attachments" do
      is_expected.to be_able_to(:download, attachment)
      is_expected.to be_able_to(:download, restricted_attachment)
    end

    it "can see all attachments" do
      is_expected.to be_able_to(:show, attachment)
      is_expected.to be_able_to(:show, restricted_attachment)
    end

    it "can visit restricted pages" do
      is_expected.to be_able_to(:show, public_page)
      is_expected.to be_able_to(:show, restricted_page)
      is_expected.to be_able_to(:index, public_page)
      is_expected.to be_able_to(:index, restricted_page)
    end

    it "can see public restricted elements" do
      is_expected.to be_able_to(:show, published_element)
      is_expected.to be_able_to(:show, restricted_element)
      is_expected.to be_able_to(:index, published_element)
      is_expected.to be_able_to(:index, restricted_element)
    end

    it "can see nodes linking to restricted pages readable with their role" do
      is_expected.to be_able_to(:read, public_node)
      is_expected.to be_able_to(:read, external_node)
      is_expected.to be_able_to(:read, restricted_node)
      is_expected.not_to be_able_to(:read, unpublished_node)
    end

    it "can not see nodes linking to pages restricted to a role they do not have" do
      is_expected.not_to be_able_to(:read, role_restricted_node)
    end

    it "can not visit pages restricted to a role they do not have" do
      is_expected.not_to be_able_to(:show, role_restricted_page)
      is_expected.not_to be_able_to(:index, role_restricted_page)
    end

    it "can not visit restricted pages without any role" do
      is_expected.not_to be_able_to(:show, roleless_restricted_page)
      is_expected.not_to be_able_to(:index, roleless_restricted_page)
    end

    it "can query accessible pages" do
      expect { LaissCms::Page.accessible_by(ability, :read).to_a }.to_not raise_error
    end
  end

  context "A member with an additional role" do
    let(:user) { build(:laiss_cms_dummy_user, laiss_cms_roles: %w[member restricted_test]) }

    it "can visit pages restricted to any of their roles" do
      is_expected.to be_able_to(:show, public_page)
      is_expected.to be_able_to(:show, restricted_page)
      is_expected.to be_able_to(:show, role_restricted_page)
    end

    it "can see nodes linking to pages restricted to any of their roles" do
      is_expected.to be_able_to(:read, restricted_node)
      is_expected.to be_able_to(:read, role_restricted_node)
    end

    it "can not visit restricted pages without any role" do
      is_expected.not_to be_able_to(:show, roleless_restricted_page)
    end
  end

  context "A user having only the additional role" do
    let(:user) { build(:laiss_cms_dummy_user, laiss_cms_roles: %w[restricted_test]) }

    # Restricted roles grant access within the member rules. They do not
    # promote a user to a member on their own.
    it "can not visit any restricted page" do
      is_expected.not_to be_able_to(:show, restricted_page)
      is_expected.not_to be_able_to(:show, role_restricted_page)
    end
  end

  context "An author" do
    let(:user) { build(:laiss_cms_dummy_user, :as_author) }

    it "can leave the admin area" do
      is_expected.to be_able_to(:leave, :laiss_cms_admin)
    end

    it "can visit the dashboard" do
      is_expected.to be_able_to(:index, :laiss_cms_admin_dashboard)
      is_expected.to be_able_to(:info, :laiss_cms_admin_dashboard)
    end

    it "can edit page content" do
      is_expected.to be_able_to(:show, unpublic_page)
      is_expected.to be_able_to(:index, LaissCms::Page)
      is_expected.to be_able_to(:info, LaissCms::Page)
      is_expected.to be_able_to(:configure, LaissCms::Page)
      is_expected.to be_able_to(:update, LaissCms::Page)
      is_expected.to be_able_to(:fold, LaissCms::Page)
      is_expected.to be_able_to(:link, LaissCms::Page)
      is_expected.to be_able_to(:visit, LaissCms::Page)
      is_expected.to be_able_to(:unlock, LaissCms::Page)
    end

    it "can not publish pages" do
      is_expected.to_not be_able_to(:publish, LaissCms::Page)
    end

    it "can manage elements" do
      is_expected.to be_able_to(:manage, LaissCms::Element)
    end

    it "can see all attachments" do
      is_expected.to be_able_to(:read, LaissCms::Attachment)
      is_expected.to be_able_to(:download, LaissCms::Attachment)
    end

    it "can see all pictures" do
      is_expected.to be_able_to(:read, LaissCms::Picture)
      is_expected.to be_able_to(:url, LaissCms::Picture)
    end

    it "can manage ingredients" do
      is_expected.to be_able_to(:manage, LaissCms::Ingredient)
    end

    it "can manage the clipboard" do
      is_expected.to be_able_to(:manage, :laiss_cms_admin_clipboard)
    end

    it "can see tags" do
      is_expected.to be_able_to(:read, LaissCms::Tag)
      is_expected.to be_able_to(:autocomplete, LaissCms::Tag)
    end

    it "can index layoutpages" do
      is_expected.to be_able_to(:index, :laiss_cms_admin_layoutpages)
    end
  end

  context "An editor" do
    let(:user) { build(:laiss_cms_dummy_user, :as_editor) }

    it "can manage pages" do
      is_expected.to be_able_to(:copy, LaissCms::Page)
      is_expected.to be_able_to(:copy_language_tree, LaissCms::Page)
      is_expected.to be_able_to(:create, LaissCms::Page)
      is_expected.to be_able_to(:destroy, LaissCms::Page)
      is_expected.to be_able_to(:flush, LaissCms::Page)
      is_expected.to be_able_to(:order, LaissCms::Page)
      is_expected.to be_able_to(:switch_language, LaissCms::Page)
      is_expected.to be_able_to(:switch, LaissCms::Language)
    end

    it "can update layoutpages" do
      is_expected.to be_able_to(:update, :laiss_cms_admin_layoutpages)
    end

    context "if page language is public" do
      let(:language) { create(:laiss_cms_language, :german, public: true) }
      let(:page) { create(:laiss_cms_page, language: language) }

      it "can publish pages" do
        is_expected.to be_able_to(:publish, page)
      end
    end

    context "if page language is not public" do
      let(:language) { create(:laiss_cms_language, :german, public: false) }
      let(:page) { create(:laiss_cms_page, language: language) }

      it "cannot publish pages" do
        is_expected.to_not be_able_to(:publish, page)
      end
    end

    it "can manage attachments" do
      is_expected.to be_able_to(:manage, LaissCms::Attachment)
    end

    it "can manage pictures" do
      is_expected.to be_able_to(:manage, LaissCms::Picture)
    end

    it "can manage tags" do
      is_expected.to be_able_to(:manage, LaissCms::Tag)
    end
  end

  context "An admin" do
    let(:user) { build(:laiss_cms_dummy_user, :as_admin) }

    it "can check for laiss_cms updates" do
      is_expected.to be_able_to(:update_check, :laiss_cms_admin_dashboard)
    end

    it "can manage languages" do
      is_expected.to be_able_to(:manage, LaissCms::Language)
    end

    it "can manage sites" do
      is_expected.to be_able_to(:manage, LaissCms::Site)
    end
  end

  context "A logged in user without a role" do
    let(:user) { mock_model(LaissCms.config.user_class, laiss_cms_roles: []) }

    it "can only see public not restricted pages (like the guest role)" do
      is_expected.to be_able_to(:show, public_page)
      is_expected.not_to be_able_to(:show, restricted_page)
    end
  end
end
