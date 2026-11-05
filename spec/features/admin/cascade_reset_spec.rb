# frozen_string_literal: true

require "rails_helper"

# Guards the cascade root fix: the theme's universal reset must not outrank our
# component rules.
#
# The theme's base layer is `* { padding: 0 }`, imported inside the `#laiss_cms { }`
# wrapper for host safety. Sass prefixes the parent, so it emitted `#laiss_cms *` at
# specificity (1,0,0) — an id — and that beat every bare-class rule we wrote. On the
# Pages index it zeroed the padding of `button`, `input`, `select`, `.toolbar`,
# `.pagination` and `.laiss-cms-popover`, and no spec noticed because nothing was
# broken, only unstyled.
#
# The fix wraps it in `:where(#laiss_cms) *` (0,0,1). These assertions fail if anyone
# puts the plain `*` back.
RSpec.describe "The theme reset does not outrank our components", type: :system, js: true do
  include LaissCms::TestSupport::ViewportScreenshots

  before { driven_with_viewport(1440, 1000) }
  before { authorize_user(:as_admin) }

  it "keeps the reset scoped through :where()" do
    visit "/admin/pages?view=list"
    sleep 0.8

    reset = page.evaluate_script(<<~JS)
      (function () {
        var hits = [];
        for (var i = 0; i < document.styleSheets.length; i++) {
          var list;
          try { list = document.styleSheets[i].cssRules; } catch (e) { continue; }
          if (!list) continue;
          for (var j = 0; j < list.length; j++) {
            var r = list[j];
            if (!r.selectorText || !r.style) continue;
            // The computed value comes back as "0px" from the CSSOM, not "0".
            var pad = r.style.getPropertyValue("padding");
            if (pad !== "0" && pad !== "0px") continue;
            if (!/\\*/.test(r.selectorText)) continue;
            if (r.selectorText.indexOf("laiss_cms") === -1) continue;
            hits.push(r.selectorText);
          }
        }
        return hits;
      })()
    JS

    expect(reset).not_to be_empty, "no scoped universal reset was found at all"
    reset.each do |sel|
      # The load-bearing assertion: no `#laiss_cms *` form. It must go through :where(),
      # which contributes zero specificity, so our classes can still beat it.
      expect(sel).to include(":where("),
        "the theme reset is emitted as '#{sel}', which carries id specificity and beats " \
        "every bare-class rule in our component layer. Wrap it in :where()."
    end
  end

  it "lets component padding compute as declared" do
    visit "/admin/pages?view=list"
    expect(page).to have_css(".toolbar", wait: 5)
    sleep 0.8

    values = page.evaluate_script(<<~JS)
      (function () {
        function pad(sel) {
          var el = document.querySelector(sel);
          return el ? getComputedStyle(el).padding : null;
        }
        return {
          toolbar: pad(".toolbar"),
          pagination: pad(".pagination"),
          wrapper: pad(".resources-table-wrapper")
        };
      })()
    JS

    # These were all 0px while the reset won. Any zero here means the bug is back.
    expect(values["toolbar"]).to eq("12px 24px")
    expect(values["pagination"]).not_to start_with("0px 0px 0px 0px")
    expect(values["wrapper"]).to eq("8px")
  end

  it "lets form controls compute their own padding" do
    visit "/admin/settings"
    expect(page).to have_css("input[type=text]", wait: 5)
    sleep 0.8

    paddings = page.evaluate_script(<<~JS)
      (function () {
        var out = {};
        ["input[type=text]", "select"].forEach(function (s) {
          var el = document.querySelector(s);
          out[s] = el ? getComputedStyle(el).padding : null;
        });
        return out;
      })()
    JS

    expect(paddings["input[type=text]"]).not_to eq("0px")
    expect(paddings["select"]).not_to eq("0px")

    # And the control must be more than its text height.
    height = page.evaluate_script(<<~JS)
      (function () {
        var el = document.querySelector("input[type=text]");
        return el ? Math.round(el.getBoundingClientRect().height) : 0;
      })()
    JS
    expect(height).to be > 20
  end
end
