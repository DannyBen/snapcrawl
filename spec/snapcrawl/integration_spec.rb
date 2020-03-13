require 'spec_helper'

describe 'integration' do
  let(:url) { 'http://localhost:3000' }
  subject { CLI.new }
  before { @logger = fresh_logger }

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
    
  end
  
  context "with url_blacklist" do

  end
end
