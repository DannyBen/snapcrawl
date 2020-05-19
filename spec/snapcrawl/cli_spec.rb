require 'spec_helper'

describe CLI do
  subject { CLI.new }

  it "works" do
    expect { subject.call }.to output_approval('cli/usage')
  end
end
