require 'colsole'

module Snapcrawl
  class Dependencies
    class << self
      include Colsole

      def verify
        return if @verified

        $logger.debug 'verifying g`phantomjs` is present'
        raise MissingPhantomJS unless command_exist? 'phantomjs'

        $logger.debug 'verifying g`imagemagick` is present'
        raise MissingImageMagick unless command_exist? 'convert'

        @verified = true
      end
    end
  end
end
