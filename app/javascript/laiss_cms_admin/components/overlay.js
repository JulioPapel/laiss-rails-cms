class Overlay extends HTMLElement {
  connectedCallback() {
    this.innerHTML = `
      <laiss-cms-spinner></laiss-cms-spinner>
      <div id="overlay_text_box">
        <span id="overlay_text">${this.getAttribute("text") ?? ""}</span>
      </div>
    `
  }

  set show(value) {
    this.classList.toggle("visible", value)
  }
}

customElements.define("laiss-cms-overlay", Overlay)
