module ViennaRna
  module Package
    class Base
      class_attribute :executable_name
      self.executable_name = ->(context) { "RNA#{context.class.name.split('::').last.underscore}" }
      
      class_attribute :call_with
      self.call_with = [:seq]
      
      class_attribute :default_flags
      self.default_flags = {}
    
      class << self
        def method_added(name)
          if name == :run
            unless @chaining
              @chaining = true
              alias_method_chain :run, :hooks
            else
              remove_instance_variable(:@chaining)
            end
          end
        end
      
        def exec_exists?(name)
          !%x[which RNA#{name.to_s.downcase}].empty?
        end
      
        def run(*data)
          flags = data.length > 1 && data.last.is_a?(Hash) ? data.pop : {}
          new(data).run(flags)
        end
      
        def bootstrap(data: nil, output: "")
          new(data).tap do |object|
            object.instance_variable_set(:@response, File.exist?(output) ? File.read(output).chomp : output)
          end
        end
      end
    
      attr_reader :data, :response, :runtime
    
      def exec_name
        executable_name.respond_to?(:call) ? executable_name[self] : executable_name
      end
    
      def initialize(data)
        data  = [data] unless data.is_a?(Array)
      
        @data = case data.map(&:class)
        when [ViennaRna::Global::Rna]         then data.first
        when *(1..3).map { |i| [String] * i } then RNA.from_string(*data)
        when [Hash]                           then RNA.from_hash(*data)
        when [Array]                          then RNA.from_array(*data)
        when [NilClass]                       then ViennaRna::Global::Rna.placeholder
        else raise TypeError.new("Unsupported ViennaRna::Global::Rna#initialize format: #{data}")
        end
      end
    
      def run_with_hooks(flags = {})
        unless @response
          tap do
            @runtime = Benchmark.measure do
              pre_run_check unless respond_to?(:run_command)
              @response = run_without_hooks(flags)
              post_process if respond_to?(:post_process)
            end
        
            ViennaRna.debugger { "Total runtime: %.3f sec." % runtime.real }
          end
        else
          self
        end
      end
    
      def pre_run_check
        if %x[which #{exec_name}].empty?
          raise RuntimeError.new("#{exec_name} is not defined on this machine")
        end
      end
    
      def stringify_flags(flags)
        flags.merge(default_flags).inject("") do |string, (flag, value)| 
          (string + (value == :empty ? " -%s" % flag : " -%s %s" % [flag, value])).strip
        end
      end
    
      def run(flags = {})
        command = if respond_to?(:run_command)
          method(:run_command).arity.zero? ? run_command : run_command(flags)
        else
          "echo %s | %s %s" % [
            "'%s'" % call_with.map { |datum| data.send(datum) }.join(?\n),
            exec_name,
            stringify_flags(flags)
          ]
        end
      
        ViennaRna.debugger { command }
        
        %x[#{command}]
      end
    
      def serialize
        YAML.dump(self)
      end
    
      def debugger(&block)
        self.class.debugger(&block)
      end
    end
  end
end