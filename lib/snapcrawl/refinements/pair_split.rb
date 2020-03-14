module Snapcrawl
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
