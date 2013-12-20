module ViennaRna
  module Package
    class Xbor < Base
      self.default_flags = {
        E: "/usr/local/bin/rna_turner2004.par"
      }
    
      self.executable_name = ->(context) { context.class.name.demodulize.gsub(/^([A-Z].*)bor$/) { |match| $1.upcase + "bor" } }
    
      def run_command(flags)
        file = Tempfile.new("rna")
        file.write("%s\n" % data.seq)
        file.write("%s\n" % data.str)
        file.close
      
        ViennaRna.debugger { "Running FFTbor on #{data.inspect}" }
      
        "%s %s %s" % [
          exec_name, 
          stringify_flags(flags), 
          file.path
        ]
      end
    
      def self.parse(response)
        response.split(/\n/).select { |line| line =~ /^\d+\t-?\d+/ }.map { |line| line.split(/\t/) }
      end
    
      def full_distribution
        distribution      = run.distribution
        full_distribution = distribution + ([0.0] * ((differnece = data.seq.length - distribution.length + 1) < 0 ? 0 : differnece))
      end
    
      def k_p_points
        full_distribution.each_with_index.to_a.map(&:reverse)[0..data.seq.length]
      end
    
      def expected_k
        k_p_points.map { |array| array.inject(&:*) }.inject(&:+)
      end
      
      def to_csv
        k_p_points.map { |k, p| "%d,%.8f" % [k, p] }.join(?\n) + ?\n
      end
      
      def to_csv!(filename)
        File.open(filename, ?w) { |file| file.write(to_csv) }
      end
    
      def quick_plot(filename: false)
        ViennaRna::Graphing::R.line_graph(
          k_p_points,
          title:    options[:title] || "%s\\n%s\\n%s" % [self.class.name, data.seq, data.safe_structure],
          filename: false
        )
      end
    
      def inspect
        "#<#{self.class.name} #{data.inspect}>"
      end
    end
  end
end
