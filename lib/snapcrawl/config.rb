require 'sting'

module Snapcrawl
  class Config < Sting
    class << self
      include Logging
      attr_accessor :logger

      def load(file = nil)
        reset!
        push defaults
        
        if file
          file = "#{file}.yml" unless file =~ /\.ya?ml$/
          if File.exist? file
            push file 
          else
            logger.debug "config file not found #{file}"
          end
        end
      end

    private

      def defaults
        {
          depth: 1,
          width: 1280,
          height: 0,
          cache_life: 86400,
          cache_dir: 'cache',
          snaps_dir: 'snaps',
          name_template: '%{url}',
          url_whitelist: nil,
          css_selector: nil,
          log_level: 1,
          log_color: 'auto',
        }
      end

    end
  end
end
