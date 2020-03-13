require 'colsole'
require 'docopt'
require 'fileutils'

module Snapcrawl
  class CLI
    include Colsole
    include Logging
    using StringRefinements
    using PairSplit
    
    def call(args = [])
      begin
        execute Docopt::docopt(docopt, version: VERSION, argv: args)
      rescue Docopt::Exit => e
        puts e.message
      end
    end

  private

    def execute(args)
      Config.load args['--config']
      tweaks = args['TWEAKS'].pair_split
      apply_tweaks tweaks if tweaks

      Dependencies.verify
      
      logger.debug 'initializing cli'
      FileUtils.mkdir_p Config.snaps_dir

      url = args['URL'].protocolize
      crawler = Crawler.new url

      crawler.crawl
    end

    def docopt
      @doc ||= File.read docopt_path
    end

    def docopt_path
      File.expand_path "docopt.txt", __dir__
    end

    def apply_tweaks(tweaks)
      tweaks.each do |key, value|
        Config.settings[key] = value
        Config.logger.level = value if key == 'log_level'
      end
    end

  end
end
