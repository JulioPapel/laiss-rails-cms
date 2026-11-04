import { vi } from "vitest"
import "laiss_cms_admin/components/dialog_link"
import { Dialog } from "laiss_cms_admin/dialog"
import { renderComponent } from "./component.helper"

describe("laiss-cms-dialog-link", () => {
  it("opens a dialog on click", () => {
    const html = `
      <a type="submit" is="laiss-cms-dialog-link">Open Dialog</a>
    `
    const openSpy = vi.spyOn(Dialog.prototype, "open")
    const dialogLink = renderComponent("laiss-cms-dialog-link", html)
    const click = new Event("click", { bubbles: true })

    dialogLink.dispatchEvent(click)
    expect(openSpy).toHaveBeenCalled()
  })

  it("has default dialogOptions", () => {
    const html = `
      <a is="laiss-cms-dialog-link">Open Dialog</a>
    `
    const dialogLink = renderComponent("laiss-cms-dialog-link", html)

    expect(dialogLink.dialogOptions).toEqual({})
  })

  it("parses dialogOptions from dataset", () => {
    const html = `
      <a is="laiss-cms-dialog-link" data-dialog-options="{&quot;title&quot;:&quot;Foo&quot;}">Open Dialog</a>
    `
    const dialogLink = renderComponent("laiss-cms-dialog-link", html)

    expect(dialogLink.dialogOptions.title).toEqual("Foo")
  })
})
