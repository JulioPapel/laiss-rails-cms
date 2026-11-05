# frozen_string_literal: true

# Custom error classes.
#
module LaissCms
  class DefaultLanguageNotFoundError < StandardError
    # Raised if no default language configuration can be found.
    def message
      "No default language configuration found!" \
      " Please ensure that you have a 'default_language' defined in LaissCms configuration file."
    end
  end

  class DefaultSiteNotFoundError < StandardError
    # Raised if no default site configuration can be found.
    def message
      "No default site configuration found!" \
      " Please ensure that you have a 'default_site' defined in LaissCms configuration file."
    end
  end

  class ElementDefinitionError < StandardError
    # Raised if element definition can not be found.
    def initialize(attributes)
      @name = attributes[:name]
    end

    def message
      "Element definition for '#{@name}' not found! Please check your element definitions."
    end
  end

  # Raised if calling +image_file+ on a Picture object returns nil.
  class MissingImageFileError < StandardError; end

  # Raised if calling +image_file+ on a Picture object returns nil.
  class WrongImageFormatError < StandardError
    def initialize(image, requested_format)
      @image = image
      @requested_format = requested_format
    end

    def message
      allowed_filetypes = LaissCms::Picture.allowed_filetypes.map(&:upcase).to_sentence
      "Requested image format (#{@requested_format.inspect}) for #{@image.inspect} is not one of allowed filetypes (#{allowed_filetypes})."
    end
  end

  class NotMountedError < StandardError
    # Raised if LaissCms is not properly mounted in the apps routes file.
    def message
      "LaissCms mount point not found! Please run `bin/rake laiss_cms:mount'"
    end
  end

  class PictureInUseError < StandardError
    # Raised if the picture is still in use and can not be deleted.
  end

  class TinymceError < StandardError; end

  class UpdateServiceUnavailable < StandardError
    # Raised if no successful connection to GitHub was possible
    def message
      "The update service is temporarily unavailable!"
    end
  end

  class MissingActiveRecordAssociation < StandardError
    # Raised if a laiss_cms_resource_relation is defined without proper ActiveRecord association
    def message
      "You need to define proper ActiveRecord associations, if you want to use laiss_cms_resource_relations."
    end
  end

  class NoCurrentUserFoundError < StandardError
    # Raised if no current_user is found to authorize against.
    def message
      "You need to provide a current_user method in your ApplicationController that returns the current authenticated user."
    end
  end

  class UnsupportedPageVersion < StandardError
    def message
      "Unknown Version! Please use one of #{LaissCms::EagerLoading::PAGE_VERSIONS.join(", ")}"
    end
  end

  # Raised at boot when the host app has no asset pipeline. The admin renders its
  # stylesheets and JavaScript through one, so without it every admin page would
  # fail with `NoMethodError: undefined method 'assets'` from inside a template.
  class AssetPipelineMissing < StandardError
    def message
      <<~MSG
        LaissCms needs an asset pipeline and this app has neither propshaft nor sprockets.

        The admin renders its stylesheets and JavaScript through the pipeline
        (`importmap-rails` reads `config.assets`), so without one every admin page
        fails with `NoMethodError: undefined method 'assets'`.

        Add one line to your Gemfile:

            gem "propshaft"

        then run `bundle install` and restart. `gem "sprockets", "~> 4.2"` works too.
        Rails' `--minimal` template is what omits both.
      MSG
    end
  end
end
