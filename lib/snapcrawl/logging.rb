require 'logger'

module Snapcrawl
  module Logging
    include LogHelpers

    attr_writer :logger

    def logger
      @logger ||= logger!
    end

  private

    def logger!
      Config.logger || Logger.new(STDOUT, formatter: log_formatter, level: Config.log_level)
    end

  end
end
