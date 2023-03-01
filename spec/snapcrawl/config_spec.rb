require 'spec_helper'

describe Config do
  subject { described_class }

  describe '#load' do
    it 'has defaults' do
      subject.load
      expect(subject.settings.to_yaml).to match_approval('config/defaults')
    end

    it 'loads file if it exists and merges it with the defaults' do
      subject.load 'spec/fixtures/config/minimal'
      expect(subject.settings.to_yaml).to match_approval('config/minimal')
    end

    context 'when the config file is not found' do
      before { system 'rm -f tmp/config.yml' }

      it 'creates it' do
        subject.load 'tmp/config.yml'
        expect(File.read 'tmp/config.yml').to eq File.read('lib/snapcrawl/templates/config.yml')
      end
    end
  end
end
