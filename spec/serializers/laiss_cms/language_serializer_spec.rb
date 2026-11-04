# frozen_string_literal: true

require "rails_helper"

RSpec.describe LaissCms::LanguageSerializer do
  subject { described_class.new(language).to_json }

  let(:language) { build_stubbed(:laiss_cms_language) }

  it "includes all attributes" do
    json = JSON.parse(subject)
    expect(json).to eq(
      "id" => language.id,
      "name" => language.name
    )
  end
end
