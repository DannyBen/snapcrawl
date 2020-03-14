require 'spec_helper'

describe 'integration' do
  let(:url) { 'http://localhost:3000' }
  subject { CLI.new }
  before do
    @logger = fresh_logger
    Config.load   # reload defaults
  end

  let(:log) { @logger.string }

  it "works" do
    subject.call [url]
    expect(log).to match_fixture('integration/default-config')
  end

  context "with depth=0" do
    it "captures the first page only" do
      subject.call [url, 'depth=0']
      expect(log).to match_fixture('integration/depth-0')
    end
  end

  context "with depth=3 log_level=2" do
    it "captures 4 levels and shows warnings and above" do
      subject.call [url, 'depth=3', 'log_level=2']
      expect(log).to match_fixture('integration/depth-3')
    end
  end

  context "with log_color=no" do
    it "outputs without colors" do
      subject.call [url, 'log_color=no', 'log_level=1']
      expect(log).to match_fixture('integration/log-color-no')
    end
  end

  context "with url_whitelist" do
    let(:url) { 'http://localhost:3000/filters' }
    
    it "only processes urls that match the regex" do
      subject.call [url, 'url_whitelist=include', 'log_level=0']
      expect(log).to match_fixture('integration/whitelist')
    end
    
  end
  
  context "with url_blacklist" do
    let(:url) { 'http://localhost:3000/filters' }
    
    it "ignores urls that match the regex" do
      subject.call [url, 'url_blacklist=exclude', 'log_level=0']
      expect(log).to match_fixture('integration/blacklist')
    end
  end

  context "when screenshot errors" do
    it "logs the error and continues" do
      expect_any_instance_of(Screenshot).to receive(:save).and_raise(ScreenshotError, "Simulated error")
      subject.call [url, "cache_life=0", "depth=0", "log_level=1"]
      expect(log).to match_fixture('integration/screenshot-error')
    end
  end
end
