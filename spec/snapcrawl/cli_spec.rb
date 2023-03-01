require 'spec_helper'

describe CLI do
  subject { described_class.new }

  it 'shows usage' do
    expect { subject.call }.to output_approval('cli/usage')
  end
end
