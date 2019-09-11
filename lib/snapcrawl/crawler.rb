require 'colsole'
require 'docopt'
require 'fileutils'
require 'httparty'
require 'nokogiri'
require 'ostruct'
require 'pstore'
require 'uri'
require 'webshot'

module Snapcrawl
  include Colsole

  class MissingPhantomJS < StandardError; end
  class MissingImageMagick < StandardError; end

  class Crawler
    def self.instance
      @@instance ||= self.new
    end

    def initialize
      @storefile  = "snapcrawl.pstore"
      @store      = PStore.new(@storefile)
    end

    def handle(args)
      @done = []
      begin
        execute Docopt::docopt(doc, version: VERSION, argv: args)
      rescue Docopt::Exit => e
        puts e.message
      end
    end

    def execute(args)
      raise MissingPhantomJS unless command_exist? "phantomjs"
      raise MissingImageMagick unless command_exist? "convert"
      crawl args['URL'].dup, opts_from_args(args)
    end

    def clear_cache
      FileUtils.rm @storefile if File.exist? @storefile
    end

    private

    def crawl(url, opts={})
      url = protocolize url
      defaults = {
        width: 1280,
        height: 0,
        depth: 1,
        age: 86400,
        folder: 'snaps',
        name: '%{url}',
        base: url,
      }
      urls = [url]

      @opts = OpenStruct.new defaults.merge(opts)

      make_screenshot_dir @opts.folder

      @opts.depth.times do
        urls = crawl_and_snap urls
      end
    end

    def crawl_and_snap(urls)
      new_urls = []
      urls.each do |url|
        next if @done.include? url
        @done << url
        say "\n!txtgrn!-----> Visit: #{url}"
        if @opts.only and url !~ /#{@opts.only}/
          say "       Snap:  Skipping. Does not match regex"
        else
          snap url
        end
        new_urls += extract_urls_from url
      end
      new_urls
    end

    # Take a screenshot of a URL, unless we already did so recently
    def snap(url)
      file = image_path_for(url)
      if file_fresh? file
        say "       Snap:  Skipping. File exists and seems fresh"
      else
        snap!(url)
      end
    end

    # Take a screenshot of the URL, even if file exists
    def snap!(url)
      say "       !txtblu!Snap!!txtrst!  Snapping picture... "
      image_path = image_path_for url

      fetch_opts = { allowed_status_codes: [404, 401, 403] }
      if @opts.selector
        fetch_opts[:selector] = @opts.selector
        fetch_opts[:full] = false
      end

      hide_output do
        webshot.capture url, image_path, fetch_opts do |magick|
          magick.combine_options do |c|
            c.background "white"
            c.gravity 'north'
            c.quality 100
            c.extent @opts.height > 0 ? "#{@opts.width}x#{@opts.height}" : "#{@opts.width}x"
          end
        end
      end      

      say "done"
    end

    def extract_urls_from(url)
      cached = nil
      @store.transaction { cached = @store[url] }
      if cached
        say "       Crawl: Page was cached. Reading subsequent URLs from cache"
        return cached
      else
        return extract_urls_from! url
      end
    end

    def extract_urls_from!(url)
      say "       !txtblu!Crawl!!txtrst! Extracting links... "

      begin
        response = HTTParty.get url
        if response.success?
          doc = Nokogiri::HTML response.body
          links = doc.css('a')
          links, warnings = normalize_links links
          @store.transaction { @store[url] = links }
          say "done"
          warnings.each do |warning|
            say "!txtylw!       Warn:  #{warning[:link]}"
            say word_wrap "              #{warning[:message]}"
          end
        else
          links = []
          say "!txtred!FAILED"
          say "!txtred!  !    HTTP Error: #{response.code} #{response.message.strip} at #{url}"
        end
      end
      links
    end

    # mkdir the screenshots folder, if needed
    def make_screenshot_dir(dir)
      Dir.exist? dir or FileUtils.mkdir_p dir
    end

    # Convert any string to a proper handle
    def handelize(str)
      str.downcase.gsub(/[^a-z0-9]+/, '-')
    end

    # Return proper image path for a UR
    def image_path_for(url)
      "#{@opts.folder}/#{@opts.name}.png" % { url: handelize(url) }
    end

    # Add protocol to a URL if neeed
    def protocolize(url)
      url =~ /^http/ ? url : "http://#{url}"
    end

    # Return true if the file exists and is not too old
    def file_fresh?(file)
      @opts.age > 0 and File.exist?(file) and file_age(file) < @opts.age
    end

    # Return file age in seconds
    def file_age(file)
      (Time.now - File.stat(file).mtime).to_i
    end

    # Process an array of links and return a better one
    def normalize_links(links)
      extensions = "png|gif|jpg|pdf|zip"
      beginnings = "mailto|tel"

      links_array = []
      warnings = []

      links.each do |link|
        link = link.attribute('href').to_s

        # Remove #hash
        link.gsub!(/#.+$/, '')
        next if link.empty?

        # Remove links to specific extensions and protocols
        next if link =~ /\.(#{extensions})(\?.*)?$/
        next if link =~ /^(#{beginnings})/

        # Strip spaces
        link.strip!

        # Convert relative links to absolute
        begin
          link = URI.join( @opts.base, link ).to_s
        rescue URI::InvalidURIError
          escaped_link = URI.escape link
          warnings << { link: link, message: "Using escaped link: #{escaped_link}" }
          link = URI.join( @opts.base, escaped_link ).to_s
        rescue => e
          warnings << { link: link, message: "#{e.class} #{e.message}" }
          next
        end

        # Keep only links in our base domain
        next unless link.include? @opts.base

        links_array << link
      end

      [links_array.uniq, warnings]
    end

    def doc
      @doc ||= File.read template 'docopt.txt'
    end

    def template(file)
      File.expand_path("../templates/#{file}", __FILE__)
    end

    def opts_from_args(args)
      opts = {}
      %w[folder name selector only].each do |opt|
        opts[opt.to_sym] = args["--#{opt}"] if args["--#{opt}"]
      end

      %w[age depth width height].each do |opt|
        opts[opt.to_sym] = args["--#{opt}"].to_i if args["--#{opt}"]
      end

      opts
    end

    def webshot
      @webshot ||= Webshot::Screenshot.instance
    end

    # The webshot gem messes with stdout/stderr streams so we keep it in 
    # check by using this method. Also, in some sites (e.g. uown.co) it
    # prints some output to stdout, this is why we override $stdout for
    # the duration of the run.
    def hide_output
      $keep_stdout, $keep_stderr = $stdout, $stderr
      $stdout, $stderr = StringIO.new, StringIO.new
      yield
    ensure
      $stdout, $stderr = $keep_stdout, $keep_stderr
    end
  end
end
