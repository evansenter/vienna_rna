module ViennaRna
  module Package
    def self.lookup(package_name)
      const_missing("#{package_name}".camelize) || raise(ArgumentError.new("#{package_name} can't be resolved as an executable"))
    end

    class Base
      include ViennaRna::Global::RunExtensions
      include ViennaRna::Global::ChainExtensions

      class_attribute :executable_name
      self.executable_name = ->(context) { "RNA#{context.class.name.split('::').last.underscore}" }

      class_attribute :call_with
      self.call_with = [:seq]

      class_attribute :default_flags
      self.default_flags = {}

      class_attribute :quote_flag_params
      self.quote_flag_params = []

      class_attribute :chains_from
      self.chains_from = Object

      class << self
        def bootstrap(data: nil, output: "")
          new(data).tap do |object|
            object.instance_variable_set(:@response, File.exist?(output) ? File.read(output).chomp : output)
            object.post_process if object.respond_to?(:post_process)
          end
        end
      end

      attr_reader :data, :flags, :response, :runtime

      def initialize(data, chaining: false)
        unless chaining
          data  = [data] unless data.is_a?(Array)

          @data = case data.map(&:class)
          when [ViennaRna::Global::Rna]         then data.first
          when *(1..3).map { |i| [String] * i } then RNA.from_string(*data)
          when [Hash]                           then RNA.from_hash(*data)
          when [Array]                          then RNA.from_array(*data)
          when [NilClass]                       then ViennaRna::Global::Rna.placeholder
          else raise TypeError.new("Unsupported ViennaRna::Global::Rna#initialize format: #{data}")
          end
        else
          @data = transform_for_chaining(data)
        end
      end

      def serialize
        YAML.dump(self)
      end

      def debugger(&block)
        self.class.debugger(&block)
      end

      def inspect
        "#<%s (%.2f sec): data: %s, flags: %s, vars: %s>" % [
          self.class.name,
          runtime.real,
          data,
          flags,
          (instance_variables - %i|@data @flags @response @runtime|).map(&:to_s).sort.join(", ")
        ]
      end
    end
  end
end
