# Maybe add something like flagsets so that common option groups can be combined together.
# Also, add a rerun feature.

module ViennaRna
  module Package
    class FftMfpt < Base
      self.executable_name = "FFTmfpt"
      
      attr_reader :mfpt
    
      def run_command(flags)      
        "%s %s %s" % [
          exec_name, 
          stringify_flags(flags), 
          data.temp_fa_file!
        ]
      end
    
      def post_process
        @mfpt = response.to_f
      end
    end
  end
end
