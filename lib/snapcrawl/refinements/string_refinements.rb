module Snapcrawl
  module StringRefinements
    refine String do
      def to_slug
        downcase.gsub(/[^a-z0-9]+/, '-')
      end

      def protocolize
        /^http/.match?(self) ? self : "http://#{self}"
      end
    end
  end
end
