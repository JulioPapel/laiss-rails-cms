import { growl } from "laiss_cms_admin/growler"

class Growl extends HTMLElement {
  connectedCallback() {
    growl(this.message, this.getAttribute("type") || "notice")
    this.remove()
  }

  get message() {
    return this.getAttribute("message") || this.innerHTML
  }
}

customElements.define("laiss-cms-growl", Growl)
