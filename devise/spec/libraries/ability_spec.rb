require_relative "../rails_helper"
require "cancan/matchers"

describe LaissCms::Permissions do
  subject { ability }

  let(:ability) { LaissCms::DeviseAbility.new(user) }

  context "A guest user" do
    let(:user) { nil }

    it "can not see any user records" do
      is_expected.not_to be_able_to(:read, LaissCms.config.user_class)
    end

    it "can signup user" do
      is_expected.to be_able_to(:signup, LaissCms.config.user_class)
    end

    context "if no user is present" do
      before { expect(LaissCms::User).to receive(:count).and_return(0) }

      it "can create user" do
        is_expected.to be_able_to(:create, LaissCms.config.user_class)
      end
    end

    context "if user is present" do
      before { expect(LaissCms::User).to receive(:count).and_return(1) }

      it "cannot create user" do
        is_expected.to_not be_able_to(:create, LaissCms.config.user_class)
      end
    end
  end

  context "A member" do
    let(:user) { build_stubbed(:laiss_cms_member_user) }
    let(:another_user) { build_stubbed(:laiss_cms_member_user) }

    it "can only update its own user record" do
      is_expected.to be_able_to(:update, user)
      is_expected.not_to be_able_to(:update, another_user)
    end

    it "can only see its own record" do
      is_expected.to be_able_to(:show, user)
      is_expected.not_to be_able_to(:show, another_user)
    end

    it "cannot see other user records" do
      is_expected.to_not be_able_to(:index, LaissCms.config.user_class)
    end
  end

  context "An author" do
    let(:user) { build_stubbed(:laiss_cms_author_user) }
    let(:another_user) { build_stubbed(:laiss_cms_member_user) }

    it "can only update its own user record" do
      is_expected.to be_able_to(:update, user)
      is_expected.not_to be_able_to(:update, another_user)
    end

    it "can only see its own record" do
      is_expected.to be_able_to(:show, user)
      is_expected.not_to be_able_to(:show, another_user)
    end
  end

  context "An editor" do
    let(:user) { build_stubbed(:laiss_cms_editor_user) }
    let(:another_user) { build_stubbed(:laiss_cms_member_user) }

    it "can see all users" do
      is_expected.to be_able_to(:read, LaissCms.config.user_class)
    end

    it "can only update its own user record" do
      is_expected.to be_able_to(:update, user)
      is_expected.not_to be_able_to(:update, another_user)
    end
  end

  context "An admin" do
    let(:user) { build_stubbed(:laiss_cms_admin_user) }

    it "can manage users" do
      is_expected.to be_able_to(:manage, LaissCms.config.user_class)
    end
  end
end
