require 'spec_helper'

describe CLI do
  subject { CLI.new }

  it "works" do
    expect { subject.call }.to output_fixture('cli/usage')
  end
end
