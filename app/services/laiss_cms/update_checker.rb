module LaissCms
  class UpdateChecker
    def initialize(origin: nil)
      @origin = origin
    end

    # Returns true if a newer LaissCms version is available.
    # @return [Boolean]
    def update_available?
      LaissCms.gem_version < latest_version
    end

    # Returns latest LaissCms gem version.
    # @return [Gem::Version]
    def latest_version
      @_latest_version ||= Gem::Version.new(
          update_check_service.new(origin:).latest_version
        )
    end

    private

    attr_reader :origin

    def update_check_service
      case LaissCms.config.update_check_service
      when :laiss_cms_app
        UpdateChecks::LaissCmsApp
      when :ruby_gems
        UpdateChecks::RubyGems
      else
        Struct.new(:origin) do
          def latest_version
            LaissCms.gem_version
          end
        end
      end
    end
  end
end
