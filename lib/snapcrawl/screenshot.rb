require 'webshot'

module Snapcrawl
  class Screenshot
    using StringRefinements

    attr_reader :url

    def initialize(url)
      @url = url
    end

    def save(outfile = nil)
      outfile ||= "#{url.to_slug}.png"
      webshot_capture url, outfile
    end

  private

    def webshot_capture(url, image_path)
      webshot_capture! url, image_path
    rescue => e
      raise ScreenshotError, "#{e.class} #{e.message}"
    end

    def webshot_capture!(url, image_path)
      hide_output do
        webshot.capture url, image_path, webshot_options do |magick|
          magick.combine_options do |c|
            c.background "white"
            c.gravity 'north'
            c.quality 100
            c.extent Config.height > 0 ? "#{Config.width}x#{Config.height}" : "#{Config.width}x"
          end
        end
      end
    end

    def webshot_options
      result = { allowed_status_codes: [404, 401, 403] }
      
      if Config.selector
        result[:selector] = Config.selector
        result[:full] = false
      end

      if Config.screenshot_delay
        result[:timeout] = Config.screenshot_delay
      end

      result
    end

    def webshot
      @webshot ||= Webshot::Screenshot.instance
    end

    # The webshot gem messes with stdout/stderr streams so we keep it in 
    # check by using this method. Also, in some sites (e.g. uown.co) it
    # prints some output to stdout, this is why we override $stdout for
    # the duration of the run.
    def hide_output
      keep_stdout, keep_stderr = $stdout, $stderr
      $stdout, $stderr = StringIO.new, StringIO.new
      yield
    ensure
      $stdout, $stderr = keep_stdout, keep_stderr
    end
  end
end
