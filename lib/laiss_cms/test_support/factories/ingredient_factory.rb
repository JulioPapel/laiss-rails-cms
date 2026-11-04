# frozen_string_literal: true

FactoryBot.define do
  %w[
    audio
    boolean
    datetime
    file
    headline
    html
    link
    node
    page
    picture
    richtext
    select
    text
  ].each do |ingredient|
    factory :"laiss_cms_ingredient_#{ingredient}", class: "LaissCms::Ingredients::#{ingredient.classify}" do
      role { ingredient }
      type { "LaissCms::Ingredients::#{ingredient.classify}" }
      association :element, name: "all_you_can_eat", factory: :laiss_cms_element
    end
  end
end
