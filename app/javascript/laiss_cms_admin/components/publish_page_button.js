class PublishPageButton extends HTMLElement {
  connectedCallback() {
    this.addEventListener("submit", this)
    document.addEventListener("laiss_cms:page-dirty", this)
  }

  disconnectedCallback() {
    this.removeEventListener("submit", this)
    document.removeEventListener("laiss_cms:page-dirty", this)
  }

  handleEvent(event) {
    switch (event.type) {
      case "laiss_cms:page-dirty":
        this.markDirty(event.detail)
        break
      case "submit":
        this.button.loading = true
        break
    }
  }

  markDirty(detail) {
    this.button.variant = "primary"
    this.button.disabled = false
    this.tooltip.content = detail.tooltip
  }

  get button() {
    return this.querySelector("sl-button")
  }

  get tooltip() {
    return this.querySelector("sl-tooltip")
  }
}

customElements.define("laiss-cms-publish-page-button", PublishPageButton)
