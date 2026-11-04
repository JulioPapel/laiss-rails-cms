# frozen_string_literal: true

module LaissCms
  module Admin
    class LanguagesController < ResourcesController
      before_action :load_current_site, only: %i[index new]

      def index
        @query = Language.on_site(@current_site).ransack(search_filter_params[:q])
        @query.sorts = default_sort_order if @query.sorts.empty?
        @languages = @query.result.page(params[:page] || 1).per(items_per_page)
      end

      def new
        @language = Language.new(
          site: @current_site,
          page_layout: LaissCms.config.default_language.page_layout
        )
      end

      def create
        @language = LaissCms::Language.new(resource_params)
        if @language.save
          flash[:notice] = LaissCms.t("Language successfully created")
          do_redirect_to laiss_cms.admin_pages_path(language_id: @language)
        else
          render :new
        end
      end

      def destroy
        if @language.destroy
          if session[:laiss_cms_language_id] == @language.id
            session.delete(:laiss_cms_language_id)
          end
          flash[:notice] = LaissCms.t("Language successfully removed")
        else
          flash[:warning] = @language.errors.full_messages.to_sentence
        end
        do_redirect_to laiss_cms.admin_languages_path
      end

      def switch
        @language = set_laiss_cms_language(params[:language_id])
        session[:laiss_cms_language_id] = @language.id
        do_redirect_to relative_referer_path || laiss_cms.admin_dashboard_path
      end

      private

      def load_current_site
        @current_site = LaissCms::Current.site
        if @current_site.nil?
          flash[:info] = LaissCms.t("Please create a site first.")
          do_redirect_to admin_sites_path
        end
      end
    end
  end
end
