class UnlinkButton extends HTMLButtonElement {
  connectedCallback() {
    this.addEventListener("click", this)
    this.classList.add("icon_button")
    // Prevent accidental form submits if this component is wrapped inside a form
    this.setAttribute("type", "button")
    this.linked = this.linked
    this.innerHTML =
      '<laiss-cms-icon name="link-unlink" icon-style="m"></laiss-cms-icon>'
  }

  handleEvent(event) {
    if (this.linked) {
      this.linked = false
      this.blur()
      this.dispatchEvent(new CustomEvent("laiss_cms:unlink", { bubbles: true }))
    }
    event.preventDefault()
  }

  set linked(isLinked) {
    if (isLinked) {
      this.classList.replace("disabled", "linked")
      this.removeAttribute("tabindex")
    } else {
      this.classList.replace("linked", "disabled")
      this.setAttribute("tabindex", "-1")
    }
  }

  get linked() {
    return this.classList.contains("linked")
  }
}

customElements.define("laiss-cms-unlink-button", UnlinkButton, {
  extends: "button"
})
