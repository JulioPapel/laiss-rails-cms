import { renderComponent } from "./component.helper"

import "laiss_cms_admin/components/attachment_select"

describe("laiss-cms-attachment-select", () => {
  /**
   * @type {HTMLElement | undefined}
   */
  let component = undefined

  beforeEach(() => {
    const html = `
      <laiss-cms-attachment-select>
        <input type="text">
      </laiss-cms-attachment-select>
    `
    component = renderComponent("laiss-cms-attachment-select", html)
  })

  const attachment = { name: "manual.pdf", icon_css_class: "file-pdf" }

  it("describes an option with the file type icon and the name", () => {
    expect(component._entry(attachment, "man")).toEqual({
      icon: "file-pdf",
      primary: "<em>man</em>ual.pdf"
    })
  })

  it("describes the selected item with the icon and the name", () => {
    expect(component._selectedEntry(attachment)).toEqual({
      icon: "file-pdf",
      primary: "manual.pdf"
    })
  })
})
