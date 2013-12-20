module ViennaRna
  module Package
    class Spectral < Base      
      self.default_flags = ->(context, flags) { { seq: context.data.seq, step_size: "1e-2" } }
      
      attr_reader :eigenvalues, :time_kinetics
    
      def run_command(flags)
        "%s %s" % [
          exec_name, 
          stringify_flags(flags)
        ]
      end
    
      def post_process
        if flags.keys.include?(:eigen_only)
          @eigenvalues = response.split(?\n).map(&:to_f).sort_by(&:abs)
        else
          @time_kinetics = response.split(?\n).map { |line| line.split(?\t).map(&:to_f) }
        end
      end
    end
  end
end