require 'addressable/uri'
require 'fileutils'
require 'httparty'
require 'lightly'
require 'nokogiri'

module Snapcrawl
  class Page
    using StringRefinements

    attr_reader :url, :depth

    EXTENSION_BLACKLIST = "png|gif|jpg|pdf|zip"
    PROTOCOL_BLACKLIST = "mailto|tel"

    def initialize(url, depth: 0)
      @url, @depth = url.protocolize, depth
    end

    def valid?
      http_response&.success?
    end

    def site
      @site ||= Addressable::URI.parse(url).site
    end

    def path
      @path ||= Addressable::URI.parse(url).request_uri
    end

    def links
      return nil unless valid?
      doc = Nokogiri::HTML http_response.body
      normalize_links doc.css('a')
    end

    def pages
      return nil unless valid?
      links.map { |link| Page.new link, depth: depth+1 }
    end

    def save_screenshot(outfile)
      return false unless valid?
      Screenshot.new(url).save "#{outfile}"
    end

    def filename_variables
      { url: url.to_slug, depth: depth }
    end

  private

    def http_response
      @http_response ||= http_response!
    end

    def http_response!
      response = cache.get(url) { HTTParty.get url, httparty_options }

      if !response.success?
        $logger.warn "http error on !undpur!#{url}!txtrst!, code: !txtylw!#{response.code}!txtrst!, message: #{response.message.strip}"
      end

      response

    rescue => e
      $logger.error "http error on !undpur!#{url}!txtrst! - !txtred!#{e.class}!txtrst!: #{e.message}"
      nil

    end

    def httparty_options
      Config.skip_ssl_verification ? { verify: false } : {}
    end

    def normalize_links(links)
      result = []

      links.each do |link|
        valid_link = normalize_link link
        result << valid_link if valid_link
      end

      result.uniq
    end

    def normalize_link(link)
      link = link.attribute('href').to_s.dup

      # Remove #hash
      link.gsub!(/#.+$/, '')
      return nil if link.empty?

      # Remove links to specific extensions and protocols
      return nil if link =~ /\.(#{EXTENSION_BLACKLIST})(\?.*)?$/
      return nil if link =~ /^(#{PROTOCOL_BLACKLIST}):/

      # Strip spaces
      link.strip!

      # Convert relative links to absolute
      begin
        link = Addressable::URI.join(url, link).to_s.dup
      rescue => e
        $logger.warn "!txtred!#{e.class}!txtrst!: #{e.message} on #{path} (link: #{link})"
        return nil
      end

      # Keep only links in our base domain
      return nil unless link.include? site
      link
    end

    def cache
      Lightly.new life: Config.cache_life
    end
  end
end
