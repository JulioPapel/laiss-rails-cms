import { vi } from "vitest"
import "laiss_cms_admin/components/image_overlay_link"
import ImageOverlay from "laiss_cms_admin/image_overlay"
import { renderComponent } from "./component.helper"

describe("laiss-cms-image-overlay-link", () => {
  it("opens an image overlay for its own href on click", () => {
    const openSpy = vi.spyOn(ImageOverlay.prototype, "open").mockImplementation()
    const link = renderComponent(
      "laiss-cms-image-overlay-link",
      `<a is="laiss-cms-image-overlay-link" href="http://localhost/admin/pictures/1">
        <laiss-cms-picture-thumbnail></laiss-cms-picture-thumbnail>
      </a>`
    )

    link.querySelector("laiss-cms-picture-thumbnail").click()

    expect(openSpy).toHaveBeenCalled()
    expect(link.dialog.url).toEqual("http://localhost/admin/pictures/1")
  })

  it("prevents navigating to the picture page", () => {
    vi.spyOn(ImageOverlay.prototype, "open").mockImplementation()
    const link = renderComponent(
      "laiss-cms-image-overlay-link",
      `<a is="laiss-cms-image-overlay-link" href="http://localhost/admin/pictures/1"></a>`
    )
    const click = new Event("click", { bubbles: true, cancelable: true })

    link.dispatchEvent(click)

    expect(click.defaultPrevented).toBeTruthy()
  })
})
