require "tempfile"
require "bigdecimal"

module ViennaRna
  class Xbor < Base
    self.executable_name = -> { name.demodulize.gsub(/^([A-Z].*)bor$/) { |match| $1.upcase + "bor" } }
    
    def run_command(flags)
      file = Tempfile.new("rna")
      file.write("%s\n" % data.seq)
      file.write("%s\n" % data.safe_structure)
      file.close
      
      "%s -nodangle -E /usr/local/bin/energy.par %s" % [exec_name, file.path]
    end
    
    def self.parse(response)
      response.split(/\n/).select { |line| line =~ /^\d+\t-?\d+/ }.map { |line| line.split(/\t/) }
    end
  end
end
