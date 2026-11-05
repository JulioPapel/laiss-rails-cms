import { defineConfig } from "vitepress"
import llmstxtPlugin from "vitepress-plugin-llmstxt"
import { VERSIONS, CURRENT_VERSION } from "./versions.js"
const VERSION_NAVITEMS = {
  6: [
    {
      text: "Getting Started",
      link: "/v6/getting_started",
    },
    {
      text: "Basics",
      collapsed: false,
      items: [
        {
          text: "About LaissCMS",
          link: "/v6/about",
        },
        {
          text: "Pages",
          link: "/v6/pages",
        },
        {
          text: "Elements",
          link: "/v6/elements",
        },
        {
          text: "Ingredients",
          link: "/v6/ingredients",
        },
        {
          text: "Rendering Images",
          link: "/v6/render_images",
        },
        {
          text: "Configuration",
          link: "/v6/configuration",
        },
        {
          text: "Updating",
          link: "/v6/upgrading",
        },
      ],
    },
    {
      text: "How To",
      collapsed: false,
      items: [
        {
          text: "Create a Blog",
          link: "/v6/how_to_create_a_blog_template",
        },
        {
          text: "Create a Contact Form",
          link: "/v6/how_to_create_a_contact_form",
        },
        {
          text: "Customize the Richtext Editor",
          link: "/v6/how_to_customize_tinymce",
        },
        {
          text: "Create Custom Ingredients",
          link: "/v6/how_to_create_custom_ingredients",
        },
        {
          text: "Deploy on Heroku",
          link: "/v6/how_to_deploy_on_heroku",
        },
        {
          text: "Create Custom Modules",
          link: "/v6/how_to_create_modules",
        },
        {
          text: "Add Custom Authentication",
          link: "/v6/how_to_add_custom_authentication",
        },
        {
          text: "Extend LaissCms",
          link: "/v6/how_to_extend_laiss_cms",
        },
      ],
    },
  ],
  7: [
    {
      text: "Getting Started",
      link: "/v7/getting_started",
    },
    {
      text: "Basics",
      collapsed: false,
      items: [
        {
          text: "About LaissCMS",
          link: "/v7/about",
        },
        {
          text: "Pages",
          link: "/v7/pages",
        },
        {
          text: "Elements",
          link: "/v7/elements",
        },
        {
          text: "Ingredients",
          link: "/v7/ingredients",
        },
        {
          text: "Rendering Images",
          link: "/v7/render_images",
        },
        {
          text: "Configuration",
          link: "/v7/configuration",
        },
        {
          text: "Updating",
          link: "/v7/upgrading",
        },
      ],
    },
    {
      text: "How To",
      collapsed: false,
      items: [
        {
          text: "Create a Blog",
          link: "/v7/how_to_create_a_blog_template",
        },
        {
          text: "Create a Contact Form",
          link: "/v7/how_to_create_a_contact_form",
        },
        {
          text: "Customize the Richtext Editor",
          link: "/v7/how_to_customize_tinymce",
        },
        {
          text: "Create Custom Ingredients",
          link: "/v7/how_to_create_custom_ingredients",
        },
        {
          text: "Deploy on Heroku",
          link: "/v7/how_to_deploy_on_heroku",
        },
        {
          text: "Create Custom Modules",
          link: "/v7/how_to_create_modules",
        },
        {
          text: "Add Custom Authentication",
          link: "/v7/how_to_add_custom_authentication",
        },
        {
          text: "Extend LaissCms",
          link: "/v7/how_to_extend_laiss_cms",
        },
      ],
    },
  ],
  8: [
    {
      text: "Introduction",
      collapsed: false,
      items: [
        {
          text: "About LaissCMS",
          link: "/about",
        },
        {
          text: "Getting Started",
          link: "/getting_started",
        },
      ],
    },
    {
      text: "Basics",
      collapsed: false,
      items: [
        {
          text: "Elements",
          link: "/elements",
        },
        {
          text: "Ingredients",
          link: "/ingredients",
        },
        {
          text: "Pages",
          link: "/pages",
        },
        {
          text: "Menus",
          link: "/menus",
        },
        {
          text: "Rendering Images",
          link: "/render_images",
        },
        {
          text: "Configuration",
          link: "/configuration",
        },
        {
          text: "I18n",
          link: "/i18n",
        },
        {
          text: "Seeder",
          link: "/seeder",
        },
        {
          text: "Deployment",
          link: "/deployment",
        },
        {
          text: "Updating",
          link: "/upgrading",
        },
      ],
    },
    {
      text: "Admin Modules",
      collapsed: true,
      items: [
        {
          text: "Library",
          link: "/library",
        },
        {
          text: "Tags",
          link: "/tags",
        },
        {
          text: "Languages",
          link: "/languages",
        },
        {
          text: "Sites",
          link: "/sites",
        },
        {
          text: "Custom Modules",
          link: "/how_to_create_modules",
        },
      ],
    },
    {
      text: "How To",
      collapsed: true,
      items: [
        {
          text: "Create a Blog",
          link: "/how_to_create_a_blog",
        },
        {
          text: "Create a Contact Form",
          link: "/how_to_create_a_contact_form",
        },
        {
          text: "Customize the Richtext Editor",
          link: "/how_to_customize_tinymce",
        },
        {
          text: "Create Custom Ingredients",
          link: "/how_to_create_custom_ingredients",
        },
        {
          text: "Deploy with Kamal",
          link: "/how_to_deploy_with_kamal",
        },
        {
          text: "Add Custom Authentication",
          link: "/how_to_add_custom_authentication",
        },
        {
          text: "Integrate Into Existing Rails App",
          link: "/how_to_integrate_into_existing_rails_app",
        },
        {
          text: "Extend LaissCms",
          link: "/how_to_extend_laiss_cms",
        },
      ],
    },
  ],
}

