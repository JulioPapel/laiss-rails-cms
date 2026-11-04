import { vi } from "vitest"
import "laiss_cms_admin/components/icon"
import { renderComponent } from "./component.helper"

describe("laiss-cms-icon", () => {
  it("can be loaded again after the element got defined", async () => {
    vi.resetModules()

    await expect(import("laiss_cms_admin/components/icon")).resolves.toBeDefined()
  })

  it("renders an icon with default style", () => {
    const html = `
      <link rel="preload" href="/assets/remixicon.symbol.svg" as="image">
      <laiss-cms-icon name="image"></laiss-cms-icon>
    `
    const icon = renderComponent("laiss-cms-icon", html)

    expect(icon.innerHTML).toEqual(
      '<svg class="icon"><use href="/assets/remixicon.symbol.svg#ri-image-line"></use></svg>'
    )
  })

  it("renders an icon with given style", () => {
    const html = `
      <link rel="preload" href="/assets/remixicon.symbol.svg" as="image">
      <laiss-cms-icon name="image" icon-style="fill"></laiss-cms-icon>
    `
    const icon = renderComponent("laiss-cms-icon", html)

    expect(icon.innerHTML).toEqual(
      '<svg class="icon"><use href="/assets/remixicon.symbol.svg#ri-image-fill"></use></svg>'
    )
  })

  it("renders an icon with no style", () => {
    const html = `
      <link rel="preload" href="/assets/remixicon.symbol.svg" as="image">
      <laiss-cms-icon name="image" icon-style="none"></laiss-cms-icon>
    `
    const icon = renderComponent("laiss-cms-icon", html)

    expect(icon.innerHTML).toEqual(
      '<svg class="icon"><use href="/assets/remixicon.symbol.svg#ri-image"></use></svg>'
    )
  })

  it("renders an icon with size", () => {
    const html = `
      <link rel="preload" href="/assets/remixicon.symbol.svg" as="image">
      <laiss-cms-icon name="image" size="medium"></laiss-cms-icon>
    `
    const icon = renderComponent("laiss-cms-icon", html)

    expect(icon.innerHTML).toEqual(
      '<svg class="icon icon--medium"><use href="/assets/remixicon.symbol.svg#ri-image-line"></use></svg>'
    )
  })

  it("renders an icon without a sprite preload link", () => {
    const html = `
      <laiss-cms-icon name="image"></laiss-cms-icon>
    `
    const icon = renderComponent("laiss-cms-icon", html)

    expect(icon.innerHTML).toEqual(
      '<svg class="icon"><use href="#ri-image-line"></use></svg>'
    )
  })
})
