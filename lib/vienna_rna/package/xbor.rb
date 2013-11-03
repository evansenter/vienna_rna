module ViennaRna
  module Package
    class Xbor < Base
      self.default_flags = {
        E: "/usr/local/bin/energy.par"
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
    
      def self.bootstrap_from_file(path, klass = self)
        log       = File.read(path)
        sequence  = log.split(/\n/).first.split(/\s+/)[1]
        structure = log.split(/\n/).first.split(/\s+/)[2]
      
        klass.bootstrap(RNA.from_string(sequence, structure), log)
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
    
      def quick_plot(options = {})
        ViennaRna::Graphing::Gnuplot.quick_plot(
          k_p_points,
          options[:title] || "%s\\n%s\\n%s" % [self.class.name, data.seq, data.safe_structure],
          options
        )
      end
    
      def inspect
        "#<#{self.class.name} #{data.inspect}>"
      end
    end
  end
end
