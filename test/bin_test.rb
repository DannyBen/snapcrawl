require_relative 'helpers'
require 'snapcrawl'

class TestBin < MiniTest::Test
  include Snapcrawl

  def setup
    @base  = "http://localhost:4567"
    @bin   = Crawler.instance
    @bin.clear_cache

    begin
      open @base
    rescue Errno::ECONNREFUSED
      fail "Cannot test, server not running"
    end

    # If you change this to true, all fixtures will be refreshed
    @make_fixtures = false
  end

  def test_should_return_usage
    out, _ = capture []
    make_fixture out, __method__
    assert_equal fixture(__method__), out
  end

  def test_should_return_version
    out, _ = capture %W[go #{@base} -v]
    assert_equal "#{VERSION}\n", out
  end

  def test_should_crawl_one_page
    clear_cache
    out, _ = capture %W[go #{@base} -a0]
    make_fixture out, __method__
    assert_equal fixture(__method__), out
  end

  def test_should_report_404
    clear_cache
    out, err = capture %W[go #{@base} -a0 -d3]
    make_fixture out, "#{__method__}-out"
    make_fixture err, "#{__method__}-err"
    assert_equal fixture("#{__method__}-out"), out
    assert_equal fixture("#{__method__}-err"), err
  end

  def test_should_respect_exclude_regex
    clear_cache
    out, _ = capture %W[go #{@base} -a0 -d3 -opage]
    make_fixture out, __method__
    assert_equal fixture(__method__), out
  end

  def test_should_skip_snap_if_fresh
    clear_cache
    # first, make sure we actually take a snap
    capture %W[go #{@base} -a0]
    out, _ = capture %W[go #{@base}]
    make_fixture out, __method__
    assert_equal fixture(__method__), out
  end


  # HELPERS

  # Simulate binary run, and return [stdout, stderr]
  def capture(argv)
    capture_io { @bin.handle argv }
  end

  # Write some output to a fixture file. Call this when you want to 
  # refresh the fixture for a given test. Considers @make_fixture
  # Usage: make_fixture out, __method__
  def make_fixture(content, name)
    make_fixture!(content, name) if @make_fixtures
  end

  # Same as make_fixture, only ignores @make_fixtures
  def make_fixture!(content, name)
    File.write "test/fixtures/#{name}", content
  end

  # Return the content of a given fixture
  # Usage: fixture(__method__)
  def fixture(name)
    File.read "test/fixtures/#{name}"
  end

  def clear_cache
    @bin.clear_cache
  end

end