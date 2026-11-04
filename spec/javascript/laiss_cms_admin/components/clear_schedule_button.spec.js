import "laiss_cms_admin/components/clear_schedule_button"
import { renderComponent } from "./component.helper.js"

describe("laiss-cms-clear-schedule-button", () => {
  const html = `
    <form>
      <input type="datetime-local" name="public_on" value="2026-09-04T10:00">
      <input type="datetime-local" name="public_until" value="2026-09-05T10:00">
      <input type="text" name="keep_me" value="untouched">
      <button type="button" is="laiss-cms-clear-schedule-button">Clear</button>
    </form>
  `

  it("clears the datetime fields of its form on click", () => {
    const button = renderComponent("laiss-cms-clear-schedule-button", html)

    button.click()

    const values = Array.from(
      button.form.querySelectorAll('input[type="datetime-local"]')
    ).map((input) => input.value)
    expect(values).toEqual(["", ""])
  })

  it("leaves other fields alone", () => {
    const button = renderComponent("laiss-cms-clear-schedule-button", html)

    button.click()

    expect(button.form.querySelector('input[name="keep_me"]').value).toEqual(
      "untouched"
    )
  })
})
