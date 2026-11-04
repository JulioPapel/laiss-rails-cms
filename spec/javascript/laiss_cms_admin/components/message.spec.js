import { describe, vi } from "vitest"
import "laiss_cms_admin/components/message"
import { renderComponent } from "./component.helper"

describe("laiss-cms-message", () => {
  describe("dismiss", () => {
    describe("when dismissable", () => {
      it("dismisses on click", () => {
        const html = `
          <laiss-cms-message dismissable>
            A message
          </laiss-cms-message>
        `
        const component = renderComponent("laiss-cms-message", html)
        const spy = vi.spyOn(component, "dismiss")
        component.dispatchEvent(new Event("click"))
        expect(spy).toHaveBeenCalled()
      })

      it("dismisses after delay", () => {
        return new Promise((resolve) => {
          const html = `
            <div id="flash_notices" data-auto-dismiss-delay="10">
              <laiss-cms-message dismissable>
                A message
              </laiss-cms-message>
            </div>
          `
          const component = renderComponent("laiss-cms-message", html)
          const spy = vi.spyOn(component, "dismiss")
          setTimeout(() => {
            expect(spy).toHaveBeenCalled()
            resolve()
          }, 15)
        })
      }, 100)

      it("when type error, does not dismis after delay", () => {
        return new Promise((resolve) => {
          const html = `
            <div id="flash_notices" data-auto-dismiss-delay="10">
              <laiss-cms-message dismissable type="error">
                A message
              </laiss-cms-message>
            </div>
          `
          const component = renderComponent("laiss-cms-message", html)
          const spy = vi.spyOn(component, "dismiss")
          setTimeout(() => {
            expect(spy).not.toHaveBeenCalled()
            resolve()
          }, 15)
        })
      }, 100)
    })

    describe("when type error", () => {
      it("dismisses on click", () => {
        const html = `
          <laiss-cms-message type="error">
            A message
          </laiss-cms-message>
        `
        const component = renderComponent("laiss-cms-message", html)
        const spy = vi.spyOn(component, "dismiss")
        component.dispatchEvent(new Event("click"))
        expect(spy).toHaveBeenCalled()
      })
    })

    describe("when not type error nor dismissable", () => {
      it("dismisses on click", () => {
        const html = `
          <laiss-cms-message type="info">
            A message
          </laiss-cms-message>
        `
        const component = renderComponent("laiss-cms-message", html)
        const spy = vi.spyOn(component, "dismiss")
        component.dispatchEvent(new Event("click"))
        expect(spy).not.toHaveBeenCalled()
      })
    })
  })

  describe("type", () => {
    describe("when message type is given", () => {
      it("is given type", () => {
        const html = `
          <laiss-cms-message type="warning">
            A warning message
          </laiss-cms-message>
        `
        const component = renderComponent("laiss-cms-message", html)
        expect(component.type).toEqual("warning")
      })
    })

    describe("when message type is not given", () => {
      it("is given type", () => {
        const html = `
          <laiss-cms-message>
            A warning message
          </laiss-cms-message>
        `
        const component = renderComponent("laiss-cms-message", html)
        expect(component.type).toEqual("notice")
      })
    })
  })

  describe("icon", () => {
    describe("when icon attribute is given", () => {
      it("uses the icon instead of type", () => {
        const html = `
          <laiss-cms-message icon="warn">
            A message with custom icon
          </laiss-cms-message>
        `
        const component = renderComponent("laiss-cms-message", html)
        expect(
          component.querySelector("laiss-cms-icon").getAttribute("name")
        ).toEqual("alert")
      })
    })
  })

  describe("dismissable", () => {
    describe("when dismissable is set", () => {
      it("is dismissable", () => {
        const html = `
          <laiss-cms-message dismissable>
            A dismissable message
          </laiss-cms-message>
        `
        const component = renderComponent("laiss-cms-message", html)
        expect(component.dismissable).toBe(true)
      })

      it("and type error, it shows close icon", () => {
        const html = `
          <laiss-cms-message type="error" dismissable>
            A dismissable message
          </laiss-cms-message>
        `
        const component = renderComponent("laiss-cms-message", html)
        expect(
          component.querySelector("laiss-cms-icon[name='close']")
        ).toBeDefined()
      })
    })

    describe("when dismissable is not set", () => {
      it("is not dismissable", () => {
        const html = `
          <laiss-cms-message>
            A not dismissable message
          </laiss-cms-message>
        `
        const component = renderComponent("laiss-cms-message", html)
        expect(component.dismissable).toBe(false)
      })
    })
  })

  describe("iconName", () => {
    describe("when 'warning', 'warn' or 'alert' message type is given", () => {
      ;["warning", "warn", "alert"].forEach((type) => {
        it("is alert", () => {
          const html = `
            <laiss-cms-message type="${type}">
              A ${type} message
            </laiss-cms-message>
          `
          const component = renderComponent("laiss-cms-message", html)
          expect(component.iconName).toEqual("alert")
        })
      })
    })

    describe("when 'notice' message type is given", () => {
      const html = `
        <laiss-cms-message type="notice">
          A notice message
        </laiss-cms-message>
      `

      it("is check", () => {
        const component = renderComponent("laiss-cms-message", html)

        expect(component.iconName).toEqual("check")
      })
    })

    describe("when 'info' or 'hint' message type is given", () => {
      ;["hint", "info"].forEach((type) => {
        it("is alert", () => {
          const html = `
            <laiss-cms-message type="${type}">
              A ${type} message
            </laiss-cms-message>
          `
          const component = renderComponent("laiss-cms-message", html)
          expect(component.iconName).toEqual("information")
        })
      })
    })

    describe("when 'error' message type is given", () => {
      const html = `
        <laiss-cms-message type="error">
          A error message
        </laiss-cms-message>
      `

      it("is check", () => {
        const component = renderComponent("laiss-cms-message", html)

        expect(component.iconName).toEqual("bug")
      })
    })

    describe("when unknown message type is given", () => {
      const html = `
        <laiss-cms-message type="foo">
          A foo message
        </laiss-cms-message>
      `

      it("is the given message type as icon name", () => {
        const component = renderComponent("laiss-cms-message", html)

        expect(component.iconName).toEqual("foo")
      })
    })
  })
})
