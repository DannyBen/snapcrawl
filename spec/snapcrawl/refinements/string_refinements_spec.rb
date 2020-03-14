require 'spec_helper'

describe StringRefinements do
  using described_class

  describe '#to_slug' do
    it "converts to hyphen-delimited string" do
      expect("http://comain.com/index.html".to_slug).to eq "http-comain-com-index-html"
    end    
  end

  describe '#protocolize' do
    context "when the string does not start with http" do
      subject { "example.com" }

      it "adds http://" do
        expect(subject.protocolize).to eq "http://#{subject}"
      end
    end      

    context "when the string starts with http" do
      subject { "https://example.com" }

      it "does nothing" do
        expect(subject.protocolize).to eq subject
      end
    end    
  end

end
