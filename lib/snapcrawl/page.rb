require 'addressable/uri'
require 'fileutils'
require 'httparty'
require 'lightly'
require 'nokogiri'

module Snapcrawl
  class Page
    include Logging
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

    def pages
      return nil unless valid?
      links.map { |link| Page.new link, depth: depth+1 }
    end

    def links
      return nil unless valid?
      doc = Nokogiri::HTML http_response.body
      normalize_links doc.css('a')
    end

    def site
      @site ||= Addressable::URI.parse(url).site
    end

    def path
      @path ||= Addressable::URI.parse(url).request_uri
    end

    def save_screenshot(outfile)
      return false unless valid?
      Screenshot.new(url).save "#{outfile}"
    end

  private

    def http_response
      @http_response ||= http_response!
    end

    def http_response!
      response = cache.get(url) { HTTParty.get url }

      if !response.success?
        logger.warn "http error on %{purple}%{underlined}#{url}%{reset}, code: %{yellow}#{response.code}%{reset}, message: #{response.message.strip}"
      end

      response

    rescue => e
      logger.error "http error on %{purple}%{underlined}#{url}%{reset} - %{red}#{e.class}%{reset}: #{e.message}"
      nil

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
        logger.warn "%{red}#{e.class}%{reset}: #{e.message} on #{path} (link: #{link})"
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
