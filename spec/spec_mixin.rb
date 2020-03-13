module SpecMixin
  include Snapcrawl::LogHelpers

  def fresh_logger
    spec_logger = StringIO.new
    Config.logger = Logger.new spec_logger
    Config.logger.formatter = log_formatter
    spec_logger
  end
end