require "rails_helper"

RSpec.describe LaissCms::Admin::CurrentUserName, type: :component do
  subject(:render) do
    render_inline described_class.new(user:)
    rendered_content
  end

  context "with no user" do
    let(:user) { nil }

    it { expect(render).to be_blank }
  end

  context "with a user" do
    context "having a `laiss_cms_display_name` method" do
      let(:user) { double("User", laiss_cms_display_name: "Peter Schroeder") }

      it "Returns a span showing the name of the currently logged in user." do
        render
        expect(page).to have_content("Peter Schroeder")
        expect(page).to have_selector("span.current-user-name")
      end
    end

    context "not having a `laiss_cms_display_name` method" do
      let(:user) { double("User", name: "Peter Schroeder") }

      it { expect(render).to be_blank }
    end

    context "with an edit_user_path configured" do
      before do
        stub_laiss_cms_config(edit_user_path: "/users/:id/edit")
        render
      end

      let(:user) { double("User", id: 42, laiss_cms_display_name: "Peter Schroeder") }

      it "links the user name to the edit user path" do
        expect(page).to have_link("Peter Schroeder", href: "/users/42/edit")
      end
    end
  end
end
