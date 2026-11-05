import fs from "node:fs"
import path from "node:path"
import SVGSpriter from "svg-sprite"
import { consola } from "consola"

const icons = [
  "Arrows/arrow-down-line",
  "Arrows/arrow-down-s-line",
  "Arrows/arrow-left-right-line",
  "Arrows/arrow-left-s-line",
  "Arrows/arrow-left-wide-line",
  "Arrows/arrow-right-s-line",
  "Arrows/arrow-right-wide-line",
  "Arrows/arrow-up-line",
  "Arrows/contract-right-line",
  "Arrows/contract-up-down-line",
  "Arrows/expand-left-line",
  "Arrows/expand-right-line",
  "Arrows/skip-left-line",
  "Arrows/skip-right-line",
  "Buildings/home-2-line",
  "Business/archive-drawer-line",
  "Business/bookmark-fill",
  "Business/bookmark-line",
  "Business/calendar-line",
  "Business/calendar-schedule-line",
  "Business/cloud-line",
  "Business/cloud-off-line",
  "Business/global-line",
  "Business/mail-line",
  "Business/profile-line",
  "Business/shake-hands-line",
  "Business/stack-line",
  "Business/window-line",
  "Design/crop-line",
  "Design/edit-line",
  "Design/eraser-line",
  "Design/layout-bottom-2-line",
  "Design/palette-line",
  "Design/pencil-ruler-2-line",
  "Design/scissors-cut-line",
  "Design/table-line",
  "Development/bug-line",
  "Device/computer-line",
  "Document/article-line",
  "Document/book-3-line",
  "Document/certificate-2-line",
  "Document/clipboard-fill",
  "Document/clipboard-line",
  "Document/file-3-line",
  "Document/file-add-line",
  "Document/file-cloud-line",
  "Document/file-copy-line",
  "Document/file-copy-2-line",
  "Document/file-damage-line",
  "Document/file-edit-line",
  "Document/file-excel-2-line",
  "Document/file-forbid-line",
  "Document/file-image-line",
  "Document/file-line",
  "Document/file-music-line",
  "Document/file-pdf-2-line",
  "Document/file-ppt-2-line",
  "Document/file-text-line",
  "Document/file-upload-line",
  "Document/file-video-line",
  "Document/file-word-2-line",
  "Document/file-zip-line",
  "Document/folder-line",
  "Document/folder-open-line",
  "Document/newspaper-line",
  "Document/pages-line",
  "Editor/draggable",
  "Editor/link-m",
  "Editor/link-unlink-m",
  "Editor/sort-asc",
  "Editor/sort-desc",
  "Editor/translate-2",
  "Finance/price-tag-3-line",
  "Finance/shopping-cart-line",
  "Finance/ticket-line",
  "Map/time-zone-line",
  "Media/camera-line",
  "Media/image-add-line",
  "Media/image-line",
  "Media/multi-image-line",
  "System/add-line",
  "System/alert-line",
  "System/check-line",
  "System/checkbox-multiple-line",
  "System/close-line",
  "System/delete-bin-2-line",
  "System/download-2-line",
  "System/external-link-line",
  "System/information-line",
  "System/lock-line",
  "System/lock-unlock-line",
  "System/logout-box-r-line",
  "System/menu-2-line",
  "System/menu-add-line",
  "System/menu-fold-line",
  "System/menu-unfold-line",
  "System/more-line",
  "System/more-2-line",
  "System/prohibited-line",
  "System/question-line",
  "System/refresh-line",
  "System/search-line",
  "System/settings-3-line",
  "System/timer-line",
  "System/upload-2-line",
  "System/upload-cloud-2-line",
  "System/zoom-in-line",
  "System/zoom-out-line",
  "User & Faces/group-line",
  "User & Faces/user-fill",
  "User & Faces/user-line",
  "User & Faces/robot-2-line",

  // Names the admin requests that had no sprite entry at all, so they rendered as
  // empty boxes. Several are Font Awesome names carried over from the old theme
  // (`times`, `info-circle`, `cog`, `angle-double-left`, `sun`, `moon`) rather than
  // remixicon ones, so they are mapped to the remixicon equivalent here. The sprite
  // guard at the end of this script fails the build if any of these is dropped.
  "Arrows/skip-left-line",          // angle-double-left
  "Document/file-copy-line",        // copy
  "Document/clipboard-line",        // (used by the clipboard action)
  "Editor/link",                    // link
  "Editor/link-unlink",             // link-unlink
  "System/close-line",              // times
  "System/download-line",           // download
  "System/information-line",        // info, info-circle
  "System/settings-3-line",         // cog
  "System/subtract-line",           // minus
  "Weather/moon-line",              // moon
  "Weather/sun-line"                // sun
]

const config = {
  dest: "app/assets/images/laiss_cms",
  mode: {
    symbol: {
      dest: "",
      sprite: "icons-sprite.svg"
    }
  },
  shape: {
    id: {
      generator: (name) => {
        const id = name.replace(".svg", "")
        return `ri-${id}`
      }
    }
  }
}

