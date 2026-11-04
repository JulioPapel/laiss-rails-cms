# frozen_string_literal: true

require "rails_helper"

RSpec.describe LaissCms::Admin::IngredientsController do
  routes { LaissCms::Engine.routes }

  let(:attachment) { build_stubbed(:laiss_cms_attachment) }
  let(:element) { build(:laiss_cms_element, name: "all_you_can_eat") }

  let(:ingredient) do
    stub_model(
      LaissCms::Ingredients::File,
      type: "LaissCms::Ingredients::File",
      element: element,
      attachment: attachment,
      role: "file"
    )
  end

  before do
    allow(LaissCms::Ingredient).to receive(:find).with(ingredient.id.to_s) { ingredient }
  end

  context "without authorized user" do
    describe "get :edit" do
      it "redirects to login path" do
        get :edit, params: {id: ingredient.id}
        expect(response).to redirect_to(LaissCms.config.login_path)
      end
    end

    describe "patch :update" do
      it "redirects to login path" do
        patch :update, params: {id: ingredient.id}
        expect(response).to redirect_to(LaissCms.config.login_path)
      end
    end
  end

  context "with autorized user" do
    before do
      authorize_user(:as_admin)
    end

    describe "get :edit" do
      subject { get(:edit, params: {id: ingredient.id}) }

      it "assigns @ingredient with the Ingredient found by id" do
        subject
        expect(assigns(:ingredient)).to eq(ingredient)
      end

      it "renders edit template" do
        expect(subject).to render_template("laiss_cms/admin/ingredients/edit")
      end
    end

    describe "patch :update" do
      let(:ingredient) do
        stub_model(
          LaissCms::Ingredients::Headline,
          type: "LaissCms::Ingredients::Text",
          element: element,
          role: "text"
        )
      end

      context "with permitted attributes" do
        let(:params) do
          {
            id: ingredient.id,
            ingredient: {
              level: "2",
              size: "3",
              dom_id: "se-id"
            }
          }
        end

        it "updates the attributes of ingredient" do
          patch :update, params: params, xhr: true
          expect(ingredient.level).to eq "2"
          expect(ingredient.size).to eq "3"
          expect(ingredient.dom_id).to eq "se-id"
        end

        context "with a picture ingredient having empty css class" do
          let(:ingredient) do
            stub_model(
              LaissCms::Ingredients::Picture,
              type: "LaissCms::Ingredients::Picture",
              element: element,
              role: "picture",
              data: {
                css_class: ""
              }
            )
          end

          render_views

          it "does not raise I18n ArgumentError" do
            expect {
              patch :update, params: params, format: :turbo_stream
            }.to_not raise_error
          end
        end
      end

      context "with unpermitted attributes" do
        let(:params) do
          {
            id: ingredient.id,
            ingredient: {
              foo: "Baz"
            }
          }
        end

        it "does not update the attributes of ingredient" do
          expect(ingredient).to receive(:update).with(ActionController::Parameters.new.permit)
          patch :update, params: params, xhr: true
        end
      end

      context "without attributes" do
        let(:params) do
          {
            id: ingredient.id
          }
        end

        it "does not update the attributes of ingredient" do
          expect(ingredient).to receive(:update).with(ActionController::Parameters.new)
          patch :update, params: params, xhr: true
        end
      end
    end

    it_behaves_like "having crop action", model_class: LaissCms::Ingredient do
      let(:picture) { build_stubbed(:laiss_cms_picture) }

      let(:croppable_resource) do
        LaissCms::Ingredients::Picture.new(
          element: element,
          picture: picture,
          role: "picture"
        )
      end
    end
  end
end
