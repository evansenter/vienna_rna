module ViennaRna
  class Rnabor < Base
    def run_command(flags)
      "./RNAbor -s %s -c %s" % [fasta.seq, flags[:scaling_factor]]
    end
    
    def parse_points
      self.class.parse(response, "ROOTS AND SOLUTIONS") { |line| line.strip.split(/\s\s+/).map { |value| eval("Complex(#{value})") } }
    end
    
    def parse_counts
      self.class.parse(response, "UNSCALED SUM") { |line| line.strip.split(/:\s*/).map(&:to_f) }
    end
    
    def self.parse(response, delimiter)
      response.split(/\n/).reject do |line| 
        line.empty?
      end.drop_while do |line|
        line !~ /^START #{delimiter}/i
      end.reverse.drop_while do |line|
        line !~ /^END #{delimiter}/i
      end.reverse[1..-2].map do |line|
        yield line
      end
    end
  end
end
