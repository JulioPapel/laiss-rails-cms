import "tinymce"
import { currentLocale } from "laiss_cms_admin/i18n"
import { readJSONScript } from "laiss_cms_admin/utils/json_script"

const DARK_THEME = "laiss-cms-dark"
const LIGHT_THEME = "laiss_cms"

export class Tinymce extends HTMLElement {
  #min_height = null

  /**
   * the observer will initialize Tinymce if the textarea becomes visible
   */
  connectedCallback() {
    this.className = "tinymce_container"

    // Append the spinner if not already present (idempotent on reconnect/clone)
    if (!this.querySelector(":scope > laiss-cms-spinner")) {
      this.insertAdjacentHTML(
        "beforeend",
        `<laiss-cms-spinner size="small"></laiss-cms-spinner>`
      )
    }

    // hide the textarea until TinyMCE is ready to show the editor
    this.style.minHeight = `${this.minHeight}px`
    this.editor.style.display = "none"

    const observerCallback = (entries, observer) => {
      entries.forEach((entry) => {
        if (entry.intersectionRatio > 0) {
          this._initTinymceEditor()
          // disable observer after the Tinymce was initialized
          observer.unobserve(entry.target)
        }
      })
    }

    const options = {
      root: document.getElementById("element_area"),
      rootMargin: "0px",
      threshold: [0.05]
    }

    this.tinymceIntersectionObserver = new IntersectionObserver(
      observerCallback,
      options
    )
    this.tinymceIntersectionObserver.observe(this)

    // Set up theme change listener
    this._setupThemeChangeListener()
  }

  /**
   * disconnect intersection observer and remove Tinymce editor if the web components get destroyed
   */
  disconnectedCallback() {
    this.tinymceIntersectionObserver?.disconnect()

    // Remove theme change listener
    this._removeThemeChangeListener()

    tinymce.get(this.editorId)?.remove(this.editorId)
  }

  /**
   * initialize Richtext area after the Intersection observer triggered
   * @private
   */
  _initTinymceEditor() {
    tinymce.init(this.configuration).then((editors) => {
      editors.forEach((editor) => this._setupEditor(editor))
    })
  }

  /**
   * Setup editor after initialization
   * @param {Object} editor - The TinyMCE editor instance
   * @private
   */
  _setupEditor(editor) {
    // mark the editor container as visible
    // without these correction the editor remains hidden
    // after a drag and drop action
    editor.show()

    // remove the spinner after the Tinymce initialized (only on first init)
    const spinner = this.getElementsByTagName("laiss-cms-spinner")[0]
    if (spinner) {
      spinner.remove()
    }

    // event listener to mark the editor as dirty
    if (this.elementEditor) {
      editor.on("dirty", (evt) => {
        this.elementEditor.setDirty(evt.target.editorContainer)
      })
      editor.on("click", () => this.elementEditor.onClickElement(false))
    }
  }

  /**
   * Set up listeners for theme changes.
   *
   * Two sources, because the admin's theme can change in two ways:
   *
   *   - the OS switches appearance, when the user is following the system
   *   - the user picks light or dark in the admin's theme control, which sets
   *     `data-theme` on <html>
   *
   * Only listening to the media query (the previous behaviour) meant the editor
   * iframe kept its old skin after an explicit choice: the chrome switched and
   * the editor did not. The MutationObserver covers that second case.
   * @private
   */
  _setupThemeChangeListener() {
    this.darkModeMediaQuery = window.matchMedia("(prefers-color-scheme: dark)")
    this.themeChangeHandler = () => this._handleThemeChange()
    this.darkModeMediaQuery.addEventListener("change", this.themeChangeHandler)

    this.attributeObserver = new MutationObserver((mutations) => {
      const themeChanged = mutations.some(
        (mutation) => mutation.attributeName === "data-theme"
      )
      if (themeChanged) this._handleThemeChange()
    })
    this.attributeObserver.observe(document.documentElement, {
      attributes: true,
      attributeFilter: ["data-theme"]
    })
  }

  /**
   * Remove theme change listeners
   * @private
   */
  _removeThemeChangeListener() {
    if (this.darkModeMediaQuery && this.themeChangeHandler) {
      this.darkModeMediaQuery.removeEventListener(
        "change",
        this.themeChangeHandler
      )
    }
    if (this.attributeObserver) {
      this.attributeObserver.disconnect()
      this.attributeObserver = null
    }
  }

