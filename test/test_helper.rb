require 'simplecov'
SimpleCov.start

require 'minitest/reporters'
require 'minitest/autorun'
require_relative '../lib/snapcrawl'

Minitest::Reporters.use!(Minitest::Reporters::SpecReporter.new)

