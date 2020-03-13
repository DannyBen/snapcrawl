module Snapcrawl
  class Dependencies
    class << self
      include Logging
      def verify
        return if @verified

        logger.debug 'verifying %{green}phantomjs%{reset} is present'
        raise MissingPhantomJS unless command_exist? "phantomjs"

        logger.debug 'verifying %{green}imagemagick%{reset} is present'
        raise MissingImageMagick unless command_exist? "convert"

        @verified = true
      end
    end
  end
end