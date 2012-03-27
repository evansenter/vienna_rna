module ViennaRna
  class Subopt < Base
    attr_reader :structures
    
    def post_process(response)
      tap do
        @structures = response.split(/\n/)
      end
    end
    
    def bin(count = 1)
      run(p: count).structures.inject(Hash.new { |hash, key| hash[key] = 0 }) do |hash, structure|
        hash.tap do
          hash[structure] += 1
        end
      end
    end
  end
end
