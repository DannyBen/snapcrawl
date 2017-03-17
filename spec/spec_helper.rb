require 'simplecov'
SimpleCov.start

require 'rubygems'
require 'bundler'
Bundler.require :default, :development

include Snapcrawl

module SpecHelper
  def capture_io(&block)
    begin
      $stdout, $stderr = StringIO.new, StringIO.new
      yield
      result = [$stdout.string, $stderr.string]
    ensure
      $stdout, $stderr = STDOUT, STDERR
    end
    result
  end
end

RSpec.configure do |config|
  config.extend SpecHelper
  config.include SpecHelper
end
