import "laiss_cms_admin/components/growl"
import { renderComponent } from "./component.helper"

describe("laiss-cms-growl", () => {
  it("should have the given message from attribute", () => {
    const html = `
      <div id="flash_notices"></div>
      <laiss-cms-growl message="Foo Bar"></laiss-cms-growl>
    `
    renderComponent("laiss-cms-growl", html)
    const message = document.querySelector("laiss-cms-message")
    expect(message.textContent).toMatch("Foo Bar")
  })

  it("should have the given message from innerHTML", () => {
    const html = `
      <div id="flash_notices"></div>
      <laiss-cms-growl>Foo Bar</laiss-cms-growl>
    `
    renderComponent("laiss-cms-growl", html)
    const message = document.querySelector("laiss-cms-message")
    expect(message.textContent).toMatch("Foo Bar")
  })

  it("removes element from DOM after connect", () => {
    const html = `
      <div id="flash_notices"></div>
      <laiss-cms-growl>Foo Bar</laiss-cms-growl>
    `
    renderComponent("laiss-cms-growl", html)
    expect(document.querySelector("laiss-cms-growl")).toBeNull()
  })
})
