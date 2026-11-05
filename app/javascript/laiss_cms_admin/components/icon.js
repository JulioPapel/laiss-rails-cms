class Icon extends HTMLElement {
  static get observedAttributes() {
    return ["name", "size", "icon-style"]
  }

  constructor() {
    super()
    this.spriteUrl =
      document
        .querySelector('link[rel="preload"][as="image"]')
        ?.getAttribute("href") ?? ""
  }

  connectedCallback() {
    this.render()
  }

  attributeChangedCallback() {
    this.render()
  }

  render() {
    const sizeClass = this.size ? ` laiss-icon--${this.size}` : ""
    // NOT `icon`. The Focus theme uses `<i class="icon icon-…">` for its own font
    // glyphs, and `.icon` selectors aimed at those were landing on our SVG — which
    // is what produced the "ghost square" artefacts the owner spotted. `laiss-icon`
    // is a name the theme does not claim, so no theme rule can ever match it.
    this.innerHTML = `<svg class="laiss-icon${sizeClass}"><use href="${this.spriteUrl}#ri-${this.iconName}${this.style}" /></svg>`
  }

  set name(value) {
    this.setAttribute("name", value)
  }

  get iconName() {
    return this.getAttribute("name")
  }

  get size() {
    return this.getAttribute("size")
  }

  get style() {
    const value = this.getAttribute("icon-style")
    switch (value) {
      case "none":
        return ""
      case null:
        return "-line"
      default:
        return `-${value}`
    }
  }
}

// Standalone components import this module next to the admin bundle, which
// already defined the element from its own copy.
if (!customElements.get("laiss-cms-icon")) {
  customElements.define("laiss-cms-icon", Icon)
}
