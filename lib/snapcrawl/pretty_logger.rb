require 'logger'

module Snapcrawl
  class PrettyLogger
    extend LogHelpers

    def self.new
      Logger.new(STDOUT, formatter: log_formatter, level: Config.log_level)
    end
  end
end
