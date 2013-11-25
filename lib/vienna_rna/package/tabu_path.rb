module ViennaRna
  module Package
    class TabuPath < Base
      self.executable_name = "get_barrier_tabu"
      self.default_flags   = ->(context, flags) { { iterations: 10, min_weight: 10, max_weight: 70 } }
      
      attr_reader :paths
    
      def run_command(flags)
        ViennaRna.debugger { "Running #{exec_name} on #{data.inspect}" }
      
        [
          exec_name, 
          data.seq.inspect,
          data.str_1.inspect,
          data.str_2.inspect,
          flags[:iterations],
          flags[:min_weight],
          flags[:max_weight]
        ].join(" ")
      end
    
      def post_process
        @paths = @response.split(data.str_1 + ?\n).reject(&:empty?).map { |path_string| Path.new(data, path_string) }
      end
      
      class Path
        attr_reader :rna, :path, :barrier, :best_weight
        
        def initialize(rna, output)
          @rna                      = rna
          @path                     = output.split(?\n)[0..-2].unshift(rna.str_1)
          @barrier, _, @best_weight = output.split(?\n)[-1].gsub(/[^\d\.]/, " ").strip.split(/\s+/).map(&:to_f)
        end
        
        def length
          path.length
        end
        
        def full_path?
          rna.str_1 == path.first && rna.str_2 == path.last
        end
      end
    end
  end
end
