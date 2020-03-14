require 'spec_helper'

describe PairSplit do
  using described_class

  subject { ["key=value", "key2=value2"] }

  it "splits an array of key=value elements into a hash" do
    expect(subject.pair_split).to eq({ 'key' => 'value', 'key2' => 'value2' })
  end

  context "when the value is integer-like" do
    subject { ["cakes=3"] }

    it "convertts it to integer" do
      expect(subject.pair_split['cakes']).to eq 3
    end
  end

  context "when the value is boolean-like" do
    subject { ["pizza=yes", "burger=true", "broccoli=no", "eggplant=false"] }

    it "convertts it to boolean" do
      expect(subject.pair_split).to eq({ 'pizza' => true, 'burger' => true, 'broccoli' => false, 'eggplant' => false })
    end
  end
end
