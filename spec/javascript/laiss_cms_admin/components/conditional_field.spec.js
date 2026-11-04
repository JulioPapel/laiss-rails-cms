import "laiss_cms_admin/components/conditional_field"
import { renderComponent } from "./component.helper"

describe("laiss-cms-conditional-field", () => {
  /**
   * @type {HTMLElement | undefined}
   */
  let component = undefined

  const checkbox = () => document.getElementById("page_restricted")

  const field = () => component.querySelector("input")

  const render = (checked, controlDisabled = false) => {
    const html = `
      <input type="checkbox" id="page_restricted"${checked ? " checked" : ""}${
        controlDisabled ? " disabled" : ""
      }>
      <laiss-cms-conditional-field control="page_restricted">
        <input type="text" name="page[foo]">
      </laiss-cms-conditional-field>
    `
    component = renderComponent("laiss-cms-conditional-field", html)
  }

  it("is hidden while the control is unchecked", () => {
    render(false)
    expect(component.hidden).toBe(true)
  })

  it("is visible while the control is checked", () => {
    render(true)
    expect(component.hidden).toBe(false)
  })

  it("shows itself once the control gets checked", () => {
    render(false)
    checkbox().checked = true
    checkbox().dispatchEvent(new Event("change"))
    expect(component.hidden).toBe(false)
  })

  it("hides itself once the control gets unchecked", () => {
    render(true)
    checkbox().checked = false
    checkbox().dispatchEvent(new Event("change"))
    expect(component.hidden).toBe(true)
  })

  it("disables its fields while hidden, so they are not submitted", () => {
    render(false)
    expect(field().disabled).toBe(true)
  })

  it("enables its fields while visible", () => {
    render(true)
    expect(field().disabled).toBe(false)
  })

  it("enables its fields once the control gets checked", () => {
    render(false)
    checkbox().checked = true
    checkbox().dispatchEvent(new Event("change"))
    expect(field().disabled).toBe(false)
  })

  it("disables its fields once the control gets unchecked", () => {
    render(true)
    checkbox().checked = false
    checkbox().dispatchEvent(new Event("change"))
    expect(field().disabled).toBe(true)
  })

  it("keeps its fields disabled if the control is disabled", () => {
    render(true, true)
    expect(field().disabled).toBe(true)
    expect(component.hidden).toBe(true)
  })

  it("does not fail without a control", () => {
    document.body.innerHTML = `<laiss-cms-conditional-field></laiss-cms-conditional-field>`
    expect(document.querySelector("laiss-cms-conditional-field").hidden).toBe(
      true
    )
  })
})
