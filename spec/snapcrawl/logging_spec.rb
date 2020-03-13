require 'spec_helper'

describe Logging do
  subject { Class.new { include Logging }.new }

  describe '#logger' do
    it "returns a logger instance" do
      expect(subject.logger).to be_a Logger
    end
  end
end

