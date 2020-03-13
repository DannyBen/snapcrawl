require 'fileutils'

module Snapcrawl
  class Crawler
    using StringRefinements

    attr_reader :url, :name_template, :folder,
      :depth, :width, :height, :selector, :age

    def initialize(url, name_template: '%{url}', folder: 'snaps', depth: 0, 
      width: 1280, height: 0, selector: nil, age: 86400, exclude_urls: nil)

      @url, @name_template, @folder = url, name_template, folder
      @depth, @height, @width, @selector = depth, height, width, selector
    end

    def crawl(&block)
      todo[url] = Page.new url
      options = { width: width, height: height, selector: selector }
     
      process_todo options, &block while todo.any?
    end

    def process_todo(options)
      url, page = todo.shift
      yield :start, page: page if block_given?
      
      outfile = "#{folder}/#{name_template}.png" % { url: page.url.to_slug }

      done.push url
      
      if page.valid?
        page.save_screenshot outfile, options
        yield :snap, page: page if block_given?
      else
        yield :http_error, 
          page: page, 
          code: page.http_response.code,
          message: page.http_response.message.strip
        return
      end

      if page.depth < depth
        pages = page.pages
        warnings = page.warnings

        if warnings and block_given?
          warnings.each do |warning|
            yield warning[:link], :warning, warning[:message]
          end
        end

        pages.each do |sub_page|
          next if todo.has_key?(sub_page) or done.include?(sub_page)
          todo[sub_page.url] = sub_page
        end
      end
    end

  private

    def todo
      @todo ||= {}
    end

    def done
      @done ||= []
    end

  end
end
