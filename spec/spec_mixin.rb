module SpecMixin
  include Snapcrawl::LogHelpers

  def fresh_logger
    spec_logger = StringIO.new
    $logger = Logger.new spec_logger
    $logger.formatter = log_formatter
    spec_logger
  end
end