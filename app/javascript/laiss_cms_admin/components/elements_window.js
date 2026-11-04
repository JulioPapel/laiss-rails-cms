import { ElementEditor } from "laiss_cms_admin/components/element_editor"

class ElementsWindow extends HTMLElement {
  #visible = true
  #turboFrame = null

  connectedCallback() {
    this.toggleButton?.addEventListener("click", this.#onToggleClick)
    this.collapseButton?.addEventListener("click", this.#onCollapseClick)
    window.addEventListener("message", this.#onWindowMessage)
    document.body.addEventListener("click", this.#onBodyClick)
    if (window.location.hash) {
      this.focusElementEditor(window.location.hash)
    }
    this.resize()
  }

  disconnectedCallback() {
    this.toggleButton?.removeEventListener("click", this.#onToggleClick)
    this.collapseButton?.removeEventListener("click", this.#onCollapseClick)
    window.removeEventListener("message", this.#onWindowMessage)
    document.body.removeEventListener("click", this.#onBodyClick)
  }

  #onToggleClick = (evt) => {
    evt.preventDefault()
    this.toggle()
  }

  #onCollapseClick = () => {
    this.collapseAllElements()
  }

  #onWindowMessage = (event) => {
    if (event.source !== this.previewWindow?.contentWindow) return

    const data = event.data
    if (data?.message == "LaissCms.focusElementEditor") {
      const element = document.getElementById(`element_${data.element_id}`)
      this.show()
      element?.focusElement()
    }
  }

  #onBodyClick = (evt) => {
    if (!evt.target.closest("laiss-cms-element-editor")) {
      this.querySelectorAll("laiss-cms-element-editor").forEach((editor) => {
        editor.classList.remove("selected")
      })
      this.previewWindow?.postMessage({ message: "LaissCms.blurElements" })
    }
  }

  collapseAllElements() {
    this.querySelectorAll(
      "laiss-cms-element-editor:not([compact]):not([fixed])"
    ).forEach((editor) => editor.collapse())
  }

  toggle() {
    this.#visible ? this.hide() : this.show()
  }

  show() {
    document.body.classList.add("elements-window-visible")
    this.#visible = true
    this.toggleButton.closest("sl-tooltip").content = LaissCms.t("Hide elements")
    this.toggleButton
      .querySelector("laiss-cms-icon")
      .setAttribute("name", "menu-unfold")
    this.resize()
  }

  hide() {
    document.body.classList.remove("elements-window-visible")
    document.body.style.removeProperty("--elements-window-width")
    this.#visible = false
    this.toggleButton.closest("sl-tooltip").content = LaissCms.t("Show elements")
    this.toggleButton
      .querySelector("laiss-cms-icon")
      .setAttribute("name", "menu-fold")
  }

  resize(width) {
    if (width === undefined) {
      width = this.widthFromCookie
    }

    if (width) {
      document.body.style.setProperty("--elements-window-width", `${width}px`)
      document.cookie = `laiss-cms-elements-window-width=${width}; SameSite=Lax; Path=/;`
    }
  }

  // Focus element editor and element in preview if URL contains hash to element editor.
  // The link is coming from the assignment view when showing assigned files or pictures.
  focusElementEditor(dom_id) {
    const el = document.querySelector(dom_id)

    if (el instanceof ElementEditor) {
      el.focusElement() && el.focusElementPreview()
    }
  }

  get collapseButton() {
    return this.querySelector("#collapse-all-elements-button")
  }

  get toggleButton() {
    return document.querySelector("#element_window_button")
  }

  get previewWindow() {
    return document.getElementById("laiss_cms_preview_window")
  }

  get turboFrame() {
    if (!this.#turboFrame) {
      this.#turboFrame = this.closest("turbo-frame")
    }
    return this.#turboFrame
  }

  get widthFromCookie() {
    return document.cookie
      .split("; ")
      .find((row) => row.startsWith("laiss-cms-elements-window-width="))
      ?.split("=")[1]
  }

  set isDragged(dragged) {
    this.turboFrame.style.transitionProperty = dragged ? "none" : null
    this.turboFrame.style.pointerEvents = dragged ? "none" : null
  }
}

customElements.define("laiss-cms-elements-window", ElementsWindow)
