import { translate, currentLocale } from "laiss_cms_admin/i18n"
import flatpickr from "flatpickr"

const locale = currentLocale()

class Datepicker extends HTMLElement {
  // Load the locales for flatpickr before setting it up.
  async connectedCallback() {
    // English is the default locale for flatpickr, so we don't need to load it
    if (locale !== "en") {
      await import(`flatpickr/${locale}.js`)
    }
    // Bail out if the element was disconnected while the locale was loading.
    // Otherwise flatpickr would leak a calendar onto a detached input.
    if (!this.isConnected) return

    this.flatpickr = flatpickr(this.inputField, this.flatpickrOptions)
  }

  disconnectedCallback() {
    this.flatpickr?.destroy()
  }

  get flatpickrOptions() {
    const enableTime = /time/.test(this.inputType)
    const options = {
      // laiss_cms_i18n supports `zh_CN` etc., but flatpickr only has two-letter codes (`zh`)
      locale: locale.slice(0, 2),
      altInput: true,
      altFormat: translate(`formats.${this.inputType}`),
      altInputClass: "flatpickr-input",
      enableTime,
      noCalendar: this.inputType === "time",
      time_24hr: translate("formats.time_24hr"),
      // Mount the calendar inside this element rather than appending it to
      // <body>. flatpickr defaults to a body-level absolute popup, which
      // detached it from the editor and could open outside the visible area
      // (the report of "a window outside of the area"). Static positioning keeps
      // it inside the element editor, clipped and scrolling with it, and
      // inherits the theme because it stays inside the themed subtree.
      static: true,
      // Never let the calendar escape its container on small screens.
      positionElement: undefined,
      onValueUpdate(_selectedDates, _dateStr, instance) {
        instance.element
          .closest("laiss-cms-element-editor")
          ?.setDirty(this.inputField)
      }
    }

    if (enableTime) {
      options.dateFormat = "Z"
    }

    return options
  }

  get inputField() {
    return this.querySelector("input")
  }

  get inputType() {
    return this.getAttribute("input-type") || "date"
  }
}

customElements.define("laiss-cms-datepicker", Datepicker)
