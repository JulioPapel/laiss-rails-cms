# frozen_string_literal: true

class CustomNewsElementsFinder
  def elements(*)
    [element]
  end

  private

  def element
    LaissCms::Element.new(
      name: "news",
      id: 1001,
      position: 1
    ).tap do |element|
      element.ingredients = ingredients(element)
    end
  end

  def ingredients(element)
    [
      LaissCms::Ingredients::Text.new(
        element: element,
        role: "news_headline",
        value: "Breaking News"
      ),
      LaissCms::Ingredients::Richtext.new(
        element: element,
        role: "body",
        value: "<p>This is a breaking news story.</p>"
      )
    ]
  end
end
