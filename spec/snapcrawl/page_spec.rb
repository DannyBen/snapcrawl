require 'spec_helper'

describe Page do
  let(:url) { 'http://localhost:3000/page' }
  subject { described_class.new url }

  describe '#valid?' do
    context "when the page is valid" do
      it "returns true" do
        expect(subject).to be_valid
      end
    end

    context "when the page is not found" do
      let(:url) { 'http://localhost:3000/not-found' }

      it "returns false and logs a warning" do
        expect($logger).to receive(:warn).with(/code.*404/)
        expect(subject).not_to be_valid
      end
    end

    context "when the url can't be reached" do
      let(:url) { 'http://localhost:1111/' }

      it "returns false and logs an error" do
        expect($logger).to receive(:error).with(/connection refused/i)
        expect(subject).not_to be_valid
      end
    end

    context "when the url has a bad SSL certificate" do
      let(:url) { 'https://untrusted-root.badssl.com/' }

      it "returns false and logs an error" do
        expect($logger).to receive(:error).with(/certificate verify failed/i)
        expect(subject).not_to be_valid
      end

      context "when skip_ssl_verification is true" do
        before { Config.skip_ssl_verification = true }
        after { Config.skip_ssl_verification = false }

        it "returns true" do
          expect(subject).to be_valid
        end        
      end

    end    
  end

  describe '#site' do
    it "returns the site name" do
      expect(subject.site).to eq "http://localhost:3000"
    end    
  end

  describe '#path' do
    it "returns the path" do
      expect(subject.path).to eq "/page"
    end    
  end

  describe '#links' do
    it "returns an array of links on the page and logs warnings" do
      expect($logger).to receive(:warn).with(/problematic/)
      expect(subject.links).to eq ["http://localhost:3000/broken", "http://localhost:3000/ok"]
    end
  end

  describe '#pages' do
    it "returns an array of Page objects from the links" do
      expect($logger).to receive(:warn).with(/problematic/)
      pages = subject.pages
      expect(pages.count).to eq 2
      expect(pages.first).to be_a Page
    end
  end

  describe '#save_screenshot' do
    let(:double) { Screenshot.new subject.url }

    it "delegates to Screenshot" do
      expect(Screenshot).to receive(:new).with(subject.url).and_return(double)
      expect(double).to receive(:save).with('outfile')
      subject.save_screenshot 'outfile'
    end
  end
end
