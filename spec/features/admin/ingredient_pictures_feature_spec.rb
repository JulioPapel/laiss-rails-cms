require "rails_helper"

RSpec.feature "Ingredient Pictures admin feature", type: :system do
  before do
    authorize_user(:as_editor)
  end

  let(:language) { create(:laiss_cms_language) }
  let(:element) { create(:laiss_cms_element, name: "all_you_can_eat") }
  let(:picture) { create(:laiss_cms_picture) }
  let(:ingredient_picture) { create(:laiss_cms_ingredient_picture, picture: picture, element: element) }

  describe "picture description" do
    let!(:picture_description) do
      LaissCms::PictureDescription.create!(picture: picture, language: language, text: "A nice picture")
    end

    scenario "Picture description is used as default for ingredient picture alt text" do
      visit laiss_cms.edit_admin_ingredient_path(ingredient_picture)
      expect(page).to have_field("Alternative text", placeholder: "A nice picture")
    end
  end

  scenario "Picture css class can be selected by editor" do
    visit laiss_cms.edit_admin_ingredient_path(ingredient_picture)
    expect(page).to have_select("Style")
  end
end
