module ViennaRna
  module Package
    class Fftbor2d < EnergyGrid2d
      BASE_FLAGS = {
        S: :empty
      }

      self.executable_name = "FFTbor2D"

      def run_command(flags = {})
        ViennaRna.debugger { "Running #{exec_name} on #{data.inspect}" }
      
        "%s %s %s" % [
          exec_name, 
          stringify_flags(BASE_FLAGS.merge(self.class.const_defined?(:FLAGS) ? self.class.const_get(:FLAGS) : {}).merge(flags)), 
          data.temp_fa_file!
        ]
      end
    
      def distribution
        response.split(/\n/).map { |line| line.split(/\t/) }
      end
    end
  end
end
