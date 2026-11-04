# frozen_string_literal: true

# This is a tableless model used for contact forms.
#
# You can specify the fields for your contact form in
# +config/laiss_cms/config.yml+ file as +:mailer+ +fields+.
#
# === Example Configuration:
#
#   mailer:
#     form_layout_name: contact
#     fields: [subject, name, email, message, info]
#     validate_fields: [name, email]
#
module LaissCms
  class Message
    include ActiveModel::Model

    attr_accessor :contact_form_id, :ip

    LaissCms.config.mailer.fields.each do |field|
      attr_accessor field.to_sym
    end

    LaissCms.config.mailer.validate_fields.each do |field|
      validates_presence_of field

      case field.to_sym
      when /email/
        validates_format_of field,
          with: LaissCms.config.format_matchers.email,
          if: -> { send(field).present? }
      when :email_confirmation
        validates_confirmation_of :email
      end
    end
  end
end
