require 'simplecov'
SimpleCov.start

require 'fakeweb'
require 'minitest/reporters'
require 'minitest/autorun'
require_relative '../lib/snapcrawl'

Minitest::Reporters.use!(Minitest::Reporters::SpecReporter.new)

FakeWeb.register_uri(:get, "http://example.com/test", body: "WORKING")

