module LaissCms
  module UpdateChecks
    class RubyGems
      def initialize(origin: nil)
      end

      # Returns latest LaissCms gem version.
      # @return [Gem::Version]
      def latest_version
        @_latest_version ||= begin
          versions = fetch_versions
          versions.reject! { _1.prerelease? }
          versions.max
        end
      end

      private

      def fetch_versions
        response = request_api
        if response.is_a?(Net::HTTPSuccess)
          laiss_cms_versions = JSON.parse(response.body)
          laiss_cms_versions.map! { Gem::Version.new(_1["number"]) }
        else
          raise UpdateServiceUnavailable
        end
      end

      def request_api
        url = URI.parse("https://rubygems.org/api/v1/versions/laiss_cms.json")
        request = Net::HTTP::Get.new(url.path)
        connection = Net::HTTP.new(url.host, url.port)
        connection.use_ssl = url.scheme == "https"
        connection.request(request)
      end
    end
  end
end
