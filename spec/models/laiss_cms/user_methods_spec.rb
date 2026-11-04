# frozen_string_literal: true

require "rails_helper"

RSpec.describe LaissCms::UserMethods do
  let(:user) { build(:laiss_cms_dummy_user) }

  it "should not have a default role" do
    expect(user.laiss_cms_roles).to be_blank
  end

  describe "validations" do
    it "should validate laiss_cms_roles inclusion" do
      user.laiss_cms_roles = ["invalid_role"]
      expect(user).not_to be_valid
      expect(user.errors[:laiss_cms_roles]).to include("is not included in #{LaissCms.config.user_roles.join(", ")}")
    end
  end

  describe "scopes" do
    let!(:user) { create(:laiss_cms_dummy_user, :as_admin) }

    describe ".laiss_cms_admins" do
      let!(:member) { create(:laiss_cms_dummy_user, :as_member) }

      it "should only return users with admin role" do
        expect(LaissCms.config.user_class.laiss_cms_admins).to include(user)
        expect(LaissCms.config.user_class.laiss_cms_admins).not_to include(member)
      end
    end

    describe ".with_laiss_cms_role" do
      [:editor, "Author", :Admin].each do |role|
        context "with role #{role}" do
          it "should return users with #{role.to_s.downcase} role" do
            user = create(:laiss_cms_dummy_user, laiss_cms_roles: role.to_s.downcase)
            expect(LaissCms.config.user_class.with_laiss_cms_role(role)).to include(user)
          end
        end
      end

      context "with users having multiple roles" do
        it "should return users with given role at the end" do
          user = create(:laiss_cms_dummy_user, laiss_cms_roles: "admin member")
          expect(LaissCms.config.user_class.with_laiss_cms_role("member")).to include(user)
        end

        it "should return users with given role at the start" do
          user = create(:laiss_cms_dummy_user, laiss_cms_roles: "member admin")
          expect(LaissCms.config.user_class.with_laiss_cms_role("member")).to include(user)
        end

        it "should return users with given role in the middle" do
          user = create(:laiss_cms_dummy_user, laiss_cms_roles: "editor member admin")
          expect(LaissCms.config.user_class.with_laiss_cms_role("member")).to include(user)
        end
      end

      context "with unknown role" do
        it "logs a warning but still runs the query" do
          expect(LaissCms::Logger).to receive(:warn).with("Unknown LaissCms role: \"unknown role\"")
          expect(LaissCms.config.user_class.with_laiss_cms_role("Unknown role")).to be_empty
        end
      end
    end
  end

  describe ".human_laiss_cms_rolename" do
    it "return a translated role name" do
      expect(LaissCms.config.user_class.human_laiss_cms_rolename("member")).to eq("Member")
    end
  end

  describe "#human_laiss_cms_roles" do
    it "should return a humanized roles string." do
      user.laiss_cms_roles = ["member", "admin"]
      expect(user.human_laiss_cms_roles).to eq("Member and Administrator")
    end
  end

  describe "#has_laiss_cms_role?" do
    let(:user) { build(:laiss_cms_dummy_user, :as_member) }

    context "with given role" do
      it "should return true." do
        expect(user.has_laiss_cms_role?("member")).to be_truthy
      end
    end

    context "with role given as symbol" do
      it "should return true." do
        expect(user.has_laiss_cms_role?(:member)).to be_truthy
      end
    end

    context "without given role" do
      it "should return true." do
        expect(user.has_laiss_cms_role?("admin")).to be_falsey
      end
    end
  end

  describe "#laiss_cms_roles" do
    let(:user) { build(:laiss_cms_dummy_user, :as_member) }

    it "should return an array of user roles" do
      expect(user.laiss_cms_roles).to eq(["member"])
    end

    context "when the laiss_cms_roles column is missing" do
      before do
        allow(user.class).to receive(:columns_hash).and_return({})
      end

      it "logs a warning" do
        expect(LaissCms::Logger).to receive(:warn).with(/laiss_cms_roles.*column is missing/m)
        user.laiss_cms_roles
      end

      it "falls back to the default member role" do
        allow(LaissCms::Logger).to receive(:warn)
        expect(user.laiss_cms_roles).to eq(["member"])
      end
    end
  end

  describe "#laiss_cms_roles=" do
    it "should accept a single user role" do
      user.laiss_cms_roles = "admin"
      expect(user.laiss_cms_roles).to eq(["admin"])
    end

    it "should accept an array of user roles" do
      user.laiss_cms_roles = ["admin"]
      expect(user.laiss_cms_roles).to eq(["admin"])
    end

    it "should accept a string of space separated user roles" do
      user.laiss_cms_roles = "admin member"
      expect(user.laiss_cms_roles).to eq(["admin", "member"])
    end

    it "should store the user roles as space seperated string" do
      user.laiss_cms_roles = ["admin", "member"]
      expect(user.read_attribute(:laiss_cms_roles)).to eq("admin member")
    end

    it "should strip user roles" do
      user.laiss_cms_roles = ["admin ", " member"]
      expect(user.read_attribute(:laiss_cms_roles)).to eq("admin member")
    end
  end

  describe "#locked_pages" do
    let(:user) { create(:laiss_cms_dummy_user) }
    let(:page) { create(:laiss_cms_page) }

    it "should return all pages that are locked by user" do
      user.save!
      page.lock_to!(user)
      expect(user.locked_pages).to include(page)
    end
  end

  describe "#unlock_pages" do
    let(:user) { create(:laiss_cms_dummy_user) }
    let(:page) { create(:laiss_cms_page) }

    before do
      page.lock_to!(user)
    end

    it "should unlock all users lockes pages" do
      user.unlock_pages!
      expect(user.locked_pages.reload).to be_empty
    end
  end

  describe "#laiss_cms_admin?" do
    it "should return true if the user has admin role" do
      user.laiss_cms_roles = "admin"
      expect(user.laiss_cms_admin?).to be_truthy
    end
  end
end
