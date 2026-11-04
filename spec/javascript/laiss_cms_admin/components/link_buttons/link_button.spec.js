import { vi } from "vitest"
import "laiss_cms_admin/components/link_buttons/link_button"
import { renderComponent } from "../component.helper"

beforeEach(() => {
  LaissCms.LinkDialog = vi.fn(function () {
    this.open = vi.fn(() => Promise.resolve({ data: {} }))
  })
})

describe("laiss-cms-link-button", () => {
  it("adds icon_button class", () => {
    const html = `
      <laiss-cms-link-buttons>
        <button is="laiss-cms-link-button">Link</button>
      </laiss-cms-link-buttons>
    `
    const button = renderComponent("laiss-cms-link-button", html)
    expect(button.classList).toContain("icon_button")
  })

  it("adds type button", () => {
    const html = `
      <laiss-cms-link-buttons>
        <button is="laiss-cms-link-button">Link</button>
      </laiss-cms-link-buttons>
    `
    const button = renderComponent("laiss-cms-link-button", html)
    expect(button.getAttribute("type")).toBe("button")
  })

  it("adds link icon", () => {
    const html = `
      <laiss-cms-link-buttons>
        <button is="laiss-cms-link-button">Link</button>
      </laiss-cms-link-buttons>
    `
    const button = renderComponent("laiss-cms-link-button", html)
    expect(button.querySelector('laiss-cms-icon[name="link"]')).toBeTruthy()
  })

  it("opens link dialog on click", () => {
    const html = `
      <laiss-cms-link-buttons>
        <button is="laiss-cms-link-button">Link</button>
      </laiss-cms-link-buttons>
    `
    const button = renderComponent("laiss-cms-link-button", html)
    const click = new Event("click", { bubbles: true })

    button.linkButtons.linkUrlField = { value: "http://example.com" }
    button.linkButtons.linkTitleField = { value: "Example" }
    button.linkButtons.linkTargetField = { value: "_blank" }
    button.linkButtons.linkClassField = { value: "external" }

    button.dispatchEvent(click)
    expect(LaissCms.LinkDialog).toHaveBeenCalledWith({
      url: "http://example.com",
      title: "Example",
      target: "_blank",
      type: "external"
    })
  })

  describe("setLink", () => {
    it("adds linked class", () => {
      const html = `
        <laiss-cms-link-buttons>
          <button is="laiss-cms-link-button">Link</button>
        </laiss-cms-link-buttons>
      `
      const button = renderComponent("laiss-cms-link-button", html)

      button.setLink("http://example.com", "Example", "_blank", "external")
      expect(button.classList).toContain("linked")
    })

    it("dispatches event", () => {
      return new Promise((resolve) => {
        const html = `
          <laiss-cms-link-buttons>
            <button is="laiss-cms-link-button">Link</button>
          </laiss-cms-link-buttons>
        `
        const button = renderComponent("laiss-cms-link-button", html)
        button
          .closest("laiss-cms-link-buttons")
          .addEventListener("laiss_cms:link", (e) => {
            expect(e.detail).toEqual({
              url: "http://example.com",
              title: "Example",
              target: "_blank",
              type: "external"
            })
            resolve()
          })
        button.setLink({
          url: "http://example.com",
          title: "Example",
          target: "_blank",
          type: "external"
        })
      })
    })
  })

  describe("linkUrl", () => {
    it("returns the link url fields value", () => {
      const html = `
        <laiss-cms-link-buttons>
          <button is="laiss-cms-link-button">Link</button>
        </laiss-cms-link-buttons>
      `
      const button = renderComponent("laiss-cms-link-button", html)

      button.linkButtons.linkUrlField = { value: "http://example.com" }

      expect(button.linkUrl).toEqual("http://example.com")
    })
  })

  describe("linkTitle", () => {
    it("returns the link url fields value", () => {
      const html = `
        <laiss-cms-link-buttons>
          <button is="laiss-cms-link-button">Link</button>
        </laiss-cms-link-buttons>
      `
      const button = renderComponent("laiss-cms-link-button", html)

      button.linkButtons.linkTitleField = { value: "Example" }

      expect(button.linkTitle).toEqual("Example")
    })
  })

  describe("linkTarget", () => {
    it("returns the link url fields value", () => {
      const html = `
        <laiss-cms-link-buttons>
          <button is="laiss-cms-link-button">Link</button>
        </laiss-cms-link-buttons>
      `
      const button = renderComponent("laiss-cms-link-button", html)

      button.linkButtons.linkTargetField = { value: "_blank" }

      expect(button.linkTarget).toEqual("_blank")
    })
  })

  describe("linkClass", () => {
    it("returns the link url fields value", () => {
      const html = `
        <laiss-cms-link-buttons>
          <button is="laiss-cms-link-button">Link</button>
        </laiss-cms-link-buttons>
      `
      const button = renderComponent("laiss-cms-link-button", html)

      button.linkButtons.linkClassField = { value: "external" }

      expect(button.linkClass).toEqual("external")
    })
  })

  describe("linkButtons", () => {
    it("returns the link url fields value", () => {
      const html = `
        <laiss-cms-link-buttons>
          <button is="laiss-cms-link-button">Link</button>
        </laiss-cms-link-buttons>
      `
      const button = renderComponent("laiss-cms-link-button", html)

      expect(button.linkButtons.tagName).toEqual("ALCHEMY-LINK-BUTTONS")
    })
  })
})
