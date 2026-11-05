# frozen_string_literal: true

module LaissCms
  module Tinymce
    mattr_accessor :languages, :plugins

    # Minimal set for BODY COPY only.
    #
    # Layout, headings and hierarchy come from element definitions, not from
    # what a writer types, so a body field needs inline formatting and lists and
    # nothing else. Dropped from the old list: anchor, charmap, code (source
    # view), directionality, fullscreen. `link` and `lists` stay because the
    # reduced toolbar still offers them; `laiss_cms_link` is our own link dialogs.
    DEFAULT_PLUGINS = %w[
      link
      lists
      laiss_cms_link
    ]

    @@plugins = DEFAULT_PLUGINS
    @@init = {
      skin: "laiss_cms",
      icons: "remixicons",
      width: "auto",
      resize: true,
      min_height: 250,
      menubar: false,
      statusbar: true,
      # One row, deliberately short. Every control here can only produce inline
      # markup or a list, which is what a body field is allowed to publish.
      # `removeformat` is the single "clear formatting" action.
      toolbar: "bold italic | link unlink | bullist numlist | quote | formats inlinecode | undo redo | removeformat",
      # `inlinecode` is a character format, not the source-view plugin: it wraps
      # the selection in <code> so inline code stays available while the
      # source/HTML editor (the `code` plugin) is gone.
      formats: {
        inlinecode: {inline: "code"},
        # blockquote is offered as a button, so it must be a declared block
        # format. Without this TinyMCE normalises the block straight back to <p>.
        quote: {block: "blockquote", wrapper: true, remove: "all"}
      },
      # Allow only the inline/block elements the reduced toolbar can produce.
      # Anything else a paste or an old record contains is unwrapped, which is
      # what keeps published body copy inside the element system.
      valid_elements: "p,br,strong/b,em/i,u,del/s,s,sub,sup,a[href|target|rel|title],ul,ol,li,blockquote,code,hr",
      extended_valid_elements: "a[href|target|rel|title|class]",
      valid_children: "+p[strong|em|u|del|s|sub|sup|a|code|br]",
      # Inline-only: no block-level menu, no table/cell/row context toolbars.
      contextmenu: false,
      quickbars_selection_toolbar: false,
      quickbars_insert_toolbar: false,
      # Paste always becomes plain text, so external styling cannot leak in.
      paste_as_text: true,
      paste_webkit_styles: "none",
      paste_merge_formats: false,
      paste_remove_styles_if_webkit: true,
      paste_remove_spans: true,
      paste_strip_class_attributes: "all",
      fix_list_elements: true,
      convert_urls: false,
      entity_encoding: "raw",
      element_format: "html",
      branding: false,
      license_key: "gpl"
    }

    class << self
      def init=(settings)
        @@init.merge!(settings)
      end

      def init
        @@init
      end

      def preloadable_plugins
        @@plugins - DEFAULT_PLUGINS
      end
    end
  end
end
