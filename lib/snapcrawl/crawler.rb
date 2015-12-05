require 'colsole'
require 'docopt'
require 'fileutils'
require 'nokogiri'
require 'open-uri'
require 'ostruct'
require 'pstore'
require 'screencap'

module Snapcrawl
  include Colsole

  class Crawler
    def self.instance
      @@instance ||= self.new
    end

    def initialize
      @storefile  = "snapcrawl.pstore"
      @store      = PStore.new(@storefile)
      @done       = []
    end

    def handle(args)
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

    private    

    def crawl_and_snap(urls)
      new_urls = []
      urls.each do |url|
        next if @done.include? url
        @done << url
        say "\n!txtgrn!-----> Visit: #{url}"
        snap url
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

      f = Screencap::Fetcher.new url
      fetch_opts = {}
      fetch_opts[:output] = image_path_for(url)
      fetch_opts[:width]  = @opts.width
      fetch_opts[:height] = @opts.height if @opts.height > 0
      fetch_opts[:div]    = @opts.selector if @opts.selector
      # :top => 0, :left => 0, :width => 100, :height => 100 # dimensions for a specific area

      screenshot = f.fetch fetch_opts 
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
        say! "!txtred!  !    HTTP Error: #{e.message} at #{url}"
      end
      links
    end

    # mkdir the screenshots folder, if needed
    def make_screenshot_dir(dir)
      Dir.exists? dir or FileUtils.mkdir_p dir
    end

    # Convert any string to a proper handle
    def handelize(str)
      str.downcase.gsub /[^a-z0-9]+/, '-'
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
      File.exist?(file) and file_age(file) < @opts.age
    end

    # Return file age in seconds
    def file_age(file)
      (Time.now - File.stat(file).mtime).to_i
    end

    # Process an array of links and return a better one
    def normalize_links(links)
      # Remove the #hash part from all links
      links = links.map {|link| link.attribute('href').to_s.gsub(/#.+$/, '')}

      # Make unique and remove empties
      links = links.uniq.reject {|link| link.empty?}

      # Remove links to images and other files
      extensions = "png|gif|jpg|pdf|zip"
      links = links.reject {|link| link =~ /\.(#{extensions})(\?.*)?$/}

      # Remove mailto, tel links
      beginnings = "mailto|tel"
      links = links.reject {|link| link =~ /^(#{beginnings})/}

      # Add the base domain to relative URLs
      links = links.map {|link| link =~ /^http/ ? link : "http://#{@base}#{link}"}

      # Keep only links in our base domain
      links = links.select {|link| link =~ /https?:\/\/#{@base}.*/}

      links
    end

    def show_version
      puts VERSION
    end

    def doc
      return @doc if @doc 
      @doc = File.read template 'docopt.txt'
    end

    def template(file)
      File.expand_path("../templates/#{file}", __FILE__)
    end

    def opts_from_args(args)
      opts = {}
      %w[folder selector].each do |opt|
        opts[opt.to_sym] = args["--#{opt}"] if args["--#{opt}"]
      end

      %w[age depth width height].each do |opt|
        opts[opt.to_sym] = args["--#{opt}"].to_i if args["--#{opt}"]
      end

      opts
    end
  end
end