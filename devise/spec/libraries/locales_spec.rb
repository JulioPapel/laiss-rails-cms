require "rails_helper"

RSpec.describe "LaissCms::Devise locales" do
  # These translations are folded into laiss_cms: laiss_cms_users.* holds the
  # admin user screens and laiss_cms_devise.* holds Devise's own messages. The
  # list is derived from the files so a newly added locale is covered without
  # editing this spec.
  let(:locales) do
    Dir[LaissCms::Engine.root.join("config", "locales", "extra", "laiss_cms_users.*.yml")]
      .map { File.basename(_1)[/\.([\w-]+)\.yml\z/, 1] }
      .compact
  end

  it "ships more than the default locale" do
    expect(locales).to include("en", "de")
  end

  it "interpolates the role confirmation in every shipped locale", :aggregate_failures do
    expect(locales).to_not be_empty

    locales.each do |locale|
      create_message = I18n.t("laiss_cms.admin.users.confirm_password_for_role_change.create",
        locale: locale, roles: "Administrator", user: "Jane Doe", raise: true)
      update_message = I18n.t("laiss_cms.admin.users.confirm_password_for_role_change.update",
        locale: locale, roles: "Administrator", user: "Jane Doe", raise: true)

      expect(create_message).to include("Administrator"), "#{locale} create drops the role"
      expect(update_message).to include("Administrator"), "#{locale} update drops the role"
      expect(update_message).to include("Jane Doe"), "#{locale} update drops the user"
    end
  end
end
