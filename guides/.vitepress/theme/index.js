// https://vitepress.dev/guide/custom-theme
import { h } from "vue"
import DefaultTheme from "vitepress/theme"
import ExtensionLinks from "./ExtensionLinks.vue"
import "./style.css"

// The upstream theme mounted three advertising components (SideBarAd, BottomAd,
// ServiceAd) into the layout. All three were deleted with the rest of the upstream
// promotion during the rebrand, which left this file importing files that no longer
// exist — so `vitepress build` failed outright and the guides could not be built at
// all. The mounts are removed with them.
export default {
  extends: DefaultTheme,
  Layout: () => {
    return h(DefaultTheme.Layout)
  },
  enhanceApp({ app }) {
    app.component("ExtensionLinks", ExtensionLinks)
  },
}
