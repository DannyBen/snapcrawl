require 'fileutils'

module Snapcrawl
  class Crawler
    include Logging
    using StringRefinements

    attr_reader :url, :name_template, :folder,
      :depth, :width, :height, :selector, :age

    def initialize(url, options = nil)
      options ||= {}

      @url = url
      @name_template = options[:name_template] || '%{url}'
      @folder = options[:folder] || 'snaps'
      @depth = options[:depth] || 0
      @width = options[:width] || 1280
      @height = options[:height] || 0
      @selector = options[:selector]
      @age = options[:age] || 86400
      @exclude_urls = options[:exclude_urls]
    end

    def crawl
      Dependencies.verify

      todo[url] = Page.new url
      options = { width: width, height: height, selector: selector }
     
      process_todo options while todo.any?
    end

    def process_todo(options)
      url, page = todo.shift
      logger.info "processing page: %{purple}%{underlined}#{page.path}%{reset}, depth: #{page.depth}"

      done.push url

      success = process_page page, options
      return unless success

      if page.depth < depth
        register_sub_pages page.pages
      end
    end

  private

    def register_sub_pages(pages)
      pages.each do |sub_page|
        next if todo.has_key?(sub_page) or done.include?(sub_page)
        todo[sub_page.url] = sub_page
      end
    end

    def process_page(page, options)
      outfile = "#{folder}/#{name_template}.png" % { url: page.url.to_slug }
      if !page.valid?
        logger.warn "page: #{page.path}, code: #{page.http_response.code}, message: #{page.http_response.message.strip}"
        return false
      end

      if file_fresh? outfile
        logger.info "screenshot for #{page.path} already exists"
      else
        logger.info "%{bold}capturing screenshot for #{page.path}%{reset}"
        page.save_screenshot outfile, options
      end

      true
    end

    def file_fresh?(file)
      age > 0 and File.exist?(file) and file_age(file) < age
    end

    def file_age(file)
      (Time.now - File.stat(file).mtime).to_i
    end

    def todo
      @todo ||= {}
    end

    def done
      @done ||= []
    end

  end
end