const spriter = new SVGSpriter(config)

consola.start(`Building svg sprite of ${icons.length} icons`)

// The icon element appends `-line` to a name by default (`icon-style` can override
// it). Some remixicon files have no `-line` counterpart — `translate-2` is one — so
// the element asked for `ri-translate-2-line`, which did not exist, and the icon
// rendered as an empty box. Rather than special-case that icon in a template, emit
// the `-line` alias alongside any icon whose name does not already end in `-line`.
//
// This keeps the naming convention the element relies on intact for every icon.
icons.forEach((icon) => {
  const name = icon.replace(/^.+\/(.+)$/, "$1")
  consola.info(`Adding ${name}.svg`)

  const source = path.resolve(`node_modules/remixicon/icons/${icon}.svg`)
  if (!fs.existsSync(source)) {
    consola.error(
      `Missing icon source: ${icon}.svg\n` +
        `Listed in bundles/remixicon.mjs but not present in node_modules/remixicon/icons/.`
    )
    process.exit(1)
  }
  const contents = fs.readFileSync(source, "utf-8")
  spriter.add(source, `${name}.svg`, contents)

  // svg-sprite requires the file name to be the local part of the source path, so an
  // alias has to be written to a real file first.
  const needsAlias =
    !name.endsWith("-line") &&
    !name.endsWith("-fill") &&
    !icons.some((other) => other.endsWith(`/${name}-line`))

  if (needsAlias) {
    const aliasPath = path.resolve(`node_modules/remixicon/icons/${name}-line.svg`)
    if (!fs.existsSync(aliasPath)) fs.writeFileSync(aliasPath, contents)
    consola.info(`  + ${name}-line.svg (alias)`)
    spriter.add(aliasPath, `${name}-line.svg`, contents)
  }
})

// Names referenced anywhere in the admin (templates, components, helpers, JS) are
// requested as `ri-<name><style>`, where style defaults to `-line`. If the sprite has
// no matching symbol the browser draws an empty box and nothing complains — which is
// exactly how `ri-translate-2-line` shipped broken. This check turns that silence
// into a build failure.
const referencedIconNames = () => {
  const roots = ["app/views", "app/components", "app/helpers", "app/javascript"]
  const names = new Set()
  const patterns = [
    /render_icon[( ]+["':]([a-z0-9-]+)/g,
    /<laiss-cms-icon[^>]*name="([a-z0-9-]+)"/g,
    /icon:\s*["']([a-z0-9-]+)["']/g
  ]

  const walk = (dir) => {
    if (!fs.existsSync(dir)) return
    for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
      const full = path.join(dir, entry.name)
      if (entry.isDirectory()) {
        walk(full)
        continue
      }
      if (!/\.(erb|rb|js)$/.test(entry.name)) continue
      const text = fs.readFileSync(full, "utf-8")
      for (const pattern of patterns) {
        for (const match of text.matchAll(pattern)) names.add(match[1])
      }
    }
  }

  roots.forEach(walk)
  return names
}

const verifySprite = (spritePath) => {
  const sprite = fs.readFileSync(spritePath, "utf-8")
  const ids = new Set([...sprite.matchAll(/<symbol[^>]*\bid="([^"]+)"/g)].map((m) => m[1]))
  const missing = []

  // Names used in the app that intentionally map to a differently named remixicon
  // symbol. Keeping this table explicit means the mapping is reviewable, and the
  // guard below still fails for anything not listed.
  const legacyAliases = {
    "angle-double-left": "skip-left",
    cog: "settings-3",
    copy: "file-copy",
    "info": "information",
    "info-circle": "information",
    minus: "subtract",
    times: "close"
  }

  for (const rawName of referencedIconNames()) {
    const name = legacyAliases[rawName] || rawName
    // The element appends `-line` unless `icon-style` says otherwise; accept any
    // variant the sprite actually carries.
    const candidates = [`ri-${name}-line`, `ri-${name}`, `ri-${name}-fill`]
    if (!candidates.some((id) => ids.has(id))) missing.push(rawName)
  }

  if (missing.length) {
    consola.error(
      `Icons referenced in the app but absent from the sprite:\n` +
        missing.map((name) => `  - ${name} (tried ri-${name}-line, ri-${name}, ri-${name}-fill)`).join("\n") +
        `\n\nAdd them to the \`icons\` list in bundles/remixicon.mjs. An icon missing here\n` +
        `renders as an empty box in the admin, silently.`
    )
    process.exit(1)
  }

  consola.success(`Verified ${ids.size} sprite symbols cover every referenced icon`)
}

spriter.compile((error, result, _data) => {
  if (error) {
    consola.error(error)
    process.exit(1)
  }

  for (const type of Object.values(result.symbol)) {
    fs.mkdirSync(path.dirname(type.path), { recursive: true })
    consola.success(`Writing ${type.path}`)
    fs.writeFileSync(type.path, type.contents)
    verifySprite(type.path)
  }
})
