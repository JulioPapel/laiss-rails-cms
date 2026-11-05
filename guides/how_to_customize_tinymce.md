# Customizing the rich-text editor

Body-copy fields use [TinyMCE](https://www.tiny.cloud). The default configuration
is intentionally narrow — see [the editor policy](../CONTRIBUTING.md) for why.

## The policy, first

Layout, headings and hierarchy come from **element definitions**, not from what a
writer types. A body field therefore offers only inline formatting and lists. It
cannot set sizes, alignment, colours or fonts, because that would let an author
break the page's structure.

Consequences worth knowing before you customise:

- `valid_elements` is a **backstop**. Anything outside the allowed set is stripped
  even on paste or on programmatic `insertContent`, so adding a button without
  adding its element produces nothing.
- Paste is forced to **plain text**. External styling cannot leak in.
- Context menu, quickbars and the block-format select are disabled.

## Current default configuration

From `lib/laiss_cms/tinymce.rb`:

```ruby
{
  skin: "laiss_cms",
  icons: "remixicons",
  min_height: 250,
  menubar: false,
  statusbar: true,
  toolbar: "bold italic | link unlink | bullist numlist | quote | formats inlinecode | undo redo | removeformat",
  formats: {
    inlinecode: { inline: "code" },
    quote: { block: "blockquote", wrapper: true, remove: "all" }
  },
  valid_elements: "p,br,strong/b,em/i,u,del/s,s,sub,sup,a[href|target|rel|title],ul,ol,li,blockquote,code,hr",
  extended_valid_elements: "a[href|target|rel|title|class]",
  valid_children: "+p[strong|em|u|del|s|sub|sup|a|code|br]",
  contextmenu: false,
  quickbars_selection_toolbar: false,
  quickbars_insert_toolbar: false,
  paste_as_text: true,
  paste_webkit_styles: "none",
  paste_remove_spans: true,
  paste_strip_class_attributes: "all",
  fix_list_elements: true,
  convert_urls: false,
  entity_encoding: "raw",
  element_format: "html",
  branding: false,
  license_key: "gpl"
}
```

**Plugins loaded:** `link`, `lists`, `laiss_cms_link`.

Buttons: bold, italic, link, unlink, bulleted list, numbered list, blockquote,
inline code, undo, redo, clear formatting.

The editor is **always light**. It does not follow the operating system, because
the admin has one theme.

## Adding a button

Three things, or the button will not work:

1. **The plugin**, in `DEFAULT_PLUGINS` (`lib/laiss_cms/tinymce.rb`) **and** in the
   imports in `bundles/tinymce.js`. The second is what actually bundles it; the
   first is what tells TinyMCE to load it. A plugin in only one of the two fails
   silently.
2. **The toolbar entry**, in the `toolbar:` string.
3. **The elements it produces**, in `valid_elements`, plus a matching rule in
   `app/stylesheets/laiss_cms/body-copy.scss` so the published page is styled.

Then rebuild and commit the artifacts:

```bash
pnpm run build        # app/assets/builds and vendor/javascript
```

CI fails if the committed artifacts are stale.

### Example: adding subscripts back

Subscript and superscript are already allowed by `valid_elements` and need no
plugin — only toolbar entries:

```ruby
toolbar: "bold italic | link unlink | bullist numlist | quote | formats inlinecode | subscript superscript | undo redo | removeformat"
```

### Example: adding a plugin

Tables, for instance, if you decide your content model needs them:

```ruby
# lib/laiss_cms/tinymce.rb
DEFAULT_PLUGINS = %w[link lists laiss_cms_link table]
toolbar: "bold italic | link unlink | bullist numlist | table | undo redo"
valid_elements: "...,table,thead,tbody,tr,th,td"
```

```js
// bundles/tinymce.js
import "tinymce/plugins/table"
```

Then add `table` and its children to `body-copy.scss`. Without that rule the
editor shows a table and the published page shows an unstyled one.

This is a real trade against the policy above. If you add tables, say why in the
commit message: the policy exists so a writer cannot change a page's structure, and
a table is structure.

## Per-instance configuration

Any attribute on the `<laiss-cms-tinymce>` element becomes a TinyMCE setting,
with dashes turned into underscores:

```erb
<laiss-cms-tinymce
  min-height="400"
  toolbar="bold italic | link unlink">
  <%= f.text_area :body %>
</laiss-cms-tinymce>
```

Boolean attributes work as HTML booleans; anything else is parsed as JSON, falling
back to a string.

## Styling the content

Two stylesheets, and they must agree:

| File | Where it applies |
| --- | --- |
| `app/stylesheets/tinymce/skins/content/laiss_cms/content.scss` | inside the editor iframe |
| `app/stylesheets/laiss_cms/body-copy.scss` | the published page |

If they disagree, a writer sees one thing and publishes another. The published
stylesheet is the one that matters; the editor's job is to imitate it.

## Configuration reference

Set these in `config/initializers/laiss_cms.rb`:

```ruby
LaissCms::Tinymce.init = {
  toolbar: "bold italic | link unlink",
  min_height: 400
}
```

`LaissCms::Tinymce.init = ...` **merges** into the defaults. To remove a default
key you must set it explicitly (for example `statusbar: false`).

`LaissCms::Tinymce.plugins` replaces the plugin list. Remember the import in
`bundles/tinymce.js` — the Ruby list alone does not bundle anything.
