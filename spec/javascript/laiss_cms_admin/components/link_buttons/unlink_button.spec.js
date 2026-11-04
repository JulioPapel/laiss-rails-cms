import { vi } from "vitest"
import "laiss_cms_admin/components/link_buttons/unlink_button"
import { renderComponent } from "../component.helper"

beforeEach(() => {
  LaissCms.LinkDialog = vi.fn(function () {
    this.open = vi.fn()
  })
})

describe("laiss-cms-unlink-button", () => {
  it("adds icon_button class", () => {
    const html = `
      <laiss-cms-link-buttons>
        <button is="laiss-cms-unlink-button">Link</button>
      </laiss-cms-link-buttons>
    `
    const button = renderComponent("laiss-cms-unlink-button", html)
    expect(button.classList).toContain("icon_button")
  })

  it("adds type button", () => {
    const html = `
      <laiss-cms-link-buttons>
        <button is="laiss-cms-unlink-button">Link</button>
      </laiss-cms-link-buttons>
    `
    const button = renderComponent("laiss-cms-unlink-button", html)
    expect(button.getAttribute("type")).toBe("button")
  })

  it("adds unlink icon", () => {
    const html = `
      <laiss-cms-link-buttons>
        <button is="laiss-cms-unlink-button">Link</button>
      </laiss-cms-link-buttons>
    `
    const button = renderComponent("laiss-cms-unlink-button", html)
    expect(
      button.querySelector('laiss-cms-icon[name="link-unlink"]')
    ).toBeTruthy()
  })

  it("removes link on click", () => {
    const html = `
      <laiss-cms-link-buttons>
        <button is="laiss-cms-unlink-button" class="linked">Link</button>
      </laiss-cms-link-buttons>
    `
    const button = renderComponent("laiss-cms-unlink-button", html)
    const submit = new Event("click", { bubbles: true })

    expect(button.linked).toBeTruthy()
    button.dispatchEvent(submit)
    expect(button.linked).toBeFalsy()
  })

  it("dispatches event on click", () => {
    return new Promise((resolve) => {
      const html = `
        <laiss-cms-link-buttons>
          <button is="laiss-cms-unlink-button" class="linked">Link</button>
        </laiss-cms-link-buttons>
      `
      const button = renderComponent("laiss-cms-unlink-button", html)
      button
        .closest("laiss-cms-link-buttons")
        .addEventListener("laiss_cms:unlink", (e) => {
          expect(e.type).toEqual("laiss_cms:unlink")
          resolve()
        })
      const click = new Event("click", { bubbles: true })
      button.dispatchEvent(click)
    })
  })

  describe("set linked", () => {
    it("adds linked class if true", () => {
      const html = `
        <laiss-cms-link-buttons>
          <button is="laiss-cms-unlink-button" class="disabled">Link</button>
        </laiss-cms-link-buttons>
      `
      const button = renderComponent("laiss-cms-unlink-button", html)

      button.linked = true
      expect(button.classList).toContain("linked")
    })

    it("removes tabindex if true", () => {
      const html = `
        <laiss-cms-link-buttons>
          <button is="laiss-cms-unlink-button" class="disabled" tabindex="-1">Link</button>
        </laiss-cms-link-buttons>
      `
      const button = renderComponent("laiss-cms-unlink-button", html)

      button.linked = true
      expect(button.getAttribute("tabindex")).toBeFalsy()
    })

    it("adds disabled class if false", () => {
      const html = `
        <laiss-cms-link-buttons>
          <button is="laiss-cms-unlink-button" class="linked">Link</button>
        </laiss-cms-link-buttons>
      `
      const button = renderComponent("laiss-cms-unlink-button", html)

      button.linked = false
      expect(button.classList).toContain("disabled")
    })

    it("adds tabindex if false", () => {
      const html = `
        <laiss-cms-link-buttons>
          <button is="laiss-cms-unlink-button" class="linked">Link</button>
        </laiss-cms-link-buttons>
      `
      const button = renderComponent("laiss-cms-unlink-button", html)

      button.linked = false
      expect(button.getAttribute("tabindex")).toEqual("-1")
    })
  })

  describe("linked", () => {
    it("returns true if has linked class", () => {
      const html = `
        <laiss-cms-link-buttons>
          <button is="laiss-cms-unlink-button" class="linked">Link</button>
        </laiss-cms-link-buttons>
      `
      const button = renderComponent("laiss-cms-unlink-button", html)

      expect(button.linked).toBeTruthy()
    })

    it("returns false if has disabled class", () => {
      const html = `
        <laiss-cms-link-buttons>
          <button is="laiss-cms-unlink-button" class="disabled">Link</button>
        </laiss-cms-link-buttons>
      `
      const button = renderComponent("laiss-cms-unlink-button", html)

      expect(button.linked).toBeFalsy()
    })
  })
})
