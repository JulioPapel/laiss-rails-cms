import "@ungap/custom-elements"
import { Turbo } from "@hotwired/turbo-rails"

import { translate } from "laiss_cms_admin/i18n"
import { currentDialog, closeCurrentDialog } from "laiss_cms_admin/dialog"
import * as FixedElements from "laiss_cms_admin/fixed_elements"
import { growl } from "laiss_cms_admin/growler"
import Initializer from "laiss_cms_admin/initializer"
import { LinkDialog } from "laiss_cms_admin/link_dialog"
import pleaseWaitOverlay from "laiss_cms_admin/please_wait_overlay"
import Spinner from "laiss_cms_admin/spinner"
import { reloadPreview } from "laiss_cms_admin/components/preview_window"
import { openConfirmDialog } from "laiss_cms_admin/confirm_dialog"

import "laiss_cms_admin/turbo_stream_actions"

// Web Components
import "laiss_cms_admin/components"

// Shoelace Setup
import "laiss_cms_admin/shoelace_theme"

// Global LaissCms object
if (typeof window.LaissCms === "undefined") {
  window.LaissCms = {}
}

// Enhance the global LaissCms object with imported features
Object.assign(LaissCms, {
  closeCurrentDialog,
  currentDialog,
  t: translate, // Global utility method for translating a given string
  FixedElements,
  growl,
  LinkDialog,
  pleaseWaitOverlay,
  Spinner,
  reloadPreview
})
Turbo.config.forms.confirm = openConfirmDialog
document.addEventListener("turbo:load", Initializer)

// Public API for extensions
export { RemoteSelect } from "laiss_cms_admin/components/remote_select"
export { PageSelect } from "laiss_cms_admin/components/page_select"
export { AttachmentSelect } from "laiss_cms_admin/components/attachment_select"
export { ElementSelect } from "laiss_cms_admin/components/element_select"
export { TagsAutocomplete } from "laiss_cms_admin/components/tags_autocomplete"
export { Tinymce } from "laiss_cms_admin/components/tinymce"
export { on } from "laiss_cms_admin/utils/events"
