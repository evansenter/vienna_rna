module ViennaRna
  module Package
    class Mfpt < Base
      self.chains_from   = ViennaRna::Package::EnergyGrid2d
      self.default_flags = ->(context, flags) { { X: :empty, H: :empty, N: context.data.seq.length, Q: "1e-8" } }
      # These flags aren't well setup for alternative options at the moment.
      
      attr_reader :mfpt
      
      def transform_for_chaining(previous_package)
        previous_package.data.tap do |data|
          data.instance_eval do
            @energy_grid_csv = Tempfile.new("rna").path.tap do |energy_grid_csv|
              previous_package.to_csv!(energy_grid_csv)
            end
          
            def energy_grid_csv; @energy_grid_csv; end
          end
        end
      end
    
      def run_command(flags)      
        "%s %s %s" % [
          exec_name, 
          stringify_flags(flags), 
          data.energy_grid_csv
        ]
      end
    
      def post_process
        @mfpt = @response.to_f
      end
    end
  end
end