import "laiss_cms_admin/components/theme_toggle"
import { renderComponent } from "./component.helper"

describe("laiss-cms-theme-toggle", () => {
  /**
   * @type {HTMLElement | undefined}
   */
  let component = undefined
  let fetchMock = undefined

  const options = () =>
    Array.from(component.querySelectorAll("[data-theme-value]"))

  const checked = () =>
    options()
      .filter((option) => option.getAttribute("aria-checked") === "true")
      .map((option) => option.getAttribute("data-theme-value"))

  beforeEach(() => {
    document.documentElement.removeAttribute("data-theme")

    fetchMock = vi.fn(() => Promise.resolve({ ok: true, status: 200 }))
    global.fetch = fetchMock

    const html = `
      <laiss-cms-theme-toggle
        current="system"
        endpoint="/admin/theme"
        label="Colour theme"></laiss-cms-theme-toggle>
    `
    component = renderComponent("laiss-cms-theme-toggle", html)
  })

  afterEach(() => {
    delete global.fetch
  })

  describe("rendering", () => {
    it("renders one option per theme", () => {
      expect(options()).toHaveLength(3)
    })

    it("offers light, system and dark", () => {
      expect(options().map((o) => o.getAttribute("data-theme-value"))).toEqual([
        "light",
        "system",
        "dark"
      ])
    })

    it("is exposed as a radiogroup with an accessible name", () => {
      expect(component.getAttribute("role")).toEqual("radiogroup")
      expect(component.getAttribute("aria-label")).toEqual("Colour theme")
    })

    it("gives every option an accessible name", () => {
      options().forEach((option) => {
        expect(option.getAttribute("aria-label")).toBeTruthy()
      })
    })

    it("marks the current value as checked", () => {
      expect(checked()).toEqual(["system"])
    })

    it("keeps only the checked option in the tab order", () => {
      const tabbable = options().filter((option) => option.tabIndex === 0)
      expect(tabbable).toHaveLength(1)
      expect(tabbable[0].getAttribute("data-theme-value")).toEqual("system")
    })

    it("re-renders when the current attribute changes", () => {
      component.setAttribute("current", "dark")
      expect(checked()).toEqual(["dark"])
    })
  })

  describe("choosing a theme", () => {
    it("sets data-theme on the root when dark is chosen", () => {
      options()
        .find((o) => o.getAttribute("data-theme-value") === "dark")
        .click()

      expect(document.documentElement.getAttribute("data-theme")).toEqual("dark")
    })

    it("sets data-theme on the root when light is chosen", () => {
      options()
        .find((o) => o.getAttribute("data-theme-value") === "light")
        .click()

      expect(document.documentElement.getAttribute("data-theme")).toEqual(
        "light"
      )
    })

    it("removes the attribute when following the system", () => {
      component.setAttribute("current", "dark")
      document.documentElement.setAttribute("data-theme", "dark")

      options()
        .find((o) => o.getAttribute("data-theme-value") === "system")
        .click()

      expect(document.documentElement.hasAttribute("data-theme")).toBe(false)
    })

    it("updates the checked option", () => {
      options()
        .find((o) => o.getAttribute("data-theme-value") === "dark")
        .click()

      expect(checked()).toEqual(["dark"])
    })
  })

  describe("persistence", () => {
    it("posts the choice to the endpoint", () => {
      options()
        .find((o) => o.getAttribute("data-theme-value") === "dark")
        .click()

      expect(fetchMock).toHaveBeenCalledTimes(1)
      const [url, init] = fetchMock.mock.calls[0]
      expect(url).toEqual("/admin/theme")
      expect(init.method).toEqual("PATCH")
      expect(JSON.parse(init.body)).toEqual({ theme: "dark" })
    })

    it("sends the CSRF token when one is present", () => {
      const meta = document.createElement("meta")
      meta.name = "csrf-token"
      meta.content = "test-token"
      document.head.appendChild(meta)

      options()
        .find((o) => o.getAttribute("data-theme-value") === "dark")
        .click()

      expect(fetchMock.mock.calls[0][1].headers["X-CSRF-Token"]).toEqual(
        "test-token"
      )
      meta.remove()
    })

    it("does not post when the value did not change", () => {
      options()
        .find((o) => o.getAttribute("data-theme-value") === "system")
        .click()

      expect(fetchMock).not.toHaveBeenCalled()
    })

    it("reverts and announces when the request fails", async () => {
      fetchMock.mockImplementation(() =>
        Promise.resolve({ ok: false, status: 422 })
      )
      const listener = vi.fn()
      document.addEventListener("laiss-cms-theme-failed", listener)

      const dark = options().find(
        (o) => o.getAttribute("data-theme-value") === "dark"
      )
      dark.click()
      await new Promise((resolve) => setTimeout(resolve, 0))

      expect(listener).toHaveBeenCalledTimes(1)
      // Back to the previous state rather than claiming a save that did not land.
      expect(document.documentElement.hasAttribute("data-theme")).toBe(false)
      expect(checked()).toEqual(["system"])

      document.removeEventListener("laiss-cms-theme-failed", listener)
    })
  })

  describe("keyboard", () => {
    const press = (option, key) => {
      const event = new KeyboardEvent("keydown", { key, bubbles: true })
      option.dispatchEvent(event)
      return event
    }

    it("moves to the next option with ArrowRight", () => {
      press(component.querySelector('[data-theme-value="system"]'), "ArrowRight")
      expect(checked()).toEqual(["dark"])
    })

    it("moves to the previous option with ArrowLeft", () => {
      press(component.querySelector('[data-theme-value="system"]'), "ArrowLeft")
      expect(checked()).toEqual(["light"])
    })

    it("wraps from the first option to the last", () => {
      press(component.querySelector('[data-theme-value="light"]'), "ArrowLeft")
      expect(checked()).toEqual(["dark"])
    })

    it("wraps from the last option to the first", () => {
      press(component.querySelector('[data-theme-value="dark"]'), "ArrowRight")
      expect(checked()).toEqual(["light"])
    })

    it("jumps to the first option with Home", () => {
      press(component.querySelector('[data-theme-value="dark"]'), "Home")
      expect(checked()).toEqual(["light"])
    })

    it("jumps to the last option with End", () => {
      press(component.querySelector('[data-theme-value="light"]'), "End")
      expect(checked()).toEqual(["dark"])
    })

    it("applies the theme chosen with the keyboard", () => {
      press(component.querySelector('[data-theme-value="system"]'), "ArrowRight")
      expect(document.documentElement.getAttribute("data-theme")).toEqual("dark")
    })

    it("ignores keys that are not navigation", () => {
      press(component.querySelector('[data-theme-value="system"]'), "a")
      expect(checked()).toEqual(["system"])
    })
  })
})
