require 'spec_helper'

describe Crawler do
  let(:url) { 'http://localhost:4567' }
  subject { described_class.instance }

  describe "#handle" do
    before do
      subject.clear_cache
    end

    it "shows usage", :focus do
      expect{ subject.handle [] }.to output(/Usage/).to_stdout
    end

    it "shows version" do
      expect{ subject.handle ['-v'] }.to output("#{VERSION}\n").to_stdout
    end

    it "crawls a single page" do
      expect{ subject.handle %W[go #{url} -a0] }.to output_fixture('crawler/single')
    end

    context "with a broken page" do
      it "reports a problem and continues past the error" do
        expect{ subject.handle %W[go #{url} -a0 -d5] }.to output_fixture('crawler/broken')
      end
    end

    context "with exclude regex" do
      it "works" do
        expect{ subject.handle %W[go #{url} -a0 -d3 -opage] }.to output_fixture('crawler/regex')
      end
    end

    context "with a freshly snapped picture" do
      it "does not resnap" do
        supress_output { subject.handle %W[go #{url} -a0] }
        expect{ subject.handle %W[go #{url}] }.to output_fixture('crawler/resnap')
      end
    end

  end
end

