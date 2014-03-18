module ViennaRna
  module Package
    class Fftbor2d < EnergyGrid2d
      self.executable_name = "FFTbor2D"
      self.default_flags   = ->(_, flags) { (flags.keys & %i|M S|).empty? ? { S: :empty } : {} }

      def run_command(flags)
        ViennaRna.debugger { "Running #{exec_name} on #{data.inspect}" }

        "%s %s %s" % [
          exec_name,
          stringify_flags(flags),
          data.temp_fa_file!
        ]
      end

      def distribution
        response.split(/\n/).map { |line| line.split(/\t/) }
      end
    end
  end
end
