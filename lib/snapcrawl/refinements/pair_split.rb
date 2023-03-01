module Snapcrawl
  module PairSplit
    refine Array do
      def pair_split
        false_values = %w[no false]
        true_values = %w[yes true]

        to_h do |pair|
          key, value = pair.split '='

          value = if /^\d+$/.match?(value)
            value.to_i
          elsif false_values.include? value
            false
          elsif true_values.include? value
            true
          else
            value
          end

          [key, value]
        end
      end
    end
  end
end
