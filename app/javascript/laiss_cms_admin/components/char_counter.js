/**
 * Show the character counter below input fields and textareas
 */
import { translate } from "laiss_cms_admin/i18n"

class CharCounter extends HTMLElement {
  connectedCallback() {
    this.translation = translate("allowed_chars", this.maxChars)
    this.formField = this.getFormField()

    if (this.formField) {
      this.createDisplayElement()
      this.countCharacters()
      this.formField.addEventListener("keyup", this)
    }
  }

  disconnectedCallback() {
    this.formField?.removeEventListener("keyup", this)
  }

  handleEvent(event) {
    if (event.type === "keyup") this.countCharacters()
  }

  getFormField() {
    const formFields = this.querySelectorAll("input, textarea")
    return formFields.length > 0 ? formFields[0] : undefined
  }

  createDisplayElement() {
    this.display = this.querySelector(":scope > .laiss-cms-char-counter")
    if (this.display) return
    this.display = document.createElement("small")
    this.display.className = "laiss-cms-char-counter"
    this.formField.after(this.display)
  }

  countCharacters() {
    const charLength = this.formField.value.length
    this.display.textContent = `${charLength} ${this.translation}`
    this.display.classList.toggle("too-long", charLength > this.maxChars)
  }

  get maxChars() {
    return this.getAttribute("max-chars") ?? 60
  }
}

customElements.define("laiss-cms-char-counter", CharCounter)
