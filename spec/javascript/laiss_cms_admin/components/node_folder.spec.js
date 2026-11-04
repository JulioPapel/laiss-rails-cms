import { describe, it, expect, beforeEach, afterEach } from "vitest"
import "laiss_cms_admin/components/node_folder"

describe("LaissCmsNodeFolder", () => {
  let container

  const render = (html) => {
    container.innerHTML = html
    return container.querySelector("laiss-cms-node-folder")
  }

  beforeEach(() => {
    container = document.createElement("div")
    document.body.appendChild(container)
  })

  afterEach(() => {
    document.body.removeChild(container)
  })

  it("renders a folder button", () => {
    const element = render("<laiss-cms-node-folder></laiss-cms-node-folder>")

    expect(element.querySelector("button.node_folder")).toBeTruthy()
  })

  it("renders a down arrow when unfolded", () => {
    const element = render("<laiss-cms-node-folder></laiss-cms-node-folder>")

    expect(element.querySelector("laiss-cms-icon").getAttribute("name")).toBe(
      "arrow-down-s"
    )
  })

  it("renders a right arrow when folded", () => {
    const element = render("<laiss-cms-node-folder folded></laiss-cms-node-folder>")

    expect(element.querySelector("laiss-cms-icon").getAttribute("name")).toBe(
      "arrow-right-s"
    )
  })

  it("updates the arrow when the folded attribute is set", () => {
    const element = render("<laiss-cms-node-folder></laiss-cms-node-folder>")

    element.toggleAttribute("folded", true)

    expect(element.querySelector("laiss-cms-icon").getAttribute("name")).toBe(
      "arrow-right-s"
    )
  })

  it("updates the arrow when the folded attribute is removed", () => {
    const element = render("<laiss-cms-node-folder folded></laiss-cms-node-folder>")

    element.toggleAttribute("folded", false)

    expect(element.querySelector("laiss-cms-icon").getAttribute("name")).toBe(
      "arrow-down-s"
    )
  })
})