const navItems = VERSIONS.map((version) => {
  const currentVersion = version === CURRENT_VERSION
  return {
    text: currentVersion ? `v${version} (latest)` : `v${version}`,
    link: currentVersion ? "/" : `/v${version}`,
    activeMatch: currentVersion ? `^\/(?!(v\d+))` : `/v${version}/`,
  }
})

const sidebar = VERSIONS.reduce((obj, version) => {
  const folder = version === CURRENT_VERSION ? "" : `v${version}/`
  return {
    ...obj,
    [`/${folder}`]: VERSION_NAVITEMS[version],
  }
}, {})

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: "LaissCMS",
  srcExclude: ["README.md"],
  head: [
    ["link", { rel: "icon", type: "image/x-icon", href: "/favicon.ico" }],
    // No third-party analytics. This documentation ships with the project and
    // must not send a reader's data anywhere.
    [
      "script",
      {},
      `window.plausible=window.plausible||function(){(plausible.q=plausible.q||[]).push(arguments)},plausible.init=plausible.init||function(i){plausible.o=i||{}};
      plausible.init()`,
    ],
  ],
  description:
    "LaissCms is the Open Source Rails CMS framework for the component based web that can be used as classic server side rendered or headless CMS.",
  // https://vitepress.dev/reference/default-theme-config
  themeConfig: {
    logo: "/icon.svg",
    nav: [
      {
        text: "Home",
        link: "/",
      },
      {
        text: "Extensions",
        link: "/extensions",
      },
      {
        text: "Version",
        items: navItems,
      },
    ],
    // This is a private, in-house project: there is no public repository,
    // Mastodon, Bluesky or Slack to point at, so no social links are shown.
    socialLinks: [],
    sidebar,
    // No edit-this-page link: this repository is private.
    footer: {
      message: `
      BSD-3 Licensed`,
      copyright:
        'Copyright © Laiss Labs',
    },
    search: {
      provider: "local",
      options: {
        _render(src, env, md) {
          const html = md.render(src, env)
          if (/^v\d+\//.test(env.relativePath)) return ""
          return html
        },
      },
    },
  },
  lastUpdated: true,
  // Three links in the guides are real but cannot resolve inside the VitePress
  // source root, and the build refused to run because of them:
  //
  //   ../CONTRIBUTING, ../README   files at the repository root; VitePress only
  //                                resolves within guides/, so it cannot see them.
  //                                The published site resolves them.
  //   http://localhost:3000/admin  an example URL, not a page. Note that
  //                                "localhostLinks" does NOT cover this — it only
  //                                matches links starting "//localhost".
  //
  // A predicate is used rather than a list so the intent is legible.
  ignoreDeadLinks: [
    (link) =>
      /(^|\/)\.\.\/(CONTRIBUTING|README)/.test(link) ||
      link.includes("localhost:3000"),
  ],
  vite: {
    plugins: [llmstxtPlugin({ ignore: ["README.md"] })],
  },
})
