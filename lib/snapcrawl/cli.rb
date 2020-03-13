require 'colsole'
require 'docopt'

module Snapcrawl
  class CLI
    include Colsole
    using StringRefinements
    
    def call(args)
      begin
        execute Docopt::docopt(docopt, version: VERSION, argv: args)
      rescue Docopt::Exit => e
        puts e.message
      end
    end

  private

    def execute(args)
      raise MissingPhantomJS unless command_exist? "phantomjs"
      raise MissingImageMagick unless command_exist? "convert"

      url = args['URL'].protocolize
      crawler = Crawler.new url, opts_from_args(args)
      
      crawler.crawl do |status, options|
        output status, options
      end
    end

    def output(status, options)
      case status
      when :start
        page = options[:page]
        say "\n!txtpur!#{page.path}!txtrst! [depth: #{page.depth}]"
      
      when :snap
        say "  !txtgrn!screenshot taken"
      
      when :http_error
        say "  !txtred!http error: #{options[:code]} #{options[:message]}"
      
      end
    end

    def opts_from_args(args)
      {
        folder: args["--folder"],
        name_template: args["--name"],
        selector: args["--selector"],
        exclude_urls: args["--only"],
        age: args["--age"]&.to_i,
        depth: args["--depth"]&.to_i,
        height: args["--height"]&.to_i,
        width: args["--width"]&.to_i,
      }
    end

    def docopt
      @doc ||= File.read docopt_path
    end

    def docopt_path
      File.expand_path "docopt.txt", __dir__
    end

  end
end
