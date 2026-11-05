module LaissCms
  module Devise
    module BaseControllerPatch
      def self.prepended(base)
        base.before_action(:store_user_request_time)
      end

      private

      # Stores the users request time.
      def store_user_request_time
        if laiss_cms_user_signed_in?
          current_laiss_cms_user.store_request_time!
        end
      end

      LaissCms::BaseController.prepend self
    end
  end
end
