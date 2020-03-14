module Snapcrawl
  module StringRefinements
    refine String do
      def to_slug
        downcase.gsub(/[^a-z0-9]+/, '-')
      end

      def protocolize
        self =~ /^http/ ? self : "http://#{self}"
      end
    end
  end
end
