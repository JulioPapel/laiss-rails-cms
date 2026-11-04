// Run this before all tests that needs translations available
export const setupTranslations = () => {
  window.LaissCms.translations = {
    allowed_chars: "of %{count} chars",
    help: "Help",
    formats: {
      date: "Y-m-d"
    }
  }
}
