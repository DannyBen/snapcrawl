require 'spec_helper'

describe 'integration' do
  let(:url) { 'http://localhost:3000' }
  subject { CLI.new }
  
  before do
    Config.load
    @logger = fresh_logger
  end

  let(:log) { @logger.string }

  it "works" do
    subject.call [url]
    expect(log).to match_fixture('integration/default-config')
  end

  context 

end
