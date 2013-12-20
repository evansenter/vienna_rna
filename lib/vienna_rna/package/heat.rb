module ViennaRna
  module Package
    class Heat < Base
      attr_reader :specific_heats
    
      def post_process
        @specific_heats = response.split(/\n/).map { |line| line.split(/\s+/).map(&:to_f) }.inject({}) do |hash, (temp, specific_heat)|
          hash.tap do
            hash[temp] = specific_heat
          end
        end
      end
    end
  end
end
