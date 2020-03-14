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

      fetch_opts = { allowed_status_codes: [404, 401, 403] }
      if Config.selector
        fetch_opts[:selector] = Config.selector
        fetch_opts[:full] = false
      end

      webshot_capture url, outfile, fetch_opts
    end

  private

    def webshot_capture(url, image_path, fetch_opts)
      webshot_capture! url, image_path, fetch_opts
    rescue => e
      raise ScreenshotError, "#{e.class} #{e.message}"
    end

    def webshot_capture!(url, image_path, fetch_opts)
      hide_output do
        webshot.capture url, image_path, fetch_opts do |magick|
          magick.combine_options do |c|
            c.background "white"
            c.gravity 'north'
            c.quality 100
            c.extent Config.height > 0 ? "#{Config.width}x#{Config.height}" : "#{Config.width}x"
          end
        end
      end
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
