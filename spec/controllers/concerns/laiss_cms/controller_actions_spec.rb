# frozen_string_literal: true

require "rails_helper"

describe "LaissCms::ControllerActions", type: "controller" do
  # Anonymous controller to test the integration against
  controller(ActionController::Base) do
    include LaissCms::ControllerActions
  end

  describe "#current_laiss_cms_user" do
    context "with default current_user_method" do
      it "calls current_user by default" do
        expect(controller).to receive :current_user
        controller.send :current_laiss_cms_user
      end
    end

    context "with custom current_user_method" do
      before do
        stub_laiss_cms_config(current_user_method: :current_admin)
      end

      it "calls the custom method" do
        expect(controller).to receive :current_admin
        controller.send :current_laiss_cms_user
      end
    end

    context "with not implemented current_user_method" do
      before do
        stub_laiss_cms_config(current_user_method: :not_implemented_method)
      end

      it "raises an error" do
        expect {
          controller.send :current_laiss_cms_user
        }.to raise_error(LaissCms::NoCurrentUserFoundError)
      end
    end
  end

  describe "#set_current_laiss_cms_user" do
    after { LaissCms::Current.user = nil }

    context "when a current user is present" do
      let(:user) { double("User") }

      before { allow(controller).to receive(:current_user).and_return(user) }

      it "stores it in Current.user" do
        controller.send :set_current_laiss_cms_user
        expect(LaissCms::Current.user).to eq(user)
      end
    end

    context "when no current_user_method is implemented" do
      before do
        stub_laiss_cms_config(current_user_method: :not_implemented_method)
      end

      it "leaves Current.user nil" do
        controller.send :set_current_laiss_cms_user
        expect(LaissCms::Current.user).to be_nil
      end
    end
  end

  describe "#set_laiss_cms_language" do
    let!(:default_language) { create(:laiss_cms_language, code: :en) }
    let(:klingon) { create(:laiss_cms_language, :klingon) }

    after do
      # We must never change the app's locale
      expect(::I18n.locale).to eq(:en)
      # Reset the current language so its fresh for every subsequent test
      LaissCms::Current.language = nil
    end

    context "with a Language object given" do
      it "should set the language to the Language instance" do
        controller.send :set_laiss_cms_language, klingon
        expect(assigns(:language)).to eq(klingon)
        expect(LaissCms::Current.language).to eq(klingon)
      end
    end

    context "with a language id given" do
      it "should find and set the language by the id" do
        controller.send :set_laiss_cms_language, klingon.id
        expect(assigns(:language)).to eq(klingon)
        expect(LaissCms::Current.language).to eq(klingon)
      end
    end

    context "with a locale given" do
      it "should find and set the language by the locale" do
        controller.send :set_laiss_cms_language, klingon.code
        expect(assigns(:language)).to eq(klingon)
        expect(LaissCms::Current.language).to eq(klingon)
      end
    end

    context "with no lang param" do
      it "should set the default language" do
        allow(controller).to receive(:params).and_return({})
        controller.send :set_laiss_cms_language
        expect(assigns(:language)).to eq(default_language)
        expect(LaissCms::Current.language).to eq(default_language)
      end
    end

    context "with lang param" do
      it "should set the language" do
        allow(controller).to receive(:params).and_return(locale: klingon.code)
        controller.send :set_laiss_cms_language
        expect(assigns(:language)).to eq(klingon)
        expect(LaissCms::Current.language).to eq(klingon)
      end

      context "for language that does not exist" do
        before do
          allow(controller).to receive(:params).and_return(locale: "fo")
        end

        it "should raise an error" do
          expect do
            controller.send :set_laiss_cms_language
          end.to raise_exception(ActionController::RoutingError, "Language not found")
        end
      end
    end
  end
end
