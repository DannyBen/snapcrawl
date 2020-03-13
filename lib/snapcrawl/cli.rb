require 'colsole'
require 'docopt'

module Snapcrawl
  class CLI
    include Colsole
    include Logging
    using StringRefinements
    
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
      Dependencies.verify
      logger.debug 'initializing cli'

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

  end
end
