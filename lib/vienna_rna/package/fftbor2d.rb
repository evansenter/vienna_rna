module ViennaRna
  module Package
    class Fftbor2d < EnergyGrid2d
      self.executable_name = "FFTbor2D"
      self.default_flags   = ->(_, flags) { (flags.keys & %i|X Y M S|).empty? ? { S: :empty } : {} }
      
      attr_reader :population_proportion_str_2_from_str_1, :population_proportion_for_str_1
      
      class Population
        attr_reader :proportion_over_time
  
        def initialize(time, proportion)
          @proportion_over_time = time.zip(proportion)
        end
        
        def time_range(from, to)
          proportion_over_time.select { |time, _| ((from.to_f)..(to.to_f)) === time }
        end
        
        def time_points; proportion_over_time.map(&:first); end
        def proportion_points; proportion_over_time.map(&:last); end
      end

      def run_command(flags)
        ViennaRna.debugger { "Running #{exec_name} on #{data.inspect}" }
      
        "%s %s %s" % [
          exec_name, 
          stringify_flags(flags),
          data.temp_fa_file!
        ]
      end
      
      def post_process
        if flags.keys.include?(:Y)
          time_points, proportion_str_2_from_str_1, proportion_for_str_1 = response.split(/\n/).map { |line| line.split(/\t/).map(&:to_f) }.transpose
          @population_proportion_str_2_from_str_1                        = Population.new(time_points, proportion_str_2_from_str_1)
          @population_proportion_for_str_1                               = Population.new(time_points, proportion_for_str_1)
        end
      end
    
      def distribution
        response.split(/\n/).map { |line| line.split(/\t/) }
      end
    end
  end
end
