module ViennaRna
  class Fftbor2d < Base
    BASE_FLAGS = {
      E: "/usr/local/bin/rna_turner1999.par",
      P: 8,
      S: :empty
    }

    self.executable_name = "FFTbor2D"

    def run_command(flags = {})
      ViennaRna.debugger { "Running FFTbor2D on #{data.inspect}" }
      
      "%s %s %s" % [
        exec_name, 
        stringify_flags(BASE_FLAGS.merge(self.class.const_defined?(:FLAGS) ? self.class.const_get(:FLAGS) : {}).merge(flags)), 
        data.temp_fa_file!
      ]
    end
    
    def distribution
      response.split(/\n/).map do |line| 
        i, j, p, ensemble = line.split(/\t/)
        [i, j].map(&:to_i) + [p, ensemble].map(&:to_f)
      end
    end
  end
end