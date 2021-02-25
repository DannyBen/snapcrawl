require 'colsole'

module Snapcrawl
  class Dependencies
    class << self
      include Colsole
      
      def verify
        return if @verified

        $logger.debug 'verifying !txtgrn!phantomjs!txtrst! is present'
        raise MissingPhantomJS unless command_exist? "phantomjs"

        $logger.debug 'verifying !txtgrn!imagemagick!txtrst! is present'
        raise MissingImageMagick unless command_exist? "convert"

        @verified = true
      end
    end
  end
end