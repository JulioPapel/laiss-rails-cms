// https://vitepress.dev/guide/custom-theme
import { h } from "vue"
import DefaultTheme from "vitepress/theme"
import ExtensionLinks from "./ExtensionLinks.vue"
import "./style.css"

// Advert components are not used here; the layout is the default theme. An earlier
// version of this file imported three of them, which no longer existed, so
// `vitepress build` failed outright.
export default {
  extends: DefaultTheme,
  Layout: () => {
    return h(DefaultTheme.Layout)
  },
  enhanceApp({ app }) {
    app.component("ExtensionLinks", ExtensionLinks)
  },
}
