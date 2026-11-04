const STYLES = {
  reset: {
    outline: "",
    "outline-offset": "",
    cursor: ""
  },
  hover: {
    outline: "2px dashed #f0b437",
    "outline-offset": "4px",
    cursor: "pointer"
  },
  selected: {
    outline: "2px dashed #90b9d0",
    "outline-offset": "4px"
  }
}

let elements = []
let selection = null

// Mark element in preview frame as selected and scrolls to it.
function selectElement(element) {
  blurElements(element)
  selection = element
  Object.assign(element.style, STYLES.selected)
  element.scrollIntoView({
    behavior: "smooth",
    block: "start"
  })
}

// Blur all elements in preview frame.
function blurElements(selectedElement) {
  elements.forEach((element) => {
    if (element !== selectedElement) {
      Object.assign(element.style, STYLES.reset)
    }
  })
  selection = null
}

function getElement(elementId) {
  return elements.find(
    (element) => element.dataset.laissCmsElement === elementId.toString()
  )
}

// Focus the element in the LaissCms preview window.
function focusElement(data) {
  const element = getElement(data.element_id)

  if (element) {
    selectElement(element)
  } else {
    console.warn("Could not focus element with id", data.element_id)
  }
}

// Focus the element editor in the LaissCms element window.
function focusElementEditor(element) {
  window.parent.postMessage(
    {
      message: "LaissCms.focusElementEditor",
      element_id: element.dataset.laissCmsElement
    },
    window.location.origin
  )
}

function observeElement(element) {
  element.addEventListener("mouseover", () => {
    if (element !== selection) {
      Object.assign(element.style, STYLES.hover)
    }
  })
  element.addEventListener("mouseout", () => {
    if (element !== selection) {
      Object.assign(element.style, STYLES.reset)
    }
  })
}

function selectClickedElement(event) {
  const element = event.target.closest("[data-laiss-cms-element]")

  if (element) {
    selectElement(element)
    focusElementEditor(element)
  }

  return element
}

function navigates(target) {
  if (target.closest("a")) return true

  const control = target.closest("button, input")
  return Boolean(control?.form) && ["submit", "image"].includes(control.type)
}

// Client side routers navigate from click handlers on the link itself, so
// navigating clicks have to be taken before the event reaches the page.
function onNavigatingClick(event) {
  if (navigates(event.target) && selectClickedElement(event)) {
    event.stopPropagation()
    event.preventDefault()
  }
}

function init() {
  window.addEventListener("message", (event) => {
    switch (event.data.message) {
      case "LaissCms.blurElements":
        blurElements()
        break
      case "LaissCms.focusElement":
        focusElement(event.data)
        break
      default:
        console.info("Received unknown message!", event.data)
    }
  })

  window.addEventListener("click", onNavigatingClick, { capture: true })
  window.addEventListener("click", selectClickedElement)

  elements = Array.from(document.querySelectorAll("[data-laiss-cms-element]"))
  elements.forEach(observeElement)

  // Notify parent window that preview is ready
  window.parent.postMessage(
    {
      message: "LaissCms.previewReady"
    },
    window.location.origin
  )
}

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", init, { once: true })
} else {
  init()
}
