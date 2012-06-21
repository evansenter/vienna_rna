Gem::Specification.new do |spec|
  spec.name        = "vienna_rna"
  spec.version     = "0.1.0"
  spec.date        = "2012-06-21"
  spec.summary     = "Bindings to the Vienna RNA package."
  spec.description = "A Ruby API for interacting with the Vienna RNA package."
  spec.authors     = ["Evan Senter"]
  spec.email       = "evansenter@gmail.com"
  spec.files       = Dir[File.join(File.dirname(__FILE__), "lib", "**", "*")]
  spec.homepage    = "http://rubygems.org/gems/vienna_rna"
  
  spec.add_dependency("bio", [">= 1.4.2"])
  spec.add_dependency("activesupport", [">= 3.2.5"])
end