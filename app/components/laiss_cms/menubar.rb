module LaissCms
  class Menubar < ViewComponent::Base
    attr_reader :page

    delegate :laiss_cms, :can?, to: :helpers

    def initialize(page: LaissCms::Current.page)
      @page = page
    end

    def render?
      page && !LaissCms::Current.preview_page? && can?(:edit_content, page)
    end
  end
end
