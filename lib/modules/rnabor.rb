require "tempfile"

module ViennaRna
  class Rnabor < Base
    def run_command(flags)
      file = Tempfile.new("rna")
      file.write("%s\n" % data.seq)
      file.write("%s\n" % data.safe_structure)
      file.close
      
      "./RNAbor %s" % file.path
    end
    
    def parse_partition
      parse_non_zero_shells.sum
    end
    
    def parse_total_count
      parse_counts.sum
    end
    
    def parse_counts
      (non_zero_counts = self.class.parse(response).map { |row| row[2].to_i }) + [0] * (data.seq.length - non_zero_counts.length + 1)
    end
    
    def parse_distribution
      (non_zero_distribution = parse_non_zero_shells.map { |i| i / parse_partition }) + [0.0] * (data.seq.length - non_zero_distribution.length + 1)
    end
    
    def parse_non_zero_shells
      self.class.parse(response).map { |row| row[1].to_f }
    end
    
    def self.parse(response)
      response.split(/\n/)[2..-1].map { |line| line.split(/\t/) }
    end
  end
end
