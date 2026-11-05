# frozen_string_literal: true

module LaissCms
  module TestSupport
    # Locate the Firefox binary Selenium Manager installed.
    #
    # WHY THIS EXISTS
    #
    # Selenium Manager downloads Firefox into ~/.cache/selenium/firefox/<platform>/
    # <version>/ and normally resolves it itself. But once a Chrome session has run in
    # the same process it stops finding it, and every later js spec fails with:
    #
    #   Expected browser binary location, but unable to find binary in default
    #   location, no 'moz:firefoxOptions.binary' capability provided
    #
    # That is a nasty failure mode: the spec passes alone and fails only when it follows
    # a Chrome-driven one, so a suite can look green while half of it never ran. Pinning
    # the path removes the ambiguity.
    #
    # Returns nil when nothing is found, in which case Selenium Manager is left to do its
    # own resolution — which is correct on a machine with a system Firefox.
    def self.forefox_binary
      return ENV["LAISS_CMS_FIREFOX_BINARY"] if ENV["LAISS_CMS_FIREFOX_BINARY"]

      cache = File.expand_path("~/.cache/selenium/firefox")
      candidates = Dir.glob(File.join(cache, "*", "*", "firefox")).sort.reverse
      candidates.find { |path| File.executable?(path) }
    end
  end
end
