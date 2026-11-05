# frozen_string_literal: true

require "rails_helper"

RSpec.describe "LaissCms::Message" do
  let(:message) { LaissCms::Message.new }

  it "has attributes writers and getters for all fields defined in mailer config" do
    LaissCms.config.mailer.fields.each do |field|
      expect(message).to respond_to(field)
      expect(message).to respond_to("#{field}=")
    end
  end

  context "validation of" do
    context "all fields defined in mailer config" do
      it "adds errors on that fields" do
        LaissCms.config.mailer.validate_fields.each do |field|
          expect(message).to_not be_valid
          expect(message.errors[field].size).to eq(1)
        end
      end
    end

    context "field containing email in its name" do
      # Message builds its accessors from the mailer config when the class is
      # loaded, so this context has to reload the class under a stubbed config.
      # The reloaded class outlives the example while the stub does not, which
      # left every later example using a Message that only knew email_of_my_boss.
      # Reloading again afterwards restores the class as it is defined for the
      # real config, so the result does not depend on example order.
      around do |example|
        begin
          example.run
        ensure
          LaissCms.send(:remove_const, :Message)
          load LaissCms::Engine.root.join("app/models/laiss_cms/message.rb")
        end
      end

      before do
        stub_laiss_cms_config(mailer: {
          fields: %w[email_of_my_boss],
          validate_fields: %w[email_of_my_boss]
        })
        LaissCms.send(:remove_const, :Message)
        load LaissCms::Engine.root.join("app/models/laiss_cms/message.rb")
      end

      context "when field has a value" do
        let(:invalid_message) { LaissCms::Message.new }

        before { invalid_message.email_of_my_boss = "wrong email format" }

        it "adds error notice (is invalid) to the field" do
          expect(invalid_message).to_not be_valid
          expect(invalid_message.errors[:email_of_my_boss]).to include("is invalid")
        end
      end

      context "when field is blank" do
        before { message.email_of_my_boss = "" }

        it "adds error notice (can't be blank) to the field" do
          expect(message).to_not be_valid
          expect(message.errors[:email_of_my_boss]).to include("can't be blank")
        end
      end
    end
  end
end
