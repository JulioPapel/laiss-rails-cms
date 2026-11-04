const DISMISS_DELAY = 5000

class Message extends HTMLElement {
  #dismissTimeoutId = null

  handleEvent(event) {
    if (event.type === "click") {
      this.dismiss()
    }
  }

  connectedCallback() {
    if (!this.querySelector(":scope > laiss-cms-icon")) {
      const closeIcon =
        this.dismissable && this.type === "error"
          ? '<laiss-cms-icon name="close"></laiss-cms-icon>'
          : ""
      this.insertAdjacentHTML(
        "afterbegin",
        `<laiss-cms-icon name="${this.iconName}"></laiss-cms-icon>${closeIcon}`
      )
    }
    if (this.dismissable || this.type === "error") {
      this.addEventListener("click", this)
    }
    if (this.dismissable && this.type !== "error") {
      this.#dismissTimeoutId = setTimeout(() => {
        this.dismiss()
      }, this.dismissDelay)
    }
  }

  disconnectedCallback() {
    if (this.#dismissTimeoutId !== null) {
      clearTimeout(this.#dismissTimeoutId)
      this.#dismissTimeoutId = null
    }
  }

  dismiss() {
    this.addEventListener("transitionend", () => this.remove())
    this.classList.add("dismissed")
  }

  get dismissable() {
    return this.hasAttribute("dismissable")
  }

  get icon() {
    return this.getAttribute("icon")
  }

  get type() {
    return this.getAttribute("type") || "notice"
  }

  get dismissDelay() {
    return parseInt(
      this.noticesWrapper?.dataset.autoDismissDelay || DISMISS_DELAY
    )
  }

  get iconName() {
    switch (this.icon || this.type) {
      case "warning":
      case "warn":
      case "alert":
        return "alert"
      case "notice":
        return "check"
      case "info":
      case "hint":
        return "information"
      case "error":
        return "bug"
      default:
        return this.type
    }
  }

  get noticesWrapper() {
    return this.closest("#flash_notices")
  }
}

customElements.define("laiss-cms-message", Message)
