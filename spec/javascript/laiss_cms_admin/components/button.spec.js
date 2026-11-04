import { vi } from "vitest"
import "laiss_cms_admin/components/button"
import { renderComponent } from "./component.helper.js"

describe("laiss-cms-button", () => {
  it("disables button on form submit", () => {
    const html = `
      <form>
        <button type="submit" is="laiss-cms-button">Save</button>
      </form>
    `
    const button = renderComponent("laiss-cms-button", html)
    const submit = new Event("submit", { bubbles: true })

    button.form.dispatchEvent(submit)

    expect(button.getAttribute("disabled")).toEqual("disabled")
    expect(button.getAttribute("tabindex")).toEqual("-1")
    expect(button.classList.contains("disabled")).toBeTruthy()
    expect(button.innerHTML).toEqual(
      '&nbsp;<laiss-cms-spinner size="small" color="currentColor"></laiss-cms-spinner>'
    )
  })

  it("logs warning if no form found", () => {
    global.console = {
      ...console,
      warn: vi.fn()
    }

    const html = `
    <button is="laiss-cms-button">Save</button>
    `
    const button = renderComponent("laiss-cms-button", html)

    expect(console.warn).toHaveBeenCalledWith(
      "No form for button found!",
      button
    )
  })

  describe("on turbo forms", () => {
    it("re-enables button on turbo:submit-end", () => {
      const html = `
        <turbo-frame>
          <form>
            <button type="submit" is="laiss-cms-button">Save</button>
          </form>
        </turbo-frame>
      `
      const button = renderComponent("laiss-cms-button", html)

      const submit = new Event("submit", { bubbles: true })
      button.form.dispatchEvent(submit)

      expect(button.getAttribute("disabled")).toEqual("disabled")

      const submitEnd = new CustomEvent("turbo:submit-end", { bubbles: true })
      button.form.dispatchEvent(submitEnd)

      expect(button.getAttribute("disabled")).toBeNull()
      expect(button.getAttribute("tabindex")).toBeNull()
      expect(button.classList.contains("disabled")).toBeFalsy()
      expect(button.innerHTML).toEqual("Save")
    })
  })
})
