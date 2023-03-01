require 'colsole'
require 'docopt'
require 'fileutils'

module Snapcrawl
  class CLI
    include Colsole
    using StringRefinements
    using PairSplit

    def call(args = [])
      execute Docopt.docopt(docopt, version: VERSION, argv: args)
    rescue Docopt::Exit => e
      puts e.message
    end

  private

    def execute(args)
      config_file = args['--config']
      Config.load config_file if config_file

      tweaks = args['SETTINGS'].pair_split
      apply_tweaks tweaks if tweaks

      Dependencies.verify

      $logger.debug 'initializing cli'
      FileUtils.mkdir_p Config.snaps_dir

      url = args['URL'].protocolize
      crawler = Crawler.new url

      crawler.crawl
    end

    def docopt
      @docopt ||= File.read docopt_path
    end

    def docopt_path
      File.expand_path 'templates/docopt.txt', __dir__
    end

    def apply_tweaks(tweaks)
      tweaks.each do |key, value|
        Config.settings[key] = value
        $logger.level = value if key == 'log_level'
      end
    end
  end
end
