require 'simplecov'

SimpleCov.start

require 'rubygems'
require 'bundler'
Bundler.require :default, :development

require 'stringio'
include Snapcrawl

# Consistent rspec fixtures output
ENV['TTY'] = 'on'

system 'rm -rf snaps'
system 'mkdir -p tmp'

require_relative 'spec_mixin'
RSpec.configure do |config|
  config.fixtures_path = 'spec/approvals'
  config.include SpecMixin
end
