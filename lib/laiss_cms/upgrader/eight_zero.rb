module LaissCms
  class Upgrader
    module EightZero
      def mention_laiss_cms_config_initializer
        todo <<~TEXT, "Configuration has changed to initializer"
          Check the new configuration file `./config/initializers/laiss_cms.rb` and
          update values from your `config/laiss_cms/config.yml` file.

          Then you can safely remove the `config/laiss_cms/config.yml` file.
        TEXT
      end
    end
  end
end
