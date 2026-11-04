import "laiss_cms_admin/components/overlay"

describe("laiss-cms-overlay", () => {
  /**
   * @type {HTMLElement | undefined}
   */
  let overlay = undefined
  let overlayText = undefined

  const renderComponent = (html = `<laiss-cms-overlay></laiss-cms-overlay>`) => {
    document.body.innerHTML = html
    overlay = document.querySelector("laiss-cms-overlay")
    overlayText = document.getElementById("overlay_text")
  }

  it("should render the overlay", () => {
    renderComponent()
    expect(overlayText).toBeTruthy()
  })

  it("should be hidden", () => {
    renderComponent()
    overlay.show = false
    expect(overlay.classList).not.toContain("visible")
  })

  it("should have a given text", () => {
    renderComponent(`<laiss-cms-overlay text="Foo Bar"></laiss-cms-overlay>`)
    expect(overlayText.textContent).toBe("Foo Bar")
  })

  it("should be visible", () => {
    renderComponent()
    overlay.show = true
    expect(overlay.classList).toContain("visible")
  })
})
