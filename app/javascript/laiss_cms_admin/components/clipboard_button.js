import "clipboard"
import { growl } from "laiss_cms_admin/growler"

class ClipboardButton extends HTMLElement {
  connectedCallback() {
    this.innerHTML = '<laiss-cms-icon name="clipboard"></laiss-cms-icon>'

    this.clipboard = new ClipboardJS(this, {
      text: () => {
        return this.getAttribute("content")
      }
    })

    this.clipboard.on("success", () => {
      growl(this.getAttribute("success-text"))
    })
  }

  disconnectedCallback() {
    this.clipboard.destroy()
  }
}

customElements.define("laiss-cms-clipboard-button", ClipboardButton)
