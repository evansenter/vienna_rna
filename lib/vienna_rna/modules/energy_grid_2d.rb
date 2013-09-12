module ViennaRna
  class EnergyGrid2d < Base
    include Enumerable
    
    def self.inherited(subclass)
      subclass.class_eval { prepend EnergyGrid2dWrapper }
    end
    
    module EnergyGrid2dWrapper
      def distribution
        super.map { |row| Row2d.new(*row) }.select { |row| row.p > 0 }.sort
      end
    end
    
    class Row2d
      attr_reader :i, :j, :p, :ensemble
  
      def initialize(i, j, p, ensemble)
        @i, @j, @p, @ensemble = i.to_i, j.to_i, BigDecimal.new(p.to_s), BigDecimal.new(ensemble.to_s)
      end
      
      def position
        [i, j]
      end
    
      def <=>(other_row)
        i == other_row.i ? j <=> other_row.j : i <=> other_row.i
      end
      
      def inspect
        "#<Row2d (%d, %d), p: %s, ensemble: %s>" % [i, j, p, ensemble]
      end
    end
    
    def self.aligned_distributions(*energy_grids)
      point_set = set_of_points(*energy_grids)
      
      energy_grids.map do |grid|
        (grid.distribution + (point_set - grid.map(&:position)).map { |i, j| Row2d.new(i, j, 0, Float::INFINITY) }).sort
      end
    end
    
    def self.set_of_points(*energy_grids)
      energy_grids.inject([]) { |list, grid| list + grid.map(&:position) }.uniq.sort
    end
    
    def each(&block)
      distribution.each(&block)
    end
    
    def quick_plot(num_colors: 8)
      Graphing::R.matrix_heatmap(
        distribution.map(&:i), 
        distribution.map(&:j), 
        distribution.map { |row| Math.log(row.p) },
        title:      "#{self.class.name} Matrix Heatmap",
        x_label:    "Distance from structure 2",
        y_label:    "Distance from structure 1",
        num_colors: num_colors
      )
    end
    
    def inspect
      "#<#{self.class.name} on #{data.inspect}>"
    end
  end
end