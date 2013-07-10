Gem::Specification.new do |spec|
  spec.name        = "vienna_rna"
  spec.version     = "0.5.5"
  spec.summary     = "Bindings to the Vienna RNA package."
  spec.description = "A Ruby API for interacting with the Vienna RNA package."
  spec.authors     = ["Evan Senter"]
  spec.email       = "evansenter@gmail.com"
  spec.files       = Dir["{lib}/**/*.rb", "bin/*", "LICENSE", "*.md"]
  spec.homepage    = "http://rubygems.org/gems/vienna_rna"
  
  spec.add_dependency("bio",           [">= 1.4.2"])
  spec.add_dependency("activesupport", [">= 3.2"])
  spec.add_dependency("shuffle",       [">= 0.1.0"])
  spec.add_dependency("gnuplot",       [">= 2.5.0"])
  spec.add_dependency("rinruby",       [">= 2.0.3"])
  spec.add_dependency("rroc",          [">= 0.1.1"])
end