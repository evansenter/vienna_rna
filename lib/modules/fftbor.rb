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
      flags = { mode: :standalone }.merge(flags)
      
      unless MODES[flags[:mode]]
        STDERR.puts "ERROR: The mode requested (%s) is not available" % flags[:mode]
      end
      
      case mode = flags.delete(:mode)
      when :standalone then
        super(flags)
      when :dispatch then
        "%s -m 6 -tr 0 -s %s -ss '%s'" % [MODES[mode], data.seq, data.safe_structure]
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
    
    def windows
      # This is starting to feel pretty hackety.
      response.gsub(/Sum.*\n+Window size:\s+\d+/) { |match| "[:separator:]" + match }.split("[:separator:]").map do |window_response|
        window_size  = window_response.match(/Window size:\s+(\d+)/)[1].to_i
        window_index = window_response.match(/Window starting index:\s+(\d+)/)[1].to_i
        
        self.class.new(seq: data.seq[window_index - 1, window_size], str: data.safe_structure[window_index - 1, window_size]).tap do |window_run|
          class << window_run
            attr_accessor :response, :window_size, :window_index
          end
          
          window_run.response     = window_response
          window_run.window_size  = window_size
          window_run.window_index = window_index
        end
      end
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
