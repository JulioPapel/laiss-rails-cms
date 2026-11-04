import { vi } from "vitest"
import { renderComponent } from "./component.helper"
import "laiss_cms_admin/components/update_check"

// Mock Spinner to avoid actual DOM manipulation
vi.mock("laiss_cms_admin/spinner")

describe("laiss-cms-update-check", () => {
  let component
  const html = `
    <laiss-cms-update-check url="/update_check">
      <div class="update_available hidden"></div>
      <div class="up_to_date hidden"></div>
      <div class="error hidden"></div>
    </laiss-cms-update-check>
  `

  beforeEach(() => {
    // Mock fetch globally
    global.fetch = vi.fn()

    vi.spyOn(console, "error").mockImplementation(() => {}) // Mock console.error
  })

  afterEach(() => {
    document.body.innerHTML = ""
    vi.clearAllMocks()
  })

  it("fetches with credentials included", async () => {
    global.fetch.mockResolvedValueOnce({
      ok: true,
      json: () => Promise.resolve({ status: "true" })
    })

    component = renderComponent("laiss-cms-update-check", html)
    await new Promise(process.nextTick)

    expect(global.fetch).toHaveBeenCalledWith("/update_check", {
      credentials: "include"
    })
  })

  it("shows update available when response is 'true'", async () => {
    global.fetch.mockResolvedValueOnce({
      ok: true,
      json: () => Promise.resolve({ status: "true" })
    })

    component = renderComponent("laiss-cms-update-check", html)
    await new Promise(process.nextTick)

    expect(
      component.querySelector(".update_available").classList.contains("hidden")
    ).toBe(false)
    expect(
      component.querySelector(".up_to_date").classList.contains("hidden")
    ).toBe(true)
    expect(component.querySelector(".error").classList.contains("hidden")).toBe(
      true
    )
  })

  it("shows update available when response is 'false'", async () => {
    global.fetch.mockResolvedValueOnce({
      ok: true,
      json: () => Promise.resolve({ status: "false" })
    })

    component = renderComponent("laiss-cms-update-check", html)
    await new Promise(process.nextTick)

    expect(
      component.querySelector(".update_available").classList.contains("hidden")
    ).toBe(true)
    expect(
      component.querySelector(".up_to_date").classList.contains("hidden")
    ).toBe(false)
    expect(component.querySelector(".error").classList.contains("hidden")).toBe(
      true
    )
  })

  it("shows error when fetch fails", async () => {
    fetch.mockRejectedValueOnce(new Error("Network error"))

    component = renderComponent("laiss-cms-update-check", html)
    await new Promise(process.nextTick)

    expect(
      component.querySelector(".update_available").classList.contains("hidden")
    ).toBe(true)
    expect(
      component.querySelector(".up_to_date").classList.contains("hidden")
    ).toBe(true)
    expect(component.querySelector(".error").classList.contains("hidden")).toBe(
      false
    )
    expect(console.error).toHaveBeenCalledWith(
      "[laiss_cms] Error fetching update status",
      expect.any(Error)
    )
  })

  it("shows error when response is not ok", async () => {
    fetch.mockResolvedValueOnce({
      ok: false,
      text: () => Promise.resolve("Error")
    })

    component = renderComponent("laiss-cms-update-check", html)
    await new Promise(process.nextTick)

    expect(
      component.querySelector(".update_available").classList.contains("hidden")
    ).toBe(true)
    expect(
      component.querySelector(".up_to_date").classList.contains("hidden")
    ).toBe(true)
    expect(component.querySelector(".error").classList.contains("hidden")).toBe(
      false
    )
    expect(console.error).toHaveBeenCalledWith(
      "[laiss_cms] Error fetching update status",
      expect.any(Object)
    )
  })
})