  /**
   * Rebuild the editor when the effective theme no longer matches the skin in
   * use. Reading `this.isDark` (rather than the event) means both sources share
   * one code path and an explicit choice correctly beats the OS query.
   * @private
   */
  _handleThemeChange() {
    const editor = tinymce.get(this.editorId)
    if (!editor) return

    // No-op when the theme did not actually change: the OS media query also
    // fires on systems where an explicit data-theme overrides it, and the
    // observer sees every attribute write.
    if (editor.settings.skin === this.preferredTheme) return

    const skin = this.preferredTheme
    const content_css = this.preferredContentCss

    // Update the skin by reinitializing the editor with new configuration.
    //
    // `this.configuration` already resolves content_css from `isDark`, so the
    // spread must come FIRST and the explicit skin last. Spreading it after
    // content_css was silently overwriting the resolved value with the raw
    // {light, dark} map, which TinyMCE ignores.
    editor.remove()
    tinymce
      .init({
        ...this.configuration,
        content_css,
        skin
      })
      .then((editors) => {
        editors.forEach((editor) => this._setupEditor(editor))
      })
  }

  get configuration() {
    const customConfig = {}

    // read the attributes on the component and add them as custom configuration
    this.getAttributeNames().forEach((attributeName) => {
      if (!["class", "id", "is", "name", "style"].includes(attributeName)) {
        const config = this.getAttribute(attributeName)
        const key = attributeName.replaceAll("-", "_")

        // Handle boolean HTML attributes (e.g., readonly="readonly" or readonly="")
        if (config === attributeName || config === "") {
          customConfig[key] = true
        } else {
          try {
            customConfig[key] = JSON.parse(config)
          } catch (e) {
            // also string values as parameter
            customConfig[key] = config
          }
        }
      }
    })

    // Order matters: `tinymce_defaults` also carries `content_css` (as a
    // {light, dark} map read by the server), so the defaults must be spread
    // FIRST and the resolved value applied after, or the map would be handed to
    // TinyMCE verbatim and it would ignore it — falling back to its built-in
    // content CSS and losing the Inter font inside the editor iframe.
    const config = {
      ...readJSONScript("laiss_cms_tinymce_defaults"),
      ...customConfig,
      content_css: this.preferredContentCss,
      language: currentLocale(),
      selector: `#${this.editorId}`,
      skin: this.preferredTheme
    }

    // Tinymce has a height of 400px by default
    // if the element has a min_height set, we use this value for the height as well
    // so we do not need to set both values in the element configuration
    config.height = config.min_height

    return config
  }

  // Dark is active when <html data-theme="dark"> is set explicitly, otherwise
  // when the OS prefers dark. The explicit attribute has to win here too, or a
  // host that forces a theme gets an editor on the opposite skin.
  // The admin ships ONE light theme, so the editor is light unless a host
  // explicitly forces the Journal dark value set via data-theme.
  //
  // This used to fall through to `prefers-color-scheme`, which meant an author
  // on a dark-mode OS got a BLACK editor inside a white admin: the chrome had
  // no data-theme (correct for light-only) but the iframe honoured the OS and
  // fetched skins/ui/laiss-cms-dark. Verified by emulating a dark OS: the page
  // reported data-theme=null while the stylesheet list contained
  // laiss-cms-dark/skin.min.css.
  //
  // Only an explicit opt-in now selects dark, never the OS.
  get isDark() {
    return (
      document.documentElement.getAttribute("data-theme") === "journal-dark"
    )
  }

  get preferredTheme() {
    return this.isDark ? DARK_THEME : LIGHT_THEME
  }

  // Absolute asset URLs for the editor content stylesheet, supplied by the
  // server in the defaults JSON. `content_css` must never be a bare theme name:
  // TinyMCE loads it inside the editor iframe, whose base URI is the admin page,
  // so "laiss_cms" resolves to /admin/laiss_cms instead of an asset path.
  get preferredContentCss() {
    const css = (readJSONScript("laiss_cms_tinymce_defaults") || {}).content_css
    if (css && typeof css === "object") {
      return this.isDark ? css.dark : css.light
    }
    return css
  }

  get editorId() {
    return this.editor.id
  }

  get editor() {
    return this.getElementsByTagName("textarea")[0]
  }

  get elementEditor() {
    return document
      .getElementById(this.editorId)
      .closest("laiss-cms-element-editor")
  }

  get minHeight() {
    return this.#min_height || this.configuration.min_height
  }

  set minHeight(value) {
    this.#min_height = value
  }
}

customElements.define("laiss-cms-tinymce", Tinymce)
