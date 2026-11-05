# frozen_string_literal: true

module LaissCms
  extend self

  VERSION = "0.1.0.beta7"

  def version
    VERSION
  end

  def gem_version
    Gem::Version.new(VERSION)
  end

  def git_revision_info
    source = Bundler.locked_gems.sources.find { _1.name == "laiss_cms" }
    return unless source.respond_to?(:revision)

    {
      revision: source.revision,
      branch: source.branch
    }
  rescue
    nil
  end
end
