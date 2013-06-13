require "set"
require "bio"
require "shuffle"
require "matrix"
require "gnuplot"
require "rroc"
require "active_support/inflector"
require "active_support/core_ext/class"
require "active_support/core_ext/module/aliasing"

module ViennaRna
  @debug = true
  
  Dir[File.join(File.dirname(__FILE__), "vienna_rna", "modules", "*.rb")].each do |file|
    # Doesn't support autoloading modules that are of the form: TwoWords
    autoload(File.basename(file, ".rb").camelize.to_sym, "vienna_rna/modules/#{File.basename(file, '.rb')}")
  end
  
  def self.const_missing(name)
    if Base.exec_exists?(name)
      module_eval do
        const_set(name, Class.new(Base))
      end
    end
  end
  
  def self.debug
    @debug
  end
  
  def self.debug=(value)
    @debug = value
  end
end

# This dirties up the public namespace, but I use it so many times that I want a shorthand to it
unless defined? RNA
  def RNA(sequence, structure = nil)
    ViennaRna::Rna.init_from_string(sequence, structure)
  end
end