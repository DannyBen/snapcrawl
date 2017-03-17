require 'spec_helper'

describe Crawler do
  url = 'http://localhost:4567'
  let(:crawler) { described_class.instance }

  describe "#handle" do

    before do
      crawler.clear_cache
    end

    it "crawls a single page" do
      output = `bin/snapcrawl go #{url} -a0`
      expect(output).to match "Visit: #{url}"
      expect(output).to match 'Snap!  Snapping picture...'
    end

    context "with a broken page" do
      output = `bin/snapcrawl go #{url} -a0 -d5`

      it "reports a problem" do
        expect(output).to match 'HTTP Error: 404 Not Found'
      end

      it "continues past the error page" do        
        expect(output).to match "Visit: #{url}/ok"
      end
    end

    context "with exclude regex" do
      output = `bin/snapcrawl go #{url} -a0 -d3 -opage`

      it "skips some pages" do
        expect(output).to match "Skipping. Does not match regex"
      end

      it "snaps some pages" do
        expect(output).to match "Snap!  Snapping picture... done"
      end
    end

    context "with a freshly snapped picture" do
      before :all do
        # first, make sure we actually take a snap
        output = `bin/snapcrawl go #{url} -a0`
      end

      it "does not resnap" do
        expect(`bin/snapcrawl go #{url}`).to match "Skipping. File exists and seems fresh"
      end
    end

  end
end

