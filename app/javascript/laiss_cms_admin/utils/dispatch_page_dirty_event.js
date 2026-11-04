export function dispatchPageDirtyEvent(data) {
  document.dispatchEvent(
    new CustomEvent("laiss_cms:page-dirty", {
      detail: { tooltip: data.publishButtonTooltip }
    })
  )
}
