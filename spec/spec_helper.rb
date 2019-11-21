require 'simplecov'

SimpleCov.start

require 'rubygems'
require 'bundler'
Bundler.require :default, :development

include Snapcrawl

# Consistent rspec fixtures output
ENV['TTY'] = 'on'

module SpecHelper
  def supress_output
    original_stdout = $stdout
    $stdout = StringIO.new
    yield
  ensure
    $stdout = original_stdout
  end
end

RSpec.configure do |config|
  config.extend SpecHelper
  config.include SpecHelper
end
