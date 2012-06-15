require "bio"
require "active_support/inflector"
require "active_support/core_ext/class"
require "active_support/core_ext/module/aliasing"

# Clean up this include order.
Dir[File.join(File.dirname(__FILE__), "/modules/*")].each do |file|
  require file
end

module Enumerable
  def sum
    inject { |sum, i| sum + i }
  end
end

module ViennaRna
  @debug = false
  
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