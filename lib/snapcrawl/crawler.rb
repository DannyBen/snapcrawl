require 'fileutils'

module Snapcrawl
  class Crawler
    using StringRefinements

    attr_reader :url

    def initialize(url)
      $logger.debug "initializing crawler with g`#{url}`"

      config_for_display = Config.settings.dup
      config_for_display['name_template'] = '%%{url}'

      $logger.debug "config #{config_for_display}"
      @url = url
    end

    def crawl
      Dependencies.verify
      todo[url] = Page.new url
      process_todo while todo.any?
    end

  private

    def process_todo
      $logger.debug "processing queue: g`#{todo.count} remaining`"

      url, page = todo.shift
      done.push url

      return unless process_page page

      register_sub_pages page.pages if page.depth < Config.depth
    end

    def register_sub_pages(pages)
      pages.each do |sub_page|
        next if todo.has_key?(sub_page) || done.include?(sub_page)

        if Config.url_whitelist && sub_page.path !~ (/#{Config.url_whitelist}/)
          $logger.debug "ignoring mu`#{sub_page.url}`, reason: whitelist"
          next
        end

        if Config.url_blacklist && sub_page.path =~ (/#{Config.url_blacklist}/)
          $logger.debug "ignoring mu`#{sub_page.url}`, reason: blacklist"
          next
        end

        todo[sub_page.url] = sub_page
      end
    end

    def process_page(page)
      outfile = "#{Config.snaps_dir}/#{Config.name_template}.png" % { url: page.url.to_slug }

      $logger.info "processing mu`#{page.url}`, depth: #{page.depth}"

      unless page.valid?
        $logger.debug "page #{page.path} is invalid, aborting process"
        return false
      end

      if file_fresh? outfile
        $logger.info "screenshot for #{page.path} already exists"
      else
        $logger.info "gb`capturing screenshot for #{page.path}`"
        save_screenshot page, outfile
      end

      true
    end

    def save_screenshot(page, outfile)
      page.save_screenshot outfile
    rescue => e
      $logger.error "screenshot error on mu`#{page.path}` - r`#{e.class}`: #{e.message}"
    end

    def file_fresh?(file)
      Config.cache_life.positive? and File.exist?(file) and file_age(file) < Config.cache_life
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
