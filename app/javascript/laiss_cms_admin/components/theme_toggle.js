// Light / dark / system theme control.
//
// A three-way segmented control rather than a two-state switch, because the
// brief asks for three states: an explicit light choice, an explicit dark
// choice, and following the OS. A binary switch cannot express "follow the
// system", so it would have to silently discard that state on first click.
//
// Accessibility: the control is a real radiogroup (`role="radiogroup"` with
// `role="radio"` children), so it is announced with its name, arrow keys move
// between options, and each option reports checked state. Space/Enter activates.
//
// Behaviour: clicking writes `data-theme` on <html> immediately (so the page
// repaints without a round trip) and POSTs the choice to the theme controller,
// which persists it against the user. If the request fails, the previous
// attribute is restored rather than leaving the UI lying about the saved state.
//
// The element is NEW. No existing element was modified to make room for it.
class ThemeToggle extends HTMLElement {
  static get observedAttributes() {
    return ["current", "endpoint"]
  }

  #options = [
    { value: "light", label: "Light", icon: "sun" },
    { value: "system", label: "System", icon: "computer" },
    { value: "dark", label: "Dark", icon: "moon" }
  ]

  #buttons = []

  connectedCallback() {
    if (this.#initialised) return
    this.#initialised = true
    this.render()
  }

  attributeChangedCallback(name, previous, next) {
    if (!this.#initialised || previous === next) return
    this.render()
  }

  get current() {
    return this.getAttribute("current") || "system"
  }

  get endpoint() {
    return this.getAttribute("endpoint")
  }

  render() {
    const label = this.getAttribute("label") || "Colour theme"
    const sprite =
      document
        .querySelector('link[rel="preload"][as="image"]')
        ?.getAttribute("href") ?? ""

    this.innerHTML = ""
    this.classList.add("theme-toggle")
    this.setAttribute("role", "radiogroup")
    this.setAttribute("aria-label", label)

    this.#buttons = this.#options.map((option) => {
      const button = document.createElement("button")
      button.type = "button"
      button.className = "theme-toggle__option"
      button.setAttribute("role", "radio")
      button.setAttribute("data-theme-value", option.value)
      // The accessible name is the option itself; the icon is decoration.
      button.setAttribute("aria-label", option.label)
      button.setAttribute("title", option.label)
      button.setAttribute(
        "aria-checked",
        String(option.value === this.current)
      )
      button.tabIndex = option.value === this.current ? 0 : -1
      button.innerHTML =
        `<svg class="theme-toggle__icon" aria-hidden="true"><use href="${sprite}#ri-${option.icon}-line"></use></svg>` +
        `<span class="theme-toggle__text">${option.label}</span>`

      button.addEventListener("click", () => this.select(option.value))
      button.addEventListener("keydown", (event) =>
        this.#handleKeydown(event, option.value)
      )
      // Roving tabindex: only the selected radio is in the tab order.
      button.addEventListener("focus", () => this.#setTabbable(option.value))

      this.appendChild(button)
      return button
    })
  }

  select(value) {
    const previous = this.current
    if (value === previous) return

    this.setAttribute("current", value)
    this.#applyToDocument(value)
    this.#selectButton(value)
    this.#persist(value, previous)
  }

  // Arrow keys cycle the group, which is the expected behaviour for a
  // radiogroup and lets the whole control be driven from one tab stop.
  #handleKeydown(event, value) {
    const keys = ["ArrowLeft", "ArrowUp", "ArrowRight", "ArrowDown", "Home", "End"]
    if (!keys.includes(event.key)) return

    event.preventDefault()
    const index = this.#options.findIndex((option) => option.value === value)
    const last = this.#options.length - 1

    let next
    if (event.key === "Home") next = 0
    else if (event.key === "End") next = last
    else if (event.key === "ArrowLeft" || event.key === "ArrowUp")
      next = index === 0 ? last : index - 1
    else next = index === last ? 0 : index + 1

    this.select(this.#options[next].value)
    this.#buttons[next]?.focus()
  }

  #setTabbable(value) {
    this.#buttons.forEach((button) => {
      button.tabIndex =
        button.getAttribute("data-theme-value") === value ? 0 : -1
    })
  }

  #selectButton(value) {
    this.#buttons.forEach((button) => {
      const selected = button.getAttribute("data-theme-value") === value
      button.setAttribute("aria-checked", String(selected))
      button.tabIndex = selected ? 0 : -1
    })
  }

  // `system` means "no attribute": the CSS media queries take over.
  #applyToDocument(value) {
    const root = document.documentElement
    if (value === "system") root.removeAttribute("data-theme")
    else root.setAttribute("data-theme", value)
  }

  async #persist(value, previous) {
    if (!this.endpoint) return

    const token = document.querySelector('meta[name="csrf-token"]')?.content
    try {
      const response = await fetch(this.endpoint, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
          Accept: "application/json",
          ...(token ? { "X-CSRF-Token": token } : {})
        },
        // Rails' resource route expects the value nested under the singular key.
        body: JSON.stringify({ theme: value }),
        credentials: "same-origin"
      })
      if (!response.ok) throw new Error(`HTTP ${response.status}`)
    } catch (error) {
      // Revert rather than claim a save that did not happen.
      document.dispatchEvent(
        new CustomEvent("laiss-cms-theme-failed", { detail: { error } })
      )
      this.setAttribute("current", previous)
      this.#applyToDocument(previous)
      this.#selectButton(previous)
    }
  }

  #initialised = false
}

if (!customElements.get("laiss-cms-theme-toggle")) {
  customElements.define("laiss-cms-theme-toggle", ThemeToggle)
}

export { ThemeToggle }
