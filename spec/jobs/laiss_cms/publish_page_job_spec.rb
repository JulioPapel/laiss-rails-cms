# frozen_string_literal: true

require "rails_helper"

RSpec.describe LaissCms::PublishPageJob, type: :job do
  describe "#perfom_later" do
    let(:page) { create(:laiss_cms_page) }
    let(:public_on) { Time.current }

    it "enqueues job" do
      expect {
        described_class.perform_later(page.id, public_on: public_on)
      }.to have_enqueued_job
    end

    it "calls the page publisher" do
      expect_any_instance_of(LaissCms::Page::Publisher).to receive(:publish!).with(
        public_on: public_on
      )
      described_class.new.perform(page.id, public_on: public_on)
    end
  end
end
