# frozen_string_literal: true

require_relative "spec_helper"

# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require_relative("dummy/config/environment")

require "capybara/rails"
require "capybara-screenshot/rspec"
require "capybara/shadowdom"
require "rails-controller-testing"
require "rspec-activemodel-mocks"
require "rspec/rails"
require "shoulda-matchers"
require "db_query_matchers"
require "factory_bot"
require "view_component/test_helpers"
require "webmock"

require "laiss_cms/seeder"
require "laiss_cms/test_support"
require "laiss_cms/test_support/capybara_helpers"
require "laiss_cms/test_support/config_stubbing"
require "laiss_cms/test_support/having_crop_action_examples"
require "laiss_cms/test_support/having_picture_thumbnails_examples"
require "laiss_cms/test_support/relatable_resource_examples"
require "laiss_cms/test_support/shared_dom_ids_examples"
require "laiss_cms/test_support/shared_ingredient_examples"
require "laiss_cms/test_support/shared_ingredient_editor_examples"
require "laiss_cms/test_support/integration_helpers"
require "laiss_cms/test_support/rspec_matchers"
require "laiss_cms/test_support/shared_contexts"
require "laiss_cms/test_support/shared_link_tab_examples"
require "laiss_cms/test_support/shared_uploader_examples"
require "laiss_cms/test_support/current_language_shared_examples"

require_relative "support/file_name_examples"
require_relative "support/hint_examples"
require_relative "support/clipboard_examples"
require_relative "support/custom_news_elements_finder"

ActionMailer::Base.delivery_method = :test
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.default_url_options[:host] = "test.com"

LaissCms::Deprecation.silenced = false

Rails.backtrace_cleaner.remove_silencers!
# Disable rails loggin for faster IO. Remove this if you want to have a test.log
Rails.logger.level = 4

# Configure capybara for integration testing
Capybara.default_selector = :css
Capybara.ignore_hidden_elements = false

FactoryBot.definition_file_paths.append(LaissCms::TestSupport.factories_path)
FactoryBot.find_definitions

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

DBQueryMatchers.configure do |config|
  config.schemaless = true
end

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.include ActiveSupport::Testing::TimeHelpers
  config.include LaissCms::Engine.routes.url_helpers
  config.include LaissCms::TestSupport::ConfigStubbing
  [:controller, :system, :request].each do |type|
    config.include LaissCms::TestSupport::IntegrationHelpers, type: type
  end
  config.include FactoryBot::Syntax::Methods
  config.include LaissCms::TestSupport::CapybaraHelpers, type: :system
  config.include ViewComponent::TestHelpers, type: :component

  [:controller, :model].each do |type|
    config.include WebMock::API, type: type
  end

  config.use_transactional_fixtures = true

  config.before(:each) do
    LaissCms::Current.site = nil
    ::I18n.locale = :en
  end

  config.around(:each, silence_deprecations: true) do |example|
    LaissCms::Deprecation.silence do
      example.run
    end
  end

  config.before(:each, type: :system) do
    driven_by :rack_test
  end

  config.before(:each, type: :system, js: true) do |example|
    screen_size = example.metadata[:screen_size] || [1280, 800]
    driven_by(:selenium, using: :headless_firefox, screen_size: screen_size) do |capabilities|
      capabilities.add_preference("intl.accept_languages", "en-GB")
      # Pin the browser binary explicitly. Selenium Manager downloads Firefox into
      # ~/.cache/selenium/firefox/<version>/ and resolves it on a cold start, but after
      # a Chrome session has run in the same process it fails to find it and every
      # subsequent js spec dies with "unable to find binary in default location".
      # Measured: this spec passes alone and fails when it follows any Chrome-driven
      # spec, which is exactly how a suite quietly stops testing what it claims to.
      if (binary = LaissCms::TestSupport.forefox_binary)
        capabilities.binary = binary
      end
    end
  end
end
