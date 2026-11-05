# frozen_string_literal: true

module LaissCms
  module TestSupport
    # Capture a screenshot at a viewport you have actually verified.
    #
    # WHY THIS EXISTS
    #
    # Every mobile screenshot in this project before 2026-11-05 was 500px wide while
    # named 375. `driver.manage.window.resize_to(375, 812)` was called, Selenium
    # accepted it, and the browser kept its own minimum window width. Nothing failed;
    # the files were reviewed and cited for weeks.
    #
    # There are two ways to get a real 375, and only one of them is reliable here:
    #
    #   * `resize_to` — does NOT work for narrow widths in this setup. The system specs
    #     run headless Firefox, which enforces a minimum window width, and the result
    #     silently reports 500.
    #   * Chrome `add_emulation(device_metrics: ...)` — works, because the metrics are
    #     applied by the browser before the page loads, so media queries fire correctly.
    #
    # `capture` refuses to write a file whose name disagrees with its pixels, and
    # refuses to write one at all if the live viewport is not the width that was asked
    # for. A screenshot that cannot be trusted is worse than no screenshot.
    module ViewportScreenshots
      # Boot a Chrome session with an emulated viewport.
      #
      #   before { driven_with_viewport(375, 812) }
      #
      # The Capybara driver persists across examples once set, so this must be called
      # per-example in a `before`, and it always installs a fresh session rather than
      # assuming the previous one was the size it claimed.
      def driven_with_viewport(width, height)
        # Register a driver named after its viewport and use it. `driven_by` with only a
        # browser reuses whatever driver is already registered under that name, so two
        # examples at different sizes silently shared one session — measured: a 375
        # example reported 1440.
        name = :"viewport_#{width}x#{height}"
        unless Capybara.drivers.key?(name)
          Capybara.register_driver(name) do |app|
            options = Selenium::WebDriver::Chrome::Options.new
            options.add_argument("--headless=new")
            options.add_argument("--no-sandbox")
            options.add_argument("--disable-dev-shm-usage")
            options.add_argument("--force-device-scale-factor=1")
            # Emulation, not resize. The browser applies these metrics before the page
            # loads, so media queries see the emulated width. `resize_to` is what
            # silently produced 500px for every "375" screenshot in this project.
            options.add_emulation(device_metrics: {width: width, height: height, pixel_ratio: 1})
            Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
          end
        end

        driven_by(name)
      end

      # Save a screenshot and prove it is what it claims to be.
      #
      #   capture("/tmp/dashboard-375.png", width: 375)
      #
      # Raises if the live viewport width is not `width`, or if the written file's pixel
      # width differs from `width`.
      def capture(path, width:, height: nil)
        raise ArgumentError, "capture needs the width it was rendered at" if width.nil?

        actual_width = page.evaluate_script("window.innerWidth")
        if actual_width != width
          raise "Refusing to write #{path}: asked for a #{width}px viewport, the browser " \
                "reports #{actual_width}px. The driver silently ignored the resize. For " \
                "widths under 500 use driven_with_viewport, which emulates rather than resizes."
        end

        page.save_screenshot(path)

        file_width, file_height = png_dimensions(path)
        raise "Wrote #{path} but it is #{file_width}px wide, not #{width}px." if file_width != width
        raise "Wrote #{path} but it is #{file_height}px tall, not #{height}px." if height && file_height != height

        [file_width, file_height]
      end

      private

      def png_dimensions(path)
        header = File.binread(path, 24)
        raise "#{path} is not a PNG" unless header && header.byteslice(0, 8) == "\x89PNG\r\n\x1a\n".b

        header.byteslice(16, 8).unpack("N2")
      end
    end
  end
end
