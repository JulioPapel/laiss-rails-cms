class LinkButton extends HTMLButtonElement {
  connectedCallback() {
    this.addEventListener("click", this)
    this.classList.add("icon_button")
    // Prevent accidental form submits if this component is wrapped inside a form
    this.setAttribute("type", "button")
    this.innerHTML = '<laiss-cms-icon name="link" icon-style="m"></laiss-cms-icon>'
  }

  handleEvent(event) {
    const dialog = new LaissCms.LinkDialog({
      url: this.linkUrl,
      title: this.linkTitle,
      target: this.linkTarget,
      type: this.linkClass
    })
    dialog.open().then((link) => this.setLink(link))
    event.preventDefault()
  }

  setLink(link) {
    if (link.url === "") {
      this.classList.remove("linked")
      this.dispatchEvent(new CustomEvent("laiss_cms:unlink", { bubbles: true }))
    } else {
      this.classList.add("linked")
      this.dispatchEvent(
        new CustomEvent("laiss_cms:link", {
          bubbles: true,
          detail: link
        })
      )
    }
  }

  get linkUrl() {
    return this.linkButtons.linkUrlField.value
  }

  get linkTitle() {
    return this.linkButtons.linkTitleField.value
  }

  get linkTarget() {
    return this.linkButtons.linkTargetField.value
  }

  get linkClass() {
    return this.linkButtons.linkClassField.value
  }

  get linkButtons() {
    return this.closest("laiss-cms-link-buttons")
  }
}

customElements.define("laiss-cms-link-button", LinkButton, { extends: "button" })
