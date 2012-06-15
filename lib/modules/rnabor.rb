module ViennaRna
  class Rnabor < Base
    def run_command(flags)
      "./RNAbor -s %s -c %s" % [fasta.seq, flags[:scaling_factor] || 1]
    end
    
    def parse_total_count
      response.split(/\n/).find { |line| line =~ /^Z\[\d+\]\[1\]:/ }.match(/^Z\[\d+\]\[1\]:\s*(.*)/)[1].to_i
    end
    
    def parse_points
      self.class.parse(response, "ROOTS AND SOLUTIONS") { |line| line.strip.split(/\s\s+/).map { |value| eval("Complex(#{value})") } }
    end
    
    def parse_counts
      self.class.parse(response, "UNSCALED SUM") { |line| line.strip.split(/:\s*/).map(&:to_f) }
    end
    
    def in_r(options = {})
      results = solve_in_r(options).processed_response
      
      options[:unscale] ? results.map { |i| i * parse_total_count } : results
    end
    
    def solve_in_r(options = {})
      options = { precision: 0, unscale: false }.merge(options)
      
      run unless response
      
      ViennaRna::FftInR.new(parse_points.map(&:last), parse_total_count, options[:precision]).run
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
