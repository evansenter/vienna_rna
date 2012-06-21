require "tempfile"

module ViennaRna
  class Fftbor < Base
    def run_command(flags)
      file = Tempfile.new("rna")
      file.write("%s\n" % data.seq)
      file.write("%s\n" % data.safe_structure)
      file.close
      
      "./FFTbor %s" % file.path
    end
    
    def partition
      # Scaling factor (Z{1, n}): 586.684
      response.split(/\n/).find { |line| line =~ /^Scaling factor.*:\s+(\d+\.\d+)/ }
      $1.to_f
    end
    
    def total_count
      response.split(/\n/).find { |line| line =~ /^Number of structures: (\d+)/ }
      $1.to_i
    end
    
    def distribution
      self.class.parse(response).map { |row| row[1].to_f }
    end
    
    def self.parse(response)
      response.split(/\n/).select { |line| line =~ /^\d+\t\d+(\.\d+)?/ }.map { |line| line.split(/\t/) }
    end
  end
end
