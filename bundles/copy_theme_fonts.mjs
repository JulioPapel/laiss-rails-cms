#!/usr/bin/env node
// Copies the Bootstrap Icons webfont into the build output.
//
// focus.css references url("./fonts/bootstrap-icons.woff2") relatively, so the
// font must sit beside the stylesheet in app/assets/builds/laiss_cms/fonts/.
// Doing it here rather than by hand keeps the build reproducible: a clean clone
// runs `pnpm run build` and gets the same output, with no manual step to forget.
//
// Bootstrap Icons is MIT licensed; the notice is in THIRD-PARTY-NOTICES.md.

import { copyFile, mkdir } from "node:fs/promises"
import path from "node:path"

const from = "node_modules/bootstrap-icons/font/fonts"
const to = "app/assets/builds/laiss_cms/fonts"

await mkdir(to, { recursive: true })

for (const file of ["bootstrap-icons.woff", "bootstrap-icons.woff2"]) {
  await copyFile(path.join(from, file), path.join(to, file))
  console.log(`  ${file}`)
}
