require "tempfile"
require "bigdecimal"

module ViennaRna
  class Xbor < Base
    BASE_FLAGS = {
      E: "/usr/local/bin/energy.par"
    }
    
    self.executable_name = -> { name.demodulize.gsub(/^([A-Z].*)bor$/) { |match| $1.upcase + "bor" } }
    
    def run_command(flags)
      file = Tempfile.new("rna")
      file.write("%s\n" % data.seq)
      file.write("%s\n" % data.safe_structure)
      file.close
      
      "%s %s %s" % [
        exec_name, 
        stringify_flags(BASE_FLAGS.merge(self.class.const_defined?(:FLAGS) ? self.class.const_get(:FLAGS) : {})), 
        file.path
      ]
    end
    
    def self.parse(response)
      response.split(/\n/).select { |line| line =~ /^\d+\t-?\d+/ }.map { |line| line.split(/\t/) }
    end
    
    def full_distribution
      distribution      = run.distribution
      full_distribution = distribution + ([0] * (data.seq.length - distribution.length + 1))
    end
    
    def quick_plot
      ViennaRna::Utils.quick_plot(
        "%s\\n%s\\n%s" % [self.class.name, data.seq, data.safe_structure], 
        full_distribution.each_with_index.to_a.map(&:reverse)
      )
    end
  end
end
