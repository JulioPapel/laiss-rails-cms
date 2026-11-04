import { readJSONScript } from "laiss_cms_admin/utils/json_script"

describe("readJSONScript", () => {
  beforeEach(() => {
    document.body.innerHTML = `
      <script type="application/json" id="laiss_cms_test_data">
        {"foo":"bar"}
      </script>
    `
  })

  it("returns the parsed content of the script tag", () => {
    expect(readJSONScript("laiss_cms_test_data")).toEqual({ foo: "bar" })
  })

  it("returns undefined if no script tag with that id exists", () => {
    expect(readJSONScript("not_there")).toBeUndefined()
  })
})
