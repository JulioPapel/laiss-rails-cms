# Third-party notices

This project includes work from other projects. Their licences require the notices
below to be retained. Nothing here affects the licence of this project's own code,
which is BSD-3-Clause — see `LICENSE`.

---

## Focus Bootstrap — admin theme

The admin's design, layout and stylesheet structure are derived from Focus Bootstrap.

```
MIT License

Copyright (c) 2016 - Present, Themefisher

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

Source: https://github.com/themefisher/focus-bootstrap

### Not included from that distribution

Two parts of Focus Bootstrap are deliberately **not** used here:

- **Helvetica Neue**, which that theme bundles as a webfont. It is a commercial
  typeface with no redistribution licence. The admin uses Inter instead (below).
- **Demonstration images.** Themefisher's README states it has no permission to share
  those images. None are included.

The theme's six bundled icon families and its jQuery-era plugin libraries are also not
included; see the icon note below.

---

## Bootstrap

```
The MIT License (MIT)

Copyright (c) 2011-2019 The Bootstrap Authors
Copyright (c) 2011-2019 Twitter, Inc.
```

Source: https://github.com/twbs/bootstrap — used as SCSS only. Bootstrap's JavaScript
is **not** loaded; the admin's interactions are custom elements.

---

## Bootstrap Icons

```
The MIT License (MIT)

Copyright (c) 2019-2024 The Bootstrap Authors
```

Source: https://github.com/twbs/icons — the single icon collection used by the admin,
vendored as a webfont at build time.

---

## Inter

```
Copyright (c) 2016 The Inter Project Authors (https://github.com/rsms/inter)

This Font Software is licensed under the SIL Open Font License, Version 1.1.
This license is available with a FAQ at: https://openfontlicense.org
```

Self-hosted from `app/assets/fonts/laiss_cms/` as a variable font. No CDN request.

---

## Other libraries in the admin bundle

The admin's JavaScript is built from packages declared in `package.json`, each
carrying its own licence in `node_modules/<package>/LICENSE`. They are not vendored
into this repository as source: they are installed from npm and bundled at build time.
The ones that ship in the admin bundle are Shoelace, Turbo, Cropper.js, Flatpickr,
Tom Select, SortableJS, Clipboard.js, Keymaster and Floating UI.

---

## Photographs

Any photograph in the admin comes from Unsplash under the Unsplash License
(https://unsplash.com/license) and is credited here with its author and source.

<!-- No photographs are currently used. If one is added, it must be recorded here
     with: subject, photographer, photo URL, and the licence reference. -->
