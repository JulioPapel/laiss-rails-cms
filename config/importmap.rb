pin "@ungap/custom-elements", to: "ungap-custom-elements.min.js", preload: true # @1.3.0
pin "clipboard", to: "clipboard.min.js", preload: true
pin "cropperjs", to: "cropperjs.min.js", preload: true
pin "flatpickr", to: "flatpickr.min.js", preload: true # @4.6.13
pin "keymaster", to: "keymaster.min.js", preload: true
pin "sortablejs", to: "sortable.min.js", preload: true # @1.15.1
pin "@floating-ui/dom", to: "floating-ui.min.js", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "shoelace", to: "shoelace.min.js", preload: true
pin "tinymce", to: "tinymce.min.js", preload: true
pin "tom-select", to: "tom-select.min.js", preload: true

pin "laiss_cms_admin", to: "laiss_cms/laiss_cms_admin.min.js", preload: true
# Individually importable admin components. These resolve to their source
# files (not the bundle) so host engines can import a single component without
# loading and executing the whole admin bundle. Not preloaded, so they add no
# fetches to normal admin page loads (which import the bundle instead).
pin "laiss_cms_admin/components/page_select"
pin "laiss_cms_admin/components/attachment_select"
pin "laiss_cms_admin/components/element_select"
pin "laiss_cms_admin/components/tags_autocomplete"
pin "laiss_cms_admin/components/tinymce"
pin "laiss_cms_admin/components/remote_select"
pin "laiss_cms_admin/components/select"
pin "laiss_cms_admin/i18n"
# Dependencies of the standalone components above. The admin bundle inlines
# these, but the source files import them by name, so importing a component on
# its own fails without pins of their own.
pin "laiss_cms_admin/components/icon"
pin "laiss_cms_admin/growler"
pin "laiss_cms_admin/utils/ajax"
pin "laiss_cms_admin/utils/dom_helpers"
pin "laiss_cms_admin/utils/json_script"
pin "laiss_cms_admin/utils/tom_select"
pin "tom-select/utils", to: "tom-select.min.js"
pin "laiss_cms_admin/utils/events", to: "laiss_cms/laiss_cms_admin.min.js"
