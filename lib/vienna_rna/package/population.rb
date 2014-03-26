module ViennaRna
  module Package
    class Population < Base
      attr_reader :population_proportion_str_2_from_str_1, :population_proportion_for_str_1

      self.default_flags = ->(context, flags) do
        {
          "-fftbor2d-i" => context.data.seq,
          "-fftbor2d-j" => context.data.str_1,
          "-fftbor2d-k" => context.data.str_2,
          "-spectral-i" => -10,
          "-spectral-j" => 10,
          "-spectral-p" => 1e-2,
        }
      end
      self.quote_flag_params = %w|-fftbor2d-i -fftbor2d-j -fftbor2d-k|

      class Population
        include Enumerable

        attr_reader :proportion_over_time

        def initialize(time, proportion)
          @proportion_over_time = time.zip(proportion)
        end

        def time_range(from, to)
          proportion_over_time.select { |time, _| ((from.to_f)..(to.to_f)) === time }
        end

        def equilibrium(percentile: 95, window_size: 5, epsilon: 1e-4)
          start       = proportion_points.first
          stop        = proportion_points.last
          sign        = stop > start ? :increasing : :decreasing
          # If the population is increasing over time, we want the 95%, otherwise we want the 5%
          percentile  = ((start.zero? || stop.zero? ? [start, stop].max : (stop / start).abs) / 100) * (sign == :increasing ? percentile : 100 - percentile)
          # Look for the first index at the percentile we're interested in, and scan to the right from there.
          start_index = proportion_points.each_with_index.find do |proportion, i|
            sign == :increasing ? proportion > percentile : proportion < percentile
          end.last

          # The first slice starting at x we find where abs(p(x + i), p(x)) < epslion for all 1 <= x < window_size is equilibrium,
          # and we return that time point.
          proportion_over_time[start_index..-1].each_cons(window_size).find do |proportion_slice|
            proportion_slice.all? { |time, proportion| (proportion - proportion_slice.first.last).abs < epsilon }
          end.first.first
        end

        def time_points; proportion_over_time.map(&:first); end
        def proportion_points; proportion_over_time.map(&:last); end

        def each
          proportion_over_time.each { |_| yield _ }
        end
      end

      def run_command(flags)
        ViennaRna.debugger { "Running #{exec_name} on #{data.inspect}" }

        "%s %s" % [exec_name, stringify_flags(flags)]
      end

      def post_process
        time_points, proportion_str_2_from_str_1, proportion_for_str_1 = response.split(/\n/).map { |line| line.split(/\t/).map(&:to_f) }.transpose
        @population_proportion_str_2_from_str_1                        = Population.new(time_points, proportion_str_2_from_str_1)
        @population_proportion_for_str_1                               = Population.new(time_points, proportion_for_str_1)
      end
    end
  end
end
