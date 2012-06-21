module ViennaRna
  class Fftbor < Base
    attr_reader :flags
    
    def run_command(flags)
      @flags = flags
      
      "./FFTbor -s %s -r \"%s\" -c %s -p %s" % [
        data.seq, 
        data.safe_structure,
        flags[:scaling_factor] ||= 1,
        flags[:precision] ||= 6
      ]
    end
    
    def parse_partition
      response.split(/\n/).find { |line| line =~ /^Z\[1\]\[\d+\]:/ }.match(/^Z\[1\]\[\d+\]:\s*(.*)/)[1].to_f
    end
    
    def parse_total_count
      response.split(/\n/).find { |line| line =~ /^Z\[\d+\]\[1\]:/ }.match(/^Z\[\d+\]\[1\]:\s*(.*)/)[1].to_i
    end
    
    def parse_points
      self.class.parse(response, "ROOTS AND SOLUTIONS") { |line| line.strip.split(/\s\s+/).map { |value| eval("Complex(#{value})") } }
    end
    
    def parse_distribution
      if flags[:scaling_factor] != 1
        puts "Warning: The scaling factor was set to #{flags[:scaling_factor]}. The Boltzmann distribution is not setup to handle scaling in this fashion."
      end
      
      self.class.parse(response, "DISTRIBUTION") { |line| line.strip.split(/:\s*/).last.to_f }
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
