module ViennaRna
  module Package
    class Kinwalker < Base
      self.executable_name = "kinwalker"
      attr_reader :nodes
                
      def post_process
        @nodes = response.split("TRAJECTORY").last.split(?\n).reject(&:empty?)[0..-2].map { |line| Node.new(*line.split(/\s+/)) }
      end
      
      def mfpt
        nodes.last.time
      end
      
      class Node
        attr_reader :structure, :energy, :time, :barrier, :energy_barrier, :transcribed
        
        def initialize(structure, energy, time, barrier, energy_barrier, transcribed)
          @structure, @energy, @time, @barrier, @energy_barrier, @transcribed = structure, energy.to_f, time.to_f, barrier.to_f, energy_barrier.to_f, transcribed.to_i
        end
      end
    end
  end
end