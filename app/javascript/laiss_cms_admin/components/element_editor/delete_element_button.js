import ajax from "laiss_cms_admin/utils/ajax"
import { removeTab } from "laiss_cms_admin/fixed_elements"
import { growl } from "laiss_cms_admin/growler"
import { reloadPreview } from "laiss_cms_admin/components/preview_window"
import { openConfirmDialog } from "laiss_cms_admin/confirm_dialog"
import { dispatchPageDirtyEvent } from "laiss_cms_admin/utils/dispatch_page_dirty_event"

export class DeleteElementButton extends HTMLElement {
  connectedCallback() {
    this.button?.addEventListener("click", this)
  }

  disconnectedCallback() {
    this.button?.removeEventListener("click", this)
  }

  async handleEvent() {
    const confirmed = await openConfirmDialog(this.message)
    if (confirmed) {
      try {
        const response = await ajax("DELETE", this.url)
        this.#removeElement(response.data)
      } catch (error) {
        growl(error.message || error, "error")
        console.error(error)
      }
    }
  }

  #removeElement(data) {
    const elementEditor = this.closest("laiss-cms-element-editor")
    elementEditor.addEventListener("transitionend", () => {
      if (elementEditor.fixed) {
        removeTab(elementEditor.elementId)
      }
      elementEditor.remove()
    })
    elementEditor.classList.add("dismiss")
    growl(data.message)
    if (data.pageHasUnpublishedChanges) {
      dispatchPageDirtyEvent(data)
    }
    reloadPreview()
  }

  get url() {
    return this.getAttribute("href")
  }

  get message() {
    return this.getAttribute("message")
  }

  get button() {
    return this.querySelector("button")
  }
}

customElements.define("laiss-cms-delete-element-button", DeleteElementButton)
