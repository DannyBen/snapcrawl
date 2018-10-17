require 'colsole'
require 'docopt'
require 'fileutils'
require 'nokogiri'
require 'open-uri'
require 'ostruct'
require 'pstore'
require 'webshot'

module Snapcrawl
  include Colsole

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
        execute Docopt::docopt(doc, argv: args)
      rescue Docopt::Exit => e
        puts e.message
      end
    end

    def execute(args)
      return show_version if args['--version']
      crawl args['<url>'].dup, opts_from_args(args)
    end

    def clear_cache
      FileUtils.rm @storefile if File.exist? @storefile
    end

    private

    def crawl(url, opts={})
      defaults = {
        width: 1280,
        height: 0,
        depth: 1,
        age: 86400,
        dir: 'snaps',
        base: url, 
      }
      urls = [protocolize(url)]

      @opts = OpenStruct.new defaults.merge(opts)

      make_screenshot_dir @opts.dir

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

      fetch_opts = @opts.selector ? { selector: @opts.selector, full: false } : {}

      webshot.capture url, image_path, fetch_opts do |magick|
        magick.combine_options do |c|
          c.background "white"
          c.gravity 'north'
          c.quality 100
          c.extent @opts.height > 0 ? "#{@opts.width}x#{@opts.height}" : "#{@opts.width}x"
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
        doc = Nokogiri::HTML open url
        links = doc.css('a')
        links = normalize_links links
        @store.transaction { @store[url] = links }
        say "done"
      rescue OpenURI::HTTPError => e
        links = []
        say "!txtred!FAILED"
        say "!txtred!  !    HTTP Error: #{e.message} at #{url}"
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
      "#{@opts.dir}/#{handelize(url)}.png"
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

      links.each_with_index do |link|
        link = link.attribute('href').to_s

        # Remove #hash
        link.gsub!(/#.+$/, '')
        next if link.empty?

        # Remove links to specific extensions and protocols
        next if link =~ /\.(#{extensions})(\?.*)?$/
        next if link =~ /^(#{beginnings})/
        
        # Add the base domain to relative URLs
        link = link =~ /^http/ ? link : "#{@opts.base}#{link}" 
        link = "http://#{link}" unless link =~ /^http/

        # Keep only links in our base domain
        next unless link.include? @opts.base

        links_array << link
      end

      links_array.uniq
    end

    def show_version
      puts VERSION
    end

    def doc
      @doc ||= File.read template 'docopt.txt'
    end

    def template(file)
      File.expand_path("../templates/#{file}", __FILE__)
    end

    def opts_from_args(args)
      opts = {}
      %w[folder selector only].each do |opt|
        opts[opt.to_sym] = args["--#{opt}"] if args["--#{opt}"]
      end

      %w[age depth width height].each do |opt|
        opts[opt.to_sym] = args["--#{opt}"].to_i if args["--#{opt}"]
      end

      opts
    end

    def webshot
      Webshot::Screenshot.instance
    end
  end
end
