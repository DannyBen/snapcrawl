require 'simplecov'

SimpleCov.start

require 'rubygems'
require 'bundler'
Bundler.require :default, :development

require 'stringio'
include Snapcrawl

# Consistent rspec fixtures output
ENV['TTY'] = 'on'

# spec_logger = StringIO.new
# Config.logger = Logger.new spec_logger
# Config.logger.formatter = proc do |severity, _t, _p, msg|
#   "[#{severity.rjust 5}] #{msg}\n"
# end

require_relative 'spec_mixin'
RSpec.configure do |config|
  config.fixtures_path = 'spec/approvals'
  config.include SpecMixin
end
