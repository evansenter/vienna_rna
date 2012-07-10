require "tempfile"
require "bigdecimal"
require "diverge"

module ViennaRna
  class Fftbor < Xbor
    MODES = {
      dispatch:   "RNAcentral",
      standalone: "FFTbor"
    }
    
    def run_command(flags = {})
      flags = { mode: :dispatch }.merge(flags)
      
      unless MODES[flags[:mode]]
        STDERR.puts "ERROR: The mode requested (%s) is not available" % flags[:mode]
      end
      
      case flags[:mode]
      when :standalone then
        super(flags)
      when :dispatch then
        "%s -m 6 -tr 0 -s %s -ss '%s'" % [MODES[flags[:mode]], data.seq, data.safe_structure(flags)]
      end
    end
    
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
    
    def compare
      {
        dispatch:   self.class.new(data).run(mode: :dispatch).distribution,
        standalone: self.class.new(data).run(mode: :standalone).distribution
      }.tap do |hash|
        hash[:tvd] = Diverge.new(hash[:dispatch], hash[:standalone]).tvd
      end
    end
  end
end
