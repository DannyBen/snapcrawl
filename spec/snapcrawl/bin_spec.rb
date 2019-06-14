require 'spec_helper'

describe 'bin/snapcrawl' do
  it "shows usage patterns" do
    expect(`bin/snapcrawl`).to match_fixture 'bin/usage'
  end

  it "shows help" do
    expect(`bin/snapcrawl --help`).to match_fixture 'bin/help'
  end

  it "shows correct version" do
    expect(`bin/snapcrawl -v`).to match VERSION
  end
end

