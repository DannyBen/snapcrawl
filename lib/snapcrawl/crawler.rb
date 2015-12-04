require 'ostruct'
require 'fileutils'
require 'screencap'
require 'nokogiri'
require 'open-uri'
require 'pstore'

module Snapcrawl
  class Crawler
    def self.instance
      @@instance ||= self.new
    end

    def initialize
      @storefile  = "snapcrawl.pstore"
      @store      = PStore.new(@storefile)
      @done       = []
    end

    def crawl(url, opts)
      defaults = {
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
        say "\n!txtgrn!Processing #{url}"
        snap url
        new_urls += extract_urls_from url
      end
      new_urls
    end

    # Take a screenshot of a URL, unless we already did so recently
    def snap(url)
      file = image_path_for(url)
      if file_fresh? file
        say "#{'Snap:'.rjust 10} Skipping. File exists and seems fresh"
      else
        snap!(url)
      end
    end

    # Take a screenshot of the URL, even if file exists
    def snap!(url)
      say "!txtblu!#{'Snap!'.rjust 10}!txtrst! Snapping picture... "

      f = Screencap::Fetcher.new url
      fetch_opts = {}
      fetch_opts[:output] = image_path_for(url)
      fetch_opts[:width]  = @opts.width
      fetch_opts[:height] = @opts.height if @opts.height
      # :height => 768,
      # :div => '.header', # selector for a specific element to take screenshot of
      # :top => 0, :left => 0, :width => 100, :height => 100 # dimensions for a specific area

      screenshot = f.fetch fetch_opts 
      say "done"
    end

    def extract_urls_from(url)
      cached = nil
      @store.transaction { cached = @store[url] }
      if cached
        say "#{'Crawl:'.rjust 10} Page was cached. Reading subsequent URLs from cache"
        return cached
      else
        return extract_urls_from! url
      end
    end

    def extract_urls_from!(url)
      say "!txtblu!#{'Crawl!'.rjust 10}!txtrst! Extracting links... "

      begin
        doc = Nokogiri::HTML open url
        links = doc.css('a')
        links = normalize_links links
        @store.transaction { @store[url] = links }
        say "done"
      rescue OpenURI::HTTPError => e
        links = []
        say "!txtred!ERROR"
        STDERR.puts "---------> HTTP Error: #{e.message} at #{url}"
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

    # Return proper image path for a URL
    def image_path_for(url)
      "#{@dir}/#{handelize(url)}.png"
    end

    # Add protocol to a URL if neeed
    def protocolize(url)
      url =~ /^http/ ? url : "http://#{url}"
    end

    # Return true if the file exists and is not too old
    def file_fresh?(file)
      File.exist?(file) and file_age(file) < @snap_age
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
  end
end