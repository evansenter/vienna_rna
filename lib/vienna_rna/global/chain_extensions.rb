module ViennaRna
  module Global
    module ChainExtensions
      def self.included(base)
        base.send(:include, InstanceMethods)
      end
      
      module InstanceMethods
        def chain(package, flags = {})
          class_chaining_to = ViennaRna::Package.lookup(package)
          
          unless instance_variable_defined?(:@response)
            raise ArgumentError.new("Can only chain a package that is not the first to be called")
          end
          
          unless class_chaining_to.instance_methods.include?(:transform_for_chaining)
            raise ArgumentError.new("#{class_chaining_to.name} doesn't support chaining because it doesn't define transform_for_chaining")
          end
          
          unless [chains_from].flatten.any? { |chaining_from| kind_of?(chaining_from) }
            raise ArgumentError.new("#{class_chaining_to.name} doesn't support chaining from #{self.class.name} because it isn't in the chains_from list")
          end
          
          class_chaining_to.new(self, chaining: true).run(flags)
        end
      end
    end
  end
end
