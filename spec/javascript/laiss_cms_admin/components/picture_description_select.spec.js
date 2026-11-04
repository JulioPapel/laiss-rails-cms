import { vi } from "vitest"
import { renderComponent } from "./component.helper"
import "laiss_cms_admin/components/picture_description_select"

describe("laiss-cms-picture-description-select", () => {
  /**
   *
   * @type {HTMLElement | undefined}
   */
  let component = undefined

  beforeEach(() => {
    const html = `
      <laiss-cms-picture-description-select url="http://example.com/some/url">
        <select>
          <option value="1"></option>
          <option value="2" selected></option>
        </select>
      </laiss-cms-picture-description-select>
    `
    component = renderComponent("laiss-cms-picture-description-select", html)
    global.Turbo = { visit: vi.fn() }
  })

  it("should use Turbo to reload the picture_descriptions frame", () => {
    const select = component.querySelector("select")
    const event = new Event("change", { bubbles: true })
    select.dispatchEvent(event)

    expect(Turbo.visit).toHaveBeenCalledWith(
      new URL("http://example.com/some/url?language_id=2"),
      { frame: "picture_descriptions" }
    )
  })
})
