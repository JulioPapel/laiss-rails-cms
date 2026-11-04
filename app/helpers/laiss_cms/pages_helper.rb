# frozen_string_literal: true

module LaissCms
  module PagesHelper
    include LaissCms::BaseHelper
    include LaissCms::ElementsHelper

    # Renders links to language root pages of all published languages.
    #
    # @option options linkname [String] ('name')
    #   Renders name/code of language, or I18n translation for code.
    #
    # @option options show_title [Boolean] (true)
    #   Renders title attributes for the links.
    #
    # @option options spacer [String] ('')
    #   Renders the passed spacer string. You can also overwrite the spacer partial: "laiss_cms/language_links/_spacer".
    #
    # @option options reverse [Boolean] (false)
    #   Reverses the ordering of the links.
    #
    def language_links(options = {})
      options = {
        linkname: "name",
        show_title: true,
        spacer: "",
        reverse: false
      }.merge(options)
      languages = Language.on_current_site.published.with_root_page.order("name #{options[:reverse] ? "DESC" : "ASC"}")
      return nil if languages.count < 2

      render(
        partial: "laiss_cms/language_links/language",
        collection: languages,
        spacer_template: "laiss_cms/language_links/spacer",
        locals: {languages: languages, options: options}
      )
    end

    # Renders the layout for current page.
    #
    # Page layout files belongs in +/app/views/laiss_cms/page_layouts/+
    #
    # Falls back to +/app/views/laiss_cms/page_layouts/standard+ if the page_layout partial is not found.
    #
    def render_page_layout
      render @page, page: @page
    rescue ActionView::MissingTemplate
      warning("[laiss_cms]: '#{@page.page_layout}' page layout not found. Rendering 'standard' page layout.")
      render "laiss_cms/page_layouts/standard", page: @page
    end

    # Renders a partial for current site
    #
    # Place a rails partial into +app/views/laiss_cms/site_layouts+
    #
    # and name it like your site name.
    #
    # == Example:
    #
    #   <%= render_site_layout %>
    #
    # renders +app/views/laiss_cms/site_layouts/_default_site.html.erb+ for the site named "Default Site".
    #
    def render_site_layout(&)
      render(current_laiss_cms_site, &)
    rescue ActionView::MissingTemplate => error
      error_or_warning(error, "Site layout for #{current_laiss_cms_site.try(:name)} not found. Please run `rails g laiss_cms:site_layouts`")
    end

    # Renders a menu partial
    #
    # Menu partials are placed in the `app/views/laiss_cms/menus` folder
    # Use the `rails g laiss_cms:menus` generator to create the partials
    #
    # @param [String] - Type of the menu
    # @param [Hash] - A set of options available in your menu partials
    def render_menu(menu_type, options = {})
      root_node = LaissCms::Node.roots.find_by(
        menu_type: menu_type,
        language: LaissCms::Current.language
      )
      if root_node.nil?
        warning("Menu with type #{menu_type} not found!")
        return
      end

      render("laiss_cms/menus/#{menu_type}/wrapper", menu: root_node, options: options)
    rescue ActionView::MissingTemplate => error
      error_or_warning(error, "Menu partial for #{menu_type} not found. Please run `rails g laiss_cms:menus`")
    end

    # Returns page links in a breadcrumb beginning from root to current page.
    #
    # === Options:
    #
    #   separator: %(<span class="separator">></span>)      # Maybe you don't want this separator. Pass another one.
    #   page: @page                                         # Pass a different Page instead of the default (@page).
    #   without: nil                                        # Pass Page object or array of Pages that must not be displayed.
    #   restricted_only: false                              # Pass boolean for displaying restricted pages only.
    #   reverse: false                                      # Pass boolean for displaying breadcrumb in reversed reversed.
    #
    def render_breadcrumb(options = {})
      options = {
        separator: ">",
        page: @page,
        restricted_only: false,
        reverse: false,
        link_active_page: false
      }.merge(options)

      pages = options[:page]
        .self_and_ancestors.contentpages
        .published

      if options.delete(:restricted_only)
        pages = pages.restricted
      end

      if options.delete(:reverse)
        pages = pages.reorder("lft DESC")
      end

      if options[:without].present?
        without = options.delete(:without)
        pages = pages.where.not(id: without.try(:collect, &:id) || without.id)
      end

      render "laiss_cms/breadcrumb/wrapper", pages: pages, options: options
    end

    # Returns current page title
    #
    # === Options:
    #
    #   prefix: ""                 # Prefix
    #   separator: ""              # Separating prefix and title
    #
    def page_title(options = {})
      return "" if @page.title.blank?

      options = {
        prefix: "",
        suffix: "",
        separator: ""
      }.update(options)
      title_parts = [options[:prefix]]
      title_parts << if response.status == 200
        @page.title
      else
        response.status
      end
      title_parts << options[:suffix]
      title_parts.reject(&:blank?).join(options[:separator]).html_safe
    end

    def meta_description
      @page.meta_description.presence || Language.current_root_page.try(:meta_description)
    end

    def meta_keywords
      @page.meta_keywords.presence || Language.current_root_page.try(:meta_keywords)
    end

    def meta_robots
      "#{"no" unless @page.robot_index?}index, #{"no" unless @page.robot_follow?}follow"
    end

    private

    def error_or_warning(error, message)
      if Rails.application.config.consider_all_requests_local?
        raise error, message
      else
        Logger.error message
        ""
      end
    end
  end
end
