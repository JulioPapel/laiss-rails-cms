# frozen_string_literal: true

module LaissCms
  module TestSupport
    # Allows you to stub the LaissCms configuration in your specs
    #
    # Require and include this file in your RSpec config.
    #
    #     RSpec.configure do |config|
    #       config.include LaissCms::TestSupport::ConfigStubbing
    #     end
    #
    module ConfigStubbing
      # Stub a key from the LaissCms config
      #
      # @param hash [Hash] The keys you would like to stub along with their values
      #
      def stub_laiss_cms_config(hash)
        stub_config(LaissCms.config, hash)
      end

      def stub_config(config, hash)
        hash.each do |key, value|
          if value.is_a?(Hash)
            stub_config(config.send(key), value)
          else
            allow(config).to receive(key).and_return(value)
          end
        end
      end
    end
  end
end
