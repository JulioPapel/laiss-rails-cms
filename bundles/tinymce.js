/* Import TinyMCE */
import tinymce from "tinymce"

/* Default icons are required. After that, import custom icons if applicable */
import "tinymce/icons/default"
import "tinymce/icons/remixicons"

/* Required TinyMCE components */
import "tinymce/themes/silver"
import "tinymce/models/dom"

/* Import plugins — body-copy set only. Every plugin here is required by a
   button in the reduced toolbar; nothing else is bundled, so removing a button
   from the config also removes its code from the bundle. */
import "tinymce/plugins/link"
import "tinymce/plugins/lists"
import "tinymce/plugins/laiss_cms_link"

export default tinymce
