module Snapcrawl
  class Dependencies
    class << self
      def verify
        raise MissingPhantomJS unless command_exist? "phantomjs"
        raise MissingImageMagick unless command_exist? "convert"
      end
    end
  end
end