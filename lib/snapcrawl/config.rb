require 'sting'

module Snapcrawl
  class Config < Sting
    class << self
      def load(file)
        file = "#{file}.yml" unless file =~ /\.ya?ml$/

        reset!
        push defaults
        push file if File.exist? file
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
