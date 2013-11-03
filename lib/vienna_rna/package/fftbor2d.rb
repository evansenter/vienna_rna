module ViennaRna
  module Package
    class Fftbor2d < EnergyGrid2d
      self.executable_name = "FFTbor2D"

      def run_command(flags = {})
        ViennaRna.debugger { "Running #{exec_name} on #{data.inspect}" }
      
        "%s %s %s" % [
          exec_name, 
          stringify_flags(flags.merge((flags.keys & %i|X M S|).empty? ? { S: :empty } : {})), 
          data.temp_fa_file!
        ]
      end
    
      def distribution
        response.split(/\n/).map { |line| line.split(/\t/) }
      end
    end
  end
end
