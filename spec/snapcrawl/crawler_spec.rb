require 'spec_helper'

describe Crawler do
  url = 'http://localhost:4567'
  crawler = described_class.instance

  describe "#handle" do

    before do
      crawler.clear_cache
    end

    it "shows usage" do
      expect{ crawler.handle [] }.to output(/Usage/).to_stdout
    end

    it "shows version" do
      expect{ crawler.handle ['-v'] }.to output("#{VERSION}\n").to_stdout
    end

    it "crawls a single page" do
      out, _err = capture_io { crawler.handle %W[go #{url} -a0] }
      expect(out).to match /Visit: #{url}/
      expect(out).to match /Snap!.*Snapping picture/
    end

    context "with a broken page" do
      out, _err = capture_io { crawler.handle %W[go #{url} -a0 -d5] }

      it "reports a problem" do
        expect(out).to match 'HTTP Error: 404 Not Found'
      end

      it "continues past the error page" do        
        expect(out).to match "Visit: #{url}/ok"
      end
    end

    context "with exclude regex" do
      out, _err = capture_io { crawler.handle %W[go #{url} -a0 -d3 -opage] }

      it "skips some pages" do
        expect(out).to match "Skipping. Does not match regex"
      end

      it "snaps some pages" do
        expect(out).to match "Snap!.*Snapping picture.*done"
      end
    end

    context "with a freshly snapped picture" do
      before :all do
        # first, make sure we actually take a snap
        capture_io { crawler.handle %W[go #{url} -a0] }
      end

      it "does not resnap" do
        out, _err = capture_io { crawler.handle %W[go #{url}] }
        expect(out).to match "Skipping. File exists and seems fresh"
      end
    end

  end
end

