require 'spec_helper'

describe PrettyLogger do
  before { Config.load }

  describe '::new' do
    it 'returns a Logger instance' do
      expect(subject).to be_a Logger
    end
  end

  describe 'log formatting' do
    let(:message) { 'g`Hello World`' }

    it 'logs with colors' do
      expect { subject.info message }.to output_approval('models/pretty_logger/colors')
    end
  end
end
