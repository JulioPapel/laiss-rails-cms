# frozen_string_literal: true

module LaissCms
  module Admin
    class LayoutpagesController < LaissCms::Admin::BaseController
      authorize_resource class: :laiss_cms_admin_layoutpages

      include LaissCms::Admin::CurrentLanguage
      include LaissCms::Admin::Clipboard

      helper LaissCms::Admin::PagesHelper

      def index
        @layout_pages = Page.layoutpages.where(language: @current_language)
        @languages = Language.on_current_site
      end

      def edit
        @page = Page.find(params[:id])
      end

      def update
        @page = Page.find(params[:id])
        if @page.update(page_params)
          @notice = LaissCms.t("Page saved", name: @page.name)
          @while_page_edit = request.referer.include?("edit")
          render "laiss_cms/admin/pages/update"
        else
          render :edit, status: 422
        end
      end

      private

      def page_params
        params.require(:page).permit(
          :name,
          :tag_list
        )
      end
    end
  end
end
