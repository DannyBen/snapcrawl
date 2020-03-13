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

  module PairSplit
    refine Array do
      def pair_split
        map do |pair|
          key, value = pair.split '='
          
          value = if value =~ /^\d+$/
            value.to_i 
          elsif ['no', 'false'].include? value
            false
          elsif ['yes', 'true'].include? value
            true
          else
            value
          end

          [key, value]
        end.to_h
      end
    end
  end
end
