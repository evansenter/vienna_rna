require "benchmark"

module ViennaRna
  class Base
    class Rna
      attr_reader :sequence, :structure
      
      def initialize(sequence, structure = nil)
        @sequence  = sequence
        @structure = structure
      end

      alias :seq :sequence
      
      def safe_structure
        structure || empty_structure
      end
      
      def empty_structure
        "." * seq.length
      end
    end
    
    class_attribute :executable_name
    
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
        !%x[which rna#{name.to_s.downcase}].empty?
      end
      
      def run(data, flags = {})
        new(data).run(flags)
      end
      
      def batch(fastas = [])
        ViennaRna::Batch.new(self, fastas).tap do |batch|
          if const_defined?(:Batch)
            @@me = self
            
            batch.singleton_class.class_eval { include @@me.const_get(:Batch) }
          end
        end
      end
      
      def debugger
        STDERR.puts yield if ViennaRna.debug
      end
    end
    
    attr_reader :data, :response, :runtime
    
    def exec_name
      if executable_name
        executable_name.respond_to?(:call) ? self.class.module_exec(&executable_name) : executable_name
      else
        "rna#{self.class.name.split('::').last.underscore}"
      end
    end
    
    def exec_sequence_format
      data.seq
    end
    
    def initialize(data)
      @data = case data
      when Bio::FastaFormat then data
      when String           then Rna.new(data)
      when Hash             then Rna.new(data[:sequence] || data[:seq], data[:structure] || data[:str])
      end
    end
    
    def run_with_hooks(flags = {})
      tap do
        @runtime = Benchmark.measure do
          pre_run_check unless respond_to?(:run_command)
          @response = run_without_hooks(flags)
          post_process if respond_to?(:post_process)
        end
        
        debugger { "Total runtime: %.3f sec." % runtime.real }
      end
    end
    
    def pre_run_check
      if self.class.exec_exists?(exec_name)
        raise RuntimeError.new("#{exec_name} is not defined on this machine")
      end
    end
    
    def stringify_flags(flags)
      flags.inject("") { |string, (flag, value)| (string + (value == :empty ? " -%s" % flag : " -%s %s" % [flag, value])).strip }
    end
    
    def run(flags = {})
      command = if respond_to?(:run_command)
        method(:run_command).arity.zero? ? run_command : run_command(flags)
      else
        "echo #{exec_sequence_format} | #{exec_name} #{stringify_flags(flags)}"
      end
      
      debugger { command }
        
      %x[#{command}]
    end
    
    def debugger(&block)
      self.class.debugger(&block)
    end
  end
end