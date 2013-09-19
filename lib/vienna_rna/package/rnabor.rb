module ViennaRna
  module Package
    class Rnabor < Xbor
      FLAGS = {
        nodangle: :empty
      }
    
      def partition
        non_zero_shells.inject(&:+)
      end
    
      def total_count
        counts.inject(&:+)
      end
    
      def counts
        (non_zero_counts = self.class.parse(response).map { |row| BigDecimal.new(row[2]).to_i }) + [0] * (data.seq.length - non_zero_counts.length + 1)
      end
    
      def distribution(options = {})
        options = { precision: 4 }.merge(options)
      
        distribution_before_precision = (non_zero_distribution = non_zero_shells.map { |i| i / partition }) + [0.0] * (data.seq.length - non_zero_distribution.length + 1)
        distribution_before_precision.map { |value| options[:precision].zero? ? value : (value * 10 ** options[:precision]).truncate / 10.0 ** options[:precision] }
      end
    
      def non_zero_shells
        self.class.parse(response).map { |row| BigDecimal.new(row[1]) }
      end
    end
  end
end
