require 'spec_helper'

describe Crawler do
  let(:url) { 'http://localhost:4567' }
  subject { described_class.instance }

  describe "#handle" do
    before do
      subject.clear_cache
    end

    it "shows usage" do
      expect{ subject.handle [] }.to output(/Usage/).to_stdout
    end

    it "shows version" do
      expect{ subject.handle ['-v'] }.to output("#{VERSION}\n").to_stdout
    end

    it "crawls a single page" do
      expect{ subject.handle %W[#{url} -a0] }.to output_fixture('crawler/single')
    end

    it "crawls multiple pages" do
      expect{ subject.handle %W[#{url} -a0 -d5] }.to output_fixture('crawler/broken')
    end

    context "with exclude regex" do
      it "works" do
        expect{ subject.handle %W[#{url} -a0 -d3 -opage] }.to output_fixture('crawler/regex')
      end
    end

    context "with a freshly snapped picture" do
      it "does not resnap" do
        supress_output { subject.handle %W[#{url} -a0] }
        expect{ subject.handle %W[#{url}] }.to output_fixture('crawler/resnap')
      end
    end

    context "when relative url conversion fails" do
      it "shows a graceful warning" do
        expect(Addressable::URI).to receive(:join).and_raise(ArgumentError, "Some unknown error")
        expect{ subject.handle %W[#{url} -a0] }.to output_fixture('crawler/normalize-error')
      end
    end

    context "with --folder" do
      before do
        system 'rm -rf tmp' if Dir.exist? 'tmp'
        expect(Dir).not_to exist './tmp'
      end

      after do
        system 'rm -rf tmp' if Dir.exist? 'tmp'
      end

      it "saves images in the requested folder" do
        supress_output { subject.handle %W[#{url} --folder tmp] }
        expect(File).to exist 'tmp/http-localhost-4567.png'
      end
    end

    context "with --name" do
      it "uses the provided filename template" do
        supress_output { subject.handle %W[#{url} --name it-works-%{url}] }
        expect(File).to exist 'snaps/it-works-http-localhost-4567.png'
      end
    end

    context "with --selector" do
      before do
        system 'rm snaps/selector*.png > /dev/null 2>&1'
        supress_output { subject.handle %W[#{url}/selector --name selector-full] }
      end

      it "only captures a portion of the page" do
        supress_output { subject.handle %W[#{url}/selector --name selector-partial --selector .select-me] }
        full_image_size = File.size('snaps/selector-full.png')
        selector_image_size = File.size('snaps/selector-partial.png')

        expect(selector_image_size).to be < full_image_size
      end
    end

  end
end

