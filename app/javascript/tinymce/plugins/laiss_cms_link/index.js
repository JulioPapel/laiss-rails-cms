tinymce.PluginManager.add("laiss_cms_link", function (editor) {
  const getAnchor = (selectedElm) => {
    return editor.dom.getParent(selectedElm, "a[href]")
  }

  const openLinkDialog = () => {
    if (LaissCms.currentDialog()) return

    let link = {}
    const anchor = getAnchor(editor.selection.getNode())
    if (anchor) {
      link = {
        url: anchor.getAttribute("href"), // avoid getting an absolute URL
        title: anchor.title,
        target: anchor.target,
        type: anchor.className
      }
    }
    const linkDialog = new LaissCms.LinkDialog(link)
    editor.focus()
    linkDialog.open().then((link) => {
      editor.execCommand("mceInsertLink", false, {
        href: link.url,
        class: link.type,
        title: link.title,
        target: link.target
      })
      editor.selection.collapse()
    })
  }

  editor.ui.registry.addToggleButton("laiss_cms_link", {
    icon: "link",
    tooltip: "Insert/edit link",
    onSetup(buttonApi) {
      const onNodeChange = () => {
        buttonApi.setActive(getAnchor(editor.selection.getNode()) !== null)
      }
      onNodeChange()
      editor.on("NodeChange", onNodeChange)
      return () => {
        editor.off("NodeChange", onNodeChange)
      }
    },
    onAction: openLinkDialog
  })

  // Replace the default link command with our own
  editor.addCommand("mceLink", openLinkDialog)
  editor.addShortcut("Meta+K", "", openLinkDialog)

  // Override the default link menu item so the contextual menu
  // (right-click) opens the LaissCms link dialog instead of TinyMCE's.
  editor.ui.registry.addMenuItem("link", {
    icon: "link",
    text: "Link...",
    shortcut: "Meta+K",
    onAction: openLinkDialog
  })
})
