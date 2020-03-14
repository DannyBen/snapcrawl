require 'spec_helper'

describe Screenshot do
  let(:url) { 'http://localhost:3000/page' }
  subject { described_class.new url }

  describe '#save' do
    let(:outfile) { 'tmp/screenshot.png' }

    before do
      system "rm -f tmp/*.png"
      expect(Dir['tmp/*.png'].count).to eq 0
    end
    
    it "saves a screenshot" do
      subject.save outfile
      expect(File).to exist outfile
      expect(File.size outfile).to be > 22000
    end

    context "when Config.selector is set" do
      let(:url) { "http://localhost:3000/selector" }

      before do
        Config.selector = nil
        subject.save "tmp/full-page.png"
      end

      after do
        Config.selector = nil
      end

      it "only captures the selected area" do
        Config.selector = '.select-me'
        subject.save "tmp/selected-area.png"
        full_size = File.size('tmp/full-page.png')
        selected_size = File.size('tmp/selected-area.png')

        expect(selected_size).to be < full_size
      end
    end

    context "when there is an error", :focus do
      let(:url) { "http://localhost:1111" }

      it "raises ScreenshotError" do
        expect { subject.save outfile }.to raise_error(ScreenshotError)
      end
    end

  end
end

