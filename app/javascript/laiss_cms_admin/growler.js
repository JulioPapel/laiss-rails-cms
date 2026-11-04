import { createHtmlElement } from "laiss_cms_admin/utils/dom_helpers"

function build(message, flashType) {
  const flashNotices = document.getElementById("flash_notices")
  const flashMessage = createHtmlElement(`
    <laiss-cms-message type="${flashType}" dismissable>
      ${message}
    </laiss-cms-message>
  `)
  flashNotices.append(flashMessage)
}

export function growl(message, style = "notice") {
  build(message, style)
}
