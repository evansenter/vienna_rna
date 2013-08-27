module ViennaRna
  class EnergyGrid2d < Base
    def self.method_added(name)
      if name == :distribution && !class_variable_defined?(:@@aliasing_distribution)
        class_variable_set(:@@aliasing_distribution, true)
        
        class_eval <<-RUBY
          alias_method :distribution_without_casting, :distribution
          alias_method :distribution, :distribution_with_casting
        RUBY
        
        remove_class_variable(:@@aliasing_distribution)
      end
    end
    
    class Row2d
      attr_reader :i, :j, :p, :ensemble
  
      def initialize(i, j, p, ensemble)
        @i, @j, @p, @ensemble = i.to_i, j.to_i, p.to_f, ensemble.to_f
      end
    
      def <=>(other_row)
        i == other_row.i ? j <=> other_row.j : i <=> other_row.i
      end
    end
    
    def distribution_with_casting
      @distribution ||= distribution_without_casting.map { |row| Row2d.new(*row) }.select { |row| row.p > 0 }.sort
    end
    
    def quick_plot(num_colors: 64)
      Graphing::R.matrix_heatmap(
        distribution.map(&:i), 
        distribution.map(&:j), 
        distribution.map { |row| Math.log(1 / row.p) },
        title:      "#{self.class.name} Matrix Heatmap for ln(1 / p)",
        num_colors: num_colors
      )
    end
  end
end