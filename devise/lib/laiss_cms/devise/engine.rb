require "laiss_cms"
require "devise"
require "flickwerk"

module LaissCms
  module Devise
    class Engine < ::Rails::Engine
      include Flickwerk

      isolate_namespace LaissCms
      engine_name "laiss_cms_devise"

      initializer "laiss_cms_devise.user_class", before: "laiss_cms.userstamp" do
        LaissCms.config.user_class = "LaissCms::User"
      end

      initializer "laiss_cms_devise.assets" do |app|
        app.config.assets.precompile += [
          "laiss-cms-devise.css"
        ]
      end
    end
  end
end
