import "laiss_cms_admin/components/link_buttons/link_button"
import "laiss_cms_admin/components/link_buttons/unlink_button"

class LinkButtons extends HTMLElement {
  connectedCallback() {
    this.addEventListener("laiss_cms:link", this)
    this.addEventListener("laiss_cms:unlink", this)
  }

  disconnectedCallback() {
    this.removeEventListener("laiss_cms:link", this)
    this.removeEventListener("laiss_cms:unlink", this)
  }

  handleEvent(event) {
    switch (event.type) {
      case "laiss_cms:link":
        this.setLink(event.detail)
        break
      case "laiss_cms:unlink":
        this.removeLink()
    }
    event.stopPropagation()
  }

  setLink(data) {
    this.linkUrlField.value = data.url
    this.linkUrlField.dispatchEvent(new Event("change"))
    this.linkTitleField.value = data.title
    this.linkClassField.value = data.type
    this.linkTargetField.value = data.target

    this.unlinkButton.linked = true
    this.setElementDirty()
  }

  removeLink() {
    this.linkUrlField.value = ""
    this.linkUrlField.dispatchEvent(new Event("change"))
    this.linkTitleField.value = ""
    this.linkClassField.value = ""
    this.linkTargetField.value = ""

    this.linkButton.classList.remove("linked")
    this.unlinkButton.linked = false

    this.setElementDirty()
  }

  setElementDirty() {
    this.elementEditor.setDirty(this)
  }

  get linkButton() {
    return this.querySelector('[is="laiss-cms-link-button"]')
  }

  get unlinkButton() {
    return this.querySelector('[is="laiss-cms-unlink-button"]')
  }

  get ingredientEditor() {
    const ingredientId = this.dataset.ingredientId
    return this.parentElement.closest(`[data-ingredient-id='${ingredientId}']`)
  }

  get elementEditor() {
    return this.closest("laiss-cms-element-editor")
  }

  get linkUrlField() {
    return this.ingredientEditor.querySelector("[data-link-value]")
  }

  get linkTitleField() {
    return this.ingredientEditor.querySelector("[data-link-title]")
  }

  get linkTargetField() {
    return this.ingredientEditor.querySelector("[data-link-target]")
  }

  get linkClassField() {
    return this.ingredientEditor.querySelector("[data-link-class]")
  }
}

customElements.define("laiss-cms-link-buttons", LinkButtons)
