module ViennaRna
  class Batch
    include Enumerable
    
    attr_reader :type, :collection
    
    def initialize(type, data)
      @type       = type
      @collection = data.map(&type.method(:new))
    end
    
    def each
      collection.each { |element| yield element }
    end
    
    def run(flags = {})
      tap do
        if (@memo ||= {})[flags]
          @memo[flags]
        else
          @memo[flags] = map { |element| element.run(flags) }
        end
      end
    end
  end
end