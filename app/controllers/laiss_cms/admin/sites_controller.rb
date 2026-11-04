# frozen_string_literal: true

module LaissCms
  module Admin
    class SitesController < ResourcesController
      def create
        @site = LaissCms::Site.new(resource_params)
        if @site.save
          flash[:info] = LaissCms.t("Please create a default language for this site.")
          do_redirect_to laiss_cms.admin_languages_path(site_id: @site)
        else
          render :new
        end
      end

      def destroy
        if @site.destroy
          flash[:notice] = LaissCms.t("Site successfully removed")
        else
          flash[:warning] = @site.errors.full_messages.to_sentence
        end
        do_redirect_to laiss_cms.admin_sites_path
      end
    end
  end
end
