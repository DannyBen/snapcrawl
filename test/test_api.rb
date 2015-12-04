require_relative 'helpers'
require_relative '../lib/snapcrawl'
include Snapcrawl

class TestApi < MiniTest::Test
  def setup
    @base = "http://example.com"
  end

  def test_crawl
    output = crawl "#{@base}/test"
    p output; exit
  end

end