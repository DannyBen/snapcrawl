require 'sting'
require 'fileutils'

module Snapcrawl
  class Config < Sting
    class << self
      def load(file = nil)
        reset!
        push defaults
        
        return unless file

        file = "#{file}.yml" unless file =~ /\.ya?ml$/

        if File.exist? file
          push file
        else
          create_config file
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

      def create_config(file)
        $logger.debug "creating config file %{green}#{file}%{reset}"
        content = File.read config_template
        dir = File.dirname file
        FileUtils.mkdir_p dir
        File.write file, content
      end

      def config_template
        File.expand_path 'templates/config.yml', __dir__
      end

    end
  end
end
