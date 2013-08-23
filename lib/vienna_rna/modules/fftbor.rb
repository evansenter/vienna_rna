require "tempfile"
require "bigdecimal"
require "diverge"

module ViennaRna
  class Fftbor < Xbor
    def partition
      response.split(/\n/).find { |line| line =~ /^Scaling factor.*:\s+(\d+\.\d+)/ }
      BigDecimal.new($1)
    end
    
    def total_count
      response.split(/\n/).find { |line| line =~ /^Number of structures: (\d+)/ }
      $1.to_i
    end
    
    def distribution
      self.class.parse(response).map { |row| BigDecimal.new(row[1]) }
    end
  end
end
