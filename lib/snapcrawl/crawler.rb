require 'fileutils'

module Snapcrawl
  class Crawler
    using StringRefinements

    attr_reader :url, :name_template, :folder,
      :depth, :width, :height, :selector, :age

    def initialize(url, name_template: nil, folder: nil, depth: nil, 
      width: nil, height: nil, selector: nil, age: nil, exclude_urls: nil)

      @url = url
      @name_template = name_template || '%{url}'
      @folder = folder || 'snaps'
      @depth = depth || 0
      @width = width || 1280
      @height = height || 0
      @selector = selector
      @age = age || 86400
      @exclude_urls = exclude_urls
    end

    def crawl(&block)
      Dependencies.verify

      todo[url] = Page.new url
      options = { width: width, height: height, selector: selector }
     
      process_todo options, &block while todo.any?
    end

    def process_todo(options, &block)
      url, page = todo.shift
      yield :start, page: page if block_given?

      done.push url

      success = process_page page, options, &block
      return unless success

      if page.depth < depth
        warnings = page.warnings

        if warnings and block_given?
          warnings.each do |warning|
            yield warning[:link], :warning, warning[:message]
          end
        end

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
        yield :http_error, 
          page: page, 
          code: page.http_response.code,
          message: page.http_response.message.strip

        return false
      end

      if file_fresh? outfile
        yield :cached, page: page if block_given?
      else
        page.save_screenshot outfile, options
        yield :snap, page: page if block_given?
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
