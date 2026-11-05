// Responsive shell drawer.
//
// Below the desktop breakpoint the fixed sidebar becomes an off-canvas drawer.
// This element owns ONLY the mechanics a drawer genuinely needs:
//
//   - a toggle button that opens/closes it
//   - a backdrop that closes on click
//   - Escape to close
//   - a focus trap while open, and focus restoration on close
//   - body scroll lock while open
//
// It is deliberately a NEW, self-contained element rather than a change to an
// existing one. The ~56 existing custom elements (and the ERB tags that use
// them) are untouched: this element only toggles a class on a container it is
// given, so it cannot interfere with any other behaviour.
//
// Markup contract:
//
//   <laiss-cms-drawer target="left_menu" label="Menu">
//     ...the toggle button is rendered by this element...
//   </laiss-cms-drawer>
//
// `target` is the id of the element to treat as the drawer panel. The panel's
// own markup is never modified, only toggled via the `is-open` class on it and
// `data-drawer-open` on <body>.
class Drawer extends HTMLElement {
  static get observedAttributes() {
    return ["label"]
  }

  #panel = null
  #backdrop = null
  #toggle = null
  #lastFocused = null
  #onKeydown = (event) => this.#handleKeydown(event)
  #onBackdrop = () => this.close()

  connectedCallback() {
    // Not rendered above the breakpoint; the CSS hides the toggle and the
    // drawer becomes part of the static layout again.
    if (this.#initialised) return
    this.#initialised = true

    this.#panel = document.getElementById(this.getAttribute("target"))
    if (!this.#panel) return

    this.#toggle = document.createElement("button")
    this.#toggle.type = "button"
    this.#toggle.className = "drawer-toggle"
    this.#toggle.setAttribute("aria-expanded", "false")
    this.#toggle.setAttribute("aria-controls", this.getAttribute("target"))
    this.#toggle.setAttribute(
      "aria-label",
      this.getAttribute("label") || "Menu"
    )
    // Three rules, drawn in CSS. No icon dependency, no extra asset.
    this.#toggle.innerHTML =
      '<span class="drawer-toggle-bars" aria-hidden="true"></span>'
    this.#toggle.addEventListener("click", () => this.toggle())

    this.appendChild(this.#toggle)

    this.#backdrop = document.createElement("div")
    this.#backdrop.className = "drawer-backdrop"
    this.#backdrop.hidden = true
    this.#backdrop.addEventListener("click", this.#onBackdrop)
    this.appendChild(this.#backdrop)
  }

  disconnectedCallback() {
    document.removeEventListener("keydown", this.#onKeydown)
    this.#unlockScroll()
  }

  get isOpen() {
    return this.hasAttribute("open")
  }

  toggle() {
    this.isOpen ? this.close() : this.open()
  }

  open() {
    if (!this.#panel) return
    this.#lastFocused = document.activeElement

    this.setAttribute("open", "")
    this.#panel.classList.add("is-open")
    document.body.setAttribute("data-drawer-open", "")
    this.#backdrop.hidden = false
    this.#toggle.setAttribute("aria-expanded", "true")

    document.addEventListener("keydown", this.#onKeydown)
    this.#lockScroll()

    // Focus the first focusable thing in the panel so keyboard users land
    // inside the drawer rather than behind the backdrop.
    const first = this.#focusable()[0]
    if (first) first.focus()
    else this.#panel.focus()
  }

  close() {
    if (!this.#panel) return
    const wasOpen = this.isOpen

    this.removeAttribute("open")
    this.#panel.classList.remove("is-open")
    document.body.removeAttribute("data-drawer-open")
    this.#backdrop.hidden = true
    this.#toggle.setAttribute("aria-expanded", "false")

    document.removeEventListener("keydown", this.#onKeydown)
    this.#unlockScroll()

    // Return focus where the user left it, but only if we actually had it.
    if (wasOpen && this.#lastFocused && this.#lastFocused.focus) {
      this.#lastFocused.focus()
    }
    this.#lastFocused = null
  }

  #focusable() {
    if (!this.#panel) return []
    return Array.from(
      this.#panel.querySelectorAll(
        'a[href], button:not([disabled]), input:not([disabled]), select:not([disabled]), textarea:not([disabled]), [tabindex]:not([tabindex="-1"])'
      )
    ).filter((el) => el.offsetParent !== null || el === document.activeElement)
  }

  #handleKeydown(event) {
    if (event.key === "Escape") {
      event.preventDefault()
      this.close()
      return
    }

    if (event.key !== "Tab") return

    // Focus trap: keep Tab inside the panel while the drawer is open.
    const focusable = this.#focusable()
    if (focusable.length === 0) {
      event.preventDefault()
      return
    }

    const first = focusable[0]
    const last = focusable[focusable.length - 1]

    if (event.shiftKey && document.activeElement === first) {
      event.preventDefault()
      last.focus()
    } else if (!event.shiftKey && document.activeElement === last) {
      event.preventDefault()
      first.focus()
    }
  }

  #lockScroll() {
    // Preserve any existing inline value so unlocking does not clobber it.
    this.#previousOverflow ??= document.body.style.overflow
    document.body.style.overflow = "hidden"
  }

  #unlockScroll() {
    if (this.#previousOverflow === undefined) return
    document.body.style.overflow = this.#previousOverflow
    this.#previousOverflow = undefined
  }

  #previousOverflow = undefined
  #initialised = false
}

customElements.define("laiss-cms-drawer", Drawer)

// Close the drawer when the viewport grows past the breakpoint, otherwise the
// body keeps its scroll lock while the sidebar is back in the static layout.
const desktop = window.matchMedia("(min-width: 1000px)")
desktop.addEventListener("change", (event) => {
  if (!event.matches) return
  document
    .querySelectorAll("laiss-cms-drawer[open]")
    .forEach((el) => el.close())
})

export { Drawer }
