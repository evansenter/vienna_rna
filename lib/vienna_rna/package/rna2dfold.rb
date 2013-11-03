module ViennaRna
  module Package
    class Rna2dfold < EnergyGrid2d
      self.default_flags = {
        d:         0,
        p:         :empty,
        "-noBT" => :empty
      }

      self.executable_name = "RNA2Dfold"

      def run_command(flags = {})
        ViennaRna.debugger { "Running RNA2Dfold on #{data.inspect}" }
      
        "cat %s | %s %s" % [
          data.temp_fa_file!,
          exec_name, 
          stringify_flags(flags)
        ]
      end
    
      def distribution
        response.split(/\n/)[6..-1].map { |line| line.split(/\t/).at_indexes([0, 1, 2, 6]) }
      end
    end
  end
end