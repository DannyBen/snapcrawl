require 'spec_helper'

describe Config do
  subject { described_class }

  describe '#load' do
    it "has defaults" do
      subject.load
      expect(subject.settings.to_yaml).to match_fixture('config/defaults')
    end

    it "loads file if it exists and merges it with the defaults" do
      subject.load 'spec/fixtures/config/minimal'
      expect(subject.settings.to_yaml).to match_fixture('config/minimal')
    end
  end
end

