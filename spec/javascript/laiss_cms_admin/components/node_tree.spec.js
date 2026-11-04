import { describe, it, expect, vi, beforeEach, afterEach } from "vitest"
import Sortable from "sortablejs"
import { patch } from "laiss_cms_admin/utils/ajax"
import { growl } from "laiss_cms_admin/growler"
import "laiss_cms_admin/components/node_tree"
import "laiss_cms_admin/components/menu_node"
import "laiss_cms_admin/components/node_folder"

vi.mock("sortablejs", () => ({
  default: vi.fn()
}))

vi.mock("laiss_cms_admin/utils/ajax", () => ({
  patch: vi.fn(() => Promise.resolve())
}))

vi.mock("laiss_cms_admin/growler", () => ({
  growl: vi.fn()
}))

vi.mock("laiss_cms_admin/i18n", () => ({
  translate: vi.fn((key) => key)
}))

vi.mock("laiss_cms_admin/routes", () => ({
  routes: {
    node: {
      move_api_path: (id) => `/api/nodes/${id}/move`
    }
  }
}))

describe("LaissCmsNodeTree", () => {
  let container
  let element

  const menuNode = (id, children = "") => `
    <laiss-cms-menu-node node-id="${id}">
      <li class="menu-item">
        <div class="sitemap_node">
          <span class="nodes_tree-left_images">
            <laiss-cms-node-folder></laiss-cms-node-folder>
          </span>
          <div class="node_name">Node ${id}</div>
        </div>
        <ul class="children" data-record-id="${id}">${children}</ul>
      </li>
    </laiss-cms-menu-node>
  `

  const childrenListOf = (id) =>
    element.querySelector(`ul.children[data-record-id="${id}"]`)

  const dragEvent = (nodeId, fromId, toId, newIndex = 0) => ({
    item: element.querySelector(`laiss-cms-menu-node[node-id="${nodeId}"]`),
    from: childrenListOf(fromId),
    to: childrenListOf(toId),
    oldIndex: 0,
    newIndex
  })

  const onEnd = () => Sortable.mock.calls[0][1].onEnd

  beforeEach(() => {
    container = document.createElement("div")
    container.innerHTML = `
      <laiss-cms-node-tree>
        <ul class="nodes_tree list">
          ${menuNode(1, `${menuNode(2)}${menuNode(3)}`)}
        </ul>
      </laiss-cms-node-tree>
    `
    document.body.appendChild(container)
    element = container.querySelector("laiss-cms-node-tree")
  })

  afterEach(() => {
    document.body.removeChild(container)
    vi.clearAllMocks()
  })

  describe("initialization", () => {
    it("makes every children list sortable", () => {
      expect(Sortable).toHaveBeenCalledTimes(3)
    })

    it("only drags menu nodes by their name", () => {
      const options = Sortable.mock.calls[0][1]

      expect(options.group).toBe("nodes")
      expect(options.handle).toBe(".node_name")
      expect(options.draggable).toBe("laiss-cms-menu-node")
    })
  })

  describe("after dragging a node", () => {
    it("patches the move endpoint with its new parent and position", async () => {
      await onEnd()(dragEvent(3, 1, 2, 1))

      expect(patch).toHaveBeenCalledWith("/api/nodes/3/move", {
        target_parent_id: "2",
        new_position: 1
      })
    })

    it("growls a success message", async () => {
      await onEnd()(dragEvent(3, 1, 2))

      expect(growl).toHaveBeenCalledWith("Successfully moved menu item")
    })

    it("updates the folder of the old and the new parent", async () => {
      const oldParent = element.querySelector('laiss-cms-menu-node[node-id="1"]')
      const newParent = element.querySelector('laiss-cms-menu-node[node-id="2"]')
      const updateOldParent = vi.spyOn(oldParent, "updateFolder")
      const updateNewParent = vi.spyOn(newParent, "updateFolder")

      await onEnd()(dragEvent(3, 1, 2))

      expect(updateOldParent).toHaveBeenCalled()
      expect(updateNewParent).toHaveBeenCalled()
    })

    it("does nothing when the node was dropped where it came from", async () => {
      const event = dragEvent(2, 1, 1)
      event.oldIndex = 0
      event.newIndex = 0

      await onEnd()(event)

      expect(patch).not.toHaveBeenCalled()
    })

    it("growls the error when the request fails", async () => {
      patch.mockRejectedValueOnce(new Error("Network error"))

      await onEnd()(dragEvent(3, 1, 2))

      expect(growl).toHaveBeenCalledWith("Network error", "error")
    })
  })
})
